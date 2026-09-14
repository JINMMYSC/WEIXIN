#!/usr/bin/env python3
"""Phase 1–7 automated release gate for the ClawBase signed Host+Keyboard package.

This gate intentionally distinguishes machine-verifiable release contracts from evidence
that requires a real iPhone / WeChat IME 3.5.3 reference capture. Pending device evidence
is reported as PENDING, never converted into a synthetic pass/failure.
"""
from __future__ import annotations

import json
import plistlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOG_DIR = ROOT / "artifacts" / "claw-base" / "logs"
REPORT = LOG_DIR / "phase1-7-release-gate.json"

failures: list[str] = []
passes: list[str] = []
pending: list[str] = []


def read(rel: str) -> str:
    path = ROOT / rel
    if not path.is_file():
        failures.append(f"missing required file: {rel}")
        return ""
    return path.read_text(encoding="utf-8")


def require(name: str, condition: bool, detail: str = "") -> None:
    if condition:
        passes.append(name)
    else:
        failures.append(f"{name}{': ' + detail if detail else ''}")


def require_contains(name: str, text: str, *needles: str) -> None:
    missing = [needle for needle in needles if needle not in text]
    require(name, not missing, f"missing {missing}")


project = read("ClawBase/project.yml")
host_ent = read("ClawBase/Host/Host.entitlements")
keyboard_ent = read("ClawBase/Keyboard/Keyboard.entitlements")
keyboard_plist_text = read("ClawBase/Keyboard/Info.plist")
host_scene = read("ClawBase/Host/SceneDelegate.swift")
keyboard_controller = read("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")
shared_store = read("iOSServices/WTSharedStoreFactory.swift")
shared_prefs = read("Sources/WeTypeReplicaCore/SharedPreferences.swift")
persistence = read("Sources/WeTypeReplicaCore/KeyboardSessionPersistence.swift")
memory_policy = read("Sources/WeTypeReplicaCore/MemoryPressurePolicy.swift")
service_mailbox = read("Sources/WeTypeReplicaCore/ServiceMailbox.swift")
visual_manifest = read("Sources/WeTypeReplicaCore/VisualParityManifest.swift")
dep_script = read("ClawBase/ci_prepare_librimekit.sh")
sign_script = read("ClawBase/ci_sign_and_validate.sh")

# Phase 1 — installation/signing structure regression.
require_contains(
    "phase1 identity/version contract",
    project,
    "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517",
    "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.123",
    "WT_APP_GROUP_ID: group.7518554",
    "MARKETING_VERSION: 3.0.1",
    "CURRENT_PROJECT_VERSION: 2",
)
require_contains(
    "phase1 dual App Group entitlements",
    host_ent + keyboard_ent,
    "com.apple.security.application-groups",
    "group.7518554",
)
try:
    kp = plistlib.loads(keyboard_plist_text.encode("utf-8"))
    ext = kp["NSExtension"]
    attrs = ext["NSExtensionAttributes"]
    require("phase1 keyboard extension point", ext.get("NSExtensionPointIdentifier") == "com.apple.keyboard-service")
    require("phase1 keyboard principal", ext.get("NSExtensionPrincipalClass") == "$(PRODUCT_MODULE_NAME).HamsterKeyboardInputViewController")
    require("phase1 primary language", attrs.get("PrimaryLanguage") == "zh-Hans")
    require("phase1 open access", attrs.get("RequestsOpenAccess") is True)
except Exception as exc:
    failures.append(f"phase1 parse Keyboard Info.plist: {exc}")
require_contains(
    "phase1 signed IPA validator contract",
    sign_script,
    "HamsterKeyboard.appex",
    "codesign",
    "embedded.mobileprovision",
    "ClawBase-3.0.1-2-signed.ipa",
)

# Phase 2/4 — preserve existing shell/panel regression gates rather than reimplement them here.
require("phase2 79-case structural verifier present", (ROOT / "Tools/verify_ui_79_alignment.py").is_file())
require("phase4 panel verifier present", (ROOT / "Tools/verify_phase4_completion.py").is_file())

# Phase 3 — real librime and pinned dependency integrity.
require_contains(
    "phase3 release uses real librime",
    keyboard_controller,
    "#if DEBUG",
    "return WTPhase3AdapterSmokeSession()",
    "#else",
    "return WTLibrimeRimeSession()",
)
commit_pins = re.findall(r'^[A-Z0-9_]+_COMMIT="([0-9a-f]{40})"$', dep_script, re.MULTILINE)
require("phase3 dependencies pinned to exact commits", len(commit_pins) >= 8, f"found {len(commit_pins)} commit pins")
require_contains(
    "phase3 framework archive integrity pin",
    dep_script,
    'FRAMEWORKS_SHA256="',
    "checkout_exact",
    '[[ "$actual" == "$commit" ]]',
)

