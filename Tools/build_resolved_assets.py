#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, re
from pathlib import Path

LAYOUT_FILES = [
    't26_pinyin.ini','t26_en.ini','t26_wubi.ini','t26_inner_hw.ini',
    't9_pinyin.ini','t9_stroke.ini','t9_number.ini','t9_number_26.ini','t9_inner_hw.ini',
    't26_cn_symbol.ini','t26_en_symbol.ini','full_symbol.ini','full_symbol2.ini',
    'handwriting.ini','numpad.ini'
]


def parse_ini(path: Path):
    sections = []
    cur = None
    for raw in path.read_text(errors='replace').splitlines():
        line = raw.strip()
        if not line or line.startswith(';'):
            continue
        m = re.match(r'^\[([^\]]+)\]', line)
        if m:
            cur = {'name': m.group(1), 'values': {}}
            sections.append(cur)
            continue
        if cur is None or '=' not in line:
            continue
        k, v = line.split('=', 1)
        cur['values'][k.strip()] = v.strip()
    return sections


def section_map(sections):
    return {s['name']: dict(s['values']) for s in sections}


def resolve_layout(name: str, root: Path, cache: dict[str, dict], stack=None):
    if name in cache:
        return cache[name]
    stack = stack or []
    if name in stack:
        raise RuntimeError('inheritance cycle: ' + ' -> '.join(stack + [name]))
    path = root / f'{name}.ini'
    sections = section_map(parse_ini(path))
    panel = sections.get('PANEL', {})
    parent = panel.get('INHERIT')
    merged = {}
    if parent:
        base = resolve_layout(parent, root, cache, stack + [name])
        merged = {k: dict(v) for k, v in base['sections'].items()}
    for sec_name, values in sections.items():
        if sec_name not in merged:
            merged[sec_name] = {}
        merged[sec_name].update(values)
    # inheritance directive is metadata, not a runtime layout property
    merged.setdefault('PANEL', {}).pop('INHERIT', None)
    base_size = merged.get('PANEL', {}).get('BASESIZE')
    parsed_size = None
    if base_size:
        try:
            w, h = [float(x) for x in base_size.split(',')[:2]]
            parsed_size = [w, h]
        except Exception:
            pass
    items = []
    for sec_name, values in merged.items():
        if not sec_name.startswith(('KEY_', 'VIEW_')):
            continue
        item = {'id': sec_name, **values}
        if 'RECT' in values:
            try:
                item['rect'] = [float(x) for x in values['RECT'].split(',')]
            except Exception:
                pass
        items.append(item)
    result = {'name': name, 'baseSize': parsed_size, 'sections': merged, 'items': items, 'inherits': parent}
    cache[name] = result
    return result


def resolve_styles(path: Path):
    raw = section_map(parse_ini(path))
    cache = {}
    def one(name, stack=None):
        if name in cache:
            return cache[name]
        stack = stack or []
        if name in stack:
            raise RuntimeError('style cycle: ' + ' -> '.join(stack + [name]))
        own = dict(raw[name])
        parent = own.pop('INHERIT', None) or own.pop('STY', None)
        merged = {}
        if parent and parent in raw:
            merged.update(one(parent, stack + [name]))
        merged.update(own)
        cache[name] = merged
        return merged
    return {name: one(name) for name in raw if name.startswith('STYLE_')}


def swift_string(value):
    if value is None:
        return 'nil'
    escaped = value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
    return f'"{escaped}"'


def swift_ident(name: str):
    parts = re.split(r'[^A-Za-z0-9]+', name)
    return parts[0].lower() + ''.join(p[:1].upper() + p[1:] for p in parts[1:] if p)


def emit_swift(layouts: list[dict], out: Path):
    lines = ['import Foundation', '', '// Generated from the effective (inheritance-resolved) WeType 3.5.3 INI layouts.', 'public enum WTLayouts353Resolved {']
    for layout in layouts:
        bs = layout['baseSize'] or [414.0, 224.0]
        lines += [f'    public static let {swift_ident(layout["name"])} = WTKeyboardLayout(',
                  f'        name: {swift_string(layout["name"])},',
                  f'        baseSize: WTSize(width: {bs[0]}, height: {bs[1]}),',
                  '        items: [']
        for item in layout['items']:
            rect = item.get('rect')
            if rect:
                rect_code = f'WTRect(x: {rect[0]}, y: {rect[1]}, width: {rect[2]}, height: {rect[3]})'
            else:
                rect_code = 'nil'
            lines += [
                '            WTKeyboardItem(',
                f'                id: {swift_string(item.get("id"))}, rect: {rect_code},',
                f'                input: {swift_string(item.get("INPUT"))}, title: {swift_string(item.get("TITLE"))}, function: {swift_string(item.get("FUNC"))},',
                f'                style: {swift_string(item.get("STY"))}, image: {swift_string(item.get("IMG"))},',
                f'                upInput: {swift_string(item.get("UPINPUT"))}, downInput: {swift_string(item.get("DINPUT"))}, floatList: {swift_string(item.get("FLOATLIST"))},',
                f'                font: {swift_string(item.get("FONT"))}, upFont: {swift_string(item.get("UPFONT"))}, subtitlePosition: {swift_string(item.get("SUBTITLEPOS"))},',
                f'                rule: {swift_string(item.get("RULE"))}, floatStyle: {swift_string(item.get("FLOATSTY"))}',
                '            ),'
            ]
        lines += ['        ]', '    )', '']
    lines += ['}', '']
    out.write_text('\n'.join(lines))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--plugin', required=True)
    ap.add_argument('--out-dir', required=True)
    ap.add_argument('--swift-out', required=True)
    args = ap.parse_args()
    plugin = Path(args.plugin)
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / 'layouts').mkdir(exist_ok=True)

    cache = {}
    layouts = []
    for fn in LAYOUT_FILES:
        p = plugin / fn
        if not p.exists():
            continue
        data = resolve_layout(p.stem, plugin, cache)
        layouts.append(data)
        (out / 'layouts' / f'{p.stem}.json').write_text(json.dumps(data, ensure_ascii=False, indent=2))
    styles = resolve_styles(plugin / 'style.ini')
    (out / 'resolved_styles.json').write_text(json.dumps(styles, ensure_ascii=False, indent=2))
    emit_swift(layouts, Path(args.swift_out))
    summary = {
        'layoutCount': len(layouts),
        'styleCount': len(styles),
        'layouts': {x['name']: {'itemCount': len(x['items']), 'baseSize': x['baseSize'], 'inherits': x['inherits']} for x in layouts}
    }
    (out / 'summary.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()
