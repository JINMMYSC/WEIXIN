#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

def text(rel):
    p = ROOT / rel
    if not p.exists():
        errors.append(f"missing {rel}")
        return ""
    return p.read_text(encoding="utf-8", errors="replace")

project = text("ClawBase/project.yml")
scene = text("ClawBase/Host/SceneDelegate.swift")
home = text("iOSApp/WTHostHome353View.swift")
display = text("iOSApp/WTDisplaySettings353View.swift")

for source in ("../iOSApp/WTHostHome353View.swift", "../iOSApp/WTDisplaySettings353View.swift"):
    if source not in project: errors.append(f"shipping Host missing source {source}")
if "UIHostingController(rootView: WTHostHome353View())" not in scene:
    errors.append("shipping SceneDelegate is not rooted at Phase14 Host home")
for token in ("灵动表达", "sectionTitle(\"设置\")", "cardGrid(WTHostHomeCatalog353.cards)"):
    if token not in home: errors.append(f"Host home missing {token}")
for token in ("键盘上显示表情键", "九宫格 - 上滑输入数字", "键盘高度调节"):
    if token not in display: errors.append(f"display settings missing {token}")

if errors:
    print("PHASE14 SHIPPING SURFACE FAIL")
    for error in errors: print("-", error)
    sys.exit(1)
print("PHASE14 SHIPPING SURFACE PASS")
