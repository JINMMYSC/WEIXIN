import SwiftUI
import UIKit

// `Color(wtHex:)`, `Color.wtDynamic(_:)` and `UIColor(wtHex:)` live in
// `iOSShared/WTHexColor.swift` so every target, including the Host app, can use them.

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
