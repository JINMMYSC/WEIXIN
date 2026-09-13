# Signed Device CI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a GitHub Actions artifact containing a correctly signed Host + Keyboard diagnostic IPA with separate provisioning profiles and hard post-signing validation gates.

**Architecture:** Keep the verified unsigned workflow unchanged. Add one signing-focused shell script that consumes the unsigned Host + Keyboard app bundle, signs the Keyboard first and Host last, validates identifiers/profiles/App Group/codesign output, and packages a signed IPA. Add a separate manual-dispatch GitHub Actions workflow that reconstructs signing materials from repository secrets in an ephemeral keychain, runs the existing unsigned build, invokes the signing script, uploads only redacted logs and the signed IPA, and always destroys temporary signing material.

**Tech Stack:** GitHub Actions (`macos-15`), Xcode 16.4 toolchain, XcodeGen, Bash, `security`, `codesign`, `plutil`, `ditto`, GitHub CLI.

## Global Constraints

- Work only on `work/v14-signed-device`; do not alter the authoritative `work/v14-ci` behavior baseline.
- Host bundle ID is exactly `app.lgm.7517`.
- Keyboard bundle ID is exactly `app.lgm.7517.123`.
- Shared App Group is exactly `group.7518554`.
- Apple Developer Team ID is exactly `X5G6AN3DYX`.
- Host profile and Keyboard profile remain distinct; never reuse one profile for both code-signing units.
- Required signing order is Keyboard Extension first, Host App last.
- Signing materials must never be committed, printed, or uploaded as standalone artifacts.
- The workflow must fail before signed artifact upload when any identifier, App Group, provisioning profile, or codesign validation gate fails.
- The existing `.github/workflows/ios-unsigned-ci.yml` and `XcodeIntegration/ci_unsigned_build.sh` remain the authoritative unsigned compile/build path.

---

### Task 1: Add a static signed-CI contract verifier

**Files:**
- Create: `tools/verify_signed_device_ci.py`
- Test: `tools/verify_signed_device_ci.py`

**Interfaces:**
- Consumes: repository files `.github/workflows/ios-signed-device-ci.yml` and `XcodeIntegration/ci_signed_device_package.sh`.
- Produces: a zero exit code only when the signed workflow/script contain all required secret names, signing order, exact identifiers, App Group checks, codesign checks, cleanup, and artifact upload behavior.

- [ ] **Step 1: Create the verifier in a failing state against the current repository**

Implement assertions equivalent to:

```python
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "ios-signed-device-ci.yml"
SCRIPT = ROOT / "XcodeIntegration" / "ci_signed_device_package.sh"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> int:
    require(WORKFLOW.is_file(), "missing signed-device workflow")
    require(SCRIPT.is_file(), "missing signed-device signing script")
    workflow = WORKFLOW.read_text(encoding="utf-8")
    script = SCRIPT.read_text(encoding="utf-8")

    for secret in (
        "WT_SIGNING_P12_BASE64",
        "WT_SIGNING_P12_PASSWORD",
        "WT_HOST_PROFILE_BASE64",
        "WT_KEYBOARD_PROFILE_BASE64",
    ):
        require(secret in workflow, f"workflow omits secret {secret}")

    require("ci_unsigned_build.sh" in workflow, "signed workflow must reuse unsigned build gate")
    require("ci_signed_device_package.sh" in workflow, "signed workflow must invoke signing script")
    require("if: always()" in workflow, "signed workflow must always clean signing material")
    require("security delete-keychain" in workflow, "workflow must delete ephemeral keychain")
    require("app.lgm.7517" in script, "Host identifier gate missing")
    require("app.lgm.7517.123" in script, "Keyboard identifier gate missing")
    require("group.7518554" in script, "App Group gate missing")
    require(script.index("WeTypeReplicaKeyboard.appex") < script.rindex("WeTypeReplicaApp.app"), "Keyboard signing must precede Host signing")
    require("codesign --verify" in script, "codesign verification gate missing")
    require("application-identifier" in script, "entitlement identifier gate missing")
    print("Signed-device CI configuration verifier passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as error:
        print(f"Signed-device CI configuration verifier failed: {error}", file=sys.stderr)
        raise SystemExit(1)
```

- [ ] **Step 2: Run the verifier and confirm the expected failure**

Run:

```bash
python tools/verify_signed_device_ci.py
```

Expected: non-zero exit with `missing signed-device workflow` before Tasks 2–3 create the required files.

