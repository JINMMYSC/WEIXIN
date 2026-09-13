import Foundation

/// Declarative backend mapping used at the final Hamster/librime integration step.
/// Schema identifiers are deliberately configurable because public Hamster installations can
/// use different Rime schemas. The replica UI never hard-codes a commercial/private schema.
public struct WTRimeModeDescriptor: Codable, Equatable, Sendable {
    public var schemaID: String?
    public var options: [String: Bool]
    public var properties: [String: String]

    public init(schemaID: String? = nil, options: [String: Bool] = [:], properties: [String: String] = [:]) {
        self.schemaID = schemaID
        self.options = options
        self.properties = properties
    }
}

public struct WTRimeBackendProfile: Codable, Equatable, Sendable {
    public var modes: [WTInputMode: WTRimeModeDescriptor]

    public init(modes: [WTInputMode: WTRimeModeDescriptor] = [:]) {
        self.modes = modes
    }

    public subscript(_ mode: WTInputMode) -> WTRimeModeDescriptor? { modes[mode] }

    /// Safe baseline: only synchronize Rime's common ASCII option. Schema changes stay opt-in.
    public static let safeDefault = WTRimeBackendProfile(modes: [
        .chinesePinyin26: .init(options: ["ascii_mode": false]),
        .chinesePinyin9: .init(options: ["ascii_mode": false]),
        .doublePinyin: .init(options: ["ascii_mode": false]),
        .wubi: .init(options: ["ascii_mode": false]),
        .stroke: .init(options: ["ascii_mode": false]),
        .handwriting: .init(options: ["ascii_mode": false]),
        .english26: .init(options: ["ascii_mode": true])
    ])

    public func merging(_ override: WTRimeBackendProfile) -> WTRimeBackendProfile {
        var result = modes
        for (mode, descriptor) in override.modes { result[mode] = descriptor }
        return .init(modes: result)
    }
}
