#!/usr/bin/env python3
"""Phase 7 stability/CI/release contract.

Default mode validates the engineering release pipeline. `--release` additionally requires all
real-device Phase 3 WeChat observations and all 79 Phase 6 same-device parity cases.
"""
from __future__ import annotations
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--release", action="store_true")
    args = parser.parse_args()

    package = text("Package.swift")
    build = text("ClawBase/ci_build_unsigned.sh")
    sign = text("ClawBase/ci_sign_and_validate.sh")
    static_ci = text(".github/workflows/phase3-static-ci.yml")
    signed_ci = text(".github/workflows/ios-claw-base-signed-ci.yml")
    controller = text("ClawBase/Keyboard/HamsterKeyboardInputViewController.swift")
    runtime = text("iOSOverlay/WTKeyboardRuntime.swift")

    for token in ('name: "WeTypeReplicaCore"', 'path: "Sources/WeTypeReplicaCore"', 'path: "Tests/WeTypeReplicaCoreTests"'):
        require(token in package, f"SwiftPM Core/replay test entry missing: {token}")

    require("for scheme in ClawBaseShare ClawBaseWidget ClawBaseVoiceActivity" in build,
            "unsigned build must compile all Phase 5 system-extension schemes")
    require('-scheme "$scheme"' in build, "system-extension loop must build each selected scheme")
    require("-scheme ClawBaseHost" in build, "unsigned build must compile ClawBaseHost")

    keyboard_first = sign.find("# SIGN_KEYBOARD_FIRST")
    host_last = sign.find("# SIGN_HOST_LAST")
    require(keyboard_first >= 0 and host_last > keyboard_first, "signing order must remain Keyboard-first / Host-last")
    for token in ("codesign --verify --strict", "codesign --verify --deep --strict", "EXPECTED_APP_GROUP", "embedded extension count"):
        require(token in sign, f"signed IPA validation missing: {token}")

    for token in ("viewWillAppear", "viewDidDisappear", "didReceiveMemoryWarning", "persistSessionState", "syncUserData"):
        require(token in controller, f"extension termination/recreation recovery contract missing: {token}")
    for token in ("releaseTransientCaches", "returnToKeyboard", "trimmedClipboard"):
        if token == "trimmedClipboard":
            require(token in text("Sources/WeTypeReplicaCore/MemoryPressurePolicy.swift"), f"memory recovery missing: {token}")
        else:
            require(token in runtime, f"memory recovery missing: {token}")

    for workflow in (static_ci, signed_ci):
        require("work/v14-phase1-7-final" in workflow, "final Phase 1-7 branch is not wired to CI")
        require("verify_phase5_completion.py" in workflow, "Phase 5 gate missing from CI")
        require("verify_phase6_evidence.py" in workflow, "Phase 6 evidence report missing from CI")
        require("verify_phase7_release.py" in workflow, "Phase 7 gate missing from CI")
    require("swift test" in signed_ci, "Core/replay Swift tests are not executed by macOS CI")

    if args.release:
        observations_path = ROOT / "ClawBase/Phase3BlackBox/observations.json"
        require(observations_path.is_file(), "Phase 3 real-device observations.json is missing")
        payload = json.loads(observations_path.read_text(encoding="utf-8"))
        observations = payload.get("observations", [])
        cases_module = ROOT / "Tools/phase3_blackbox_matrix.py"
        namespace: dict[str, object] = {}
        exec(compile(cases_module.read_text(encoding="utf-8"), str(cases_module), "exec"), namespace)
        cases = namespace["build_cases"]()
        case_ids = {case.case_id for case in cases}
        observed_ids = {
            item.get("case_id") for item in observations
            if item.get("reference") == "wechat-ime" and item.get("captured_on_real_device") is True
        }
        require(observed_ids == case_ids,
                f"Phase 3 release parity requires {len(case_ids)} real observations; have {len(observed_ids)}")
        result = subprocess.run(
            [sys.executable, str(ROOT / "Tools/verify_phase6_evidence.py"), "--strict"],
            cwd=ROOT,
            check=False,
        )
        require(result.returncode == 0, "Phase 6 79-case same-device evidence is incomplete")
        print("Phase 7 final release gate: PASS")
    else:
        print("Phase 7 engineering stability/CI/signing contract: PASS")
        print("Final pixel/behavior release remains fail-closed behind Phase 3 real observations + Phase 6 79-case evidence.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError, json.JSONDecodeError) as error:
        print(f"Phase 7 contract: FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
