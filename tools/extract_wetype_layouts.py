#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, os, re, plistlib
from pathlib import Path
from collections import Counter

KEY_FILES = [
    't26_pinyin.ini','t9_pinyin.ini','t9_stroke.ini','t9_number.ini','t9_number_26.ini',
    't26_cn_symbol.ini','t26_en_symbol.ini','full_symbol.ini','full_symbol2.ini',
    'handwriting.ini','t9_inner_hw.ini','style.ini'
]

FEATURE_PATTERNS = {
    'ai': re.compile(r'AI|AskAI|rewrite|textpolish|copywriting', re.I),
    'clipboard': re.compile(r'Clipboard|Pasteboard|quicksend', re.I),
    'emoji': re.compile(r'Emoji|Emotion|Sticker', re.I),
    'handwriting': re.compile(r'Handwrit|HandWrite|drawing', re.I),
    'voice': re.compile(r'Voice|ASR|offlineVoice', re.I),
    'translate': re.compile(r'Translate', re.I),
    'correction': re.compile(r'Correct|Correction|spell', re.I),
    'device_sync_transfer': re.compile(r'DeviceSync|P2P|Transfer|QuickSend', re.I),
    'candidate': re.compile(r'Candidate', re.I),
    'dictionary': re.compile(r'Dict|Hotword|HotWord', re.I),
}

def parse_ini(path: Path):
    sections=[]
    current=None
    for raw in path.read_text(errors='replace').splitlines():
        line=raw.strip()
        if not line or line.startswith(';'):
            continue
        m = re.match(r'^\[([^\]]+)\]', line)
        if m:
            current={'name':m.group(1), 'values':{}}
            sections.append(current)
            continue
        if current is None or '=' not in line:
            continue
        k,v=line.split('=',1)
        current['values'][k.strip()]=v.strip()
    out={'source':path.name, 'sections':sections}
    panel = next((s for s in sections if s['name']=='PANEL'), None)
    if panel and 'BASESIZE' in panel['values']:
        try: out['baseSize']=[float(x) for x in panel['values']['BASESIZE'].split(',')]
        except: pass
    keys=[]
    for s in sections:
        if not s['name'].startswith(('KEY_','VIEW_')): continue
        item={'id':s['name'], **s['values']}
        rect=s['values'].get('RECT')
        if rect:
            try:item['rect']=[float(x) for x in rect.split(',')]
            except: pass
        keys.append(item)
    out['items']=keys
    return out

def feature_strings(strings_text: str):
    lines=[ln for ln in strings_text.splitlines() if ln.strip()]
    result={}
    for name,pat in FEATURE_PATTERNS.items():
        vals=sorted({ln.strip() for ln in lines if pat.search(ln)})
        result[name]=vals[:250]
    # Objective-C style classes visible in symbol/string table
    classes=set()
    for ln in lines:
        for m in re.finditer(r'\b(?:WB|WXKB|KBIME)[A-Z][A-Za-z0-9_]{2,}\b', ln):
            classes.add(m.group(0))
    result['classes']=sorted(classes)
    return result

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--plugin', required=True)
    ap.add_argument('--app', required=True)
    ap.add_argument('--strings-file', required=True)
    ap.add_argument('--out', required=True)
    args=ap.parse_args()
    plugin=Path(args.plugin); app=Path(args.app); out=Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    layouts={}
    for fn in KEY_FILES:
        p=plugin/fn
        if p.exists():
            data=parse_ini(p)
            layouts[fn]=data
            (out/'layouts'/f'{p.stem}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2))

    def plist(path):
        with open(path,'rb') as f:return plistlib.load(f)
    components=[]
    for p in [app/'Info.plist', *sorted((app/'PlugIns').glob('*.appex/Info.plist'))]:
        d=plist(p)
        components.append({
            'path':str(p.relative_to(app)),
            'bundleIdentifier':d.get('CFBundleIdentifier'),
            'version':d.get('CFBundleShortVersionString'),
            'build':d.get('CFBundleVersion'),
            'executable':d.get('CFBundleExecutable'),
            'extension':d.get('NSExtension'),
        })
    counts=Counter()
    for p in plugin.rglob('*'):
        if p.is_file(): counts[p.suffix.lower() or '<noext>']+=1
    strings=Path(args.strings_file).read_text(errors='replace')
    manifest={
        'components':components,
        'resourceExtensionCounts':dict(counts.most_common()),
        'layouts':{k:{'baseSize':v.get('baseSize'),'itemCount':len(v['items'])} for k,v in layouts.items()},
        'featureEvidence':feature_strings(strings),
    }
    (out/'wetype353_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
