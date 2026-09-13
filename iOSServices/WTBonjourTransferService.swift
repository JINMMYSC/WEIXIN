#if canImport(Network) && canImport(CryptoKit)
import Foundation
import Network
import CryptoKit

/// Clean-room LAN transfer service used by the host app/share extension.
/// V8 protocol improvements over the prototype:
/// - streams files instead of loading them fully in memory;
/// - resumes interrupted transfers from an on-disk `.part` file;
/// - verifies SHA-256 before publishing the received file;
/// - supports an optional six-or-more-character pairing code via HMAC-SHA256;
/// - encrypts paired payload chunks with ChaCha20-Poly1305 using an HKDF-derived per-transfer key;
/// - sends a final acknowledgement so the sender does not report success early.
///
/// Discovery remains local Bonjour. When a pairing code is configured, file bytes are AEAD-protected
/// end-to-end at the application layer even though the underlying NWConnection is TCP.
public final class WTBonjourTransferService: WTDeviceTransferService {
    public private(set) var state: WTTransferState = .idle { didSet { onStateChange?(state) } }
    public private(set) var peers: [WTPeerDevice] = [] { didSet { onPeersChange?(peers) } }

    public var onStateChange: ((WTTransferState) -> Void)?
    public var onPeersChange: (([WTPeerDevice]) -> Void)?
    public var onReceivedFile: ((URL, String) -> Void)?
    /// Fired after a peer has passed pairing/authentication and a transfer is ACKed.
    public var onAuthenticatedPeer: ((WTPeerDevice) -> Void)?

    private let serviceType = "_wtreplica._tcp"
    private let queue = DispatchQueue(label: "wtreplica.transfer", qos: .userInitiated)
    private var browser: NWBrowser?
    private var listener: NWListener?
    private var endpoints: [String: NWEndpoint] = [:]
    private let receiveDirectory: URL
    private let deviceName: String
    private let pairingCode: String?
    private let chunkSize: Int

    public init(
        deviceName: String,
        receiveDirectory: URL,
        pairingCode: String? = nil,
        chunkSize: Int = WTTransferProtocol.defaultChunkSize
    ) {
        self.deviceName = deviceName
        self.receiveDirectory = receiveDirectory
        let normalized = pairingCode?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.pairingCode = (normalized?.count ?? 0) >= 6 ? normalized : nil
        self.chunkSize = max(16 * 1024, min(chunkSize, 2 * 1024 * 1024))
        try? FileManager.default.createDirectory(at: receiveDirectory, withIntermediateDirectories: true)
    }

