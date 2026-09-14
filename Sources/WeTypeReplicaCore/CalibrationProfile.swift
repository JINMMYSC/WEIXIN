import Foundation

/// Central calibration knobs used during side-by-side iPhone screenshot/video matching.
/// Defaults are conservative placeholders; the profile is designed so captured measurements
/// can be applied without rewriting individual SwiftUI surfaces.
public struct WTVisualCalibrationProfile: Codable, Equatable, Sendable {
    public var candidateHeight: Double
    public var toolbarHeight: Double
    public var keyCornerRadius: Double
    public var panelCornerRadius: Double
    public var keyPopupScale: Double
    public var candidateExpandDuration: Double
    public var panelTransitionDuration: Double
    public var keyPopupDuration: Double
    public var voicePulseDuration: Double

    public init(
        candidateHeight: Double = WTTheme353.candidateCompactHeight,
        toolbarHeight: Double = WTTheme353.toolbarHeight,
        keyCornerRadius: Double = WTTheme353.keyCornerRadius,
        panelCornerRadius: Double = WTTheme353.sheetCornerRadius,
        keyPopupScale: Double = 1.08,
        candidateExpandDuration: Double = 0.18,
        panelTransitionDuration: Double = 0.20,
        keyPopupDuration: Double = 0.10,
        voicePulseDuration: Double = 0.85
    ) {
        self.candidateHeight = candidateHeight
        self.toolbarHeight = toolbarHeight
        self.keyCornerRadius = keyCornerRadius
        self.panelCornerRadius = panelCornerRadius
        self.keyPopupScale = keyPopupScale
        self.candidateExpandDuration = candidateExpandDuration
        self.panelTransitionDuration = panelTransitionDuration
        self.keyPopupDuration = keyPopupDuration
        self.voicePulseDuration = voicePulseDuration
    }
}