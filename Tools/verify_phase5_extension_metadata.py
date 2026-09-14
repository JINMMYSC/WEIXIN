#!/usr/bin/env python3
from pathlib import Path
import json
import plistlib

ROOT = Path(__file__).resolve().parents[1]
XCODE = ROOT / "XcodeIntegration"
CONTRACT = json.loads((ROOT / "ReverseEngineering/Phase7/original-353-contract.json").read_text(encoding="utf-8"))


def load_plist(name: str):
    with (XCODE / "Plists" / name).open("rb") as handle:
        return plistlib.load(handle)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    share = load_plist("Share-Info.plist")
    widget = load_plist("Widget-Info.plist")
    voice = load_plist("VoiceActivity-Info.plist")
    project = (XCODE / "project.yml").read_text(encoding="utf-8")

    original_share = CONTRACT["extensions"]["WXKBShareExtension.appex"]
    share_ext = share["NSExtension"]
    require(share_ext["NSExtensionPointIdentifier"] == original_share["extension_point"], "share extension point mismatch")
    require(share["CFBundleDisplayName"] == original_share["display_name"], "share display name mismatch")
    require(share_ext["NSExtensionAttributes"]["NSExtensionActivationRule"] == original_share["activation_rule"], "share activation rule mismatch")
    require(share.get("NSPhotoLibraryUsageDescription") == "用于读取相册中的照片和视频，以完成隔空传送分享", "share photo usage copy mismatch")
    require(share.get("UIRequiredDeviceCapabilities") == ["arm64"], "share arm64 capability mismatch")

    original_widget = CONTRACT["extensions"]["widgetExtension.appex"]
    widget_ext = widget["NSExtension"]
    require(widget_ext["NSExtensionPointIdentifier"] == original_widget["extension_point"], "widget extension point mismatch")
    require(widget["CFBundleDisplayName"] == original_widget["display_name"], "widget display name mismatch")
    require(widget.get("UIRequiredDeviceCapabilities") == ["arm64"], "widget arm64 capability mismatch")
    require(widget.get("WXKBAppGroupIdentifier") == "$(WT_APP_GROUP_ID)", "widget App Group key mismatch")

    original_voice = CONTRACT["extensions"]["WBVoiceInputWidgetExtension.appex"]
    voice_ext = voice["NSExtension"]
    require(voice_ext["NSExtensionPointIdentifier"] == original_voice["extension_point"], "voice extension point mismatch")
    require(voice["CFBundleDisplayName"] == original_voice["display_name"], "voice display name mismatch")
    require(voice.get("NSSupportsLiveActivities") is True, "voice Live Activity flag missing")
    require(voice.get("UIRequiredDeviceCapabilities") == ["arm64"], "voice arm64 capability mismatch")

    for token in [
        "MARKETING_VERSION: 3.0.1",
        "CURRENT_PROJECT_VERSION: 2",
        'deploymentTarget: "16.0"',
        'deploymentTarget: "16.1"',
        'deploymentTarget: "17.0"',
        "WT_SHARE_BUNDLE_ID",
        "WT_WIDGET_BUNDLE_ID",
        "WT_VOICE_ACTIVITY_BUNDLE_ID",
    ]:
        require(token in project, f"project metadata missing {token}")

    print("PHASE 5 EXTENSION METADATA PARITY: PASS")
    print("Share/Widget/VoiceActivity public metadata and deployment floors match the 3.5.3 contract; bundle identifiers remain replica-owned.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, KeyError, OSError, ValueError) as exc:
        print(f"PHASE 5 EXTENSION METADATA PARITY: FAIL: {exc}")
        raise SystemExit(1)