- [ ] **Step 3: Commit the verifier together with Tasks 2–3 after it passes**

Do not make an isolated red-only commit. The verifier becomes the local regression gate for the implementation commit.

---

### Task 2: Add deterministic Host + Keyboard signing and validation

**Files:**
- Create: `XcodeIntegration/ci_signed_device_package.sh`
- Modify: `CI_FIX_LOG.md`
- Test: `tools/verify_signed_device_ci.py`

**Interfaces:**
- Consumes environment variables `WT_SIGNING_IDENTITY`, `WT_HOST_PROFILE_PATH`, `WT_KEYBOARD_PROFILE_PATH`, and the unsigned app produced at `artifacts/unsigned/Payload/WeTypeReplicaApp.app`.
- Produces `artifacts/WeTypeReplicaApp-sideload-diagnostic-signed.ipa` and `artifacts/logs/signed-device-validation.log`.

- [ ] **Step 1: Validate the unsigned bundle shape before touching signatures**

The script must fail unless these exist:

```bash
UNSIGNED_APP="$ROOT_DIR/artifacts/unsigned/Payload/WeTypeReplicaApp.app"
KEYBOARD_RELATIVE="PlugIns/WeTypeReplicaKeyboard.appex"
KEYBOARD_SOURCE="$UNSIGNED_APP/$KEYBOARD_RELATIVE"
[[ -d "$UNSIGNED_APP" ]] || fail "unsigned Host app missing"
[[ -d "$KEYBOARD_SOURCE" ]] || fail "Keyboard extension missing"
[[ "$(find "$UNSIGNED_APP/PlugIns" -maxdepth 1 -type d -name '*.appex' | wc -l | tr -d ' ')" == "1" ]] || fail "diagnostic package must contain exactly one extension"
```

- [ ] **Step 2: Copy the unsigned app to a signed staging directory and decode profile metadata without logging raw profile content**

Use:

```bash
SIGNED_ROOT="$ROOT_DIR/artifacts/signed"
SIGNED_APP="$SIGNED_ROOT/Payload/WeTypeReplicaApp.app"
TEMP_DIR="$ROOT_DIR/artifacts/signing-temp"
rm -rf "$SIGNED_ROOT" "$TEMP_DIR"
mkdir -p "$SIGNED_ROOT/Payload" "$TEMP_DIR"
ditto "$UNSIGNED_APP" "$SIGNED_APP"
security cms -D -i "$WT_HOST_PROFILE_PATH" > "$TEMP_DIR/host-profile.plist"
security cms -D -i "$WT_KEYBOARD_PROFILE_PATH" > "$TEMP_DIR/keyboard-profile.plist"
plutil -extract Entitlements xml1 -o "$TEMP_DIR/host-entitlements.plist" "$TEMP_DIR/host-profile.plist"
plutil -extract Entitlements xml1 -o "$TEMP_DIR/keyboard-entitlements.plist" "$TEMP_DIR/keyboard-profile.plist"
```

The shell must not enable `set -x`.

- [ ] **Step 3: Enforce the profile and Info.plist identifiers before signing**

Read exact values with `plutil -extract ... raw` and require:

```text
Host CFBundleIdentifier = app.lgm.7517
Keyboard CFBundleIdentifier = app.lgm.7517.123
Host profile application-identifier = X5G6AN3DYX.app.lgm.7517
Keyboard profile application-identifier = X5G6AN3DYX.app.lgm.7517.123
```

Validate `group.7518554` in both profile entitlement arrays using `/usr/libexec/PlistBuddy -c 'Print :Entitlements:com.apple.security.application-groups'` piped only to exact-string matching; do not print the full plist.

- [ ] **Step 4: Embed the matching profiles and sign Keyboard before Host**

Implement exactly this order:

```bash
KEYBOARD_APP="$SIGNED_APP/PlugIns/WeTypeReplicaKeyboard.appex"
ditto "$WT_KEYBOARD_PROFILE_PATH" "$KEYBOARD_APP/embedded.mobileprovision"
/usr/bin/codesign --force --sign "$WT_SIGNING_IDENTITY" \
  --entitlements "$TEMP_DIR/keyboard-entitlements.plist" \
  --generate-entitlement-der \
  "$KEYBOARD_APP"

ditto "$WT_HOST_PROFILE_PATH" "$SIGNED_APP/embedded.mobileprovision"
/usr/bin/codesign --force --sign "$WT_SIGNING_IDENTITY" \
  --entitlements "$TEMP_DIR/host-entitlements.plist" \
  --generate-entitlement-der \
  "$SIGNED_APP"
```

