from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class Phase14KeyboardGeometryIntegrationTests(unittest.TestCase):
    def test_keyboard_canvas_uses_runtime_resolved_frames_without_double_scaling(self):
        canvas = (ROOT / "iOSOverlay/WTKeyboardCanvasView.swift").read_text(encoding="utf-8")
        runtime = (ROOT / "iOSOverlay/WTKeyboardRuntime.swift").read_text(encoding="utf-8")

        self.assertIn("resolvedFrame(\n        for item: WTKeyboardItem", runtime)
        self.assertIn("WTKeyboardGeometryResolver353.resolve", runtime)
        self.assertIn("runtime.resolvedFrame(\n                            for: item", canvas)
        self.assertIn(".frame(width: renderRect.width * renderSx", canvas)
        self.assertIn("geometryRect: renderRect", canvas)
        self.assertIn("sourceRect: geometryRect", canvas)


    def test_phase14_canvas_keeps_raw_layout_fallback_for_non_measured_viewports(self):
        runtime = (ROOT / "iOSOverlay/WTKeyboardRuntime.swift").read_text(encoding="utf-8")
        self.assertIn("viewportWidth == WTMeasuredKeyboard353.viewportWidth", runtime)
        self.assertIn("WTKeyboardGeometryResolver353.hasMeasuredGeometry(layout)", runtime)
        self.assertIn("guard usesMeasuredFrames(for: layout, viewportWidth: viewportWidth) else { return sourceRect }", runtime)

    def test_canvas_draws_the_measured_bottom_bar_and_panel_height(self):
        canvas = (ROOT / "iOSOverlay/WTKeyboardCanvasView.swift").read_text(encoding="utf-8")
        theme = (ROOT / "Sources/WeTypeReplicaCore/ThemeTokens.swift").read_text(encoding="utf-8")
        contract = (ROOT / "Sources/WeTypeReplicaCore/Phase14VisualContract.swift").read_text(encoding="utf-8")
        controller = (ROOT / "ClawBase/Keyboard/HamsterKeyboardInputViewController.swift").read_text(encoding="utf-8")

        self.assertIn("WTKeyboardBottomBar353(runtime: runtime)", canvas)
        self.assertIn("WTMeasuredKeyboard353.bottomBarLanguageFrame", canvas)
        self.assertIn("WTMeasuredKeyboard353.bottomBarVoiceFrame", canvas)
        self.assertIn("CGFloat(WTMeasuredKeyboard353.keyAreaHeight)", canvas)
        self.assertIn("keyboardHeaderHeight", theme)
        self.assertIn("keyboardCanvasHeight", theme)
        self.assertIn("panelHeight: Double = 371", contract)
        self.assertIn("t26BottomRowWidths: [Double] = [79.33, 36, 154.33, 39.67, 85.33]", contract)
        self.assertIn("WTTheme353.keyboardHeaderHeight + WTTheme353.keyboardCanvasHeight", controller)
