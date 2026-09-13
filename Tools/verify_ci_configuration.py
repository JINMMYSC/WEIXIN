from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "ios-unsigned-ci.yml"
LEGACY_WORKFLOW = ROOT / ".github" / "workflows" / "ios-build.yml"
BUILD_SCRIPT = ROOT / "XcodeIntegration" / "ci_unsigned_build.sh"
VALIDATE_SCRIPT = ROOT / "XcodeIntegration" / "validate_on_mac.sh"
GIT_ATTRIBUTES = ROOT / ".gitattributes"

SCHEMES = (
    "WeTypeReplicaApp",
    "WeTypeReplicaKeyboard",
    "WeTypeReplicaShare",
    "WeTypeReplicaWidget",
    "WeTypeReplicaVoiceActivity",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    require(WORKFLOW.is_file(), f"missing workflow: {WORKFLOW.relative_to(ROOT)}")
    require(not LEGACY_WORKFLOW.exists(), "legacy workflow would run a duplicate incomplete build matrix")
    require(BUILD_SCRIPT.is_file(), f"missing build script: {BUILD_SCRIPT.relative_to(ROOT)}")
    require(GIT_ATTRIBUTES.is_file(), "missing .gitattributes line-ending policy")

    workflow = WORKFLOW.read_text(encoding="utf-8")
    build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
    validate_script = VALIDATE_SCRIPT.read_text(encoding="utf-8")
    attributes = GIT_ATTRIBUTES.read_text(encoding="utf-8")

    require("macos-" in workflow, "workflow must use a macOS runner")
    require("actions/upload-artifact@v4" in workflow, "workflow must upload artifacts")
    require("if: always()" in workflow, "workflow must upload logs even after failure")
    require("ci_unsigned_build.sh" in workflow, "workflow must call the repository build script")
    require("*.sh text eol=lf" in attributes, "shell scripts must be stored with LF line endings")
    require("CODE_SIGNING_ALLOWED=NO" in build_script, "device build must disable signing")
    require("generic/platform=iOS" in build_script, "device build must use the iOS device destination")
    require("Payload" in build_script and ".ipa" in build_script, "build script must package an IPA")

    for scheme in SCHEMES:
        require(scheme in build_script, f"build script omits {scheme}")
        require(scheme in validate_script, f"validation script omits {scheme}")

    for script in (BUILD_SCRIPT, VALIDATE_SCRIPT):
        staged = subprocess.check_output(
            ["git", "show", f":{script.relative_to(ROOT).as_posix()}"], cwd=ROOT
        )
        require(b"\r\n" not in staged, f"staged {script.name} contains CRLF line endings")

    print("CI configuration verifier passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"CI configuration verifier failed: {error}", file=sys.stderr)
        raise SystemExit(1)