Do not use `--deep` while signing; each nested code unit is signed explicitly.

- [ ] **Step 5: Validate actual codesign entitlements after signing**

Capture, but do not dump wholesale to the public log:

```bash
/usr/bin/codesign -d --entitlements "$TEMP_DIR/keyboard-codesign-entitlements.plist" "$KEYBOARD_APP"
/usr/bin/codesign -d --entitlements "$TEMP_DIR/host-codesign-entitlements.plist" "$SIGNED_APP"
```

Require the same `application-identifier` and `group.7518554` values from those two files, then run:

```bash
/usr/bin/codesign --verify --strict "$KEYBOARD_APP"
/usr/bin/codesign --verify --deep --strict "$SIGNED_APP"
```

- [ ] **Step 6: Package only after all gates pass**

Create:

```bash
SIGNED_IPA="$ROOT_DIR/artifacts/WeTypeReplicaApp-sideload-diagnostic-signed.ipa"
(
  cd "$SIGNED_ROOT"
  /usr/bin/zip -qry "$SIGNED_IPA" Payload
)
```

Write only safe validation metadata to `artifacts/logs/signed-device-validation.log`: Host/Keyboard bundle IDs, profile names/UUIDs, expected application identifiers, App Group confirmation, codesign verification result, IPA SHA-256, and extension count.

- [ ] **Step 7: Record the implementation in `CI_FIX_LOG.md`**

Document the observed device-install blocker: the phone-side signer replaced the Host profile/entitlements with the Keyboard profile, producing Host `CFBundleIdentifier=app.lgm.7517` but Host signing `application-identifier=X5G6AN3DYX.app.lgm.7517.123`. Record that the CI fix signs nested Keyboard first with `7517ext`, Host last with `7517`, and hard-fails on mismatch.

---

### Task 3: Add the isolated Signed Device GitHub Actions workflow

**Files:**
- Create: `.github/workflows/ios-signed-device-ci.yml`
- Test: `tools/verify_signed_device_ci.py`

**Interfaces:**
- Consumes repository secrets `WT_SIGNING_P12_BASE64`, `WT_SIGNING_P12_PASSWORD`, `WT_HOST_PROFILE_BASE64`, `WT_KEYBOARD_PROFILE_BASE64`.
- Produces the signed IPA artifact and redacted validation/build logs; never uploads standalone P12 or provisioning files.

- [ ] **Step 1: Add a manual-dispatch-only workflow**

Use `workflow_dispatch` only so ordinary branch pushes keep the verified unsigned CI behavior separate. The job runs on `macos-15`, checks out the branch, installs XcodeGen, and reconstructs secret files under `$RUNNER_TEMP/wetype-signing` with restrictive permissions.

- [ ] **Step 2: Create and configure an ephemeral keychain without printing passwords**

The workflow shell must perform equivalent commands:

```bash
set -Eeuo pipefail
SIGNING_DIR="$RUNNER_TEMP/wetype-signing"
KEYCHAIN_PATH="$RUNNER_TEMP/wetype-signing.keychain-db"
KEYCHAIN_PASSWORD="$(openssl rand -hex 24)"
mkdir -p "$SIGNING_DIR"
chmod 700 "$SIGNING_DIR"
printf '%s' "$WT_SIGNING_P12_BASE64" | base64 --decode > "$SIGNING_DIR/signing.p12"
printf '%s' "$WT_HOST_PROFILE_BASE64" | base64 --decode > "$SIGNING_DIR/host.mobileprovision"
printf '%s' "$WT_KEYBOARD_PROFILE_BASE64" | base64 --decode > "$SIGNING_DIR/keyboard.mobileprovision"
chmod 600 "$SIGNING_DIR"/*
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$SIGNING_DIR/signing.p12" -k "$KEYCHAIN_PATH" -P "$WT_SIGNING_P12_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security list-keychains -d user -s "$KEYCHAIN_PATH"
```

Select the single usable codesigning identity hash from that keychain and export only the hash into `GITHUB_ENV` as `WT_SIGNING_IDENTITY`. Do not print the P12 password or binary material.

- [ ] **Step 3: Reuse the current unsigned build gate and then sign**

Run:

