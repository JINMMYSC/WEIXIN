#!/usr/bin/env python3
import argparse, json
from pathlib import Path

def esc(s):
    return s.replace('\\','\\\\').replace('"','\\"')

ap=argparse.ArgumentParser(); ap.add_argument('--json',required=True); ap.add_argument('--out',required=True); args=ap.parse_args()
data=json.load(open(args.json))
lines=['import Foundation','','// Generated from inheritance-resolved WeType 3.5.3 style.ini.','public enum WTStyleCatalog353 {','    public static let raw: [String: [String: String]] = [']
for name in sorted(data):
    lines.append(f'        "{esc(name)}": [')
    for k,v in sorted(data[name].items()):
        lines.append(f'            "{esc(k)}": "{esc(v)}",')
    lines.append('        ],')
lines += ['    ]','', '    public static func values(for styleNames: String?) -> [String: String] {','        guard let styleNames else { return [:] }','        var merged: [String: String] = [:]','        for name in styleNames.split(separator: ",").map({ String($0) }) {','            if let values = raw[name] { merged.merge(values) { _, new in new } }','        }','        return merged','    }','}','']
Path(args.out).write_text('\n'.join(lines))
