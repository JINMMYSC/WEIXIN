import Foundation

/// Local trust/history record for devices that have successfully authenticated with the
/// clean-room transfer protocol. This is intentionally separate from Tencent's private
/// bound-device control plane. A record is useful for UI/history/revocation bookkeeping;
/// cryptographic access is still governed by the current pairing secret.
public struct WTTrustedTransferDevice: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var firstTrustedAt: Date
    public var lastSeenAt: Date
    public var successfulTransfers: Int
    public var revokedAt: Date?

    public init(
        id: String,
        name: String,
        firstTrustedAt: Date = Date(),
        lastSeenAt: Date = Date(),
        successfulTransfers: Int = 1,
        revokedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.firstTrustedAt = firstTrustedAt
        self.lastSeenAt = lastSeenAt
        self.successfulTransfers = max(0, successfulTransfers)
        self.revokedAt = revokedAt
    }

    public var isRevoked: Bool { revokedAt != nil }
}

public struct WTTrustedTransferRegistry: Codable, Equatable, Sendable {
    public private(set) var devices: [WTTrustedTransferDevice]

    public init(devices: [WTTrustedTransferDevice] = []) {
        self.devices = devices
    }

    public var activeDevices: [WTTrustedTransferDevice] {
        devices.filter { !$0.isRevoked }
            .sorted { $0.lastSeenAt > $1.lastSeenAt }
    }

    public var revokedDevices: [WTTrustedTransferDevice] {
        devices.filter(\.isRevoked)
            .sorted { ($0.revokedAt ?? .distantPast) > ($1.revokedAt ?? .distantPast) }
    }

    public func device(id: String) -> WTTrustedTransferDevice? {
        devices.first { $0.id == id }
    }

    public mutating func recordSuccessfulTransfer(to peer: WTPeerDevice, at now: Date = Date()) {
        if let index = devices.firstIndex(where: { $0.id == peer.id }) {
            devices[index].name = peer.name
            devices[index].lastSeenAt = now
            devices[index].successfulTransfers += 1
            devices[index].revokedAt = nil
        } else {
            devices.append(.init(id: peer.id, name: peer.name, firstTrustedAt: now, lastSeenAt: now))
        }
    }

    public mutating func markSeen(_ peer: WTPeerDevice, at now: Date = Date()) {
        guard let index = devices.firstIndex(where: { $0.id == peer.id }), devices[index].revokedAt == nil else { return }
        devices[index].name = peer.name
        devices[index].lastSeenAt = now
    }

    public mutating func revoke(id: String, at now: Date = Date()) {
        guard let index = devices.firstIndex(where: { $0.id == id }) else { return }
        devices[index].revokedAt = now
    }

    public mutating func restore(id: String, at now: Date = Date()) {
        guard let index = devices.firstIndex(where: { $0.id == id }) else { return }
        devices[index].revokedAt = nil
        devices[index].lastSeenAt = now
    }

    public mutating func forget(id: String) {
        devices.removeAll { $0.id == id }
    }

    public mutating func pruneRevoked(olderThan cutoff: Date) {
        devices.removeAll { device in
            guard let revokedAt = device.revokedAt else { return false }
            return revokedAt < cutoff
        }
    }

    public func encoded() throws -> Data { try JSONEncoder().encode(self) }
    public static func decode(_ data: Data) throws -> Self { try JSONDecoder().decode(Self.self, from: data) }
}
