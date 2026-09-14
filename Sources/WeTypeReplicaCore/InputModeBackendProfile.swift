import Foundation

public enum WTFuzzyPinyinOption: String, Codable, Sendable, CaseIterable {
    /// Retroflex/non-retroflex initials: zh/z, ch/c, sh/s.
    case retroflexInitials
    /// Nasal/lateral initials: n/l.
    case nasalLateral
}

/// Declarative backend mapping used at the Hamster/librime integration boundary.
/// Schema identifiers come only from CLAW-owned wrappers or exact pinned public Rime projects;
/// no Tencent/WeChat private schema or dictionary is used.
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

    /// Phase 3 production bootstrap backed by exact pinned public Rime data.
    /// Handwriting remains outside librime and is intentionally left schema-less.
    public static let phase3PublicLibrime = WTRimeBackendProfile(modes: [
        .chinesePinyin26: .init(
            schemaID: "claw_pinyin26",
            options: ["ascii_mode": false, "zh_hans": true]
        ),
        .chinesePinyin9: .init(
            schemaID: "claw_pinyin9",
            options: ["ascii_mode": false, "zh_hans": true]
        ),
        .doublePinyin: .init(
            schemaID: "double_pinyin",
            options: ["ascii_mode": false, "simplification": true]
        ),
        .wubi: .init(
            schemaID: "wubi86",
            options: ["ascii_mode": false]
        ),
        .stroke: .init(
            schemaID: "stroke",
            options: ["ascii_mode": false]
        ),
        .handwriting: .init(options: ["ascii_mode": false]),
        .english26: .init(
            schemaID: "claw_pinyin26",
            options: ["ascii_mode": true]
        )
    ])

    public func merging(_ override: WTRimeBackendProfile) -> WTRimeBackendProfile {
        var result = modes
        for (mode, descriptor) in override.modes { result[mode] = descriptor }
        return .init(modes: result)
    }
}
