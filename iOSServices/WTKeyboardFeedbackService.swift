#if canImport(UIKit) && canImport(AudioToolbox)
import UIKit
import AudioToolbox

@MainActor
public final class WTKeyboardFeedbackService {
    public init() {}

    public func keyPressed(settings: WTQuickSettingState, intensity: Double = 0.55) {
        if settings.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred(intensity: min(max(intensity, 0.0), 1.0))
        }
        if settings.keySoundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
    }

    public func deletePressed(settings: WTQuickSettingState, intensity: Double = 0.45) {
        if settings.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare()
            generator.impactOccurred(intensity: min(max(intensity, 0.0), 1.0))
        }
        if settings.keySoundEnabled {
            AudioServicesPlaySystemSound(1155)
        }
    }
}
#endif
