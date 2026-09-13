#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, re
from pathlib import Path

GROUPS = {
    'candidate': [r'candidate', r'syllable', r'userdict'],
    'gesture_key': [r'floating', r'swipe', r'longpress', r'keyview', r'deletebackward', r'doubletap'],
    'emoji_sticker': [r'emoji', r'emotion', r'sticker'],
    'clipboard': [r'pasteboard', r'clipboard'],
    'handwriting': [r'handwrit', r'innerhw'],
    'voice': [r'voice', r'asr', r'vad'],
    'translate': [r'translate', r'translater'],
    'ai_rewrite_polish': [r'askai', r'rewrite', r'polish', r'copywriting'],
    'correction': [r'correct', r'correction', r'spell'],
    'device_transfer': [r'devicesync', r'transfer', r'p2p', r'quicksend'],
    'panel_toolbar': [r'switchpanel', r'rootview', r'toolbar', r'panelview'],
}

HIGHLIGHTS = [
    'floatingBecomeUpSwipe:', 'floatingBecomeDownSwipe:', 'floatingBecomeLongPress:',
    '_showLongPressPopupItems:sourceRect:defaultIndex:style:',
    'handleCandidateActionLongPress:', 'candidateView:didLongPressCandidate:atIndex:isFirstScreen:sourceRect:',
    'candidateView:didSelectCandidate:atIndex:isFirstScreen:', 'candidateView:requireMoreCandidate:',
    'processHandWriteInput:session:', 'selectPasteboardHistoryItem:selectedTag:',
    'getRecentlyEmojis', 'didTapEmojiInEmojiKeyboard:skinEmoji:',
    'showCorrectionDetailViewWithCorrection:animated:isFromOpenPlus:',
    'switchPanelView:'
]


def clean_lines(path: Path):
    out=[]
    for line in path.read_text(errors='replace').splitlines():
        line=re.sub(r'^\s*[0-9a-fA-F]+\s+', '', line).strip()
        if line: out.append(line)
    return out


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--classes', required=True)
    ap.add_argument('--methods', required=True)
    ap.add_argument('--out-dir', required=True)
    args=ap.parse_args()
    classes=clean_lines(Path(args.classes))
    methods=clean_lines(Path(args.methods))
    out=Path(args.out_dir); out.mkdir(parents=True, exist_ok=True)

    grouped={}
    for group, patterns in GROUPS.items():
        rx=re.compile('|'.join(patterns), re.I)
        grouped[group]={
            'classes': sorted({x for x in classes if rx.search(x)}),
            'methods': sorted({x for x in methods if rx.search(x) and not x.startswith('T@')})
        }
    highlights={h: any(h.lower() in m.lower() for m in methods) for h in HIGHLIGHTS}
    payload={'classCount':len(classes),'methodStringCount':len(methods),'groups':grouped,'highlights':highlights}
    (out/'binary_behavior_map.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2))

    lines=['# WeType 3.5.3 binary behavior map','',
           f'- Objective-C class-name entries: **{len(classes)}**',
           f'- Objective-C method/property strings: **{len(methods)}**','',
           'This report is generated from Mach-O `__objc_classname` and `__objc_methname`; it documents observable interfaces/behavioral clues, not Tencent source code.','',
           '## High-confidence behavior selectors','']
    for h, present in highlights.items():
        lines.append(f'- [{"x" if present else " "}] `{h}`')
    for group, data in grouped.items():
        lines += ['', f'## {group}', '', '### Classes']
        for x in data['classes'][:80]: lines.append(f'- `{x}`')
        lines += ['', '### Selectors / behavior strings']
        for x in data['methods'][:140]: lines.append(f'- `{x}`')
    (out/'BINARY_BEHAVIOR_MAP.md').write_text('\n'.join(lines))

if __name__=='__main__': main()
