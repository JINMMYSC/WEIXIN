#!/usr/bin/env python3
from pathlib import Path
import re, sys
roots=[Path('iOSShared'),Path('iOSOverlay'),Path('iOSApp'),Path('iOSExtensions')]
patterns=[re.compile(r'Image\s*\(\s*systemName\s*:'),re.compile(r'systemImage\s*:')]
hits=[]
for root in roots:
    for path in root.rglob('*.swift'):
        text=path.read_text(errors='ignore')
        for line_no,line in enumerate(text.splitlines(),1):
            if any(p.search(line) for p in patterns): hits.append((str(path),line_no,line.strip()))
if hits:
    print('SF Symbol placeholder usages remain:')
    for h in hits: print(f'{h[0]}:{h[1]}: {h[2]}')
    sys.exit(1)
print('PASS: no Image(systemName:) or systemImage: placeholders remain in shipping UI sources')
