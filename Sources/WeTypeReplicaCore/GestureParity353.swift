import Foundation

public enum WT353DirectionalGesture: String, Codable, Sendable {
    case tap
    case swipeUp
    case swipeDown
}

/// Single source of truth for keyboard gesture thresholds while same-device video calibration is performed.
/// Defaults preserve the currently validated V14 behavior; captured 3.5.3 measurements can replace values
/// without changing the state machine or document-proxy mutation code.
public struct WT353GestureCalibration: Codable, Equatable, Sendable {
    public var verticalSwipeThreshold: Double
    public var longPressDuration: Double
    public var longPressMaximumDistance: Double
    public var longPressGlideStep: Double
    public var deleteClearVerticalThreshold: Double
    public var deleteVerticalDominance: Double
    public var deleteHorizontalActivation: Double
    public var deleteHorizontalStep: Double
    public var deleteMaximumSteps: Int
    public var deleteRepeatInitialDelay: Double
    public var deleteRepeatInterval: Double

    public init(
        verticalSwipeThreshold: Double = 18,
        longPressDuration: Double = 0.36,
        longPressMaximumDistance: Double = 14,
        longPressGlideStep: Double = 33,
        deleteClearVerticalThreshold: Double = 28,
        deleteVerticalDominance: Double = 0.72,
        deleteHorizontalActivation: Double = 10,
        deleteHorizontalStep: Double = 22,
        deleteMaximumSteps: Int = 24,
        deleteRepeatInitialDelay: Double = 0.110,
        deleteRepeatInterval: Double = 0.078
    ) {
        self.verticalSwipeThreshold = verticalSwipeThreshold
        self.longPressDuration = longPressDuration
        self.longPressMaximumDistance = longPressMaximumDistance
        self.longPressGlideStep = longPressGlideStep
        self.deleteClearVerticalThreshold = deleteClearVerticalThreshold
        self.deleteVerticalDominance = deleteVerticalDominance
        self.deleteHorizontalActivation = deleteHorizontalActivation
        self.deleteHorizontalStep = deleteHorizontalStep
        self.deleteMaximumSteps = deleteMaximumSteps
        self.deleteRepeatInitialDelay = deleteRepeatInitialDelay
        self.deleteRepeatInterval = deleteRepeatInterval
    }
}

public enum WT353GestureModel {
    public static func directionalGesture(
        dx: Double,
        dy: Double,
        calibration: WT353GestureCalibration = .init()
    ) -> WT353DirectionalGesture {
        guard abs(dy) > abs(dx) else { return .tap }
        if dy < -calibration.verticalSwipeThreshold { return .swipeUp }
        if dy > calibration.verticalSwipeThreshold { return .swipeDown }
        return .tap
    }

    public static func longPressIndex(
        origin: Int,
        translationX: Double,
        itemCount: Int,
        calibration: WT353GestureCalibration = .init()
    ) -> Int {
        guard itemCount > 0 else { return 0 }
        let step = max(1, calibration.longPressGlideStep)
        let delta = Int((translationX / step).rounded())
        return min(max(origin + delta, 0), itemCount - 1)
    }

    public static func deleteClearIsArmed(
        dx: Double,
        dy: Double,
        calibration: WT353GestureCalibration = .init()
    ) -> Bool {
        dy < -calibration.deleteClearVerticalThreshold && abs(dy) > abs(dx) * calibration.deleteVerticalDominance
    }

    public static func deleteTargetSteps(
        dx: Double,
        dy: Double,
        currentSteps: Int,
        calibration: WT353GestureCalibration = .init()
    ) -> Int {
        if deleteClearIsArmed(dx: dx, dy: dy, calibration: calibration) { return currentSteps }
        guard abs(dx) >= abs(dy) else { return currentSteps }
        guard dx < -calibration.deleteHorizontalActivation else { return 0 }
        let raw = Int((-dx - calibration.deleteHorizontalActivation) / max(1, calibration.deleteHorizontalStep)) + 1
        return min(calibration.deleteMaximumSteps, max(0, raw))
    }

    public static func isTapDelete(
        dx: Double,
        dy: Double,
        mutated: Bool,
        deletedSteps: Int,
        calibration: WT353GestureCalibration = .init()
    ) -> Bool {
        !mutated && deletedSteps == 0 && abs(dx) < calibration.deleteHorizontalActivation && abs(dy) < calibration.deleteHorizontalActivation
    }
}
