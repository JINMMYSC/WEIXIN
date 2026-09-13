from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "ios-signed-device-ci.yml"
SCRIPT = ROOT / "XcodeIntegration" / "ci_signed_device_package.sh"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    require(WORKFLOW.is_file(), f"missing signed-device workflow: {WORKFLOW.relative_to(ROOT)}")
    require(SCRIPT.is_file(), f"missing signed-device signing script: {SCRIPT.relative_to(ROOT)}")

    workflow = WORKFLOW.read_text(encoding="utf-8")
    script = SCRIPT.read_text(encoding="utf-8")

    require("push:" in workflow, "signed workflow must trigger from pushes to the diagnostic branch")
    require("work/v14-signed-device" in workflow, "signed workflow must stay isolated to work/v14-signed-device")
    require("- main" not in workflow, "signed workflow must not run from main")
    require("macos-15" in workflow, "signed workflow must use the macOS runner")
    require("ci_unsigned_build.sh" in workflow, "signed workflow must reuse the unsigned build gate")
    require("ci_signed_device_package.sh" in workflow, "signed workflow must invoke the signing script")
    require("python3 Tools/verify_signed_device_ci.py" in workflow, "signed workflow must run its static verifier")
    require("actions/upload-artifact@v4" in workflow, "signed workflow must upload artifacts")
    require("if: always()" in workflow, "signed workflow must always upload logs and clean up")
    require("security delete-keychain" in workflow, "signed workflow must delete its ephemeral keychain")

    for secret in (
        "WT_SIGNING_P12_BASE64",
        "WT_SIGNING_P12_PASSWORD",
        "WT_HOST_PROFILE_BASE64",
        "WT_KEYBOARD_PROFILE_BASE64",
    ):
        require(secret in workflow, f"workflow omits secret {secret}")

    require("app.lgm.7517" in script, "Host identifier gate missing")
    require("app.lgm.7517.123" in script, "Keyboard identifier gate missing")
    require("X5G6AN3DYX.app.lgm.7517" in script, "Host application-identifier gate missing")
    require("X5G6AN3DYX.app.lgm.7517.123" in script, "Keyboard application-identifier gate missing")
    require("group.7518554" in script, "App Group gate missing")
    require("# SIGN_KEYBOARD_FIRST" in script, "Keyboard signing marker missing")
    require("# SIGN_HOST_LAST" in script, "Host signing marker missing")
    require(
        script.index("# SIGN_KEYBOARD_FIRST") < script.index("# SIGN_HOST_LAST"),
        "Keyboard must be signed before Host",
    )
    require("codesign --verify --strict" in script, "Keyboard codesign verification gate missing")
    require("codesign --verify --deep --strict" in script, "Host deep codesign verification gate missing")
    require("application-identifier" in script, "post-sign entitlement identifier gate missing")
    require("embedded.mobileprovision" in script, "profiles must be embedded in both signed bundles")
    require("WeTypeReplicaApp-sideload-diagnostic-signed.ipa" in script, "signed IPA output path missing")

    print("Signed-device CI configuration verifier passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Signed-device CI configuration verifier failed: {error}", file=sys.stderr)
        raise SystemExit(1)
