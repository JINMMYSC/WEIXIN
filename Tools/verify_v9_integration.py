#!/usr/bin/env python3
from pathlib import Path
import json, re, sys
root=Path(__file__).resolve().parents[1]
errors=[]
# No system symbol placeholders in shipping UI.
for folder in ['iOSShared','iOSOverlay','iOSApp','iOSExtensions']:
    for p in (root/folder).glob('*.swift'):
        t=p.read_text(errors='ignore')
        if re.search(r'Image\s*\(\s*systemName\s*:', t) or 'systemImage:' in t:
            errors.append(f'SF Symbol placeholder remains: {p.relative_to(root)}')
# Corpus scope.
corpus=json.loads((root/'ReverseEngineering/V9/IME_BEHAVIOR_CORPUS.json').read_text(encoding='utf-8'))
if len(corpus.get('probes',[])) < 100: errors.append('IME corpus has fewer than 100 probes')
cats={p.get('category') for p in corpus.get('probes',[])}
needed={'t9','shuangpin','wubi','stroke','learning','correction'}
if not needed <= cats: errors.append(f'IME corpus missing categories {sorted(needed-cats)}')
# Visual capture scope.
visual=json.loads((root/'ReverseEngineering/V9/VISUAL_CAPTURE_MANIFEST.json').read_text(encoding='utf-8'))
if len(visual.get('cases',[])) < 50: errors.append('visual manifest has fewer than 50 cases')
# Xcode shared source.
yml=(root/'XcodeIntegration/project.yml').read_text(encoding='utf-8')
if yml.count('../iOSShared') < 4: errors.append('iOSShared not included in all 4 targets')
if errors:
    print('\n'.join('ERROR: '+e for e in errors)); sys.exit(1)
print(f"V9 integration OK; probes={len(corpus['probes'])}; visual_cases={len(visual['cases'])}; SF placeholders=0")
