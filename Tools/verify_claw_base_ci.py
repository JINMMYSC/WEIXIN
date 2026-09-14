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
ROOT_VIEW = ROOT / "ClawBase" / "Keyboard" / "WTPhase2KeyboardRootView.swift"
PHASE3_SMOKE = ROOT / "ClawBase" / "Keyboard" / "WTPhase3AdapterSmokeSession.swift"
REAL_SESSION = ROOT / "ClawBase" / "Keyboard" / "WTLibrimeRimeSession.swift"
REAL_BRIDGE_M = ROOT / "ClawBase" / "Keyboard" / "WTLibrimeBridge.m"
PIN_SCRIPT = ROOT / "ClawBase" / "ci_prepare_librimekit.sh"
BACKEND_PROFILE = ROOT / "Sources" / "WeTypeReplicaCore" / "InputModeBackendProfile.swift"
ADAPTER = ROOT / "HamsterBridge" / "WTHamsterRimeSessionAdapter.swift"
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
        PROJECT, HOST_PLIST, HOST_ENTITLEMENTS, KEYBOARD_PLIST, KEYBOARD_ENTITLEMENTS,
        CONTROLLER, ROOT_VIEW, PHASE3_SMOKE, REAL_SESSION, REAL_BRIDGE_M,
        PIN_SCRIPT, BACKEND_PROFILE, ADAPTER, BUILD_SCRIPT, SIGN_SCRIPT, WORKFLOW,
        ROOT / "iOSApp" / "WTSettingsAppView.swift",
        ROOT / "iOSOverlay" / "WTPanelRootView.swift",
        ROOT / "iOSServices" / "WTKeyboardServiceBinder.swift",
        ROOT / "ClawBase" / "RimeSchemas" / "claw_pinyin26.schema.yaml",
        ROOT / "ClawBase" / "RimeSchemas" / "claw_pinyin9.schema.yaml",
        ROOT / "ClawBase" / "RimeSchemas" / "claw_wubi98.schema.yaml",
    ]
    for path in required:
        require(path.is_file(), f"missing required file: {path.relative_to(ROOT)}")

    project = PROJECT.read_text(encoding="utf-8")
    controller = CONTROLLER.read_text(encoding="utf-8")
    root_view = ROOT_VIEW.read_text(encoding="utf-8")
    smoke = PHASE3_SMOKE.read_text(encoding="utf-8")
    session = REAL_SESSION.read_text(encoding="utf-8")
    bridge = REAL_BRIDGE_M.read_text(encoding="utf-8")
    pin_script = PIN_SCRIPT.read_text(encoding="utf-8")
    backend_profile = BACKEND_PROFILE.read_text(encoding="utf-8")
    adapter = ADAPTER.read_text(encoding="utf-8")
    build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
    sign_script = SIGN_SCRIPT.read_text(encoding="utf-8")
    workflow = WORKFLOW.read_text(encoding="utf-8")

    # Frozen install identity. Phase 5 adds other app-extension targets, but there must still be
    # exactly one keyboard-service target with the frozen keyboard bundle identity.
    for token in (
        "MARKETING_VERSION: 3.0.1", "CURRENT_PROJECT_VERSION: 2",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517\n",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.123\n",
        "WT_APP_GROUP_ID: group.7518554", "GENERATE_INFOPLIST_FILE: NO",
    ):
        require(token in project, f"install identity drifted: {token}")
    require(project.count("type: application") == 1, "expected exactly one Host target")
    require("HamsterKeyboard:\n    type: app-extension" in project, "Keyboard app-extension target missing")
    require(project.count("PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.123\n") == 1,
            "expected exactly one frozen Keyboard bundle identity")

    # Current Phase 3 source topology. The old slice-only verifier intentionally no longer
    # forbids iOSApp/iOSServices/iOSOverlay: Phase 3 now depends on those migrated modules.
    for source in (
        "Keyboard/HamsterKeyboardInputViewController.swift",
        "Keyboard/WTPhase2KeyboardRootView.swift",
        "Keyboard/WTPhase3KeyboardSurface.swift",
        "Keyboard/WTPhase3AdapterSmokeSession.swift",
        "Keyboard/WTLibrimeRimeSession.swift",
        "Keyboard/WTLibrimeBridge.m",
        "Vendor/RimeSharedSupport",
        "../Sources/WeTypeReplicaCore",
        "../iOSShared", "../iOSOverlay", "../HamsterBridge", "../iOSServices",
        "../iOSApp/WTSettingsAppView.swift",
    ):
        require(source in project, f"Phase 3 source group missing: {source}")
    require("WTPanelRootView(runtime: runtime)" in root_view,
            "stable ClawBase root must route into the complete V14 panel router")

    # Real Release engine, Debug smoke only.
    require("#if DEBUG" in controller and "WTPhase3AdapterSmokeSession()" in controller,
            "Debug smoke session missing")
    require("#else\n        return WTLibrimeRimeSession()" in controller,
            "Release must construct the real librime session")
    require("backendProfile: .phase3PublicLibrime" in controller,
            "Release adapter must use the public Phase 3 backend profile")
    require("WTPreviewIMEEngine()" not in controller, "Release controller must not bypass librime")
    require("WTPhase3AdapterSmokeSession.selfTest()" in controller, "Debug smoke self-test missing")
    require("64426" in smoke and "你好" in smoke, "T9 smoke case missing")
    require("public final class WTHamsterRimeSessionAdapter: WTIMEEngine" in adapter,
            "typed Hamster/librime adapter missing")

    for framework in (
        "librime.xcframework", "boost_atomic.xcframework", "boost_filesystem.xcframework",
        "boost_regex.xcframework", "boost_system.xcframework", "libglog.xcframework",
        "libleveldb.xcframework", "libmarisa.xcframework", "libopencc.xcframework",
        "libyaml-cpp.xcframework",
    ):
        require(framework in project, f"librime link dependency missing: {framework}")
    require("SWIFT_OBJC_BRIDGING_HEADER: Keyboard/WTLibrimeBridge.h" in project,
            "librime bridge header missing")
    require("libc++.tbd" in project and "CoreFoundation.framework" in project,
            "librime system dependencies missing")

    # Real C API input/context/commit chain.
    for token in (
        "RimeCreateSession", "RimeGetContext", "RimeProcessKey", "RimeGetCommit",
        "RimeClearComposition", "rime_get_api", "RimeSyncUserData",
    ):
        require(token in bridge, f"real librime bridge missing: {token}")
    for token in (
        "group.7518554", "bridge.selectSchema", "bridge.setOption", "t9GroupToDigit",
        "wt.script.simplified", "wt.pinyin.blur", "wt.double.scheme", "wt.wubi.scheme",
        "claw_wubi98", "stageFuzzyCustomization", "wtSyncUserData",
    ):
        require(token in session, f"real Phase 3 session missing: {token}")
    require("phase3PublicLibrime" in backend_profile, "public backend profile missing")
    require('schemaID: "claw_pinyin26"' in backend_profile, "full-pinyin mapping missing")
    require('schemaID: "claw_pinyin9"' in backend_profile, "T9 mapping missing")

    # Exact public dependency/provenance pins.
    for token in (
        "d1a4c26aaa6dc2e081f7933ec852fc3732321efa",
        "08dd95f5d9282346f0d4a3e8fc6b20811dc3d063",
        "082425ea0684bca36474415d4a0e8db9b016487e",
        "56b934b099dfbeab842320f13aa8b461a6ab3e42",
        "152a0d3f3efe40cae216d1e3b338242446848d07",
        "6b8b6fb9d3c34e0d5e3b17211e1f1c100e7eb697",
        "8500e3b9c5d09a7eef29708693d41bfc70ce2e7c",
        'WUBI98_TABLE_BYTES="1988020"',
        'FRAMEWORKS_BYTES="24815214"',
    ):
        require(token in pin_script, f"dependency/provenance pin missing: {token}")
    require("generate_wubi98_dict.py" in pin_script and "claw_wubi98.dict.yaml" in pin_script,
            "Wubi98 deterministic resource build missing")
    require("ci_prepare_librimekit.sh" in build_script, "unsigned build must prepare pinned dependencies")

    host_plist = load_plist(HOST_PLIST)
    keyboard_plist = load_plist(KEYBOARD_PLIST)
    host_entitlements = load_plist(HOST_ENTITLEMENTS)
    keyboard_entitlements = load_plist(KEYBOARD_ENTITLEMENTS)
    for plist, label, package_type in (
        (host_plist, "Host", "APPL"), (keyboard_plist, "Keyboard", "XPC!"),
    ):
        require(plist.get("CFBundleExecutable") == "$(EXECUTABLE_NAME)", f"{label} executable metadata missing")
        require(plist.get("CFBundleIdentifier") == "$(PRODUCT_BUNDLE_IDENTIFIER)", f"{label} identifier metadata missing")
        require(plist.get("CFBundlePackageType") == package_type, f"{label} package type mismatch")
        require(plist.get("CFBundleShortVersionString") == "$(MARKETING_VERSION)", f"{label} version metadata missing")
        require(plist.get("CFBundleVersion") == "$(CURRENT_PROJECT_VERSION)", f"{label} build metadata missing")

    extension = keyboard_plist.get("NSExtension", {})
    attrs = extension.get("NSExtensionAttributes", {})
    require(extension.get("NSExtensionPointIdentifier") == "com.apple.keyboard-service", "Keyboard extension point mismatch")
    require(extension.get("NSExtensionPrincipalClass") == "$(PRODUCT_MODULE_NAME).HamsterKeyboardInputViewController", "Keyboard principal mismatch")
    require(attrs.get("PrimaryLanguage") == "zh-Hans", "Keyboard primary language mismatch")
    require(attrs.get("RequestsOpenAccess") is True, "Keyboard RequestsOpenAccess must be true")
    require(host_entitlements.get("com.apple.security.application-groups") == ["group.7518554"], "Host App Group mismatch")
    require(keyboard_entitlements.get("com.apple.security.application-groups") == ["group.7518554"], "Keyboard App Group mismatch")

    # Signing order and final artifact contract.
    for token in (
        'EXPECTED_VERSION="3.0.1"', 'EXPECTED_BUILD="2"',
        "X5G6AN3DYX.app.lgm.7517", "X5G6AN3DYX.app.lgm.7517.123",
        "group.7518554", "build_minimal_entitlements", "require_minimal_signed_entitlements",
        "codesign --verify --strict", "codesign --verify --deep --strict",
    ):
        require(token in sign_script, f"signed validation missing: {token}")
    require(sign_script.index("# SIGN_KEYBOARD_FIRST") < sign_script.index("# SIGN_HOST_LAST"),
            "Keyboard must be signed before Host")
    require("work/v14-clawbase-t9-rime" in workflow, "signed workflow branch mismatch")
    require("work/v14-signed-device" not in workflow, "frozen Phase 1 branch must stay untouched")
    require("ClawBase/ci_build_unsigned.sh" in workflow and "ClawBase/ci_sign_and_validate.sh" in workflow,
            "signed workflow must build then sign")
    require("ClawBase-3.0.1-2-signed.ipa" in workflow, "signed IPA artifact path mismatch")

    print("ClawBase Phase 3 final-candidate verifier passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"ClawBase Phase 3 verifier failed: {error}", file=sys.stderr)
        raise SystemExit(1)
