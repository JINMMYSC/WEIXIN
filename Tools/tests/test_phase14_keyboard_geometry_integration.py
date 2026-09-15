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
        self.assertIn("viewportWidth == 430, layout.name.hasPrefix(\"t26_pinyin\")", runtime)
        self.assertIn("return sourceRect", runtime)
