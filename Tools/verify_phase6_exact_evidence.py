#!/usr/bin/env python3
"""Fail-closed Phase 6 exact-parity evidence certification.

This is deliberately separate from the structural/runtime calibration pipeline. It must not pass
until all 79 required same-device WeChat 3.5.3 vs replica capture pairs exist with raw-pixel metrics.
"""
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "ReverseEngineering/Phase6/device-evidence.json"
REQUIRED = 79
REQUIRED_METRICS = {"exact_pixel_fraction", "pixels_over_threshold_fraction", "mae_0_255", "rmse_0_255"}


def fail(message: str) -> None:
    raise AssertionError(message)


def main() -> int:
    if not EVIDENCE.exists():
        fail("missing ReverseEngineering/Phase6/device-evidence.json")
    data = json.loads(EVIDENCE.read_text(encoding="utf-8"))
    if data.get("reference_build") != "WeChat IME 3.5.3":
        fail("reference_build must be WeChat IME 3.5.3")
    if data.get("required_cases") != REQUIRED:
        fail(f"required_cases must be {REQUIRED}")

    requirements = data.get("capture_requirements") or {}
    for key in ("same_device", "same_host_app", "same_orientation", "same_appearance", "same_text_state", "no_resize_for_acceptance"):
        if requirements.get(key) is not True:
            fail(f"capture requirement {key}=true is mandatory")

    captures = data.get("captures")
    if not isinstance(captures, list):
        fail("captures must be a list")
    if len(captures) != REQUIRED:
        fail(f"exact parity evidence incomplete: {len(captures)}/{REQUIRED} capture pairs")

    ids = set()
    for index, item in enumerate(captures, start=1):
        if not isinstance(item, dict):
            fail(f"capture #{index} must be an object")
        case_id = item.get("case_id")
        if not isinstance(case_id, str) or not case_id.strip():
            fail(f"capture #{index} missing case_id")
        if case_id in ids:
            fail(f"duplicate case_id: {case_id}")
        ids.add(case_id)
        for field in ("reference", "replica", "metrics"):
            if not item.get(field):
                fail(f"{case_id}: missing {field}")
        metrics_path = ROOT / str(item["metrics"])
        if not metrics_path.exists():
            fail(f"{case_id}: metrics file does not exist: {item['metrics']}")
        metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
        missing = REQUIRED_METRICS - metrics.keys()
        if missing:
            fail(f"{case_id}: metrics missing {sorted(missing)}")
        if metrics.get("crop") is not None:
            fail(f"{case_id}: acceptance metrics must use the uncropped same-device frame")

    print("Phase 6 exact parity evidence: PASS")
    print(f"Certified same-device original-vs-replica pairs: {len(captures)}/{REQUIRED}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, json.JSONDecodeError) as exc:
        print(f"Phase 6 exact parity evidence: FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
