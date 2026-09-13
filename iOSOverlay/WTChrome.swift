import SwiftUI

public enum WTChrome353 {
    // Exact light/dark palette extracted from WeType 3.5.3 style.ini.
    public static let accent = WTThemeColor353.accent
    public static let panelBackground = WTThemeColor353.panelBackground
    public static let surface = WTThemeColor353.surface
    public static let elevatedSurface = WTThemeColor353.elevatedSurface
    public static let separator = WTThemeColor353.separator
    public static let primaryText = WTThemeColor353.primaryText
    public static let secondary = WTThemeColor353.secondaryText

    public static func measuredAssetName(_ tool: WTKeyboardTool, controlCenter: Bool = false) -> String? {
        if controlCenter {
            switch tool {
            case .emoji: return "control_center_emoji"
            case .correction: return "control_center_correction"
            case .hotWords: return "control_center_hotword"
            case .quickSend: return "control_center_quicksend"
            case .voice: return "control_center_voice"
            case .handwriting: return "control_center_write"
            default: break
            }
        }
        switch tool {
        case .emoji: return "icon_bar_emoji_24"
        case .phrases: return "icon_bar_changyongyu_24"
        case .handwriting: return "icon_bar_write_24"
        case .voice: return "icon_bar_voice_24"
        case .translate: return "icon_bar_translate_24"
        case .correction: return "icon_bar_correction_24"
        case .inputMode: return "icon_bar_keyboard_24"
        case .oneHanded: return "icon_bar_handedly_24"
        case .quickSend: return "icon_bar_quicksend_24"
        case .textPolish: return "icon_bar_retouching_24"
        default: return nil
        }
    }

    public static func measuredGlyphSize(_ tool: WTKeyboardTool, controlCenter: Bool = false) -> CGSize {
        guard let name = measuredAssetName(tool, controlCenter: controlCenter), let metric = WTIconGeometry353.geometry(name) else {
            return controlCenter ? CGSize(width: 22, height: 22) : CGSize(width: 18, height: 18)
        }
        return CGSize(width: metric.glyph.width, height: metric.glyph.height)
    }

    public static func toolSymbol(_ tool: WTKeyboardTool) -> String {
        switch tool {
        case .emoji: return "face.smiling"
        case .clipboard: return "doc.on.clipboard"
        case .phrases: return "text.quote"
        case .handwriting: return "scribble"
        case .voice: return "waveform"
        case .translate: return "character.book.closed"
        case .askAI: return "sparkles"
        case .correction: return "checkmark.circle"
        case .inputMode: return "keyboard"
        case .oneHanded: return "hand.raised"
        case .deviceSync: return "laptopcomputer.and.iphone"
        case .quickSend: return "paperplane"
        case .textPolish: return "wand.and.stars"
        case .picture: return "photo"
        case .fullSymbols: return "number.square"
        case .quickSettings: return "gearshape"
        case .hotWords: return "flame"
        case .stickers: return "face.smiling.inverse"
        case .wordSplitting: return "rectangle.split.3x1"
        case .fontPicker: return "textformat.size"
        case .keyboardAdjust: return "rectangle.arrowtriangle.2.outward"
        case .plus: return "plus.circle"
        }
    }
}

public struct WTPanelHeader: View {
    let title: String
    let onBack: () -> Void
    var trailingSystemName: String? = nil
    var trailingAction: (() -> Void)? = nil

    public init(title: String, onBack: @escaping () -> Void, trailingSystemName: String? = nil, trailingAction: (() -> Void)? = nil) {
        self.title = title
        self.onBack = onBack
        self.trailingSystemName = trailingSystemName
        self.trailingAction = trailingAction
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button(action: onBack) {
                WTBasicGlyphView(.chevronLeft, size: 17, lineWidth: 1.9)
                    .frame(width: 42, height: 40)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
            Spacer(minLength: 0)

            if let trailingSystemName, let trailingAction {
                Button(action: trailingAction) {
                    WTSemanticGlyph(name: trailingSystemName)
                        .font(.system(size: 16))
                        .frame(width: 42, height: 40)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 42, height: 40)
            }
        }
        .frame(height: 40)
        .background(WTChrome353.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(WTChrome353.separator).frame(height: 0.5) }
    }
}

public struct WTEmptyPanelState: View {
    let systemName: String
    let title: String
    let subtitle: String

    public init(systemName: String, title: String, subtitle: String) {
        self.systemName = systemName
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: 8) {
            WTSemanticGlyph(name: systemName)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(.secondary)
            Text(title).font(.system(size: 14, weight: .medium))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct WTGreenPillButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: 34)
            .background(WTChrome353.accent.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(Capsule())
    }
}
