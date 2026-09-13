#!/usr/bin/env python3
from pathlib import Path
import json, re, sys
root = Path(__file__).resolve().parents[1]
required = [
    'Sources/WeTypeReplicaCore/ReturnKeyPresentation.swift',
    'Sources/WeTypeReplicaCore/TransferPairing.swift',
    'Sources/WeTypeReplicaCore/TransferProtocol.swift',
    'Sources/WeTypeReplicaCore/IMEBehaviorParity.swift',
    'iOSOverlay/WTThemeColor353.swift',
    'iOSOverlay/WTCleanRoomIconView.swift',
    'iOSOverlay/WTBasicGlyphView.swift',
    'iOSServices/WTBonjourTransferService.swift',
    'Tools/measure_visual_diff.py',
    'ReverseEngineering/V8/WBColor353.json',
    'ReverseEngineering/V8/TRANSFER_FINDINGS.md',
    'ReverseEngineering/V8/RETURN_KEY_FINDINGS.md',
    'ReverseEngineering/V8/UI_PARITY_DELTA.md',
    'ReverseEngineering/V8/IME_BEHAVIOR_CORPUS.json',
    'ReverseEngineering/V8/IME_BEHAVIOR_PARITY.md',
    'ReverseEngineering/V8/HAMSTER_PUBLIC_REVISION_NOTE.md',
    'ReverseEngineering/V8/diff_selftest/metrics.json',
]
missing = [x for x in required if not (root / x).exists()]
if missing:
    print('missing:', missing); sys.exit(1)
metrics = json.loads((root/'ReverseEngineering/V8/diff_selftest/metrics.json').read_text())
assert metrics['mae_0_255'] == 0
assert metrics['exact_pixel_fraction'] == 1.0
system_symbols = 0
for f in (root/'iOSOverlay').glob('*.swift'):
    system_symbols += len(re.findall(r'Image\(systemName:', f.read_text()))
assert system_symbols <= 36, system_symbols
palette = json.loads((root/'ReverseEngineering/V8/WBColor353.json').read_text())
assert palette
corpus = json.loads((root/'ReverseEngineering/V8/IME_BEHAVIOR_CORPUS.json').read_text())
assert len(corpus['probes']) >= 30
print(f'V8 integration OK; remaining iOSOverlay SF Symbol usages={system_symbols}; diff self-test exact=1.0')
