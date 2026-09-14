#!/usr/bin/env python3
"""Classify observable WeChat 3.5.3 vs replica IME differences into actionable buckets.

The tool never fabricates reference output. Reference rows must be real-device captures.
It reports which candidate differences can be fixed by compatibility reordering and which
require dictionary/schema/provider work because the reference text is absent locally.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Tools"))
from phase3_blackbox_matrix import build_cases  # type: ignore


def load(path: Path) -> dict[str, dict]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    rows = raw if isinstance(raw, list) else raw.get("observations", [])
    if not isinstance(rows, list):
        raise ValueError(f"observations must be an array: {path}")
    result: dict[str, dict] = {}
    for row in rows:
        if not isinstance(row, dict) or not row.get("case_id"):
            raise ValueError(f"invalid observation row: {path}")
        result[str(row["case_id"])] = row
    return result


def texts(value) -> list[str]:
    if not isinstance(value, list):
        return []
    return [str(x) for x in value]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("reference", type=Path)
    parser.add_argument("actual", type=Path)
    parser.add_argument("--prefix", type=int, default=10)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    prefix = max(1, min(args.prefix, 50))
    reference = load(args.reference)
    actual = load(args.actual)
    cases = {case.case_id: case for case in build_cases()}

    rows: list[dict] = []
    counts = {
        "exact": 0,
        "reorder_only": 0,
        "missing_local_candidates": 0,
        "composition_mismatch": 0,
        "commit_mismatch": 0,
        "uncaptured_reference": 0,
        "missing_actual": 0,
    }

    for case_id in cases:
        ref = reference.get(case_id)
        got = actual.get(case_id)
        if ref is None or ref.get("captured_on_real_device") is not True:
            counts["uncaptured_reference"] += 1
            rows.append({"case_id": case_id, "status": "uncaptured_reference"})
            continue
        if got is None:
            counts["missing_actual"] += 1
            rows.append({"case_id": case_id, "status": "missing_actual"})
            continue

        ref_candidates = texts(ref.get("candidates"))[:prefix]
        got_candidates = texts(got.get("candidates"))
        got_set = set(got_candidates)
        missing = [item for item in ref_candidates if item not in got_set]
        common_desired = [item for item in ref_candidates if item in got_set]
        composition_match = ref.get("composition") == got.get("composition")
        commit_match = ref.get("commit") == got.get("commit")
        prefix_match = got_candidates[: len(ref_candidates)] == ref_candidates

        problems: list[str] = []
        if not composition_match:
            counts["composition_mismatch"] += 1
            problems.append("composition")
        if not commit_match:
            counts["commit_mismatch"] += 1
            problems.append("commit")
        if missing:
            counts["missing_local_candidates"] += 1
            problems.append("missing_local_candidates")
        elif not prefix_match:
            counts["reorder_only"] += 1
            problems.append("candidate_reorder")

        if not problems:
            counts["exact"] += 1
            status = "exact"
        elif problems == ["candidate_reorder"]:
            status = "reorder_only"
        else:
            status = "needs_engine_compatibility"

        rows.append({
            "case_id": case_id,
            "status": status,
            "problems": problems,
            "reference_composition": ref.get("composition"),
            "actual_composition": got.get("composition"),
            "reference_prefix": ref_candidates,
            "actual_prefix": got_candidates[:prefix],
            "missing_local_candidates": missing,
            "safe_reorder_hint": common_desired,
            "reference_commit": ref.get("commit"),
            "actual_commit": got.get("commit"),
        })

    payload = {
        "schema_version": 1,
        "reference": "WeChat Input 3.5.3 real-device capture",
        "prefix_limit": prefix,
        "counts": counts,
        "strict_ready": counts["uncaptured_reference"] == 0 and counts["missing_actual"] == 0,
        "observations": rows,
    }
    output = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
    else:
        print(output, end="")

    # Analyzer itself succeeds for partial capture sets; strict parity remains a separate gate.
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
