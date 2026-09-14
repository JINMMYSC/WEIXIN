#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    p = ROOT / path
    if not p.exists():
        raise AssertionError(f"missing required file: {path}")
    return p.read_text(encoding="utf-8")


def require(haystack: str, needle: str, label: str) -> None:
    if needle not in haystack:
        raise AssertionError(f"{label}: missing {needle!r}")


def main() -> int:
    project = read("ClawBase/project.yml")
    sign = read("ClawBase/ci_sign_and_validate.sh")
    static_workflow = read(".github/workflows/phase3-static-ci.yml")
    signed_workflow = read(".github/workflows/ios-claw-base-signed-ci.yml")
    status = read("ReverseEngineering/Phase7/RELEASE_STATUS.md")

    for token in [
        "app.lgm.7517",
        "app.lgm.7517.123",
        "group.7518554",
        "MARKETING_VERSION: 3.0.1",
        "CURRENT_PROJECT_VERSION: 2",
    ]:
        require(project, token, "release project identity")

    for token in [
        'EXPECTED_TEAM_ID="X5G6AN3DYX"',
        'SIGN_KEYBOARD_FIRST',
        'SIGN_HOST_LAST',
        'codesign --verify --deep --strict',
        'embedded extension count',
        'Signed IPA SHA-256',
    ]:
        require(sign, token, "signed release validator")

    for workflow, label in [(static_workflow, "static workflow"), (signed_workflow, "signed workflow")]:
        require(workflow, "work/v14-clawbase-phase5-7", label)
        require(workflow, "verify_phase5_convergence.py", label)
        require(workflow, "verify_phase6_parity.py", label)
        require(workflow, "verify_phase7_release.py", label)

    require(status, "不得用“相似度百分比”冒充完成度", "release truth document")
    require(status, "122 reference stimuli", "Phase 3 evidence disclosure")
    require(status, "79 same-device", "Phase 6 evidence disclosure")
    require(status, "Host + Keyboard provisioning profiles only", "system-extension packaging disclosure")

    forbidden_suffixes = {".p12", ".pfx", ".mobileprovision", ".cer"}
    sensitive_files = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(ROOT)
        if rel.parts and rel.parts[0] in {".git", "artifacts"}:
            continue
        if path.suffix.lower() in forbidden_suffixes:
            sensitive_files.append(str(rel))
    if sensitive_files:
        raise AssertionError(f"sensitive signing material present in checkout: {sensitive_files}")

    print("Phase 7 release contract: PASS")
    print("Release identity/sign order/codesign verification: PASS")
    print("No signing certificates/provisioning profiles present in checkout: PASS")
    print("Remaining-difference disclosure: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"Phase 7 release contract: FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
