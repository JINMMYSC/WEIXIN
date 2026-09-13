#!/usr/bin/env python3
import argparse, io, json, os, re, zipfile
from collections import defaultdict
from PIL import Image

PREFIX = 'Payload/wxkb.app/RNBundles/assets/src/Setup/'
IMG_EXTS = ('.png', '.jpg', '.jpeg', '.webp')


def scale_for_name(name: str) -> int:
    m = re.search(r'@(2|3)x(?=\.)', name)
    return int(m.group(1)) if m else 1


def family_name(filename: str) -> str:
    base = os.path.basename(filename)
    return re.sub(r'@(2|3)x(?=\.)', '', base).rsplit('.', 1)[0]


def alpha_bbox(img: Image.Image):
    rgba = img.convert('RGBA')
    alpha = rgba.getchannel('A')
    bbox = alpha.getbbox()
    if bbox is None:
        return [0, 0, 0, 0]
    x0, y0, x1, y1 = bbox
    return [x0, y0, x1 - x0, y1 - y0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('ipa')
    ap.add_argument('--json', required=True)
    ap.add_argument('--swift', required=True)
    args = ap.parse_args()

    records = []
    screen_counts = defaultdict(int)
    with zipfile.ZipFile(args.ipa) as zf:
        for zi in zf.infolist():
            if not zi.filename.startswith(PREFIX) or not zi.filename.lower().endswith(IMG_EXTS):
                continue
            rel = zi.filename[len(PREFIX):]
            parts = rel.split('/')
            if len(parts) < 2:
                continue
            screen = parts[0]
            try:
                raw = zf.read(zi)
                img = Image.open(io.BytesIO(raw))
                width, height = img.size
                bbox = alpha_bbox(img)
            except Exception:
                continue
            scale = scale_for_name(zi.filename)
            logical = [round(width / scale, 3), round(height / scale, 3)]
            logical_bbox = [round(v / scale, 3) for v in bbox]
            records.append({
                'screen': screen,
                'path': rel,
                'family': family_name(zi.filename),
                'scale': scale,
                'pixelSize': [width, height],
                'logicalSize': logical,
                'alphaBounds': logical_bbox,
            })
            screen_counts[screen] += 1

    records.sort(key=lambda r: (r['screen'], r['family'], r['scale'], r['path']))
    payload = {
        'source': 'WeType 3.5.3 IPA host-app Setup asset measurements; no proprietary pixels copied',
        'recordCount': len(records),
        'screens': dict(sorted(screen_counts.items())),
        'assets': records,
    }
    os.makedirs(os.path.dirname(args.json), exist_ok=True)
    with open(args.json, 'w', encoding='utf-8') as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    # Keep one preferred record per screen/family, preferring 3x then 2x then 1x.
    preferred = {}
    for r in records:
        key = (r['screen'], r['family'])
        if key not in preferred or r['scale'] > preferred[key]['scale']:
            preferred[key] = r

    def ident(s):
        s = re.sub(r'[^A-Za-z0-9_]', '_', s)
        if s and s[0].isdigit(): s = '_' + s
        return s

    lines = [
        'import Foundation', '',
        'public struct WTHostSetupAssetGeometry: Hashable, Sendable {',
        '    public let screen: String',
        '    public let family: String',
        '    public let canvas: WTSize',
        '    public let glyphBounds: WTRect',
        '    public init(screen: String, family: String, canvas: WTSize, glyphBounds: WTRect) {',
        '        self.screen = screen; self.family = family; self.canvas = canvas; self.glyphBounds = glyphBounds',
        '    }',
        '}', '',
        'public enum WTHostSetupGeometry353 {',
        '    public static let all: [String: WTHostSetupAssetGeometry] = [',
    ]
    for (screen, fam), r in sorted(preferred.items()):
        key = f'{screen}/{fam}'
        w,h = r['logicalSize']; x,y,bw,bh = r['alphaBounds']
        lines.append(f'        {json.dumps(key)}: .init(screen: {json.dumps(screen)}, family: {json.dumps(fam)}, canvas: .init(width: {w}, height: {h}), glyphBounds: .init(x: {x}, y: {y}, width: {bw}, height: {bh})),')
    lines += [
        '    ]',
        '    public static func geometry(screen: String, family: String) -> WTHostSetupAssetGeometry? { all["\\(screen)/\\(family)"] }',
        '    public static var screens: [String] { Array(Set(all.values.map(\\.screen)).sorted()) }',
        '}', ''
    ]
    with open(args.swift, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print(f'host setup geometry: {len(records)} asset variants, {len(preferred)} families, {len(screen_counts)} screens')

if __name__ == '__main__':
    main()
