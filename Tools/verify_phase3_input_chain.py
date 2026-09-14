#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    t9 = (ROOT / "ClawBase/RimeSchemas/claw_pinyin9.schema.yaml").read_text(encoding="utf-8")
    session = (ROOT / "ClawBase/Keyboard/WTLibrimeRimeSession.swift").read_text(encoding="utf-8")
    bridge = (ROOT / "ClawBase/Keyboard/WTLibrimeBridge.m").read_text(encoding="utf-8")
    controller = (ROOT / "ClawBase/Keyboard/HamsterKeyboardInputViewController.swift").read_text(encoding="utf-8")

    # Real T9 schema must project public pinyin spellings onto the 2-9 keypad.
    for token in (
        'alphabet: "23456789"',
        'initials: "23456789"',
        'xlit/abcdefghijklmnopqrstuvwxyz/22233344455566677778889999/',
        'dictionary: luna_pinyin',
        'enable_user_dict: true',
        'opencc_config: t2s.json',
    ):
        require(token in t9, f"T9 schema contract missing: {token}")

    # The extracted key canvas sends ABC/DEF/... groups; Release normalizes them to digits.
    for group, digit in (
        ("ABC", "2"), ("DEF", "3"), ("GHI", "4"), ("JKL", "5"),
        ("MNO", "6"), ("PQRS", "7"), ("TUV", "8"), ("WXYZ", "9"),
    ):
        require(f'"{group}": "{digit}"' in session, f"T9 group mapping missing: {group}->{digit}")

    # nihao -> 64426 under the standard mobile keypad mapping.
    keypad = dict(zip("abcdefghijklmnopqrstuvwxyz", "22233344455566677778889999"))
    require("".join(keypad[ch] for ch in "nihao") == "64426", "T9 nihao reference mapping drifted")

    # Candidate navigation/selection must be page-correct, then expose a real Rime commit.
    require("WTKeyPageUp" in bridge and "WTKeyPageDown" in bridge, "candidate PageUp/PageDown bridge missing")
    require("select_candidate_on_current_page" in bridge,
            "candidate selection must prefer librime current-page API")
    require("state.pageNumber * pageSize + index" in bridge,
            "legacy candidate API fallback must translate page-local index to global index")
    require("return [self drainCommit];" in bridge,
            "candidate selection must drain the real Rime commit")
    require("RimeProcessKey(_sessionID, WTKeyBackSpace, 0)" in bridge,
            "backspace must be processed by librime while composing")
    require("RimeClearComposition(_sessionID)" in bridge,
            "reset must clear the real librime composition")

    # Controller must propagate commit/space/return/backspace to the host textDocumentProxy.
    for token in (
        "engine.drainCommit()",
        "engine.deleteBackward()",
        'engine.process(" ")',
        "engine.selectCandidate(at: 0)",
        'textDocumentProxy.insertText("\\n")',
    ):
        require(token in controller, f"controller input-chain token missing: {token}")

    print("Phase 3 T9/candidate input-chain gate: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Phase 3 T9/candidate input-chain gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
