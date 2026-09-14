#!/usr/bin/env python3
"""Fail-closed static contract for Phase 5 Host/system-extension convergence.

This verifies that the final ClawBase XcodeGen project contains the system-extension targets and
that Host, Keyboard and extension storage all converge on group.7518554. It does not claim that
Share/Widget/Live Activity are present in the signed engineering IPA: those targets require their
own provisioning profiles before they may be embedded and signed for device installation.
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    project = text("ClawBase/project.yml")
    controller = text("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")
    runtime = text("iOSOverlay/WTKeyboardRuntime.swift")
    binder = text("iOSServices/WTKeyboardServiceBinder.swift")
    memory = text("Sources/WeTypeReplicaCore/MemoryPressurePolicy.swift")
    settings = text("iOSApp/WTSettingsAppView.swift")
    share_plist = text("XcodeIntegration/Plists/Share-Info.plist")
    widget_plist = text("XcodeIntegration/Plists/Widget-Info.plist")
    activity_plist = text("XcodeIntegration/Plists/VoiceActivity-Info.plist")

    for target, bundle in (
        ("ClawBaseHost:", "app.lgm.7517"),
        ("HamsterKeyboard:", "app.lgm.7517.123"),
        ("ClawBaseShare:", "app.lgm.7517.share"),
        ("ClawBaseWidget:", "app.lgm.7517.widget"),
        ("ClawBaseVoiceActivity:", "app.lgm.7517.voiceactivity"),
    ):
        require(target in project, f"final ClawBase project missing target {target}")
        require(f"PRODUCT_BUNDLE_IDENTIFIER: {bundle}" in project, f"bundle id not fixed for {target}")

    for source in (
        "../iOSExtensions/WTQuickSendShareView.swift",
        "../iOSExtensions/WTQuickSendShareViewController.swift",
        "../iOSExtensions/WTVoiceWidgetView.swift",
        "../iOSExtensions/WTWidgetBundle.swift",
        "../iOSExtensions/WTControlCenterButtons.swift",
        "../iOSExtensions/WTVoiceLiveActivityWidget.swift",
        "../iOSServices/WTBonjourTransferService.swift",
    ):
        require(source in project, f"Phase 5 source not mapped into final project: {source}")

    for path in (
        "ClawBase/Host/Host.entitlements",
        "ClawBase/Keyboard/Keyboard.entitlements",
        "XcodeIntegration/Entitlements/Share.entitlements",
        "XcodeIntegration/Entitlements/Widget.entitlements",
        "XcodeIntegration/Entitlements/VoiceActivity.entitlements",
    ):
        data = text(path)
        require("com.apple.security.application-groups" in data, f"App Group entitlement missing: {path}")
        require("group.7518554" in data or "$(WT_APP_GROUP_ID)" in data,
                f"App Group does not converge on group.7518554: {path}")

    require("com.apple.share-services" in share_plist, "Share extension point missing")
    require("WTQuickSendShareViewController" in share_plist, "Share principal class missing")
    require("com.apple.widgetkit-extension" in widget_plist, "Widget extension point missing")
    require("com.apple.widgetkit-extension" in activity_plist and "NSSupportsLiveActivities" in activity_plist,
            "Voice/Live Activity plist contract missing")

    require("../iOSApp/WTSettingsAppView.swift" in project, "Host settings surface not compiled")
    for token in ("WTAppGroupIdentifier", "UserDefaults(suiteName:"):
        require(token in settings, f"Host settings are not bound to shared defaults: {token}")
    require("appGroupIdentifier" in binder and "UserDefaults(suiteName:" in binder,
            "Keyboard service binder is not App Group bound")

    for token in ("viewWillAppear", "persistSessionState", "didReceiveMemoryWarning", "syncUserData", "releaseTransientCaches"):
        require(token in controller, f"Keyboard lifecycle recovery missing: {token}")
    for token in ("maxVisibleCandidates", "maxClipboardItems", "maxPhrases", "maxRecentEmoji", "trimmedClipboard"):
        require(token in memory, f"memory budget missing: {token}")
    for token in ("releaseTransientCaches", "candidateExpanded = false", "handwritingCandidates.removeAll", "mediaCards.removeAll"):
        require(token in runtime, f"runtime memory-pressure recovery missing: {token}")

    require("CODE_SIGNING_ALLOWED: NO" in project,
            "system-extension compile-only targets must remain unsigned until dedicated profiles are supplied")

    print("Phase 5 Host/system-extension/App Group/memory contract: PASS")
    print("NOTE: Share/Widget/VoiceActivity are final-project compile targets but are intentionally not embedded in the two-profile engineering IPA.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError) as error:
        print(f"Phase 5 contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
