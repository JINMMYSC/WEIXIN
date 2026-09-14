#!/usr/bin/env python3
"""Compare captured WeChat reference observations with CLAW Phase 3 observations.

This comparator fails closed: reference records must come from a real device, every field
required by the case actions must be present, and missing cases are never treated as matches.
"""
from __future__ import annotations

import argparse
from dataclasses import asdict
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Tools"))
from phase3_blackbox_matrix import BlackBoxCase, build_cases  # type: ignore


def load_records(path: Path) -> dict[str, dict]:
    if not path.is_file():
        raise FileNotFoundError(path)
    raw = json.loads(path.read_text(encoding="utf-8"))
    rows = raw if isinstance(raw, list) else raw.get("observations", [])
    if not isinstance(rows, list):
        raise ValueError(f"observations must be a list in {path}")
    result: dict[str, dict] = {}
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError(f"non-object record in {path}")
        case_id = row.get("case_id")
        if not isinstance(case_id, str) or not case_id:
            raise ValueError(f"record without case_id in {path}")
        if case_id in result:
            raise ValueError(f"duplicate case_id {case_id} in {path}")
        result[case_id] = row
    return result


def required_fields(case: BlackBoxCase) -> tuple[str, ...]:
    actions = set(case.actions)
    fields: list[str] = []
    if "inspect_composition" in actions:
        fields.append("composition")
    if "inspect_candidates" in actions or "page_next" in actions or "page_previous" in actions:
        fields.append("candidates")
    if "inspect_commit" in actions:
        fields.append("commit")
    return tuple(fields)


def normalized(value):
    if value is None:
        return None
    if isinstance(value, list):
        return [str(item) for item in value]
    if isinstance(value, dict):
        return {str(key): normalized(item) for key, item in sorted(value.items())}
    return str(value)


def validate_reference(case: BlackBoxCase, row: dict) -> None:
    if row.get("reference") != "wechat-ime":
        raise ValueError(f"{case.case_id}: reference must be wechat-ime")
    if row.get("captured_on_real_device") is not True:
        raise ValueError(f"{case.case_id}: captured_on_real_device=true is required")
    for field in required_fields(case):
        if field not in row:
            raise ValueError(f"{case.case_id}: missing required reference field {field}")


def validate_actual(case: BlackBoxCase, row: dict) -> None:
    for field in required_fields(case):
        if field not in row:
            raise ValueError(f"{case.case_id}: missing required CLAW field {field}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path, help="real WeChat observation JSON")
    parser.add_argument("actual", type=Path, help="CLAW observation JSON")
    parser.add_argument("--allow-subset", action="store_true", help="compare only cases present in both files")
    args = parser.parse_args()

    cases = build_cases()
    by_id = {case.case_id: case for case in cases}
    required_ids = [case.case_id for case in cases]
    reference = load_records(args.reference)
    actual = load_records(args.actual)

    unknown_reference = sorted(set(reference) - set(by_id))
    unknown_actual = sorted(set(actual) - set(by_id))
    if unknown_reference or unknown_actual:
        print(
            f"Phase 3 parity: FAIL; unknown reference={unknown_reference[:5]}, actual={unknown_actual[:5]}",
            file=sys.stderr,
        )
        return 2

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

    try:
        for case_id in compare_ids:
            case = by_id[case_id]
            validate_reference(case, reference[case_id])
            validate_actual(case, actual[case_id])
    except ValueError as error:
        print(f"Phase 3 parity: FAIL; {error}", file=sys.stderr)
        return 2

    mismatches: list[str] = []
    for case_id in compare_ids:
        case = by_id[case_id]
        ref = reference[case_id]
        got = actual[case_id]
        for field in required_fields(case):
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
