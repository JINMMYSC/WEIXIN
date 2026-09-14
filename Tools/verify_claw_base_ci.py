from pathlib import Path
import plistlib
import sys

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "ClawBase" / "project.yml"
HOST_PLIST = ROOT / "ClawBase" / "Host" / "Info.plist"
HOST_ENTITLEMENTS = ROOT / "ClawBase" / "Host" / "Host.entitlements"
KEYBOARD_PLIST = ROOT / "ClawBase" / "Keyboard" / "Info.plist"
KEYBOARD_ENTITLEMENTS = ROOT / "ClawBase" / "Keyboard" / "Keyboard.entitlements"
CONTROLLER = ROOT / "ClawBase" / "Keyboard" / "HamsterKeyboardInputViewController.swift"
PHASE2_ROOT = ROOT / "ClawBase" / "Keyboard" / "WTPhase2KeyboardRootView.swift"
PHASE3_SMOKE = ROOT / "ClawBase" / "Keyboard" / "WTPhase3AdapterSmokeSession.swift"
ADAPTER = ROOT / "HamsterBridge" / "WTHamsterRimeSessionAdapter.swift"
ADAPTER_TEMPLATE = ROOT / "HamsterBridge" / "WTHamsterAdapterTemplate.swift"
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
        CONTROLLER,
        PHASE2_ROOT,
        PHASE3_SMOKE,
        ADAPTER,
        ADAPTER_TEMPLATE,
        KEYBOARD_PLIST,
        KEYBOARD_ENTITLEMENTS,
        BUILD_SCRIPT,
        SIGN_SCRIPT,
        WORKFLOW,
    ]
    for path in required:
        require(path.is_file(), f"missing required file: {path.relative_to(ROOT)}")

    project = PROJECT.read_text(encoding="utf-8")
    controller = CONTROLLER.read_text(encoding="utf-8")
    phase2_root = PHASE2_ROOT.read_text(encoding="utf-8")
    phase3_smoke = PHASE3_SMOKE.read_text(encoding="utf-8")
    adapter = ADAPTER.read_text(encoding="utf-8")
    build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
    sign_script = SIGN_SCRIPT.read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")

    # Frozen Phase 1 install identity.
    require("MARKETING_VERSION: 3.0.1" in project, "marketing version must stay 3.0.1")
    require("CURRENT_PROJECT_VERSION: 2" in project, "build must stay 2")
    require("PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517\n" in project, "Host bundle ID missing")
    require("PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.123\n" in project, "Keyboard bundle ID missing")
    require("WT_APP_GROUP_ID: group.7518554" in project, "App Group build setting missing")
    require("GENERATE_INFOPLIST_FILE: NO" in project, "checked-in plists must be preserved")
    require(project.count("type: application") == 1, "expected one Host target")
    require(project.count("type: app-extension") == 1, "expected one Keyboard target")

    # Phase 2 T9 migration plus Phase 3 adapter-smoke path.
    expected_sources = (
        "Keyboard/WTPhase2KeyboardRootView.swift",
        "Keyboard/WTPhase3AdapterSmokeSession.swift",
        "../Sources/WeTypeReplicaCore",
        "../HamsterBridge/WTHamsterRimeSessionAdapter.swift",
        "../HamsterBridge/WTHamsterAdapterTemplate.swift",
        "../iOSOverlay/WTKeyboardRuntime.swift",
        "../iOSOverlay/WTKeyboardCanvasView.swift",
        "../iOSOverlay/WTCandidateBar.swift",
    )
    for source in expected_sources:
        require(source in project, f"T9/Phase 3 source missing: {source}")

    for forbidden in ("iOSServices", "WTKeyboardInputViewController.swift", "WTPanelRootView.swift", "iOSApp"):
        require(forbidden not in project, f"later-phase dependency leaked into T9/Phase 3 slice: {forbidden}")

    require("WTPhase3AdapterSmokeSession()" in controller, "adapter smoke session must own the Phase 3 boundary")
    require("WTHamsterRimeSessionAdapter(session: phase3Session)" in controller, "controller must drive WTIMEEngine through Hamster adapter")
    require("inputMode: initialMode" in controller and ".chinesePinyin9" in controller, "T9 must be the default real-device smoke layout")
    require("WTPhase3AdapterSmokeSession.selfTest()" in controller, "Debug adapter/T9 self-test missing")
    require("WTPreviewIMEEngine()" not in controller, "controller must not bypass the Phase 3 adapter")
    require("WTLayouts353Resolved.t9Pinyin" in phase2_root, "measured V14 T9 layout missing")
    require("WTLayouts353Resolved.t26Pinyin" in phase2_root, "T26 fallback layout missing")
    require("WTLayouts353Resolved.t26En" in phase2_root, "English fallback layout missing")
    require("WTCandidateBar(runtime: runtime)" in phase2_root, "candidate bar missing")
    require("64426" in phase3_smoke and "你好" in phase3_smoke, "T9 nihao smoke case missing")
    require("WTHamsterRimeSessionProtocol" in phase3_smoke, "smoke session must implement Hamster Rime protocol")
    require("public final class WTHamsterRimeSessionAdapter: WTIMEEngine" in adapter, "typed Hamster adapter missing")

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
    require(extension.get("NSExtensionPrincipalClass") == "$(PRODUCT_MODULE_NAME).HamsterKeyboardInputViewController", "Keyboard principal class mismatch")
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
    require(sign_script.index("# SIGN_KEYBOARD_FIRST") < sign_script.index("# SIGN_HOST_LAST"), "Keyboard must be signed first")
    require("build_minimal_entitlements" in sign_script, "minimal entitlement builder missing")
    require("require_minimal_signed_entitlements" in sign_script, "post-sign entitlement gate missing")
    require("codesign --verify --strict" in sign_script, "Keyboard codesign verification missing")
    require("codesign --verify --deep --strict" in sign_script, "Host codesign verification missing")

    require("push:" in workflow, "workflow must run on branch push")
    require("work/v14-clawbase-t9-rime" in workflow, "workflow must run on T9/Rime branch")
    require("work/v14-signed-device" not in workflow, "frozen Phase 1 branch must not be retargeted")
    require("- main" not in workflow, "workflow must not run on main")
    require("python3 Tools/verify_claw_base_ci.py" in workflow, "workflow must run verifier")
    require("ClawBase/ci_build_unsigned.sh" in workflow, "workflow must run unsigned build")
    require("ClawBase/ci_sign_and_validate.sh" in workflow, "workflow must run signing")
    require("ClawBase-3.0.1-2-signed.ipa" in workflow, "signed artifact path mismatch")

    for secret in (
        "WT_SIGNING_P12_BASE64",
        "WT_SIGNING_P12_PASSWORD",
        "WT_HOST_PROFILE_BASE64",
        "WT_KEYBOARD_PROFILE_BASE64",
    ):
        require(secret in workflow, f"workflow omits signing secret reference: {secret}")

    print("ClawBase T9 + Phase 3 adapter-smoke verifier passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"ClawBase T9 + Phase 3 verifier failed: {error}", file=sys.stderr)
        raise SystemExit(1)
