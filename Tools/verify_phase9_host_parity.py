#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
catalog = (ROOT / "Sources/WeTypeReplicaCore/HostAppSurfaceCatalog.swift").read_text(encoding="utf-8")
home = (ROOT / "iOSApp/WTHostHome353View.swift").read_text(encoding="utf-8")
scene = (ROOT / "ClawBase/Host/SceneDelegate.swift").read_text(encoding="utf-8")

expected = [
    "布局和显示", "按键效果", "定制工具栏", "辅助输入", "跨设备粘贴传送",
    "剪贴板", "键盘管理", "语音转文字", "拼写 Plus", "单机模式",
    "隐私与权限", "电脑版", "关于", "帮助与反馈",
]
positions = [catalog.find(f'title: "{title}"') for title in expected]
assert all(p >= 0 for p in positions), f"Phase14 Host home missing title: {expected!r}"
assert positions == sorted(positions), "Phase14 Host home card order drifted"
assert "WTHostHome353View()" in scene, "shipping Host root is not Phase14 home"
assert (
    'sectionTitle("设置")' in home and 'sectionTitle("更多")' in home
), "shipping Host home lost observed section structure"
assert (
    "featureCard" in home and "灵动表达" in home
), "shipping Host home lost observed leading feature card"
assert "cardGrid(WTHostHomeCatalog353.cards)" in home, "shipping Host home is not catalog-driven"
print("Phase 9 Host observed-home contract: PASS (10 settings + 4 more cards)")
