import Foundation

/// Versioned wire metadata for the clean-room LAN transfer implementation.
/// The binary payload itself follows this JSON header as a raw TCP byte stream.
public struct WTTransferEnvelope: Codable, Equatable, Sendable {
    public static let currentVersion = 3

    public var version: Int
    public var transferID: UUID
    public var fileName: String
    public var totalSize: Int64
    public var sha256Hex: String
    public var chunkSize: Int
    public var authTagHex: String?
    /// Transport payload protection. `none` keeps legacy/plain compatibility; `chacha20poly1305`
    /// is used when both peers share a pairing code.
    public var encryption: WTTransferEncryption
    /// Random per-transfer salt used to derive the transport key from the pairing code.
    public var keySaltHex: String?

    public init(
        version: Int = WTTransferEnvelope.currentVersion,
        transferID: UUID = UUID(),
        fileName: String,
        totalSize: Int64,
        sha256Hex: String,
        chunkSize: Int = 256 * 1024,
        authTagHex: String? = nil,
        encryption: WTTransferEncryption = .none,
        keySaltHex: String? = nil
    ) {
        self.version = version
        self.transferID = transferID
        self.fileName = WTTransferProtocol.safeFileName(fileName)
        self.totalSize = max(0, totalSize)
        self.sha256Hex = sha256Hex.lowercased()
        self.chunkSize = max(16 * 1024, min(chunkSize, 2 * 1024 * 1024))
        self.authTagHex = authTagHex?.lowercased()
        self.encryption = encryption
        self.keySaltHex = keySaltHex?.lowercased()
    }
}


public enum WTTransferEncryption: String, Codable, Equatable, Sendable {
    case none
    case chacha20poly1305
}

public struct WTTransferResumeReply: Codable, Equatable, Sendable {
    public var version: Int
    public var acceptedOffset: Int64
    public var requiresAuthentication: Bool
    public var message: String?

    public init(
        version: Int = WTTransferEnvelope.currentVersion,
        acceptedOffset: Int64,
        requiresAuthentication: Bool = false,
        message: String? = nil
    ) {
        self.version = version
        self.acceptedOffset = max(0, acceptedOffset)
        self.requiresAuthentication = requiresAuthentication
        self.message = message
    }
}

public struct WTTransferAck: Codable, Equatable, Sendable {
    public var version: Int
    public var transferID: UUID
    public var success: Bool
    public var receivedSize: Int64
    public var sha256Hex: String?
    public var message: String?

    public init(
        version: Int = WTTransferEnvelope.currentVersion,
        transferID: UUID,
        success: Bool,
        receivedSize: Int64,
        sha256Hex: String? = nil,
        message: String? = nil
    ) {
        self.version = version
        self.transferID = transferID
        self.success = success
        self.receivedSize = max(0, receivedSize)
        self.sha256Hex = sha256Hex?.lowercased()
        self.message = message
    }
}

public enum WTTransferProtocol {
    public static let maxControlFrameBytes = 256 * 1024
    public static let defaultChunkSize = 256 * 1024
    /// Encrypted records add an AEAD tag and framing overhead. Keep a hard upper bound separate
    /// from JSON control-frame sizing so malformed peers cannot request unbounded allocations.
    public static let maxEncryptedRecordBytes = 2 * 1024 * 1024 + 128

    public static func safeFileName(_ name: String) -> String {
        let last = URL(fileURLWithPath: name).lastPathComponent
        let cleaned = last
            .replacingOccurrences(of: "\0", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "transfer.bin" : String(cleaned.prefix(240))
    }

    public static func clampedResumeOffset(_ value: Int64, totalSize: Int64) -> Int64 {
        min(max(0, value), max(0, totalSize))
    }

    /// Encrypted transport resumes only at complete plaintext chunk boundaries. This avoids
    /// nonce reuse and lets the receiver safely discard a partially-written final chunk.
    public static func alignedResumeOffset(_ value: Int64, totalSize: Int64, chunkSize: Int) -> Int64 {
        let clamped = clampedResumeOffset(value, totalSize: totalSize)
        let size = Int64(max(16 * 1024, chunkSize))
        guard clamped < totalSize else { return clamped }
        return (clamped / size) * size
    }

    public static func encryptedRecordFrame(_ payload: Data) throws -> Data {
        guard payload.count <= maxEncryptedRecordBytes else { throw WTTransferProtocolError.encryptedRecordTooLarge }
        var length = UInt32(payload.count).bigEndian
        var result = Data(bytes: &length, count: MemoryLayout<UInt32>.size)
        result.append(payload)
        return result
    }

    public static func encryptedRecordLength(from prefix: Data) throws -> Int {
        guard prefix.count == 4 else { throw WTTransferProtocolError.invalidLengthPrefix }
        let value = prefix.withUnsafeBytes { raw -> UInt32 in
            var copy: UInt32 = 0
            withUnsafeMutableBytes(of: &copy) { destination in destination.copyBytes(from: raw) }
            return UInt32(bigEndian: copy)
        }
        let count = Int(value)
        guard count >= 0, count <= maxEncryptedRecordBytes else { throw WTTransferProtocolError.encryptedRecordTooLarge }
        return count
    }

    /// 4-byte big-endian length prefix used for JSON control frames.
    public static func frame(_ payload: Data) throws -> Data {
        guard payload.count <= maxControlFrameBytes else { throw WTTransferProtocolError.controlFrameTooLarge }
        var length = UInt32(payload.count).bigEndian
        var result = Data(bytes: &length, count: MemoryLayout<UInt32>.size)
        result.append(payload)
        return result
    }

    public static func payloadLength(from prefix: Data) throws -> Int {
        guard prefix.count == 4 else { throw WTTransferProtocolError.invalidLengthPrefix }
        let value = prefix.withUnsafeBytes { raw -> UInt32 in
            var copy: UInt32 = 0
            withUnsafeMutableBytes(of: &copy) { destination in
                destination.copyBytes(from: raw)
            }
            return UInt32(bigEndian: copy)
        }
        let count = Int(value)
        guard count >= 0, count <= maxControlFrameBytes else { throw WTTransferProtocolError.controlFrameTooLarge }
        return count
    }
}

public enum WTTransferProtocolError: Error, Equatable {
    case invalidLengthPrefix
    case controlFrameTooLarge
    case unsupportedVersion(Int)
    case invalidResumeOffset
    case authenticationFailed
    case integrityMismatch
    case incompleteTransfer
    case encryptedRecordTooLarge
    case missingEncryptionKeyMaterial
    case decryptionFailed
}
