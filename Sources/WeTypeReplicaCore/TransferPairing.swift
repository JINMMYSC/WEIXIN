import Foundation

/// Clean-room representation of the transfer-code / invite state discovered in WeType 3.5.3.
/// The original binary exposes `currentTransferCode`, `generateDeviceCode`, pending invite and
/// authentication selectors. This type lets our LAN provider reproduce that product state without
/// depending on Tencent's dispatch/bound-device backend.
public struct WTTransferPairingInfo: Codable, Equatable, Sendable {
    public var code: String
    public var deviceName: String
    public var generatedAt: Date

    public init(code: String, deviceName: String, generatedAt: Date = Date()) {
        self.code = Self.normalized(code)
        self.deviceName = deviceName
        self.generatedAt = generatedAt
    }

    public static func normalized(_ raw: String) -> String {
        String(raw.filter(\.isNumber).prefix(8))
    }

    public var isUsable: Bool { code.count >= 6 }
}

public struct WTTransferInvite: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var code: String
    public var peerName: String
    public var receivedAt: Date

    public init(id: UUID = UUID(), code: String, peerName: String, receivedAt: Date = Date()) {
        self.id = id
        self.code = WTTransferPairingInfo.normalized(code)
        self.peerName = peerName
        self.receivedAt = receivedAt
    }
}
