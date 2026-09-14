import Foundation

/// Clean-room bridge for the delete-key gestures observed in the public 3.5.3 tutorial surfaces.
///
/// The SwiftUI keyboard surface owns gesture recognition while the input-view controller owns
/// document-proxy/Rime mutation. Keeping the bridge callback-only avoids leaking UIKit into the
/// reusable overlay target and lets the gesture state stay tied to one WTKeyboardRuntime instance.
@MainActor
public enum WTDeleteGestureBridge {
    public struct Callbacks {
        public let begin: () -> Void
        public let deleteStep: () -> Void
        public let restoreStep: () -> Void
        public let clear: () -> Void
        public let end: () -> Void

        public init(
            begin: @escaping () -> Void,
            deleteStep: @escaping () -> Void,
            restoreStep: @escaping () -> Void,
            clear: @escaping () -> Void,
            end: @escaping () -> Void
        ) {
            self.begin = begin
            self.deleteStep = deleteStep
            self.restoreStep = restoreStep
            self.clear = clear
            self.end = end
        }
    }

    private static var callbacks: [ObjectIdentifier: Callbacks] = [:]

    public static func bind(runtime: WTKeyboardRuntime, callbacks value: Callbacks) {
        callbacks[ObjectIdentifier(runtime)] = value
    }

    public static func unbind(runtime: WTKeyboardRuntime) {
        callbacks.removeValue(forKey: ObjectIdentifier(runtime))
    }

    public static func begin(_ runtime: WTKeyboardRuntime) {
        callbacks[ObjectIdentifier(runtime)]?.begin()
    }

    public static func deleteStep(_ runtime: WTKeyboardRuntime) {
        callbacks[ObjectIdentifier(runtime)]?.deleteStep()
    }

    public static func restoreStep(_ runtime: WTKeyboardRuntime) {
        callbacks[ObjectIdentifier(runtime)]?.restoreStep()
    }

    public static func clear(_ runtime: WTKeyboardRuntime) {
        callbacks[ObjectIdentifier(runtime)]?.clear()
    }

    public static func end(_ runtime: WTKeyboardRuntime) {
        callbacks[ObjectIdentifier(runtime)]?.end()
    }
}
