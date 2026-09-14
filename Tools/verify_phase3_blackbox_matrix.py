#!/usr/bin/env python3
"""Fail-closed validation for the Phase 3 WeChat black-box test matrix."""

from collections import Counter
import json
from pathlib import Path
import sys

from phase3_blackbox_matrix import build_cases

ROOT = Path(__file__).resolve().parents[1]
OBSERVATIONS = ROOT / "ClawBase" / "Phase3BlackBox" / "observations.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    cases = build_cases()
    ids = [case.case_id for case in cases]
    require(len(cases) >= 100, f"need at least 100 black-box cases, got {len(cases)}")
    require(len(ids) == len(set(ids)), "black-box case IDs must be unique")

    mode_counts = Counter(case.mode for case in cases)
    for mode in ("chinesePinyin26", "chinesePinyin9", "doublePinyin", "wubi", "stroke", "english26"):
        require(mode_counts[mode] > 0, f"missing black-box mode coverage: {mode}")

    all_actions = {action for case in cases for action in case.actions}
    for action in (
        "inspect_composition", "inspect_candidates", "page_next", "page_previous",
        "select_0", "inspect_commit", "backspace", "space", "return", "reset",
        "set_simplified", "set_traditional", "enable_fuzzy_zh_z", "enable_fuzzy_l_n",
        "learn_user_phrase",
    ):
        require(action in all_actions, f"missing black-box action coverage: {action}")

    observed_count = 0
    if OBSERVATIONS.is_file():
        payload = json.loads(OBSERVATIONS.read_text(encoding="utf-8"))
        observations = payload.get("observations", [])
        known = set(ids)
        seen = set()
        for observation in observations:
            case_id = observation.get("case_id")
            require(case_id in known, f"observation references unknown case: {case_id}")
            require(case_id not in seen, f"duplicate observation: {case_id}")
            require(observation.get("reference") == "wechat-ime", f"{case_id}: reference must be wechat-ime")
            require(observation.get("captured_on_real_device") is True, f"{case_id}: real-device provenance required")
            seen.add(case_id)
        observed_count = len(seen)

    print(f"Phase 3 black-box matrix: PASS ({len(cases)} cases defined; {observed_count} real WeChat observations captured)")
    if observed_count < len(cases):
        print("Reference parity remains PENDING: CI does not fabricate missing WeChat outputs.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, json.JSONDecodeError) as error:
        print(f"Phase 3 black-box matrix: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
