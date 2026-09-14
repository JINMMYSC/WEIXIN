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

    for token in (
        '"KEY_EMOTION", "KEY_SWITCH", "KEY_At"',
        '"KEY_123": WTRect(x: 5, y: 173, width: 75, height: 46)',
        '"KEY_SPACE": WTRect(x: 127, y: 173, width: 147, height: 46)',
        '"KEY_CHANGE": WTRect(x: 280, y: 173, width: 46, height: 46)',
        '"KEY_RETURN": WTRect(x: 332, y: 173, width: 77, height: 46)',
        '"VIEW_LIST", "KEY_SWITCH", "KEY_EMOTION"',
        '"KEY_SPACE": WTRect(x: 136, y: 171, width: 142, height: 50)',
        '"KEY_RETURN": WTRect(x: 341, y: 115, width: 68, height: 106)',
        '["，", "。", "！", "？"]',
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

    print("Phase 3 device-visible UI contract: PASS (resolved T26/T9 geometry + idle/candidate chrome)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 device-visible UI contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