```bash
chmod +x XcodeIntegration/ci_unsigned_build.sh XcodeIntegration/ci_signed_device_package.sh
XcodeIntegration/ci_unsigned_build.sh
WT_HOST_PROFILE_PATH="$RUNNER_TEMP/wetype-signing/host.mobileprovision" \
WT_KEYBOARD_PROFILE_PATH="$RUNNER_TEMP/wetype-signing/keyboard.mobileprovision" \
XcodeIntegration/ci_signed_device_package.sh
```

The workflow must not alter or bypass Core tests/XcodeGen/real iOS SDK compilation already performed by the unsigned script.

- [ ] **Step 4: Upload safe logs on every run and signed IPA only on success**

Use `actions/upload-artifact@v4` with:

```text
logs artifact: artifacts/logs/**, if: always()
signed artifact: artifacts/WeTypeReplicaApp-sideload-diagnostic-signed.ipa, if: success()
```

Do not include `$RUNNER_TEMP/wetype-signing`, `.p12`, or standalone `.mobileprovision` paths.

- [ ] **Step 5: Always destroy temporary signing files and keychain**

An `if: always()` cleanup step must run:

```bash
security delete-keychain "$KEYCHAIN_PATH" 2>/dev/null || true
rm -rf "$RUNNER_TEMP/wetype-signing" "$KEYCHAIN_PATH"
```

- [ ] **Step 6: Run the local static verifier**

Run:

```bash
python tools/verify_signed_device_ci.py
```

Expected: `Signed-device CI configuration verifier passed`.

- [ ] **Step 7: Commit the implementation**

Run:

```bash
git add .github/workflows/ios-signed-device-ci.yml XcodeIntegration/ci_signed_device_package.sh tools/verify_signed_device_ci.py CI_FIX_LOG.md docs/superpowers/plans/2026-09-13-signed-device-ci.md
git commit -m "signing: add dual-profile device CI"
```

---

### Task 4: Provision GitHub Secrets and run the CI repair loop

**Files:**
- No signing material is added to git.
- Modify `CI_FIX_LOG.md` only when a run exposes a real causal failure or when the final run succeeds.

**Interfaces:**
- Consumes local P12 and provisioning files plus a legitimately known P12 password.
- Produces repository Actions secrets and a green signed-device workflow run.

- [ ] **Step 1: Push committed source changes to `work/v14-signed-device`**

Verify `origin` is HTTPS and the branch still descends from `fec044bdec7d37b0e3f33647481b52baf146a9cc`, then push with the authenticated `JINMMYSC` account.

- [ ] **Step 2: Set binary secrets through stdin without echoing values**

Use pipelines equivalent to:

```bash
base64 -w 0 /secure/path/signing.p12 | gh secret set WT_SIGNING_P12_BASE64 --repo JINMMYSC/WEIXIN
base64 -w 0 /secure/path/7517.mobileprovision | gh secret set WT_HOST_PROFILE_BASE64 --repo JINMMYSC/WEIXIN
base64 -w 0 /secure/path/7517ext.mobileprovision | gh secret set WT_KEYBOARD_PROFILE_BASE64 --repo JINMMYSC/WEIXIN
```

Set `WT_SIGNING_P12_PASSWORD` only from a legitimate known source, using stdin so it is not shown in command output or shell history. Never guess or brute-force the password.

- [ ] **Step 3: Dispatch and watch the signed workflow**

Run:

```bash
gh workflow run ios-signed-device-ci.yml --repo JINMMYSC/WEIXIN --ref work/v14-signed-device
gh run list --repo JINMMYSC/WEIXIN --branch work/v14-signed-device --workflow ios-signed-device-ci.yml --limit 1
gh run watch RUN_ID --repo JINMMYSC/WEIXIN --exit-status
```

- [ ] **Step 4: Repair only the first causal failure on each red run**

For each failure, use:

```bash
gh run view RUN_ID --repo JINMMYSC/WEIXIN --log-failed
```

Make the smallest behavior-preserving fix, update `CI_FIX_LOG.md` with the run ID/root cause/fix/result, commit, push, redispatch, and repeat.

- [ ] **Step 5: Verify the successful artifact**

After a green run, confirm the signed artifact exists, download it locally, compute SHA-256, and inspect the IPA to confirm it contains exactly Host + Keyboard and separate embedded profiles. Record the final commit, run URL, artifact name, and SHA-256 in `CI_FIX_LOG.md`.

- [ ] **Step 6: Final completion evidence**

Report the final branch/commit, green Actions run URL, unsigned build/test status inherited from the run, signed IPA artifact name and SHA-256, and state that only iPhone installation + Keyboard Runtime Validation remains.
