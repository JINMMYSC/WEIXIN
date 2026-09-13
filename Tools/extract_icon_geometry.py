#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import json, re, sys
from PIL import Image

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('/mnt/data/wetype353/Payload/wxkb.app/PlugIns/wxkb_plugin.appex')
out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path('ReverseEngineering/V7/icon_geometry.json')
patterns = ('icon_bar_', 'control_center_', 'icon_setup_', 'icon_key', 'icon_emoji', 'icon_bookvideo_', 'icon_popup_', 'icon_size_', 'icon_plus_')
rows=[]
for path in sorted(root.glob('*.png')):
    if not path.name.startswith(patterns):
        continue
    m=re.search(r'@(2|3)x', path.stem)
    scale=int(m.group(1)) if m else 1
    try:
        im=Image.open(path).convert('RGBA')
    except Exception:
        continue
    alpha=im.getchannel('A')
    bbox=alpha.getbbox()
    if bbox:
        l,t,r,b=bbox
        bw,bh=r-l,b-t
    else:
        l=t=r=b=bw=bh=0
    logical_name=re.sub(r'@(2|3)x$', '', path.stem)
    rows.append({
        'file': path.name,
        'logicalName': logical_name,
        'scale': scale,
        'pixelWidth': im.width,
        'pixelHeight': im.height,
        'pointWidth': round(im.width/scale, 3),
        'pointHeight': round(im.height/scale, 3),
        'alphaBBoxPixels': [l,t,r,b],
        'glyphPointWidth': round(bw/scale, 3),
        'glyphPointHeight': round(bh/scale, 3),
        'glyphOffsetPointX': round(l/scale, 3),
        'glyphOffsetPointY': round(t/scale, 3),
    })

# Prefer @3x per logical asset; fall back to @2x / 1x.
best={}
for row in rows:
    key=row['logicalName']
    if key not in best or row['scale'] > best[key]['scale']:
        best[key]=row
summary=sorted(best.values(), key=lambda x:x['logicalName'])
out.parent.mkdir(parents=True,exist_ok=True)
out.write_text(json.dumps({'source':'WeType 3.5.3 keyboard extension','count':len(summary),'icons':summary}, ensure_ascii=False, indent=2))

md=out.with_suffix('.md')
lines=['# WeType 3.5.3 icon geometry measurements','',
       'Clean-room geometry only: dimensions and alpha bounds are measured from the installed IPA resources; the original bitmap assets are **not** copied into the replica.', '',
       f'Measured logical icon families: **{len(summary)}**.', '',
       '| logical name | canvas pt | alpha glyph pt | offset pt | source scale |',
       '|---|---:|---:|---:|---:|']
for x in summary:
    lines.append(f"| `{x['logicalName']}` | {x['pointWidth']}×{x['pointHeight']} | {x['glyphPointWidth']}×{x['glyphPointHeight']} | {x['glyphOffsetPointX']},{x['glyphOffsetPointY']} | {x['scale']}x |")
md.write_text('\n'.join(lines))
print(f'wrote {out} and {md} ({len(summary)} logical icons)')