# Phase 5 — Host/App Group/extension convergence.
require_contains(
    "phase5 Host route and service mailbox",
    host_scene,
    'private static let appGroupID = "group.7518554"',
    'url.scheme?.lowercased() == "wtreplica"',
    'case "voice"',
    'case "quick-send"',
    'case "picture"',
    "WTJSONServiceMailbox",
)
require_contains(
    "phase5 Keyboard shared settings lifecycle",
    keyboard_controller,
    'private static let appGroupID = "group.7518554"',
    "UserDefaults(suiteName: Self.appGroupID)",
    "serviceBinder?.reloadSharedSettings()",
    "applyStoredPhase3Settings()",
    "serviceBinder?.persistSessionState()",
    "consumeServiceResponses()",
)
require_contains(
    "phase5 App Group stores",
    shared_store,
    "containerURL(forSecurityApplicationGroupIdentifier:",
    "WeTypeReplica/clipboard.json",
    "WeTypeReplica/emoji-recent.json",
    "WeTypeReplica/phrases.json",
    "WeTypeReplica/service-mailbox.json",
    "WeTypeReplica/provider-config.json",
)
require_contains(
    "phase5 shared preferences surface",
    shared_prefs,
    "clipboardEnabled",
    "cloudEnabled",
    "voiceEnabled",
    "toolbarEnabled",
    "oneHandedMode",
)
require("phase5 keyboard session persistence present", bool(persistence.strip()))
require("phase5 service mailbox present", bool(service_mailbox.strip()))
require_contains(
    "phase5 Host-only APIs excluded from Keyboard target",
    project,
    "APPLICATION_EXTENSION_API_ONLY: YES",
    "WTHostSpeechRecognitionService.swift",
    "WTVoiceLiveActivityController.swift",
)
# Make sure the ActivityKit controller is a Host source but not a direct Keyboard source entry.
host_section, _, keyboard_section = project.partition("  HamsterKeyboard:")
require("phase5 ActivityKit controller owned by Host", "../iOSServices/WTVoiceLiveActivityController.swift" in host_section)
require(
    "phase5 ActivityKit controller not directly compiled as Keyboard source",
    "- path: ../iOSServices/WTVoiceLiveActivityController.swift" not in keyboard_section,
)

# Widget / Live Activity source exists, but current ClawBase signed product has only Host+Keyboard profiles.
widget_sources = [
    ROOT / "iOSExtensions/WTWidgetBundle.swift",
    ROOT / "iOSExtensions/WTVoiceLiveActivityWidget.swift",
    ROOT / "iOSShared/WTVoiceActivityAttributes.swift",
]
require("phase5 Widget/Live Activity source set present", all(p.is_file() for p in widget_sources))
if "type: app-extension" not in keyboard_section.replace("HamsterKeyboard", "", 1):
    pending.append("phase5 Widget/Live Activity are not independent targets in the current ClawBase signed Host+Keyboard package; additional target/profile evidence is required before claiming device-complete extension coverage")
else:
    pending.append("phase5 Widget/Live Activity device registration/launch still requires real-device evidence")

# Phase 6 — automated parity contracts. Pixel/behavior identity still needs real-device captures.
require("phase6 visual parity manifest present", bool(visual_manifest.strip()))
require("phase6 extracted style verifier present", (ROOT / "Tools/verify_ui_style_tokens.py").is_file())
require("phase6 runtime geometry verifier present", (ROOT / "Tools/verify_phase3_device_ui_contract.py").is_file())
obs_path = ROOT / "ClawBase/Phase3BlackBox/observations.json"
try:
    observations = json.loads(obs_path.read_text(encoding="utf-8")).get("observations", [])
except Exception as exc:
    observations = []
    failures.append(f"phase6 reference observation file parse: {exc}")
if observations:
    passes.append(f"phase6 reference observations present ({len(observations)})")
else:
    pending.append("phase3/6 WeChat IME 3.5.3 reference observations pending; candidate order/commit parity and pixel-level identity are not machine-verified")
pending.append("phase6 same-device portrait/landscape, light/dark, panels, gestures, animation and pixel-diff evidence requires real iPhone captures")

# Phase 7 — release/stability contracts that are automatable in CI.
require_contains(
    "phase7 memory pressure handling",
    keyboard_controller,
    "didReceiveMemoryWarning",
    "persistSessionState()",
    "syncUserData()",
    "releaseTransientCaches()",
)
require("phase7 memory pressure policy present", bool(memory_policy.strip()))
require("phase7 core regression test target present", (ROOT / "Tests/WeTypeReplicaCoreTests").is_dir())
require("phase7 deterministic XcodeGen source present", (ROOT / "ClawBase/project.yml").is_file())
require("phase7 pinned dependency builder present", (ROOT / "ClawBase/ci_prepare_librimekit.sh").is_file())
pending.append("phase7 real-device repeated keyboard switching, Host launch, extension load, rotation, OS memory kill/relaunch and crash-free soak require device execution evidence")

LOG_DIR.mkdir(parents=True, exist_ok=True)
report = {
    "gate": "phase1-7-automated-release",
    "automated_pass_count": len(passes),
    "automated_fail_count": len(failures),
    "pending_device_evidence_count": len(pending),
    "passes": passes,
    "failures": failures,
    "pending_device_evidence": pending,
    "claim": "Automated release gate only; not a claim of 100% visual/behavioral identity.",
}
REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

print(f"Phase 1–7 automated release gate: {len(passes)} pass, {len(failures)} fail, {len(pending)} pending device evidence")
for item in pending:
    print(f"PENDING: {item}")
for item in failures:
    print(f"FAIL: {item}")
print(f"Report: {REPORT.relative_to(ROOT)}")
raise SystemExit(1 if failures else 0)
