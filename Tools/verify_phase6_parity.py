#!/usr/bin/env python3
from pathlib import Path
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def run(script: str) -> None:
    subprocess.run([sys.executable, str(ROOT / "Tools" / script)], cwd=ROOT, check=True)


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label}: missing {needle!r}")


def main() -> int:
    # Phase 6 starts by keeping every structural/runtime geometry gate green.
    for script in (
        "verify_ui_79_alignment.py",
        "verify_phase3_device_ui_contract.py",
        "verify_ui_style_tokens.py",
    ):
        run(script)

    visual_tool = (ROOT / "Tools/measure_visual_diff.py").read_text(encoding="utf-8")
    for token in (
        "same iPhone",
        "image size mismatch",
        "exact_pixel_fraction",
        "pixels_over_threshold_fraction",
        "The tool never OCRs screenshots",
    ):
        require(visual_tool, token, "same-device visual diff tool")

    manifest = (ROOT / "Sources/WeTypeReplicaCore/VisualParityManifest.swift").read_text(encoding="utf-8")
    # Existing verifier is the authority for the exact 79-case count; this token protects the source itself.
    require(manifest, "VisualParity", "visual parity manifest")

    evidence_path = ROOT / "ReverseEngineering/Phase6/device-evidence.json"
    captured = 0
    if evidence_path.exists():
        data = json.loads(evidence_path.read_text(encoding="utf-8"))
        if data.get("required_cases") != 79:
            raise AssertionError("device evidence must declare required_cases=79")
        captures = data.get("captures", [])
        if not isinstance(captures, list):
            raise AssertionError("device evidence captures must be a list")
        captured = sum(1 for item in captures if isinstance(item, dict) and item.get("reference") and item.get("replica"))

    print("Phase 6 calibration pipeline: PASS")
    print("79-case structural/runtime geometry/style gates: PASS")
    if captured < 79:
        print(f"DEVICE_EVIDENCE_PENDING: {captured}/79 same-device original-vs-replica capture pairs")
        print("CI PASS means the calibration pipeline is ready; it does NOT certify pixel identity.")
    else:
        print("Same-device capture manifest: 79/79 present (pixel metrics remain case-specific evidence).")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, subprocess.CalledProcessError, json.JSONDecodeError) as exc:
        print(f"Phase 6 calibration pipeline: FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
