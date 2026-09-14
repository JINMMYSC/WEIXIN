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
    project = text("ClawBase/project.yml")
    surface = text("ClawBase/Keyboard/WTPhase3KeyboardSurface.swift")
    controller = text("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")
    session = text("ClawBase/Keyboard/WTLibrimeRimeSession.swift")
    adapter = text("HamsterBridge/WTHamsterRimeSessionAdapter.swift")
    profile = text("Sources/WeTypeReplicaCore/InputModeBackendProfile.swift")
    generator = text("ClawBase/RimeSchemas/generate_fuzzy_variants.py")
    prepare = text("ClawBase/ci_prepare_librimekit.sh")
    pinyin26 = text("ClawBase/RimeSchemas/claw_pinyin26.schema.yaml")
    pinyin9 = text("ClawBase/RimeSchemas/claw_pinyin9.schema.yaml")

    for source in (
        "Keyboard/WTPhase3KeyboardSurface.swift",
        "../iOSOverlay/WTEmojiPanelView.swift",
        "../iOSOverlay/WTInputModeSwitcherView.swift",
        "../iOSOverlay/WTCleanRoomIconView.swift",
    ):
        require(source in project, f"missing Phase 3 UI source: {source}")

    require("case .emoji:" in surface and "WTEmojiPanelView(runtime: runtime)" in surface,
            "emoji panel is not routed from the live keyboard root")
    require("case .inputModeSwitcher:" in surface and "WTInputModeSwitcherView(runtime: runtime)" in surface,
            "input-mode panel is not routed from the live keyboard root")
    require("frame(height: CGFloat(keyboardLayout.baseSize.height))" in surface,
            "measured keyboard height is not preserved")
    require("WTTheme353.keyboardHeight + WTTheme353.compositionHeight + WTTheme353.candidateCompactHeight" in controller,
            "controller does not reserve the full measured keyboard+candidate height")
    require("phase3.recentEmoji" in controller and "runtime.recordEmoji" in controller,
            "emoji recents are not persisted in the App Group")

    require("wtSetSimplifiedChinese" in adapter and "wtSetFuzzyPinyin" in adapter,
            "typed Phase 3 script/fuzzy controls missing")
    require("WTFuzzyPinyinOption" in profile, "fuzzy option model missing")
    for token in (
        "claw_pinyin26_fuzzy_zhz",
        "claw_pinyin26_fuzzy_ln",
        "claw_pinyin26_fuzzy_all",
        "phase3.simplifiedChinese",
        "phase3.fuzzy.retroflexInitials",
        "phase3.fuzzy.nasalLateral",
        "group.7518554",
    ):
        require(token in session, f"real session missing Phase 3 behavior token: {token}")

    require("enable_user_dict: true" in pinyin26 and "enable_user_dict: true" in pinyin9,
            "pinyin user dictionary learning must stay enabled")
    require("derive/^zh/z/" in generator and "derive/^n/l/" in generator,
            "fuzzy schema generator missing required fuzzy pairs")
    for name in (
        "claw_pinyin26_fuzzy_zhz.schema.yaml",
        "claw_pinyin26_fuzzy_ln.schema.yaml",
        "claw_pinyin26_fuzzy_all.schema.yaml",
    ):
        require(name in prepare, f"CI does not require generated fuzzy schema: {name}")

    print("Phase 3 functional completion gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 functional completion gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
