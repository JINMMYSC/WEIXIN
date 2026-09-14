#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / "iOSApp/WTHostSettings353View.swift").read_text(encoding="utf-8")
scene = (ROOT / "ClawBase/Host/SceneDelegate.swift").read_text(encoding="utf-8")

expected = [
    ("icon_app_setup_keyboard", "键盘管理"),
    ("icon_layout", "显示设置"),
    ("icon_app_setup_customize_toolbar", "工具栏设置"),
    ("icon_app_setup_vibration", "按键效果"),
    ("icon_clipboard", "剪贴板"),
    ("icon_app_setup_voice", "语音输入"),
    ("icon_app_setup_pluslogo", "微信输入法+"),
    ("icon_app_setup_air", "隔空传送"),
    ("icon_app_setup_multiple_devices", "多设备"),
    ("icon_app_setup_computer", "电脑端"),
    ("icon_setup_migration", "迁移助手"),
    ("icon_app_setup_privacy", "隐私"),
    ("icon_app_setup_help", "帮助与反馈"),
    ("icon_app_setup_about", "关于微信输入法"),
]
found = re.findall(r'assetFamily:\s*"([^"]+)",\s*title:\s*"([^"]+)"', source)
assert found == expected, f"SetupMain order mismatch: expected={expected!r}, found={found!r}"
assert "WTHostSettings353View()" in scene, "Host root is not the 3.5.3 SetupMain renderer"
assert "featureBannerStrip" not in source, "observed 3.5.3 root must not contain replica-invented feature banners"
assert 'screen: "SetupMain"' in source and "WTHostSetupGeometry353.geometry" in source, "measured SetupMain icon geometry is not used"
print("Phase 9 Host SetupMain observed-order contract: PASS (14/14 entries)")
