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
    bridge_h = text("ClawBase/Keyboard/WTLibrimeBridge.h")
    bridge_m = text("ClawBase/Keyboard/WTLibrimeBridge.m")
    adapter = text("HamsterBridge/WTHamsterRimeSessionAdapter.swift")
    profile = text("Sources/WeTypeReplicaCore/InputModeBackendProfile.swift")
    generator = text("ClawBase/RimeSchemas/generate_fuzzy_variants.py")
    prepare = text("ClawBase/ci_prepare_librimekit.sh")
    pinyin26 = text("ClawBase/RimeSchemas/claw_pinyin26.schema.yaml")
    pinyin9 = text("ClawBase/RimeSchemas/claw_pinyin9.schema.yaml")
    sogou = text("ClawBase/RimeSchemas/claw_double_pinyin_sogou.schema.yaml")
    wubi98 = text("ClawBase/RimeSchemas/claw_wubi98.schema.yaml")
    segmentation = text("ClawBase/Phase3BlackBox/SEGMENTATION_CONTRACT.md")
    blackbox = text("Tools/phase3_blackbox_matrix.py")

    for source in ("../iOSShared", "../iOSOverlay", "../HamsterBridge", "../iOSServices"):
        require(source in project, f"missing complete migrated keyboard source group: {source}")
    require("../iOSApp/WTSettingsAppView.swift" in project,
            "Host Phase 3 settings surface missing from project")
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

    for token in ("wtSetSimplifiedChinese", "wtSetFuzzyPinyin", "wtReloadPhase3Preferences", "wtSyncUserData"):
        require(token in adapter, f"typed Phase 3 adapter control missing: {token}")
    for option in ("zZh", "cCh", "sSh", "nasalLateral", "fH", "anAng", "enEng", "inIng"):
        require(f"case {option}" in profile or f"case .{option}" in session,
                f"fuzzy option missing: {option}")

    for token in (
        "wt.script.simplified", "wt.pinyin.blur",
        "wt.fuzzy.z_zh", "wt.fuzzy.c_ch", "wt.fuzzy.s_sh", "wt.fuzzy.n_l",
        "wt.fuzzy.f_h", "wt.fuzzy.an_ang", "wt.fuzzy.en_eng", "wt.fuzzy.in_ing",
        "stageFuzzyCustomization", "deployCurrentFuzzyCustomization",
        "derive/^zh/z/", "derive/^ch/c/", "derive/^sh/s/", "derive/^n/l/",
        "derive/^f/h/", "derive/an$/ang/", "derive/en$/eng/", "derive/in$/ing/",
        "wt.double.scheme", "double_pinyin_flypy", "double_pinyin_mspy", "claw_double_pinyin_sogou",
        "wt.wubi.scheme", "claw_wubi98", "group.7518554",
    ):
        require(token in session, f"real session missing Phase 3 behavior token: {token}")

    require("deploySchemaFile" in bridge_h and "RimeDeploySchema" in bridge_m,
            "runtime fuzzy schema redeploy bridge missing")
    require("syncUserData" in bridge_h and "RimeSyncUserData" in bridge_m,
            "librime user-dictionary sync bridge missing")
    require("phase3Engine.syncUserData()" in controller,
            "keyboard lifecycle does not persist learned user data")
    require("reloadPhase3Preferences" in controller,
            "shared Host settings are not reloaded when keyboard reappears")

    require("dictionary: luna_pinyin" in pinyin26 and "dictionary: luna_pinyin" in pinyin9,
            "pinyin schemas must retain traditional source forms for a real 简/繁 toggle")
    require("opencc_config: t2s.json" in pinyin26 and "opencc_config: t2s.json" in pinyin9,
            "pinyin schemas must use the public OpenCC simplified filter")
    require("enable_user_dict: true" in pinyin26 and "enable_user_dict: true" in pinyin9,
            "pinyin user dictionary learning must stay enabled")
    require("schema_id: claw_double_pinyin_sogou" in sogou and "dictionary: luna_pinyin" in sogou,
            "Sogou double-pinyin must stay clean-room and use the pinned public dictionary")
    for token in ("schema_id: claw_wubi98", "dictionary: claw_wubi98", "opencc_config: s2t.json", "option_name: zh_trad"):
        require(token in wubi98, f"Wubi98 schema missing: {token}")
    for token in ("derive/^zh/z/", "derive/^n/l/", "derive/^f/h/", "derive/an$/ang/", "derive/en$/eng/", "derive/in$/ing/"):
        require(token in generator, f"fuzzy schema generator missing rule: {token}")

    for name in (
        "luna_pinyin.dict.yaml",
        "claw_pinyin26_fuzzy_zhz.schema.yaml", "claw_pinyin26_fuzzy_ln.schema.yaml", "claw_pinyin26_fuzzy_all.schema.yaml",
        "double_pinyin.schema.yaml", "double_pinyin_flypy.schema.yaml", "double_pinyin_mspy.schema.yaml",
        "claw_double_pinyin_sogou.schema.yaml",
        "wubi86.schema.yaml", "wubi86.dict.yaml", "claw_wubi98.schema.yaml", "claw_wubi98.dict.yaml",
        "stroke.schema.yaml", "stroke.dict.yaml",
    ):
        require(name in prepare, f"CI does not require Phase 3 Rime resource: {name}")
    for token in (
        'WUBI98_TABLE_BLOB="8500e3b9c5d09a7eef29708693d41bfc70ce2e7c"',
        'WUBI98_TABLE_BYTES="1988020"',
        'wubi98-license=Unlicense-public-domain',
    ):
        require(token in prepare, f"Wubi98 reproducibility contract missing: {token}")

    # Do not overstate librime segmentation capability. The pinned C API exposes preedit,
    # length/cursor/selection metadata but no explicit internal segment array.
    require("does not expose explicit internal segmentation boundaries" in segmentation,
            "segmentation capability boundary must stay explicit")
    require("compositionLength" in bridge_h and "cursorPosition" in bridge_h,
            "real composition metadata bridge missing")

    # Matrix must include explicit 86/98 Wubi stimuli while never fabricating reference output.
    require('"behavior-021"' in blackbox and '"set_wubi86"' in blackbox,
            "explicit Wubi86 black-box stimulus missing")
    require('"behavior-022"' in blackbox and '"set_wubi98"' in blackbox,
            "explicit Wubi98 black-box stimulus missing")
    require("Reference observations are a separate real-device capture artifact" in blackbox,
            "black-box matrix must keep WeChat observations external/fail-closed")

    print("Phase 3 functional completion gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 functional completion gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
