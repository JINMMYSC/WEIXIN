import Foundation

/// Declarative backend mapping used at the Hamster/librime integration boundary.
/// Schema identifiers are public CLAW-owned wrappers around public Rime dictionaries; no
/// Tencent/WeChat private schema or dictionary is used.
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

    /// Conservative compatibility profile for adapter-only tests.
    public static let safeDefault = WTRimeBackendProfile(modes: [
        .chinesePinyin26: .init(options: ["ascii_mode": false]),
        .chinesePinyin9: .init(options: ["ascii_mode": false]),
        .doublePinyin: .init(options: ["ascii_mode": false]),
        .wubi: .init(options: ["ascii_mode": false]),
        .stroke: .init(options: ["ascii_mode": false]),
        .handwriting: .init(options: ["ascii_mode": false]),
        .english26: .init(options: ["ascii_mode": true])
    ])

    /// Phase 3 production bootstrap. Full pinyin and T9 are real librime schemas backed by
    /// the pinned public Luna Pinyin dictionary. Other modes remain explicitly schema-less
    /// until their public dictionaries/configurations are added in the next Phase 3 slices.
    public static let phase3PublicLibrime = WTRimeBackendProfile(modes: [
        .chinesePinyin26: .init(schemaID: "claw_pinyin26", options: ["ascii_mode": false, "zh_hans": true]),
        .chinesePinyin9: .init(schemaID: "claw_pinyin9", options: ["ascii_mode": false, "zh_hans": true]),
        .doublePinyin: .init(options: ["ascii_mode": false]),
        .wubi: .init(options: ["ascii_mode": false]),
        .stroke: .init(options: ["ascii_mode": false]),
        .handwriting: .init(options: ["ascii_mode": false]),
        .english26: .init(schemaID: "claw_pinyin26", options: ["ascii_mode": true])
    ])

    public func merging(_ override: WTRimeBackendProfile) -> WTRimeBackendProfile {
        var result = modes
        for (mode, descriptor) in override.modes { result[mode] = descriptor }
        return .init(modes: result)
    }
}
