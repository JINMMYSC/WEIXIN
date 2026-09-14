#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def main() -> int:
    geometry = text("Sources/WeTypeReplicaCore/WT353RuntimeLayoutGeometry.swift")
    panel = text("iOSOverlay/WTPanelRootView.swift")
    candidate = text("iOSOverlay/WTCandidateBar.swift")
    canvas = text("iOSOverlay/WTKeyboardCanvasView.swift")
    glyph = text("iOSOverlay/WTBasicGlyphView.swift")
    delete_bridge = text("iOSOverlay/WTDeleteGestureBridge.swift")
    controller = text("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")

    for token in (
        '"KEY_EMOTION", "KEY_SWITCH", "KEY_At"',
        '"KEY_123": WTRect(x: 5, y: 173, width: 75, height: 46)',
        '"KEY_SPACE": WTRect(x: 127, y: 173, width: 147, height: 46)',
        '"KEY_CHANGE": WTRect(x: 280, y: 173, width: 46, height: 46)',
        '"KEY_RETURN": WTRect(x: 332, y: 173, width: 77, height: 46)',
        'case .chinesePinyin9, .stroke:',
        '"VIEW_LIST", "KEY_SWITCH", "KEY_EMOTION"',
        '"KEY_SPACE": WTRect(x: 136, y: 171, width: 142, height: 50)',
        '"KEY_RETURN": WTRect(x: 341, y: 115, width: 68, height: 106)',
        '["，", "。", "！", "？"]',
        'style: "STYLE_GRAY"',
    ):
        require(token in geometry, f"3.5.3 runtime geometry missing: {token}")

    require("WT353RuntimeLayoutGeometry.primaryLayout" in panel,
            "live panel router does not resolve final 3.5.3 geometry")
    require("runtime.composition.isEmpty && runtime.candidates.isEmpty" in panel,
            "idle/candidate chrome is not state-dependent")
    require("WTIdleInputBar353(runtime: runtime)" in panel,
            "idle gray 3.5.3 chrome is missing")
    require("WTFunctionToolbarView(runtime: runtime)" not in panel,
            "legacy stacked toolbar must not add a second row above the keyboard")

    require(".background(WTThemeColor353.keyboardBackground)" in candidate,
            "candidate chrome must share the measured keyboard background")
    require("index == 0 ? WTChrome353.accent" in candidate,
            "first candidate highlight styling missing")
    require("index == 0 ? WTChrome353.elevatedSurface" in candidate,
            "first candidate selected card missing")

    for token in (
        'items: ["换行", "。", "？", "！", "@", "…"]',
        'case .doublePinyin: return "双"',
        'case .wubi: return "五"',
        'WTBasicGlyphView(.delete',
        'WTBasicGlyphView(.shift',
        'runtime.submitReturn()',
        'Text("上滑清空")',
        'WTDeleteGestureBridge.deleteStep(runtime)',
        'WTDeleteGestureBridge.restoreStep(runtime)',
        'WTDeleteGestureBridge.clear(runtime)',
        'startRapidDelete()',
    ):
        require(token in canvas, f"device-visible key chrome/gesture missing: {token}")
    require("case shift, delete" in glyph, "clean-room shift/delete glyphs missing")

    for token in (
        "public let begin: () -> Void",
        "public let deleteStep: () -> Void",
        "public let restoreStep: () -> Void",
        "public let clear: () -> Void",
        "callbacks[ObjectIdentifier(runtime)]",
    ):
        require(token in delete_bridge, f"delete gesture bridge missing: {token}")

    for token in (
        "deleteGestureRestoreBuffer",
        "documentContextBeforeInput",
        "performDeleteGestureStep()",
        "performDeleteGestureRestoreStep()",
        "performDeleteGestureClear()",
        "WTDeleteGestureBridge.bind(",
        "engine.reset()",
    ):
        require(token in controller, f"delete gesture controller contract missing: {token}")

    print("Phase 3 device-visible UI contract: PASS (resolved T26/T9/stroke geometry + candidate/idle chrome + key glyphs + delete hold/drag/restore/clear gestures)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 device-visible UI contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
