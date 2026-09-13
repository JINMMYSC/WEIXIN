import Foundation

public enum WTSharedPreferenceKey {
    public static let keySound = "wt.feedback.sound"
    public static let haptic = "wt.feedback.haptic"
    public static let hapticLevel = "wt.feedback.haptic.level"
    public static let oneHandedMode = "wt.onehand.mode"
    public static let oneHandedWidth = "wt.onehand.width"
    public static let fontScale = "wt.display.fontScale"
    public static let keyboardWidth = "wt.rect.width"
    public static let keyboardHeight = "wt.rect.height"
    public static let keyboardX = "wt.rect.x"
    public static let keyboardY = "wt.rect.y"
    public static let clipboardEnabled = "wt.clipboard.enabled"
    public static let cloudEnabled = "wt.cloud.enabled"
    public static let voiceEnabled = "wt.voice.enabled"
    public static let toolbarEnabled = "wt.toolbar.enabled"
    public static let transferPairingCode = "wt.transfer.pairingCode"
    public static let transferTrustedDevices = "wt.transfer.trustedDevices.v1"
}

public struct WTKeyboardPreferenceSnapshot: Equatable, Sendable {
    public var keySoundEnabled: Bool
    public var hapticEnabled: Bool
    public var hapticLevel: Double
    public var oneHandedMode: WTOneHandedMode
    public var oneHandedWidth: Double
    public var fontScale: Double
    public var keyboardAdjustment: WTKeyboardAdjustment
    public var clipboardEnabled: Bool
    public var cloudEnabled: Bool
    public var voiceEnabled: Bool
    public var toolbarEnabled: Bool

    public init(
        keySoundEnabled: Bool = true,
        hapticEnabled: Bool = true,
        hapticLevel: Double = 0.5,
        oneHandedMode: WTOneHandedMode = .off,
        oneHandedWidth: Double = 0.82,
        fontScale: Double = 1.0,
        keyboardAdjustment: WTKeyboardAdjustment = .init(),
        clipboardEnabled: Bool = true,
        cloudEnabled: Bool = true,
        voiceEnabled: Bool = true,
        toolbarEnabled: Bool = true
    ) {
        self.keySoundEnabled = keySoundEnabled
        self.hapticEnabled = hapticEnabled
        self.hapticLevel = Self.clamp(hapticLevel, 0...1)
        self.oneHandedMode = oneHandedMode
        self.oneHandedWidth = Self.clamp(oneHandedWidth, 0.68...0.95)
        self.fontScale = Self.clamp(fontScale, 0.85...1.20)
        var adjustment = keyboardAdjustment
        adjustment.clamp()
        self.keyboardAdjustment = adjustment
        self.clipboardEnabled = clipboardEnabled
        self.cloudEnabled = cloudEnabled
        self.voiceEnabled = voiceEnabled
        self.toolbarEnabled = toolbarEnabled
    }

    public init(defaults: UserDefaults) {
        func bool(_ key: String, _ fallback: Bool) -> Bool {
            defaults.object(forKey: key) as? Bool ?? fallback
        }
        func double(_ key: String, _ fallback: Double) -> Double {
            if let value = defaults.object(forKey: key) as? NSNumber { return value.doubleValue }
            return fallback
        }
        let modeString = defaults.string(forKey: WTSharedPreferenceKey.oneHandedMode) ?? "关闭"
        let mode: WTOneHandedMode
        switch modeString.lowercased() {
        case "左手", "left": mode = .left
        case "右手", "right": mode = .right
        default: mode = .off
        }
        self.init(
            keySoundEnabled: bool(WTSharedPreferenceKey.keySound, true),
            hapticEnabled: bool(WTSharedPreferenceKey.haptic, true),
            hapticLevel: double(WTSharedPreferenceKey.hapticLevel, 0.5),
            oneHandedMode: mode,
            oneHandedWidth: double(WTSharedPreferenceKey.oneHandedWidth, 0.82),
            fontScale: double(WTSharedPreferenceKey.fontScale, 1.0),
            keyboardAdjustment: WTKeyboardAdjustment(
                widthScale: double(WTSharedPreferenceKey.keyboardWidth, 1.0),
                heightScale: double(WTSharedPreferenceKey.keyboardHeight, 1.0),
                horizontalOffset: double(WTSharedPreferenceKey.keyboardX, 0.0),
                verticalOffset: double(WTSharedPreferenceKey.keyboardY, 0.0)
            ),
            clipboardEnabled: bool(WTSharedPreferenceKey.clipboardEnabled, true),
            cloudEnabled: bool(WTSharedPreferenceKey.cloudEnabled, true),
            voiceEnabled: bool(WTSharedPreferenceKey.voiceEnabled, true),
            toolbarEnabled: bool(WTSharedPreferenceKey.toolbarEnabled, true)
        )
    }

    private static func clamp(_ value: Double, _ range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
