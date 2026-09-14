#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    styles = (ROOT / "Sources/WeTypeReplicaCore/GeneratedStylesV3.swift").read_text(encoding="utf-8")
    canvas = (ROOT / "iOSOverlay/WTKeyboardCanvasView.swift").read_text(encoding="utf-8")

    for style in (
        '"STYLE_NORMAL"', '"STYLE_T26_LETTER"', '"STYLE_T9_ABC"',
        '"STYLE_T9_1"', '"STYLE_GRAY"', '"STYLE_DEL"', '"STYLE_123_T9"',
        '"STYLE_RETURN"', '"STYLE_SPACE"', '"STYLE_SHIFT"',
    ):
        require(style in styles, f"extracted style missing: {style}")

    for token in (
        "WTStyleCatalog353.values(for: item.style)",
        'extractedColor(for: pressed ? "HLBG" : "BG"',
        'extractedColor(for: "TINT"',
        'extractedColor(for: "STINT"',
        'extractedColor(for: "BORDER"',
        'extractedColor(for: "SHADOW"',
        'styleValues["FONT"]',
        'styleValues["UPFONT"]',
        '@Environment(\\.colorScheme)',
    ):
        require(token in canvas, f"live keycap does not consume extracted style token: {token}")

    # Rule-driven bracket arrays must remain state-machine controlled instead of being misread as
    # light/dark pairs.
    require('!raw.hasPrefix("[")' in canvas,
            "rule-driven style arrays must fail back to the explicit runtime state machine")

    print("UI extracted-style gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"UI extracted-style gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