    public func startDiscovery() {
        stopDiscovery()
        state = .discovering
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true
        let browser = NWBrowser(for: .bonjour(type: serviceType, domain: nil), using: parameters)
        browser.browseResultsChangedHandler = { [weak self] results, _ in
            guard let self else { return }
            var next: [WTPeerDevice] = []
            var nextEndpoints: [String: NWEndpoint] = [:]
            for result in results {
                let id = String(describing: result.endpoint)
                nextEndpoints[id] = result.endpoint
                next.append(.init(id: id, name: self.displayName(result.endpoint)))
            }
            self.endpoints = nextEndpoints
            self.peers = next.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        browser.stateUpdateHandler = { [weak self] newState in
            if case .failed(let error) = newState { self?.state = .failed(error.localizedDescription) }
        }
        browser.start(queue: queue)
        self.browser = browser
        startListenerIfNeeded()
    }

    public func stopDiscovery() {
        browser?.cancel(); browser = nil
        endpoints.removeAll(); peers.removeAll()
        if case .discovering = state { state = .idle }
    }

    public func send(file: URL, to peer: WTPeerDevice) async throws {
        try Task.checkCancellation()
        guard let endpoint = endpoints[peer.id] else { throw WTTransferError.peerUnavailable }
        let size = try fileSize(file)
        let digest = try sha256Hex(file)
        let transferID = stableTransferID(file: file, size: size, digest: digest)
        let encryption: WTTransferEncryption = pairingCode == nil ? .none : .chacha20poly1305
        let salt = encryption == .none ? nil : randomSaltHex(byteCount: 16)
        let authTag = authenticationTag(
            transferID: transferID,
            digest: digest,
            encryption: encryption,
            saltHex: salt,
            code: pairingCode
        )
        let envelope = WTTransferEnvelope(
            transferID: transferID,
            fileName: file.lastPathComponent,
            totalSize: size,
            sha256Hex: digest,
            chunkSize: chunkSize,
            authTagHex: authTag,
            encryption: encryption,
            keySaltHex: salt
        )
        let payloadKey = try transportKey(for: envelope)

        state = .connecting(peer: peer.name)
        let connection = NWConnection(to: endpoint, using: .tcp)
        try await startAndWaitReady(connection)
        defer { connection.cancel() }

        try await sendControl(envelope, on: connection)
        let reply: WTTransferResumeReply = try await receiveControl(from: connection)
        guard reply.version == WTTransferEnvelope.currentVersion else {
            throw WTTransferProtocolError.unsupportedVersion(reply.version)
        }
        if reply.requiresAuthentication { throw WTTransferProtocolError.authenticationFailed }
        let offset = WTTransferProtocol.clampedResumeOffset(reply.acceptedOffset, totalSize: size)
        guard offset == reply.acceptedOffset else { throw WTTransferProtocolError.invalidResumeOffset }

        state = .transferring(peer: peer.name, progress: size == 0 ? 1 : Double(offset) / Double(size))
        try await streamFile(
            file,
            fromOffset: offset,
            envelope: envelope,
            payloadKey: payloadKey,
            peerName: peer.name,
            connection: connection
        )

        let ack: WTTransferAck = try await receiveControl(from: connection)
        guard ack.transferID == transferID, ack.success else {
            throw WTTransferError.remoteRejected(ack.message ?? "远端校验失败")
        }
        guard ack.receivedSize == size, ack.sha256Hex?.lowercased() == digest.lowercased() else {
            throw WTTransferProtocolError.integrityMismatch
        }
        state = .completed(peer: peer.name)
        onAuthenticatedPeer?(peer)
    }

    public func stopHosting() {
        listener?.cancel(); listener = nil
    }

    private func startListenerIfNeeded() {
        guard listener == nil else { return }
        do {
            let listener = try NWListener(using: .tcp)
            listener.service = NWListener.Service(name: deviceName, type: serviceType)
            listener.newConnectionHandler = { [weak self] connection in self?.receive(connection) }
            listener.start(queue: queue)
            self.listener = listener
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func receive(_ connection: NWConnection) {
        connection.start(queue: queue)
        Task { [weak self] in
            guard let self else { connection.cancel(); return }
            do {
                let envelope: WTTransferEnvelope = try await self.receiveControl(from: connection)
                guard envelope.version == WTTransferEnvelope.currentVersion else {
                    throw WTTransferProtocolError.unsupportedVersion(envelope.version)
                }
                guard envelope.totalSize >= 0 else { throw WTTransferProtocolError.incompleteTransfer }
                guard self.validateAuthentication(envelope) else {
                    let reply = WTTransferResumeReply(acceptedOffset: 0, requiresAuthentication: true, message: "配对码不匹配")
                    try? await self.sendControl(reply, on: connection)
                    throw WTTransferProtocolError.authenticationFailed
                }

                let payloadKey = try self.transportKey(for: envelope)
                let part = self.partialURL(for: envelope.transferID)
                var resumeOffset = self.partialSize(part)
                if resumeOffset > envelope.totalSize {
                    try? FileManager.default.removeItem(at: part)
                    resumeOffset = 0
                }
                if envelope.encryption != .none {
                    let aligned = WTTransferProtocol.alignedResumeOffset(
                        resumeOffset,
                        totalSize: envelope.totalSize,
                        chunkSize: envelope.chunkSize
                    )
                    if aligned != resumeOffset {
                        try self.truncate(part, to: aligned)
                        resumeOffset = aligned
                    }
                }
                try await self.sendControl(WTTransferResumeReply(acceptedOffset: resumeOffset), on: connection)

                let peerName = self.displayName(connection.endpoint)
                self.state = .transferring(peer: peerName, progress: envelope.totalSize == 0 ? 1 : Double(resumeOffset) / Double(envelope.totalSize))
                try await self.receivePayload(
                    into: part,
                    startingAt: resumeOffset,
                    envelope: envelope,
                    payloadKey: payloadKey,
                    peerName: peerName,
                    connection: connection
                )

                let receivedSize = try self.fileSize(part)
                guard receivedSize == envelope.totalSize else { throw WTTransferProtocolError.incompleteTransfer }
                let actualDigest = try self.sha256Hex(part)
                guard actualDigest.caseInsensitiveCompare(envelope.sha256Hex) == .orderedSame else {
                    try? FileManager.default.removeItem(at: part)
                    throw WTTransferProtocolError.integrityMismatch
                }

                let destination = self.uniqueDestination(named: WTTransferProtocol.safeFileName(envelope.fileName))
                try FileManager.default.moveItem(at: part, to: destination)
                let ack = WTTransferAck(
                    transferID: envelope.transferID,
                    success: true,
                    receivedSize: receivedSize,
                    sha256Hex: actualDigest
                )
                try await self.sendControl(ack, on: connection)
                self.state = .completed(peer: peerName)
                self.onReceivedFile?(destination, peerName)
            } catch {
                self.state = .failed(error.localizedDescription)
                connection.cancel()
            }
        }
    }

    private func streamFile(
        _ url: URL,
        fromOffset offset: Int64,
        envelope: WTTransferEnvelope,
        payloadKey: SymmetricKey?,
        peerName: String,
        connection: NWConnection
    ) async throws {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(offset))
        var sent = offset
        var chunkIndex = UInt64(offset / Int64(envelope.chunkSize))
        while sent < envelope.totalSize {
            try Task.checkCancellation()
            let remaining = Int(min(Int64(envelope.chunkSize), envelope.totalSize - sent))
            guard let chunk = try handle.read(upToCount: remaining), !chunk.isEmpty else {
                throw WTTransferProtocolError.incompleteTransfer
            }
            switch envelope.encryption {
            case .none:
                try await sendData(chunk, on: connection)
            case .chacha20poly1305:
                guard let payloadKey else { throw WTTransferProtocolError.missingEncryptionKeyMaterial }
                let nonce = try ChaChaPoly.Nonce(data: nonceData(chunkIndex: chunkIndex))
                let box = try ChaChaPoly.seal(chunk, using: payloadKey, nonce: nonce)
                try await sendData(WTTransferProtocol.encryptedRecordFrame(box.combined), on: connection)
            }
            sent += Int64(chunk.count)
            chunkIndex += 1
            state = .transferring(peer: peerName, progress: envelope.totalSize == 0 ? 1 : min(1, Double(sent) / Double(envelope.totalSize)))
        }
    }

    private func receivePayload(
        into url: URL,
        startingAt offset: Int64,
        envelope: WTTransferEnvelope,
        payloadKey: SymmetricKey?,
        peerName: String,
        connection: NWConnection
    ) async throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(offset))
        var received = offset
        var chunkIndex = UInt64(offset / Int64(envelope.chunkSize))
        while received < envelope.totalSize {
            try Task.checkCancellation()
            let wanted = Int(min(Int64(max(16 * 1024, envelope.chunkSize)), envelope.totalSize - received))
            let plaintext: Data
            switch envelope.encryption {
            case .none:
                plaintext = try await receiveExact(wanted, from: connection)
            case .chacha20poly1305:
                guard let payloadKey else { throw WTTransferProtocolError.missingEncryptionKeyMaterial }
                let prefix = try await receiveExact(4, from: connection)
                let sealedLength = try WTTransferProtocol.encryptedRecordLength(from: prefix)
                let combined = try await receiveExact(sealedLength, from: connection)
                do {
                    let box = try ChaChaPoly.SealedBox(combined: combined)
                    // The sealed box carries the nonce. Check it is the exact deterministic nonce
                    // expected for this chunk so reordered/replayed records are rejected.
                    let expectedNonce = try ChaChaPoly.Nonce(data: nonceData(chunkIndex: chunkIndex))
                    guard Data(box.nonce) == Data(expectedNonce) else { throw WTTransferProtocolError.decryptionFailed }
                    plaintext = try ChaChaPoly.open(box, using: payloadKey)
                } catch let error as WTTransferProtocolError {
                    throw error
                } catch {
                    throw WTTransferProtocolError.decryptionFailed
                }
                guard plaintext.count == wanted else { throw WTTransferProtocolError.incompleteTransfer }
            }
            guard !plaintext.isEmpty else { throw WTTransferProtocolError.incompleteTransfer }
            try handle.write(contentsOf: plaintext)
            received += Int64(plaintext.count)
            chunkIndex += 1
            state = .transferring(peer: peerName, progress: envelope.totalSize == 0 ? 1 : min(1, Double(received) / Double(envelope.totalSize)))
        }
        try handle.synchronize()
    }

