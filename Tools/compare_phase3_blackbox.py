#!/usr/bin/env python3
"""Compare captured WeChat reference observations with CLAW Phase 3 observations.

This deliberately fails closed.  Missing real-device reference records are never treated as
matches and no Tencent/WeChat output is synthesized.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Tools"))
from phase3_blackbox_matrix import build_cases  # type: ignore

FIELDS = ("composition", "candidates", "commit")


def load_records(path: Path) -> dict[str, dict]:
    if not path.is_file():
        raise FileNotFoundError(path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    rows = raw if isinstance(raw, list) else raw.get("observations", [])
    result: dict[str, dict] = {}
    for row in rows:
        case_id = row.get("case_id")
        if not isinstance(case_id, str) or not case_id:
            raise ValueError(f"record without case_id in {path}")
        if case_id in result:
            raise ValueError(f"duplicate case_id {case_id} in {path}")
        result[case_id] = row
    return result


def normalized(value):
    if value is None:
        return None
    if isinstance(value, list):
        return [str(item) for item in value]
    return str(value)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path, help="real WeChat observation JSON")
    parser.add_argument("actual", type=Path, help="CLAW observation JSON")
    parser.add_argument("--allow-subset", action="store_true", help="compare only cases present in both files")
    args = parser.parse_args()

    cases = build_cases()
    required_ids = [case["case_id"] for case in cases]
    reference = load_records(args.reference)
    actual = load_records(args.actual)

    if not args.allow_subset:
        missing_reference = [case_id for case_id in required_ids if case_id not in reference]
        missing_actual = [case_id for case_id in required_ids if case_id not in actual]
        if missing_reference or missing_actual:
            print(f"Phase 3 parity: FAIL; missing reference={len(missing_reference)}, actual={len(missing_actual)}", file=sys.stderr)
            if missing_reference:
                print("missing reference sample:", ", ".join(missing_reference[:10]), file=sys.stderr)
            if missing_actual:
                print("missing actual sample:", ", ".join(missing_actual[:10]), file=sys.stderr)
            return 2
        compare_ids = required_ids
    else:
        compare_ids = [case_id for case_id in required_ids if case_id in reference and case_id in actual]
        if not compare_ids:
            print("Phase 3 parity: FAIL; no overlapping real observations", file=sys.stderr)
            return 2

    mismatches: list[str] = []
    for case_id in compare_ids:
        ref = reference[case_id]
        got = actual[case_id]
        for field in FIELDS:
            if field not in ref:
                continue
            if normalized(ref.get(field)) != normalized(got.get(field)):
                mismatches.append(
                    f"{case_id}:{field}: reference={ref.get(field)!r} actual={got.get(field)!r}"
                )

    if mismatches:
        print(f"Phase 3 parity: FAIL; {len(mismatches)} mismatches across {len(compare_ids)} cases", file=sys.stderr)
        for row in mismatches[:50]:
            print(row, file=sys.stderr)
        return 1

    print(f"Phase 3 parity: PASS; {len(compare_ids)} captured cases matched")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
