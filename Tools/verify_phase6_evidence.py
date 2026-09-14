#!/usr/bin/env python3
"""Evidence gate for Phase 6 visual/behavior parity.

The old 79-case gate only proves structural coverage. This gate requires same-device evidence and
therefore never calls missing captures a pass. CI uses report mode so engineering builds can still
be produced while calibration is in progress. `--strict` is the release/pixel-parity gate.
"""
from __future__ import annotations
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "Phase6Evidence"


def case_ids() -> list[str]:
    source = (ROOT / "Sources/WeTypeReplicaCore/VisualParityManifest.swift").read_text(encoding="utf-8")
    raw = re.findall(r'add\("([^"]+)"', source)
    ids: list[str] = []
    for value in raw:
        if "\\(appearance)" in value:
            ids.extend(value.replace("\\(appearance)", appearance) for appearance in ("light", "dark"))
        else:
            ids.append(value)
    if len(ids) != 79 or len(set(ids)) != 79:
        raise AssertionError(f"VisualParityManifest must resolve to exactly 79 unique cases, got {len(ids)}/{len(set(ids))}")
    return ids


def capture(root: Path, case_id: str) -> Path | None:
    for suffix in (".png", ".mov", ".mp4"):
        path = root / f"{case_id}{suffix}"
        if path.is_file() and path.stat().st_size > 0:
            return path
    return None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true", help="fail unless all 79 same-device pairs and review records exist")
    parser.add_argument("--json", dest="json_path", help="optional report path")
    args = parser.parse_args()

    ids = case_ids()
    reference_root = EVIDENCE / "reference"
    replica_root = EVIDENCE / "replica"
    review_root = EVIDENCE / "reviews"

    rows = []
    for case_id in ids:
        reference = capture(reference_root, case_id)
        replica = capture(replica_root, case_id)
        review = review_root / f"{case_id}.json"
        review_data = None
        if review.is_file():
            try:
                review_data = json.loads(review.read_text(encoding="utf-8"))
            except Exception:
                review_data = None
        reviewed = bool(
            isinstance(review_data, dict)
            and review_data.get("same_device") is True
            and review_data.get("target_version") == "3.5.3"
            and review_data.get("status") in {"pass", "fail"}
        )
        passed = bool(reviewed and review_data.get("status") == "pass")
        rows.append({
            "id": case_id,
            "reference": str(reference.relative_to(ROOT)) if reference else None,
            "replica": str(replica.relative_to(ROOT)) if replica else None,
            "review": str(review.relative_to(ROOT)) if reviewed else None,
            "status": "pass" if passed and reference and replica else "missing-or-unverified",
        })

    complete = [row for row in rows if row["status"] == "pass"]
    missing = [row["id"] for row in rows if row["status"] != "pass"]
    report = {
        "target_version": "3.5.3",
        "required_cases": 79,
        "verified_cases": len(complete),
        "missing_or_unverified": missing,
        "strict_release_ready": len(complete) == 79,
        "cases": rows,
    }

    if args.json_path:
        output = ROOT / args.json_path
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if len(complete) == 79:
        print("Phase 6 same-device visual/behavior evidence: PASS (79/79)")
        return 0

    print(f"Phase 6 same-device visual/behavior evidence: BLOCKED ({len(complete)}/79 verified)")
    print("Missing/unverified cases: " + ", ".join(missing[:12]) + (" ..." if len(missing) > 12 else ""))
    print("Static geometry/style checks are not accepted as pixel-identical evidence.")
    if args.strict:
        return 2
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError) as error:
        print(f"Phase 6 evidence gate: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
