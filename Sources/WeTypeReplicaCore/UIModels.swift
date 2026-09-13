import Foundation

public enum WTOneHandedMode: String, Codable, Sendable, CaseIterable {
    case off
    case left
    case right
}

public struct WTQuickSettingState: Codable, Sendable, Equatable {
    public var keySoundEnabled: Bool
    public var hapticEnabled: Bool
    public var smartPunctuationEnabled: Bool
    public var autoCorrectionEnabled: Bool
    public var oneHandedMode: WTOneHandedMode

    public init(
        keySoundEnabled: Bool = true,
        hapticEnabled: Bool = true,
        smartPunctuationEnabled: Bool = true,
        autoCorrectionEnabled: Bool = true,
        oneHandedMode: WTOneHandedMode = .off
    ) {
        self.keySoundEnabled = keySoundEnabled
        self.hapticEnabled = hapticEnabled
        self.smartPunctuationEnabled = smartPunctuationEnabled
        self.autoCorrectionEnabled = autoCorrectionEnabled
        self.oneHandedMode = oneHandedMode
    }
}

public enum WTSymbolCategory: String, Codable, Sendable, CaseIterable {
    case common
    case chinese
    case english
    case mathematics
    case greek
    case japanese
    case radical
    case other

    public var title: String {
        switch self {
        case .common: return "常用"
        case .chinese: return "中文"
        case .english: return "英文"
        case .mathematics: return "数学"
        case .greek: return "希腊"
        case .japanese: return "日文"
        case .radical: return "部首"
        case .other: return "其他"
        }
    }
}

public enum WTKeyboardTool: String, Codable, Sendable, CaseIterable, Identifiable {
    case emoji
    case clipboard
    case phrases
    case handwriting
    case voice
    case translate
    case askAI
    case correction
    case inputMode
    case oneHanded
    case deviceSync
    case quickSend
    case textPolish
    case picture
    case fullSymbols
    case quickSettings
    case hotWords
    case stickers
    case wordSplitting
    case fontPicker
    case keyboardAdjust
    case plus

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .emoji: return "表情"
        case .clipboard: return "剪贴板"
        case .phrases: return "常用语"
        case .handwriting: return "手写"
        case .voice: return "语音"
        case .translate: return "翻译"
        case .askAI: return "问 AI"
        case .correction: return "纠错"
        case .inputMode: return "键盘"
        case .oneHanded: return "单手"
        case .deviceSync: return "设备"
        case .quickSend: return "快传"
        case .textPolish: return "润色"
        case .picture: return "图片"
        case .fullSymbols: return "符号"
        case .quickSettings: return "设置"
        case .hotWords: return "热词"
        case .stickers: return "表情包"
        case .wordSplitting: return "拆词"
        case .fontPicker: return "字体"
        case .keyboardAdjust: return "键盘调节"
        case .plus: return "微信输入法+"
        }
    }
}

/// Toolbar ordering reconstructed from the keyboard extension's public resource names
/// (icon_bar_*, icon_popup_* and control-center resources). The icons are redrawn by the
/// replica and no proprietary image bytes are embedded in this package.
public enum WTToolbarCatalog353 {
    public static let compact: [WTKeyboardTool] = [
        .emoji, .clipboard, .phrases, .handwriting, .voice, .translate, .askAI
    ]

    public static let expanded: [WTKeyboardTool] = [
        .emoji, .clipboard, .phrases, .handwriting,
        .voice, .translate, .askAI, .correction,
        .inputMode, .oneHanded, .deviceSync, .quickSend,
        .textPolish, .picture, .fullSymbols, .quickSettings,
        .hotWords, .stickers, .wordSplitting, .fontPicker,
        .keyboardAdjust, .plus
    ]
}

