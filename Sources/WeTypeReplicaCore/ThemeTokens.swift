import Foundation

public struct WTRGBAHex: Codable, Hashable, Sendable {
    public let light: String
    public let dark: String
    public init(_ light: String, _ dark: String) { self.light = light; self.dark = dark }
}

/// Measurements reconstructed from wxkb_plugin.appex/style.ini and keyboard INI files in
/// WeType 3.5.3. No proprietary source code or image assets are copied into the replica.
public enum WTTheme353 {
    public static let designWidth: Double = 414
    public static let keyboardHeight: Double = 224
    public static let candidateCompactHeight: Double = 40
    public static let compositionHeight: Double = 18
    public static let toolbarHeight: Double = 40
    public static let panelHeaderHeight: Double = 40

    /// Measured 3.5.3 panel split on iPhone 15 Pro Max: the keyboard surface is 371 pt tall,
    /// made of a 72.33 pt header above a 298.67 pt canvas that carries the key rows and the
    /// bottom bar. `keyboardHeight` above remains the height of the key rows themselves.
    public static let keyboardHeaderHeight: Double = WTMeasuredKeyboard353.headerHeight
    public static let keyboardCanvasHeight: Double = WTMeasuredKeyboard353.canvasHeight
    public static let keyboardPanelHeight: Double = WTMeasuredKeyboard353.panelHeight
    public static let keyboardBottomBarHeight: Double =
        WTMeasuredKeyboard353.canvasHeight - WTMeasuredKeyboard353.keyAreaHeight
    /// Shared header row for the toolbar and the candidate list.
    public static let keyboardHeaderRowTop: Double = WTMeasuredKeyboard353.headerRowTop
    public static let keyboardHeaderRowHeight: Double = WTMeasuredKeyboard353.headerRowHeight

    public static let keyboardBackground = WTRGBAHex(WTPhase14Palette353.keyboardBackground, "#1C1C1E")
    public static let panelBackground = WTRGBAHex("#F2F3F5", "#1C1C1E")
    public static let surface = WTRGBAHex("#FFFFFF", "#2C2C2E")
    public static let elevatedSurface = WTRGBAHex("#FFFFFF", "#3A3A3C")
    public static let separator = WTRGBAHex("#00000014", "#FFFFFF1A")

    public static let normalBackground = WTRGBAHex(WTPhase14Palette353.normalKey, "#BBBBBB66")
    public static let normalPressedBackground = WTRGBAHex("#B7BCC4", "#66666666")
    public static let normalText = WTRGBAHex("#000000", "#FEFEFE")
    public static let normalSecondaryText = WTRGBAHex("#00000066", "#FEFEFE66")
    public static let grayBackground = WTRGBAHex(WTPhase14Palette353.grayKey, "#55555566")
    public static let grayPressedBackground = WTRGBAHex("#FCFCFE", "#BBBBBB66")
    public static let accent = WTRGBAHex(WTPhase14Palette353.accent, "#23C891")
    public static let accentGreen = "#23C891"
    public static let destructive = WTRGBAHex("#FA5151", "#FA5151")

    public static let keyCornerRadius: Double = 5
    public static let cardCornerRadius: Double = 10
    public static let sheetCornerRadius: Double = 12
    public static let letterFontSize: Double = 24
    public static let keySubtitleFontSize: Double = 9
    public static let functionFontSize: Double = 16
    public static let candidateFontSize: Double = WTMeasuredKeyboard353.candidateFontSize
    public static let toolbarIconSize: Double = 20
}


/// Shared light/dark palette extracted from WeType 3.5.3 host-app `WBColor.json`.
/// Key caps still use the keyboard extension's `style.ini` values above.
public enum WTAppPalette353 {
    public static let highlight = WTRGBAHex("#DFDFDF", "#FFFFFF0D")
    public static let primaryText = WTRGBAHex("#000000FF", "#FFFFFFFF")
    public static let primaryText90 = WTRGBAHex("#000000E6", "#FFFFFFE6")
    public static let secondaryText = WTRGBAHex("#00000066", "#FFFFFF66")
    public static let separator = WTRGBAHex("#0000001A", "#FFFFFF1A")
    public static let hairline = WTRGBAHex("#0000000D", "#FFFFFF0D")
    public static let surface = WTRGBAHex("#FFFFFFFF", "#000000FF")
    public static let elevatedSurface = WTRGBAHex("#FCFCFEFF", "#5F5F5FFF")
    public static let graySurface = WTRGBAHex("#B7BCC4FF", "#4C4C4CFF")
    public static let brand = WTRGBAHex("#23C891FF", "#23C891FF")
    public static let panelBackground = WTRGBAHex("#F2F2F2FF", "#050505FF")
}
