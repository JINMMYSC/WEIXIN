#!/usr/bin/env python3
"""Fail-closed exact WeChat parity certification.

Engineering/build/signing gates are intentionally separate. This script certifies exact parity
only when both externally observed evidence sets are complete:
1. all Phase 3 black-box stimuli have real-device WeChat and replica observations that match; and
2. all 79 Phase 6 same-device original-vs-replica capture pairs have raw-pixel metrics.

No missing observation is inferred or fabricated.
"""
from pathlib import Path
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "ClawBase/Phase3BlackBox/observations.json"
ACTUAL = ROOT / "ClawBase/Phase3BlackBox/replica-observations.json"

sys.path.insert(0, str(ROOT / "Tools"))
from phase3_blackbox_matrix import build_cases  # type: ignore


def count_rows(path: Path) -> int:
    if not path.is_file():
        return 0
    payload = json.loads(path.read_text(encoding="utf-8"))
    rows = payload if isinstance(payload, list) else payload.get("observations", [])
    if not isinstance(rows, list):
        raise AssertionError(f"observations must be a list: {path}")
    return len(rows)


def main() -> int:
    required = len(build_cases())
    if required != 122:
        raise AssertionError(f"exact certification expects 122 Phase 3 cases, matrix has {required}")

    reference_count = count_rows(REFERENCE)
    actual_count = count_rows(ACTUAL)
    print(f"Phase 3 exact evidence: WeChat {reference_count}/{required}; replica {actual_count}/{required}")
    if reference_count != required or actual_count != required:
        raise AssertionError(
            "Phase 3 exact parity evidence incomplete; real-device observations are mandatory"
        )

    subprocess.run(
        [sys.executable, str(ROOT / "Tools/compare_phase3_blackbox.py"), str(REFERENCE), str(ACTUAL)],
        cwd=ROOT,
        check=True,
    )
    subprocess.run(
        [sys.executable, str(ROOT / "Tools/verify_phase6_exact_evidence.py")],
        cwd=ROOT,
        check=True,
    )

    print("EXACT WECHAT PARITY CERTIFICATION: PASS")
    print("Phase 3: 122/122 real-device behavior cases matched")
    print("Phase 6: 79/79 same-device raw-pixel evidence pairs certified")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, json.JSONDecodeError, subprocess.CalledProcessError) as exc:
        print(f"EXACT WECHAT PARITY CERTIFICATION: FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
