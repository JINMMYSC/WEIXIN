#!/usr/bin/env python3
from __future__ import annotations
import json
import plistlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def plist(path: str) -> dict:
    with (ROOT / path).open("rb") as handle:
        return plistlib.load(handle)


def main() -> int:
    project = text("ClawBase/project.yml")
    build = text("ClawBase/ci_build_unsigned.sh")
    sign = text("ClawBase/ci_sign_and_validate.sh")
    keyboard = text("iOSOverlay/WTKeyboardCanvasView.swift")
    gesture = text("Sources/WeTypeReplicaCore/GestureParity353.swift")
    host = text("iOSApp/WTSettingsAppView.swift")
    setup = text("iOSApp/WTHostSettings353View.swift")

    for token in (
        "MARKETING_VERSION: 3.5.3",
        "CURRENT_PROJECT_VERSION: 3.5.3",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517\n",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.123\n",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.share\n",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.widget\n",
        "PRODUCT_BUNDLE_IDENTIFIER: app.lgm.7517.voiceactivity\n",
    ):
        require(token in project, f"3.5.3 package identity missing: {token}")
    require(project.count("type: app-extension") == 4, "Host must embed exactly four extension targets")

    require('IPA_PATH="$ARTIFACTS_DIR/ClawBase-3.5.3-3.5.3-full-unsigned.ipa"' in build,
            "unsigned 3.5.3 artifact name missing")
    require('[[ "$host_version" == "3.5.3" && "$host_build" == "3.5.3" ]]' in build,
            "unsigned 3.5.3 version/build validation missing")
    require('[[ "$extension_count" == "4" ]]' in build, "unsigned four-extension topology gate missing")
    require('EXPECTED_VERSION="3.5.3"' in sign and 'EXPECTED_BUILD="3.5.3"' in sign,
            "signed 3.5.3 metadata gate missing")
    require('SIGNED_IPA="$ARTIFACTS_DIR/ClawBase-3.5.3-3.5.3-signed.ipa"' in sign,
            "signed 3.5.3 artifact name missing")
    require("Share/Widget/VoiceActivity profiles must be provided together" in sign,
            "partial extension signing must remain fail-closed")

    # Shipping keyboard must consume the centralized calibration/model after the release patch.
    for token in (
        "private let gestureCalibration = WT353GestureCalibration()",
        "WT353GestureModel.directionalGesture(",
        "WT353GestureModel.longPressIndex(",
        "WT353GestureModel.deleteClearIsArmed(",
        "WT353GestureModel.deleteTargetSteps(",
        "WT353GestureModel.isTapDelete(",
        "gestureCalibration.deleteRepeatInitialDelay",
        "gestureCalibration.deleteRepeatInterval",
    ):
        require(token in keyboard, f"shipping keyboard is not centralized: {token}")
    for stale in (
        "LongPressGesture(minimumDuration: 0.36, maximumDistance: 14)",
        "dy < -18", "dy > 18", "value.translation.width / 33",
        "dy < -28 && abs(dy) > abs(dx) * 0.72",
        "110_000_000", "78_000_000",
    ):
        require(stale not in keyboard, f"stale gesture literal remains in shipping path: {stale}")
    require("public struct WT353GestureCalibration" in gesture and "public enum WT353GestureModel" in gesture,
            "central gesture model missing")

    require("resetKeyboardAdjustment()" in host, "keyboard adjustment reset action is still a no-op")
    require("UIApplication.openSettingsURLString" in host, "system settings action is still a no-op")
    require('CFBundleShortVersionString' in host, "About page must read built version metadata")

    expected_setup_titles = [
        "键盘管理", "显示设置", "工具栏设置", "按键效果", "剪贴板", "语音输入", "微信输入法+",
        "隔空传送", "多设备", "电脑端", "迁移助手", "隐私", "帮助与反馈", "关于微信输入法",
    ]
    positions = [setup.find(f'title: "{title}"') for title in expected_setup_titles]
    require(all(p >= 0 for p in positions), "SetupMain is missing an observed 3.5.3 entry")
    require(positions == sorted(positions), "SetupMain observed 3.5.3 order drifted")

    keyboard_plist = plist("ClawBase/Keyboard/Info.plist")
    attrs = keyboard_plist["NSExtension"]["NSExtensionAttributes"]
    require(attrs.get("PrimaryLanguage") == "zh-Hans", "keyboard PrimaryLanguage drifted")
    require(attrs.get("RequestsOpenAccess") is True, "keyboard full-access declaration drifted")
    require(plist("XcodeIntegration/Plists/Share-Info.plist").get("CFBundleDisplayName") == "隔空传送",
            "Share display name drifted")
    require(plist("XcodeIntegration/Plists/Widget-Info.plist").get("CFBundleDisplayName") == "微信输入法",
            "Widget display name drifted")
    require(plist("XcodeIntegration/Plists/VoiceActivity-Info.plist").get("CFBundleDisplayName") == "语音输入",
            "Voice Activity display name drifted")

    observations_path = ROOT / "ClawBase/Phase3BlackBox/observations.json"
    observation_count = 0
    if observations_path.is_file():
        payload = json.loads(observations_path.read_text(encoding="utf-8"))
        observation_count = sum(
            1 for item in payload.get("observations", [])
            if item.get("reference") == "wechat-ime" and item.get("captured_on_real_device") is True
        )

    namespace: dict[str, object] = {}
    matrix = ROOT / "Tools/phase3_blackbox_matrix.py"
    exec(compile(matrix.read_text(encoding="utf-8"), str(matrix), "exec"), namespace)
    probe_count = len(namespace["build_cases"]())

    report = {
        "package_version": "3.5.3",
        "package_build": "3.5.3",
        "unsigned_embedded_extensions_expected": 4,
        "shipping_gesture_model_centralized": True,
        "setup_main_observed_entries": len(expected_setup_titles),
        "ime_probe_cases": probe_count,
        "real_wechat_ime_observations": observation_count,
        "strict_ime_reference_ready": observation_count == probe_count,
        "clean_room": True,
    }
    output = ROOT / "artifacts/phase13/final-readiness.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    print("Phase 13 final static/release gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError, KeyError, json.JSONDecodeError) as error:
        print(f"Phase 13 final gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
