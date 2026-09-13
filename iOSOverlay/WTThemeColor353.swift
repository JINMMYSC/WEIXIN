import SwiftUI
import UIKit

public extension Color {
    init(wtHex: String) {
        self.init(uiColor: UIColor(wtHex: wtHex))
    }

    static func wtDynamic(_ pair: WTRGBAHex) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(wtHex: traits.userInterfaceStyle == .dark ? pair.dark : pair.light)
        })
    }
}

public extension UIColor {
    convenience init(wtHex: String) {
        var hex = wtHex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let r, g, b, a: CGFloat
        switch hex.count {
        case 8:
            r = CGFloat((value >> 24) & 0xff) / 255
            g = CGFloat((value >> 16) & 0xff) / 255
            b = CGFloat((value >> 8) & 0xff) / 255
            a = CGFloat(value & 0xff) / 255
        case 6:
            r = CGFloat((value >> 16) & 0xff) / 255
            g = CGFloat((value >> 8) & 0xff) / 255
            b = CGFloat(value & 0xff) / 255
            a = 1
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

public enum WTThemeColor353 {
    public static let keyboardBackground = Color.wtDynamic(WTTheme353.keyboardBackground)
    public static let panelBackground = Color.wtDynamic(WTAppPalette353.panelBackground)
    public static let surface = Color.wtDynamic(WTAppPalette353.surface)
    public static let elevatedSurface = Color.wtDynamic(WTAppPalette353.elevatedSurface)
    public static let separator = Color.wtDynamic(WTAppPalette353.separator)
    public static let primaryText = Color.wtDynamic(WTAppPalette353.primaryText)
    public static let secondaryText = Color.wtDynamic(WTAppPalette353.secondaryText)
    public static let normalKey = Color.wtDynamic(WTTheme353.normalBackground)
    public static let normalPressedKey = Color.wtDynamic(WTTheme353.normalPressedBackground)
    public static let grayKey = Color.wtDynamic(WTTheme353.grayBackground)
    public static let grayPressedKey = Color.wtDynamic(WTTheme353.grayPressedBackground)
    public static let accent = Color.wtDynamic(WTTheme353.accent)
    public static let destructive = Color.wtDynamic(WTTheme353.destructive)

    public static let normalBorder = Color(uiColor: UIColor { traits in
        UIColor(wtHex: traits.userInterfaceStyle == .dark ? "#FFFFFF1A" : "#0000001A")
    })
    public static let grayBorder = Color(uiColor: UIColor { traits in
        UIColor(wtHex: traits.userInterfaceStyle == .dark ? "#FFFFFF14" : "#0000000D")
    })
    public static let keyShadow = Color(uiColor: UIColor { traits in
        UIColor(wtHex: traits.userInterfaceStyle == .dark ? "#00000099" : "#0000004D")
    })
}
