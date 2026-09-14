#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    bridge_h = (ROOT / "ClawBase/Keyboard/WTLibrimeBridge.h").read_text(encoding="utf-8")
    bridge_m = (ROOT / "ClawBase/Keyboard/WTLibrimeBridge.m").read_text(encoding="utf-8")
    session = (ROOT / "ClawBase/Keyboard/WTLibrimeRimeSession.swift").read_text(encoding="utf-8")
    prepare = (ROOT / "ClawBase/ci_prepare_librimekit.sh").read_text(encoding="utf-8")
    contract = (ROOT / "ClawBase/Phase3BlackBox/SEGMENTATION_CONTRACT.md").read_text(encoding="utf-8")

    require('LIBRIME_COMMIT="08dd95f5d9282346f0d4a3e8fc6b20811dc3d063"' in prepare,
            "segmentation capability audit must remain pinned to the reviewed librime revision")

    for token in (
        "compositionLength",
        "cursorPosition",
        "selectionStart",
        "selectionEnd",
    ):
        require(token in bridge_h, f"public composition metadata missing from bridge header: {token}")
        require(token in bridge_m, f"public composition metadata missing from bridge implementation: {token}")

    for token in (
        "context.composition.length",
        "context.composition.cursor_pos",
        "context.composition.sel_start",
        "context.composition.sel_end",
        "context.composition.preedit",
    ):
        require(token in bridge_m, f"bridge is not sourcing metadata from real RimeContext: {token}")

    require("WTIMECompositionState(" in session,
            "real librime composition metadata is not mapped into WTIMECompositionState")
    require("segment" not in bridge_h.lower(),
            "do not expose fabricated segment boundaries in the public Objective-C bridge")
    require("does **not** expose the engine's internal `Composition` segment list" in contract,
            "segmentation capability boundary must remain explicit")
    require("explicit segmentation parity is an open external/backend capability gate" in contract,
            "Phase 3 must not silently claim unavailable segmentation parity")

    print("Phase 3 segmentation contract: PASS (real composition metadata; explicit segments not fabricated)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 segmentation contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
