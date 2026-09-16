#!/usr/bin/env python3
"""Static gate for the 79-case WeType 3.5.3 UI parity contract."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    manifest = text("Sources/WeTypeReplicaCore/VisualParityManifest.swift")
    theme = text("Sources/WeTypeReplicaCore/ThemeTokens.swift")
    canvas = text("iOSOverlay/WTKeyboardCanvasView.swift")
    candidate = text("iOSOverlay/WTCandidateBar.swift")
    chrome = text("iOSOverlay/WTChrome.swift")
    panel = text("iOSOverlay/WTPanelRootView.swift")

    paired_cases = (
        "keyboard26", "keyboard9", "candidate-expanded", "symbol-cn", "symbol-en",
        "emoji", "clipboard", "handwriting", "voice-idle", "voice-listening",
        "translate", "ai", "correction", "plus", "control-center", "quick-settings",
        "input-switcher", "one-handed-left", "one-handed-right", "device-sync",
        "sticker-gif", "book-video", "settings-home", "settings-keyboard-select",
        "settings-fuzzy-pinyin", "settings-auxiliary-input", "settings-display",
        "settings-keystroke-effect", "settings-clipboard", "settings-desktop",
        "settings-migration", "settings-plus", "settings-shuangpin", "settings-wubi",
    )
    single_cases = (
        "popup-q", "longpress-v", "candidate-menu", "return-send", "return-search",
        "secure-field", "spotlight", "landscape-26", "landscape-9", "share-extension",
        "voice-widget",
    )
    require(2 * len(paired_cases) + len(single_cases) == 79, "internal 79-case count changed")
    require('for appearance in ["light", "dark"]' in manifest,
            "visual manifest must explicitly cover light and dark appearance")
    for case_id in paired_cases + single_cases:
        require(f'"{case_id}' in manifest, f"visual manifest missing required case: {case_id}")

    for token in (
        "designWidth: Double = 414", "keyboardHeight: Double = 224",
        "candidateCompactHeight: Double = 40", "compositionHeight: Double = 18",
        "toolbarHeight: Double = 40", "panelHeaderHeight: Double = 40",
        "keyCornerRadius: Double = 5", "letterFontSize: Double = 24",
        "keySubtitleFontSize: Double = 9", "functionFontSize: Double = 16",
        "candidateFontSize: Double = 18",
    ):
        require(token in theme, f"extracted 3.5.3 metric drifted: {token}")

    for token in (
        "let sx =", "let sy =", "layout.baseSize.width", "layout.baseSize.height",
        "runtime.resolvedFrame(", "renderRect.width * renderSx", "renderRect.height * sy",
        "geometryRect: renderRect", "WTKeyTapPopupView", "WTLongPressPopupView",
        "runtime.visualCalibration.keyPopupScale", "runtime.visualCalibration.keyPopupDuration",
        "T26_LETTER", "WTTheme353.letterFontSize", "WTTheme353.keySubtitleFontSize",
        "The original 3.5.3 key popup rises above",
    ):
        require(token in canvas, f"live keyboard canvas missing parity token: {token}")

    for token in (
        "runtime.visualCalibration.candidateHeight",
        "runtime.visualCalibration.candidateExpandDuration",
        "runtime.candidatePageState.hasPrevious",
        "runtime.candidatePageState.hasNext",
        "runtime.showCandidateActions",
    ):
        require(token in candidate, f"candidate bar missing parity behavior: {token}")

    require("WTIconGeometry353.geometry" in chrome,
            "toolbar/control-center icons must use extracted 3.5.3 geometry")
    require(".frame(height: 40)" in chrome,
            "panel chrome must retain extracted 40pt header height")

    for token in (
        "WTLayouts353Resolved.t26Pinyin", "WTLayouts353Resolved.t9Pinyin",
        "WTLayouts353Resolved.t26En", "WTLayouts353Resolved.t26Wubi",
        "WTLayouts353Resolved.t9Stroke", "WTLayouts353Resolved.t9Number",
        "WTLayouts353Resolved.t26CnSymbol", "WTLayouts353Resolved.t26EnSymbol",
        "WTOneHandedShell", "WTCandidateBar(runtime: runtime)",
        "WT353RuntimeLayoutGeometry.primaryLayout", "WTIdleInputBar353(runtime: runtime)",
    ):
        require(token in panel, f"live panel router missing extracted UI path: {token}")

    offenders = []
    for folder in ("iOSOverlay", "iOSApp", "iOSExtensions"):
        for path in (ROOT / folder).glob("*.swift"):
            source = path.read_text(encoding="utf-8")
            if "Image(systemName:" in source or "systemImage:" in source:
                offenders.append(str(path.relative_to(ROOT)))
    require(not offenders, "direct SF Symbol placeholders remain: " + ", ".join(offenders))

    print("UI 79 static manifest gate: PASS (capture cases defined; same-device visual acceptance remains required)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"UI 79 static alignment gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
