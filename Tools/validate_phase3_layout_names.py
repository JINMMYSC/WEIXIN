#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
generated = (ROOT / "Sources/WeTypeReplicaCore/GeneratedLayoutsV3.swift").read_text(encoding="utf-8")
surface = (ROOT / "ClawBase/Keyboard/WTPhase3KeyboardSurface.swift").read_text(encoding="utf-8")

available = set(re.findall(r"public static let\s+(\w+)\s*=\s*WTKeyboardLayout", generated))
referenced = set(re.findall(r"WTLayouts353Resolved\.(\w+)", surface))
missing = sorted(referenced - available)
if missing:
    raise SystemExit("Phase 3 surface references missing generated layouts: " + ", ".join(missing))
print("Phase 3 extracted layout-name gate: PASS")
