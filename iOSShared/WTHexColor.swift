import SwiftUI
import UIKit
import Foundation

/// Shared hex colour helpers. They live in `iOSShared` so the Host app, the keyboard
/// extension and the other extensions can all build colours from the extracted 3.5.3 hex
/// strings without depending on the keyboard overlay target. Only generic hex parsing
/// belongs here: `WTRGBAHex` and the dynamic-pair helper stay with the Core-aware targets.
public extension Color {
    init(wtHex: String) {
        self.init(uiColor: UIColor(wtHex: wtHex))
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
