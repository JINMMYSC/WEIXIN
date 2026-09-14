#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]

PHASES = {
    1: ["verify_claw_base_ci.py"],
    2: ["verify_ui_79_alignment.py", "verify_phase3_device_ui_contract.py", "verify_ui_style_tokens.py"],
    3: [
        "verify_phase3_blackbox_matrix.py",
        "verify_phase3_completion.py",
        "verify_phase3_segmentation_contract.py",
        "verify_phase3_wubi_contract.py",
        "verify_phase3_stroke_contract.py",
        "verify_phase3_input_chain.py",
        "verify_phase3_host_surface.py",
        "validate_phase3_layout_names.py",
    ],
    4: ["verify_phase4_completion.py"],
    5: ["verify_phase5_convergence.py"],
    6: ["verify_phase6_parity.py"],
    7: ["verify_phase7_release.py"],
}


def main() -> int:
    for phase, scripts in PHASES.items():
        print(f"=== Phase {phase} ===", flush=True)
        for script in scripts:
            subprocess.run([sys.executable, str(ROOT / "Tools" / script)], cwd=ROOT, check=True)
        print(f"Phase {phase} engineering gate: PASS", flush=True)
    print("Phase 1-7 engineering regression: PASS")
    print("External parity evidence remains governed by Phase 3/6 evidence disclosures.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as exc:
        print(f"Phase 1-7 engineering regression: FAIL at exit {exc.returncode}", file=sys.stderr)
        raise SystemExit(exc.returncode)
