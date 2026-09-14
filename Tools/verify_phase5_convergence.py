#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
APP_GROUP = "group.7518554"


def text(path: str) -> str:
    p = ROOT / path
    if not p.exists():
        raise AssertionError(f"missing required file: {path}")
    return p.read_text(encoding="utf-8")


def require(haystack: str, needle: str, label: str) -> None:
    if needle not in haystack:
        raise AssertionError(f"{label}: missing {needle!r}")


def main() -> int:
    runtime = text("Sources/WeTypeReplicaCore/WTPhase5SharedRuntime.swift")
    scene = text("ClawBase/Host/SceneDelegate.swift")
    keyboard = text("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")
    host_ent = text("ClawBase/Host/Host.entitlements")
    keyboard_ent = text("ClawBase/Keyboard/Keyboard.entitlements")
    project = text("ClawBase/project.yml")

    for token in [
        f'public static let appGroupIdentifier = "{APP_GROUP}"',
        'case host', 'case keyboard', 'markActive(', 'markBackground(',
        'noteMemoryWarning(', 'pruneTransientFiles(', 'Phase4Handoff',
    ]:
        require(runtime, token, "Phase 5 shared runtime")

    for token in [
        'WTPhase5SharedRuntime.appGroupIdentifier',
        'WTPhase5SharedRuntime.markActive(.host)',
        'WTPhase5SharedRuntime.markBackground(.host)',
        'WTPhase5SharedRuntime.pruneTransientFiles()',
        'WTPhase5SharedRuntime.containerURL()',
    ]:
        require(scene, token, "Host lifecycle")

    for token in [
        'WTPhase5SharedRuntime.appGroupIdentifier',
        'WTPhase5SharedRuntime.markActive(.keyboard)',
        'WTPhase5SharedRuntime.markBackground(.keyboard)',
        'WTPhase5SharedRuntime.noteMemoryWarning()',
        'runtime?.releaseTransientCaches()',
        'phase3Engine.syncUserData()',
    ]:
        require(keyboard, token, "Keyboard lifecycle")

    require(host_ent, APP_GROUP, "Host entitlements")
    require(keyboard_ent, APP_GROUP, "Keyboard entitlements")
    require(project, 'WT_APP_GROUP_ID: group.7518554', "XcodeGen App Group")
    require(project, 'WTVoiceLiveActivityController.swift', "Host Live Activity source")
    require(project, 'WTHostSpeechRecognitionService.swift', "Host speech source")
    require(project, 'excludes:', "Keyboard host-only source exclusion")

    expected_extension_sources = {
        "WTControlCenterButtons.swift",
        "WTKeyboardInputViewController.swift",
        "WTQuickSendShareView.swift",
        "WTQuickSendShareViewController.swift",
        "WTVoiceLiveActivityWidget.swift",
        "WTVoiceWidgetView.swift",
        "WTWidgetBundle.swift",
    }
    extension_dir = ROOT / "iOSExtensions"
    present = {p.name for p in extension_dir.glob("*.swift")}
    missing = sorted(expected_extension_sources - present)
    if missing:
        raise AssertionError(f"system-extension source inventory incomplete: {missing}")

    # The current release signing contract deliberately embeds one extension (the keyboard).
    # Widget/Share sources are audited here but are not silently added without their own profiles.
    sign_script = text("ClawBase/ci_sign_and_validate.sh")
    require(sign_script, 'embedded extension count', "signed release extension contract")
    require(sign_script, '"1"', "signed release extension count")

    print("Phase 5 convergence contract: PASS")
    print(f"Shared App Group: {APP_GROUP}")
    print("Host/Keyboard lifecycle + memory-pressure hooks: PASS")
    print("System-extension source inventory: PASS")
    print("Packaging scope: Host + Keyboard only until additional extension provisioning profiles are supplied")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"Phase 5 convergence contract: FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
