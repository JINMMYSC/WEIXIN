import Foundation

/// Same-device visual capture case used to calibrate the clean-room UI against an observed
/// WeType 3.5.3 screen. It stores only the scenario description and measured output metadata.
public struct WTVisualParityCase: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var surface: String
    public var inputMode: String?
    public var appearance: String
    public var orientation: String
    public var hostContext: String?
    public var action: String?
    public var required: Bool

    public init(
        id: String,
        surface: String,
        inputMode: String? = nil,
        appearance: String = "light",
        orientation: String = "portrait",
        hostContext: String? = nil,
        action: String? = nil,
        required: Bool = true
    ) {
        self.id = id
        self.surface = surface
        self.inputMode = inputMode
        self.appearance = appearance
        self.orientation = orientation
        self.hostContext = hostContext
        self.action = action
        self.required = required
    }
}

public struct WTVisualParityManifest: Codable, Equatable, Sendable {
    public var formatVersion: Int
    public var targetVersion: String
    public var cases: [WTVisualParityCase]

    public init(formatVersion: Int = 1, targetVersion: String = "3.5.3", cases: [WTVisualParityCase]) {
        self.formatVersion = formatVersion
        self.targetVersion = targetVersion
        self.cases = cases
    }

    public var requiredCases: [WTVisualParityCase] { cases.filter(\.required) }
    public var surfaceCount: Int { Set(cases.map(\.surface)).count }
}

public enum WTVisualParityStarterManifest {
    public static let cases: [WTVisualParityCase] = {
        var c: [WTVisualParityCase] = []
        func add(_ id: String, _ surface: String, mode: String? = nil, appearance: String = "light", orientation: String = "portrait", host: String? = nil, action: String? = nil, required: Bool = true) {
            c.append(.init(id: id, surface: surface, inputMode: mode, appearance: appearance, orientation: orientation, hostContext: host, action: action, required: required))
        }

        for appearance in ["light", "dark"] {
            add("keyboard26-\(appearance)", "keyboard26", mode: "pinyin26", appearance: appearance, host: "normalText")
            add("keyboard9-\(appearance)", "keyboard9", mode: "pinyin9", appearance: appearance, host: "normalText")
            add("candidate-expanded-\(appearance)", "candidateExpanded", mode: "pinyin26", appearance: appearance, action: "expandCandidates")
            add("symbol-cn-\(appearance)", "symbolPanel", mode: "chineseSymbol", appearance: appearance)
            add("symbol-en-\(appearance)", "symbolPanel", mode: "englishSymbol", appearance: appearance)
            add("emoji-\(appearance)", "emoji", appearance: appearance)
            add("clipboard-\(appearance)", "clipboard", appearance: appearance)
            add("handwriting-\(appearance)", "handwriting", appearance: appearance)
            add("voice-idle-\(appearance)", "voice", appearance: appearance, action: "idle")
            add("voice-listening-\(appearance)", "voice", appearance: appearance, action: "listening")
            add("translate-\(appearance)", "translate", appearance: appearance)
            add("ai-\(appearance)", "askAI", appearance: appearance)
            add("correction-\(appearance)", "correction", appearance: appearance)
            add("plus-\(appearance)", "plus", appearance: appearance)
            add("control-center-\(appearance)", "controlCenter", appearance: appearance)
            add("quick-settings-\(appearance)", "quickSettings", appearance: appearance)
            add("input-switcher-\(appearance)", "inputModeSwitcher", appearance: appearance)
            add("one-handed-left-\(appearance)", "oneHanded", mode: "pinyin26", appearance: appearance, action: "left")
            add("one-handed-right-\(appearance)", "oneHanded", mode: "pinyin26", appearance: appearance, action: "right")
            add("device-sync-\(appearance)", "deviceSync", appearance: appearance)
            add("sticker-gif-\(appearance)", "stickerGIF", appearance: appearance)
            add("book-video-\(appearance)", "bookVideo", appearance: appearance)
            add("settings-home-\(appearance)", "settingsHome", appearance: appearance)
            add("settings-keyboard-select-\(appearance)", "settingsKeyboardSelect", appearance: appearance)
            add("settings-fuzzy-pinyin-\(appearance)", "settingsFuzzyPinyin", appearance: appearance)
            add("settings-auxiliary-input-\(appearance)", "settingsAuxiliaryInput", appearance: appearance)
            add("settings-display-\(appearance)", "settingsDisplay", appearance: appearance)
            add("settings-keystroke-effect-\(appearance)", "settingsKeystrokeEffect", appearance: appearance)
            add("settings-clipboard-\(appearance)", "settingsClipboard", appearance: appearance)
            add("settings-desktop-\(appearance)", "settingsDesktop", appearance: appearance)
            add("settings-migration-\(appearance)", "settingsMigration", appearance: appearance)
            add("settings-plus-\(appearance)", "settingsPlus", appearance: appearance)
            add("settings-shuangpin-\(appearance)", "settingsShuangpin", appearance: appearance)
            add("settings-wubi-\(appearance)", "settingsWubi", appearance: appearance)
        }

        add("popup-q", "keyPopup", mode: "pinyin26", action: "press:q")
        add("longpress-v", "longPressPopup", mode: "pinyin26", action: "longPress:v")
        add("candidate-menu", "candidateActionMenu", mode: "pinyin26", action: "longPressCandidate")
        add("return-send", "returnKey", mode: "pinyin26", host: "send")
        add("return-search", "returnKey", mode: "pinyin26", host: "search")
        add("secure-field", "keyboard26", mode: "pinyin26", host: "secureText")
        add("spotlight", "keyboard26", mode: "pinyin26", host: "spotlight")
        add("landscape-26", "keyboard26", mode: "pinyin26", orientation: "landscape")
        add("landscape-9", "keyboard9", mode: "pinyin9", orientation: "landscape")
        add("share-extension", "shareExtension")
        add("voice-widget", "voiceWidget")
        return c
    }()

    public static let manifest = WTVisualParityManifest(cases: cases)
}
