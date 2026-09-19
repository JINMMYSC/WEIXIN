#!/usr/bin/env python3
from pathlib import Path
import json, re, sys
root = Path(__file__).resolve().parents[1]
required = [
    'XcodeIntegration/project.yml',
    'XcodeIntegration/Plists/Keyboard-Info.plist',
    'XcodeIntegration/Entitlements/Keyboard.entitlements',
    'HamsterBridge/WTHamsterRimeSessionAdapter.swift',
    'iOSExtensions/WTKeyboardInputViewController.swift',
    'iOSOverlay/WTBookVideoPanelView.swift',
    'iOSServices/WTVisionHandwritingRecognizer.swift',
]
missing = [p for p in required if not (root/p).exists()]
if missing:
    print('missing:', *missing, sep='\n- '); sys.exit(1)
text=(root/'Sources/WeTypeReplicaCore/SurfaceCatalog.swift').read_text(encoding='utf-8')
for cls in ['WBFinderView','WBTPListView','WBTPPlayerView']:
    if cls not in text: print('surface missing', cls); sys.exit(2)
print('V6 integration structure OK')
