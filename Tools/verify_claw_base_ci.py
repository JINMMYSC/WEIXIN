from pathlib import Path
import plistlib
import sys

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "ClawBase" / "project.yml"
HOST_PLIST = ROOT / "ClawBase" / "Host" / "Info.plist"
HOST_ENTITLEMENTS = ROOT / "ClawBase" / "Host" / "Host.entitlements"
KEYBOARD_PLIST = ROOT / "ClawBase" / "Keyboard" / "Info.plist"
KEYBOARD_ENTITLEMENTS = ROOT / "ClawBase" / "Keyboard" / "Keyboard.entitlements"
BUILD_SCRIPT = ROOT / "ClawBase" / "ci_build_unsigned.sh"
SIGN_SCRIPT = ROOT / "ClawBase" / "ci_sign_and_validate.sh"
WORKFLOW = ROOT / ".github" / "workflows" / "ios-claw-base-signed-ci.yml"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def load_plist(path: Path) -> dict:
    with path.open("rb") as handle:
        return plistlib.load(handle)


def main() -> int:
    required = [
        PROJECT,
        ROOT / "ClawBase" / "Host" / "AppDelegate.swift",
        ROOT / "ClawBase" / "Host" / "SceneDelegate.swift",
        HOST_PLIST,
        HOST_ENTITLEMENTS,
        ROOT / "ClawBase" / "Keyboard" / "HamsterKeyboardInputViewController.swift",
        ROOT / "ClawBase" / "Keyboard" / "WTPhase2KeyboardRootView.swift",
        KEYBOARD_PLIST,
        KEYBOARD_ENTITLEMENTS,
        BUILD_SCRIPT,
        SIGN_SCRIPT,
        WORKFLOW,
    ]
    for path in required:
        require(path.is_file(), f"missing required ClawBase file: {path.relative_to(ROOT)}")

    project = PROJECT.read_text(encoding="utf-8")
    controller = (ROOT / "ClawBase" / "Keyboard" / "HamsterKeyboardInputViewController.swift").read_text(encoding="utf-8")
    phase2_root = (ROOT / "ClawBase" / "Keyboard" / "WTPhase2KeyboardRootView.swift").read_text(encoding="utf-8")
    build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
    sign_script = SIGN_SCRIPT.read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")

    # Phase 1 installability identity remains frozen while Phase 2 changes only Keyboard UI sources.
    require("MARKETING_VERSION: 3.0.1" in project, "ClawBase marketing version must stay 3.0.1")
    require("CURRENT_PROJECT_VERSION: 2" in project, "ClawBase build must stay 2")
    require("PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517\n" in project, "Host bundle ID missing")
    require("PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.123\n" in project, "Keyboard bundle ID missing")
    require("WT_APP_GROUP_ID: group.7518554" in project, "App Group build setting missing")
    require("GENERATE_INFOPLIST_FILE: NO" in project, "checked-in plist must not be replaced")
    require("ClawBaseHost:" in project and "HamsterKeyboard:" in project, "expected two-target ClawBase project")
    require(project.count("type: application") == 1, "ClawBase must contain one Host app target")
    require(project.count("type: app-extension") == 1, "ClawBase must contain one Keyboard extension target")

    # Phase 2 slice 1: V14 shell + candidate bar + measured T26 layout, Preview Engine only.
    expected_phase2_sources = (
        "Keyboard/WTPhase2KeyboardRootView.swift",
        "../Sources/WeTypeReplicaCore",
        "../iOSShared/WTSemanticGlyph.swift",
        "../iOSOverlay/WTKeyboardRuntime.swift",
        "../iOSOverlay/WTKeyboardCanvasView.swift",
        "../iOSOverlay/WTCandidateBar.swift",
        "../iOSOverlay/WTThemeColor353.swift",
        "../iOSOverlay/WTChrome.swift",
        "../iOSOverlay/WTBasicGlyphView.swift",
    )
    for source in expected_phase2_sources:
        require(source in project, f"Phase 2 slice source missing: {source}")

    forbidden_premature_sources = (
        "iOSServices",
        "HamsterBridge",
        "WTKeyboardInputViewController.swift",
        "WTPanelRootView.swift",
        "iOSApp",
    )
    for forbidden in forbidden_premature_sources:
        require(forbidden not in project, f"later-phase dependency leaked into Phase 2 slice 1: {forbidden}")

    require("WTPreviewIMEEngine()" in controller, "Phase 2 slice must use deterministic Preview Engine")
    require("UIHostingController<WTPhase2KeyboardRootView>" in controller, "Phase 2 root hosting controller missing")
    require("advanceToNextInputMode()" in controller, "next-keyboard action must remain wired")
    require("WTLayouts353Resolved.t26Pinyin" in phase2_root, "measured V14 T26 layout missing")
    require("WTCandidateBar(runtime: runtime)" in phase2_root, "V14 candidate bar missing")
    require("WTKeyboardCanvasView" in phase2_root, "V14 keyboard canvas missing")

    host_plist = load_plist(HOST_PLIST)
    keyboard_plist = load_plist(KEYBOARD_PLIST)
    host_entitlements = load_plist(HOST_ENTITLEMENTS)
    keyboard_entitlements = load_plist(KEYBOARD_ENTITLEMENTS)

    for plist, label, package_type in (
        (host_plist, "Host", "APPL"),
        (keyboard_plist, "Keyboard", "XPC!"),
    ):
        require(plist.get("CFBundleExecutable") == "$(EXECUTABLE_NAME)", f"{label} executable metadata missing")
        require(plist.get("CFBundleIdentifier") == "$(PRODUCT_BUNDLE_IDENTIFIER)", f"{label} identifier metadata missing")
        require(plist.get("CFBundlePackageType") == package_type, f"{label} package type mismatch")
        require(plist.get("CFBundleShortVersionString") == "$(MARKETING_VERSION)", f"{label} version metadata missing")
        require(plist.get("CFBundleVersion") == "$(CURRENT_PROJECT_VERSION)", f"{label} build metadata missing")

    extension = keyboard_plist.get("NSExtension", {})
    attributes = extension.get("NSExtensionAttributes", {})
    require(extension.get("NSExtensionPointIdentifier") == "com.apple.keyboard-service", "Keyboard extension point mismatch")
    require(
        extension.get("NSExtensionPrincipalClass") == "$(PRODUCT_MODULE_NAME).HamsterKeyboardInputViewController",
        "Keyboard principal class mismatch",
    )
    require(attributes.get("PrimaryLanguage") == "zh-Hans", "Keyboard primary language mismatch")
    require(attributes.get("RequestsOpenAccess") is True, "Keyboard RequestsOpenAccess must be true")
    require(attributes.get("IsASCIICapable") is True, "Keyboard IsASCIICapable must be true")
    require(attributes.get("PrefersRightToLeft") is False, "Keyboard PrefersRightToLeft must be false")

    expected_groups = ["group.7518554"]
    require(host_entitlements.get("com.apple.security.application-groups") == expected_groups, "Host App Group mismatch")
    require(keyboard_entitlements.get("com.apple.security.application-groups") == expected_groups, "Keyboard App Group mismatch")

    for token in (
        "app.lgm.7517",
        "app.lgm.7517.123",
        "3.0.1",
        "EXPECTED_BUILD",
        "com.apple.keyboard-service",
        "HamsterKeyboard.HamsterKeyboardInputViewController",
    ):
        require(token in build_script or token in sign_script, f"runtime validation token missing: {token}")

    require("EXPECTED_VERSION=\"3.0.1\"" in sign_script, "signed version gate missing")
    require("EXPECTED_BUILD=\"2\"" in sign_script, "signed build gate missing")
    require("X5G6AN3DYX.app.lgm.7517" in sign_script, "Host application-identifier gate missing")
    require("X5G6AN3DYX.app.lgm.7517.123" in sign_script, "Keyboard application-identifier gate missing")
    require("group.7518554" in sign_script, "signed App Group gate missing")
    require("# SIGN_KEYBOARD_FIRST" in sign_script, "Keyboard signing marker missing")
    require("# SIGN_HOST_LAST" in sign_script, "Host signing marker missing")
    require(sign_script.index("# SIGN_KEYBOARD_FIRST") < sign_script.index("# SIGN_HOST_LAST"), "Keyboard must be signed first")
    require("build_minimal_entitlements" in sign_script, "minimal entitlement builder missing")
    require("require_minimal_signed_entitlements" in sign_script, "post-sign entitlement gate missing")
    require("/usr/bin/plutil -extract Entitlements" not in sign_script, "must not copy profile entitlements wholesale")
    require("codesign --verify --strict" in sign_script, "Keyboard codesign verification missing")
    require("codesign --verify --deep --strict" in sign_script, "Host codesign verification missing")

    require("push:" in workflow, "ClawBase workflow must run on branch push")
    require("work/v14-clawbase-ui" in workflow, "Phase 2 workflow must run on UI migration branch")
    require("work/v14-signed-device" not in workflow, "Phase 2 branch must not mutate the frozen Phase 1 workflow trigger")
    require("- main" not in workflow, "ClawBase workflow must not run on main")
    require("python3 Tools/verify_claw_base_ci.py" in workflow, "workflow must run ClawBase verifier")
    require("ClawBase/ci_build_unsigned.sh" in workflow, "workflow must run ClawBase unsigned build")
    require("ClawBase/ci_sign_and_validate.sh" in workflow, "workflow must run ClawBase signing")
    require("ClawBase-3.0.1-2-signed.ipa" in workflow, "workflow signed artifact path mismatch")
    for secret in (
        "WT_SIGNING_P12_BASE64",
        "WT_SIGNING_P12_PASSWORD",
        "WT_HOST_PROFILE_BASE64",
        "WT_KEYBOARD_PROFILE_BASE64",
    ):
        require(secret in workflow, f"workflow omits signing secret reference: {secret}")

    print("ClawBase Phase 2 slice 1 CI configuration verifier passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"ClawBase Phase 2 slice 1 verifier failed: {error}", file=sys.stderr)
        raise SystemExit(1)
