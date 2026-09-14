#!/usr/bin/env python3
"""Emit a deterministic Phase 3 real-device capture worksheet.

The generated reference worksheet deliberately marks every row uncaptured and contains no
expected WeChat output. Operators must fill observations from an actual device.
"""
from __future__ import annotations

import argparse
from dataclasses import asdict
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Tools"))
from phase3_blackbox_matrix import build_cases  # type: ignore


def required_fields(actions: tuple[str, ...]) -> list[str]:
    fields: list[str] = []
    action_set = set(actions)
    if "inspect_composition" in action_set:
        fields.append("composition")
    if "inspect_candidates" in action_set or "page_next" in action_set or "page_previous" in action_set:
        fields.append("candidates")
    if "inspect_commit" in action_set:
        fields.append("commit")
    return fields


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kind", choices=("reference", "actual"), default="reference")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    observations = []
    for case in build_cases():
        row = {
            "case_id": case.case_id,
            "mode": case.mode,
            "input": case.input,
            "actions": list(case.actions),
        }
        if args.kind == "reference":
            row.update({"reference": "wechat-ime", "captured_on_real_device": False})
        else:
            row.update({"implementation": "claw-phase3", "captured_on_real_device": False})
        for field in required_fields(case.actions):
            row[field] = None
        observations.append(row)

    payload = {
        "schema_version": 2,
        "kind": args.kind,
        "note": "No expected output is prefilled; capture on a real device.",
        "observations": observations,
    }
    output = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
    else:
        print(output, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