public enum WTSymbolCatalog353 {
    public static func values(for category: WTSymbolCategory) -> [String] {
        switch category {
        case .common:
            return ["，","。","？","！","～","…","、","；","：","“","”","‘","’","（","）","《","》","【","】","—","·","￥","@","#"]
        case .chinese:
            return ["，","。","？","！","：","；","、","～","…","——","·","“","”","‘","’","（","）","［","］","｛","｝","《","》","〈","〉","「","」","『","』","〔","〕"]
        case .english:
            return [",",".","?","!",":",";","'","\"","-","_","/","\\","@","#","$","%","&","*","+","=","(",")","[","]","{","}","<",">"]
        case .mathematics:
            return ["+","−","×","÷","=","≠","≈","≡","≤","≥","±","∞","√","∑","∏","∫","∂","∆","∇","∈","∉","⊂","⊃","∩","∪","∧","∨","¬","°","‰","%"]
        case .greek:
            return ["α","β","γ","δ","ε","ζ","η","θ","ι","κ","λ","μ","ν","ξ","ο","π","ρ","σ","τ","υ","φ","χ","ψ","ω","Γ","Δ","Θ","Λ","Ξ","Π","Σ","Φ","Ψ","Ω"]
        case .japanese:
            return ["あ","い","う","え","お","か","き","く","け","こ","さ","し","す","せ","そ","た","ち","つ","て","と","な","に","ぬ","ね","の","は","ひ","ふ","へ","ほ","ま","み","む","め","も","や","ゆ","よ","ら","り","る","れ","ろ","わ","を","ん"]
        case .radical:
            return ["一","丨","丶","丿","乙","亅","二","亠","人","儿","入","八","冂","冖","冫","几","凵","刀","力","勹","匕","匚","匸","十","卜","卩","厂","厶","又","口","囗","土","士","夂","夊","夕","大","女","子","宀","寸","小","尢","尸","屮","山","巛","工","己","巾","干","幺","广","廴","廾","弋","弓","彐","彡","彳"]
        case .other:
            return ["©","®","™","✓","✔","✕","★","☆","●","○","■","□","◆","◇","▲","△","▼","▽","→","←","↑","↓","↔","↕","※","№","℃","℉","㊣","〒","♪","♫"]
        }
    }
}


public struct WTHotWordItem: Identifiable, Codable, Hashable, Sendable {
    public var id: String { word }
    public var word: String
    public var rank: Int
    public var tag: String?
    public init(word: String, rank: Int, tag: String? = nil) { self.word = word; self.rank = rank; self.tag = tag }
}

public struct WTWordSplitOption: Identifiable, Codable, Hashable, Sendable {
    public var id: String { parts.joined(separator: "|") }
    public var parts: [String]
    public init(parts: [String]) { self.parts = parts }
}

public struct WTKeyboardAdjustment: Codable, Hashable, Sendable {
    public var widthScale: Double
    public var heightScale: Double
    public var horizontalOffset: Double
    public var verticalOffset: Double
    public init(widthScale: Double = 1, heightScale: Double = 1, horizontalOffset: Double = 0, verticalOffset: Double = 0) {
        self.widthScale = widthScale; self.heightScale = heightScale; self.horizontalOffset = horizontalOffset; self.verticalOffset = verticalOffset
        clamp()
    }
    public mutating func clamp() {
        widthScale = min(max(widthScale, 0.72), 1.0)
        heightScale = min(max(heightScale, 0.80), 1.18)
        horizontalOffset = min(max(horizontalOffset, -0.20), 0.20)
        verticalOffset = min(max(verticalOffset, -0.15), 0.15)
    }
}

public enum WTMediaContentKind: String, Codable, Sendable, CaseIterable {
    case sticker
    case customSticker
    case gif
}

public struct WTMediaCard: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var subtitle: String?
    public var kind: WTMediaContentKind
    public var remoteURL: URL?
    public init(id: String, title: String, subtitle: String? = nil, kind: WTMediaContentKind, remoteURL: URL? = nil) {
        self.id = id; self.title = title; self.subtitle = subtitle; self.kind = kind; self.remoteURL = remoteURL
    }
}
