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
    root = text("ClawBase/Keyboard/WTPhase2KeyboardRootView.swift")
    panel_root = text("iOSOverlay/WTPanelRootView.swift")
    runtime = text("iOSOverlay/WTKeyboardRuntime.swift")
    service_binder = text("iOSServices/WTKeyboardServiceBinder.swift")
    controller = text("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")
    session = text("ClawBase/Keyboard/WTLibrimeRimeSession.swift")
    adapter = text("HamsterBridge/WTHamsterRimeSessionAdapter.swift")
    profile = text("Sources/WeTypeReplicaCore/InputModeBackendProfile.swift")
    generator = text("ClawBase/RimeSchemas/generate_fuzzy_variants.py")
    prepare = text("ClawBase/ci_prepare_librimekit.sh")
    pinyin26 = text("ClawBase/RimeSchemas/claw_pinyin26.schema.yaml")
    pinyin9 = text("ClawBase/RimeSchemas/claw_pinyin9.schema.yaml")
    sogou = text("ClawBase/RimeSchemas/claw_double_pinyin_sogou.schema.yaml")

    for source in ("../iOSShared", "../iOSOverlay", "../HamsterBridge", "../iOSServices"):
        require(source in project, f"missing complete migrated keyboard source group: {source}")
    require("WTPanelRootView(runtime: runtime)" in root,
            "ClawBase live root must use the complete V14 panel router")
    for token in (
        "case .emoji:", "WTEmojiPanelView(runtime: runtime)",
        "case .inputModeSwitcher:", "WTInputModeSwitcherView(runtime: runtime)",
        "case .number:", "case .symbols:",
        "WTLayouts353Resolved.t26Pinyin", "WTLayouts353Resolved.t9Pinyin",
        "WTLayouts353Resolved.t26Wubi", "WTLayouts353Resolved.t9Stroke",
    ):
        require(token in panel_root, f"complete live panel router missing token: {token}")
    require('case "emoji": state.present(.emoji)' in runtime,
            "emoji key does not transition to the live emoji panel")
    require("WTTheme353.keyboardHeight + WTTheme353.compositionHeight + WTTheme353.candidateCompactHeight" in controller,
            "controller does not reserve the full measured keyboard+candidate height")
    require("WTKeyboardServiceBinder(" in controller and "services.bind()" in controller,
            "ClawBase controller is not bound to V14 App Group persistence/services")
    require("persistSessionState" in controller and "reloadSharedSettings" in controller,
            "logical mode/settings are not restored across keyboard extension relaunch")
    require("runtime.recordEmoji" in service_binder and "emojiStore?.record" in service_binder,
            "emoji recents are not persisted by the shared App Group store")

    require("wtSetSimplifiedChinese" in adapter and "wtSetFuzzyPinyin" in adapter,
            "typed Phase 3 script/fuzzy controls missing")
    require("WTFuzzyPinyinOption" in profile, "fuzzy option model missing")
    for token in (
        "claw_pinyin26_fuzzy_zhz", "claw_pinyin26_fuzzy_ln", "claw_pinyin26_fuzzy_all",
        "wt.script.simplified", "wt.pinyin.blur", "wt.fuzzy.z_zh", "wt.fuzzy.n_l",
        "wt.double.scheme", "double_pinyin_flypy", "double_pinyin_mspy", "claw_double_pinyin_sogou",
        "group.7518554",
    ):
        require(token in session, f"real session missing Phase 3 behavior token: {token}")

    require("dictionary: luna_pinyin" in pinyin26 and "dictionary: luna_pinyin" in pinyin9,
            "pinyin schemas must retain traditional source forms for a real 简/繁 toggle")
    require("opencc_config: t2s.json" in pinyin26 and "opencc_config: t2s.json" in pinyin9,
            "pinyin schemas must use the public OpenCC simplified filter")
    require("enable_user_dict: true" in pinyin26 and "enable_user_dict: true" in pinyin9,
            "pinyin user dictionary learning must stay enabled")
    require("schema_id: claw_double_pinyin_sogou" in sogou and "dictionary: luna_pinyin" in sogou,
            "Sogou double-pinyin must stay clean-room and use the pinned public dictionary")
    require("derive/^zh/z/" in generator and "derive/^n/l/" in generator,
            "fuzzy schema generator missing required fuzzy pairs")
    for name in (
        "luna_pinyin.dict.yaml",
        "claw_pinyin26_fuzzy_zhz.schema.yaml", "claw_pinyin26_fuzzy_ln.schema.yaml", "claw_pinyin26_fuzzy_all.schema.yaml",
        "double_pinyin.schema.yaml", "double_pinyin_flypy.schema.yaml", "double_pinyin_mspy.schema.yaml",
        "claw_double_pinyin_sogou.schema.yaml",
    ):
        require(name in prepare, f"CI does not require Phase 3 Rime resource: {name}")

    print("Phase 3 functional completion gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 functional completion gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