    private func startAndWaitReady(_ connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var finished = false
            connection.stateUpdateHandler = { newState in
                guard !finished else { return }
                switch newState {
                case .ready:
                    finished = true
                    continuation.resume()
                case .failed(let error):
                    finished = true
                    continuation.resume(throwing: error)
                case .cancelled:
                    finished = true
                    continuation.resume(throwing: WTTransferError.cancelled)
                default: break
                }
            }
            connection.start(queue: queue)
        }
    }

    private func sendControl<T: Encodable>(_ value: T, on connection: NWConnection) async throws {
        let payload = try JSONEncoder().encode(value)
        try await sendData(WTTransferProtocol.frame(payload), on: connection)
    }

    private func receiveControl<T: Decodable>(from connection: NWConnection) async throws -> T {
        let prefix = try await receiveExact(4, from: connection)
        let length = try WTTransferProtocol.payloadLength(from: prefix)
        let payload = try await receiveExact(length, from: connection)
        return try JSONDecoder().decode(T.self, from: payload)
    }

    private func sendData(_ data: Data, on connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume() }
            })
        }
    }

    private func receiveExact(_ count: Int, from connection: NWConnection) async throws -> Data {
        if count == 0 { return Data() }
        var result = Data()
        while result.count < count {
            let piece = try await receiveSome(maximum: count - result.count, from: connection)
            guard !piece.isEmpty else { throw WTTransferProtocolError.incompleteTransfer }
            result.append(piece)
        }
        return result
    }

    private func receiveSome(maximum: Int, from connection: NWConnection) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            connection.receive(minimumIncompleteLength: 1, maximumLength: max(1, maximum)) { data, _, isComplete, error in
                if let error { continuation.resume(throwing: error); return }
                if let data, !data.isEmpty { continuation.resume(returning: data); return }
                if isComplete { continuation.resume(returning: Data()); return }
                continuation.resume(returning: Data())
            }
        }
    }

    private func fileSize(_ url: URL) throws -> Int64 {
        let values = try url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values.fileSize ?? 0)
    }

    private func sha256Hex(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            guard let data = try handle.read(upToCount: 1024 * 1024), !data.isEmpty else { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func stableTransferID(file: URL, size: Int64, digest: String) -> UUID {
        let seed = Data("\(file.lastPathComponent)|\(size)|\(digest)".utf8)
        let bytes = Array(SHA256.hash(data: seed).prefix(16))
        let tuple: uuid_t = (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        )
        return UUID(uuid: tuple)
    }

    private func authenticationTag(
        transferID: UUID,
        digest: String,
        encryption: WTTransferEncryption,
        saltHex: String?,
        code: String?
    ) -> String? {
        guard let code else { return nil }
        let key = SymmetricKey(data: Data(code.utf8))
        let payload = Data(
            "\(transferID.uuidString.lowercased())|\(digest.lowercased())|\(encryption.rawValue)|\(saltHex ?? "")".utf8
        )
        let tag = HMAC<SHA256>.authenticationCode(for: payload, using: key)
        return Data(tag).hexString
    }

    private func validateAuthentication(_ envelope: WTTransferEnvelope) -> Bool {
        guard let pairingCode else {
            // Refuse an encrypted envelope when this peer has no pairing secret configured.
            return envelope.encryption == .none && envelope.authTagHex == nil
        }
        guard let received = envelope.authTagHex else { return false }
        let expected = authenticationTag(
            transferID: envelope.transferID,
            digest: envelope.sha256Hex,
            encryption: envelope.encryption,
            saltHex: envelope.keySaltHex,
            code: pairingCode
        )
        guard let expected else { return false }
        return Data(received.utf8).wtConstantTimeEquals(Data(expected.utf8))
    }

    private func transportKey(for envelope: WTTransferEnvelope) throws -> SymmetricKey? {
        guard envelope.encryption != .none else { return nil }
        guard envelope.encryption == .chacha20poly1305,
              let pairingCode,
              let saltHex = envelope.keySaltHex,
              let salt = Data(hexString: saltHex), !salt.isEmpty else {
            throw WTTransferProtocolError.missingEncryptionKeyMaterial
        }
        let input = SymmetricKey(data: Data(pairingCode.utf8))
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: input,
            salt: salt,
            info: Data("WeTypeReplica.Transfer.v3".utf8),
            outputByteCount: 32
        )
    }

    private func randomSaltHex(byteCount: Int) -> String {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<max(16, byteCount)).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        return Data(bytes).hexString
    }

    private func nonceData(chunkIndex: UInt64) -> Data {
        // ChaChaPoly requires 96-bit nonces. Four domain bytes + a big-endian 64-bit chunk index
        // makes nonce derivation deterministic for resume while the HKDF salt makes each transfer key unique.
        var data = Data([0x57, 0x54, 0x52, 0x33])
        var index = chunkIndex.bigEndian
        withUnsafeBytes(of: &index) { data.append(contentsOf: $0) }
        return data
    }

    private func truncate(_ url: URL, to offset: Int64) throws {
        if !FileManager.default.fileExists(atPath: url.path) { return }
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.truncate(atOffset: UInt64(max(0, offset)))
    }

    private func partialURL(for transferID: UUID) -> URL {
        receiveDirectory.appendingPathComponent(".\(transferID.uuidString.lowercased()).part")
    }

    private func partialSize(_ url: URL) -> Int64 {
        (try? fileSize(url)) ?? 0
    }

    private func uniqueDestination(named name: String) -> URL {
        let base = receiveDirectory.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: base.path) { return base }
        let stem = base.deletingPathExtension().lastPathComponent
        let ext = base.pathExtension
        for n in 2...9999 {
            let candidateName = ext.isEmpty ? "\(stem)-\(n)" : "\(stem)-\(n).\(ext)"
            let candidate = receiveDirectory.appendingPathComponent(candidateName)
            if !FileManager.default.fileExists(atPath: candidate.path) { return candidate }
        }
        return receiveDirectory.appendingPathComponent(UUID().uuidString + "-" + name)
    }

    private func displayName(_ endpoint: NWEndpoint) -> String {
        if case .service(let name, _, _, _) = endpoint { return name }
        return String(describing: endpoint)
    }
}

private extension Data {
    init?(hexString: String) {
        let clean = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count.isMultiple(of: 2) else { return nil }
        var data = Data(); data.reserveCapacity(clean.count / 2)
        var index = clean.startIndex
        while index < clean.endIndex {
            let next = clean.index(index, offsetBy: 2)
            guard let byte = UInt8(clean[index..<next], radix: 16) else { return nil }
            data.append(byte); index = next
        }
        self = data
    }

    var hexString: String { map { String(format: "%02x", $0) }.joined() }

    func wtConstantTimeEquals(_ other: Data) -> Bool {
        guard count == other.count else { return false }
        var diff: UInt8 = 0
        for (a, b) in zip(self, other) { diff |= a ^ b }
        return diff == 0
    }
}

public enum WTTransferError: Error {
    case peerUnavailable
    case cancelled
    case remoteRejected(String)
}
#endif
