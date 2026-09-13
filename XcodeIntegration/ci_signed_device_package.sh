#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts"
UNSIGNED_APP="$ARTIFACTS_DIR/unsigned/Payload/WeTypeReplicaApp.app"
SIGNED_ROOT="$ARTIFACTS_DIR/signed"
SIGNED_APP="$SIGNED_ROOT/Payload/WeTypeReplicaApp.app"
KEYBOARD_RELATIVE="PlugIns/WeTypeReplicaKeyboard.appex"
KEYBOARD_SOURCE="$UNSIGNED_APP/$KEYBOARD_RELATIVE"
KEYBOARD_APP="$SIGNED_APP/$KEYBOARD_RELATIVE"
TEMP_DIR="$ARTIFACTS_DIR/signing-temp"
LOG_DIR="$ARTIFACTS_DIR/logs"
LOG_FILE="$LOG_DIR/signed-device-validation.log"
SIGNED_IPA="$ARTIFACTS_DIR/WeTypeReplicaApp-sideload-diagnostic-signed.ipa"

SIGNING_IDENTITY="${WT_SIGNING_IDENTITY:?Set WT_SIGNING_IDENTITY to the imported codesigning identity hash}"
HOST_PROFILE="${WT_HOST_PROFILE_PATH:?Set WT_HOST_PROFILE_PATH to the Host provisioning profile}"
KEYBOARD_PROFILE="${WT_KEYBOARD_PROFILE_PATH:?Set WT_KEYBOARD_PROFILE_PATH to the Keyboard provisioning profile}"

EXPECTED_HOST_BUNDLE_ID="app.lgm.7517"
EXPECTED_KEYBOARD_BUNDLE_ID="app.lgm.7517.123"
EXPECTED_HOST_APPLICATION_ID="X5G6AN3DYX.app.lgm.7517"
EXPECTED_KEYBOARD_APPLICATION_ID="X5G6AN3DYX.app.lgm.7517.123"
EXPECTED_APP_GROUP="group.7518554"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

fail() {
  echo "SIGNED DEVICE ERROR: $*" >&2
  exit 1
}

require_equal() {
  local label="$1"
  local actual="$2"
  local expected="$3"
  if [[ "$actual" != "$expected" ]]; then
    fail "$label mismatch: expected '$expected', got '$actual'"
  fi
}

plist_value() {
  local plist="$1"
  local key_path="$2"
  /usr/libexec/PlistBuddy -c "Print :$key_path" "$plist" 2>/dev/null
}

require_group() {
  local plist="$1"
  local key_path="$2"
  local label="$3"
  if ! /usr/libexec/PlistBuddy -c "Print :$key_path" "$plist" 2>/dev/null | /usr/bin/grep -Fq "$EXPECTED_APP_GROUP"; then
    fail "$label does not contain required App Group '$EXPECTED_APP_GROUP'"
  fi
}

[[ -d "$UNSIGNED_APP" ]] || fail "unsigned Host app missing at $UNSIGNED_APP"
[[ -d "$KEYBOARD_SOURCE" ]] || fail "Keyboard extension missing at $KEYBOARD_SOURCE"
[[ -f "$HOST_PROFILE" ]] || fail "Host provisioning profile missing"
[[ -f "$KEYBOARD_PROFILE" ]] || fail "Keyboard provisioning profile missing"

extension_count="$(find "$UNSIGNED_APP/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | wc -l | tr -d '[:space:]')"
require_equal "diagnostic extension count" "$extension_count" "1"

rm -rf "$SIGNED_ROOT" "$TEMP_DIR" "$SIGNED_IPA"
mkdir -p "$SIGNED_ROOT/Payload" "$TEMP_DIR" "$LOG_DIR"
ditto "$UNSIGNED_APP" "$SIGNED_APP"

security cms -D -i "$HOST_PROFILE" > "$TEMP_DIR/host-profile.plist"
security cms -D -i "$KEYBOARD_PROFILE" > "$TEMP_DIR/keyboard-profile.plist"
/usr/bin/plutil -extract Entitlements xml1 -o "$TEMP_DIR/host-entitlements.plist" "$TEMP_DIR/host-profile.plist"
/usr/bin/plutil -extract Entitlements xml1 -o "$TEMP_DIR/keyboard-entitlements.plist" "$TEMP_DIR/keyboard-profile.plist"
/usr/bin/plutil -lint "$TEMP_DIR/host-entitlements.plist" >/dev/null
/usr/bin/plutil -lint "$TEMP_DIR/keyboard-entitlements.plist" >/dev/null

host_bundle_id="$(plist_value "$SIGNED_APP/Info.plist" CFBundleIdentifier)"
keyboard_bundle_id="$(plist_value "$KEYBOARD_APP/Info.plist" CFBundleIdentifier)"
host_profile_application_id="$(plist_value "$TEMP_DIR/host-profile.plist" Entitlements:application-identifier)"
keyboard_profile_application_id="$(plist_value "$TEMP_DIR/keyboard-profile.plist" Entitlements:application-identifier)"

require_equal "Host CFBundleIdentifier" "$host_bundle_id" "$EXPECTED_HOST_BUNDLE_ID"
require_equal "Keyboard CFBundleIdentifier" "$keyboard_bundle_id" "$EXPECTED_KEYBOARD_BUNDLE_ID"
require_equal "Host profile application-identifier" "$host_profile_application_id" "$EXPECTED_HOST_APPLICATION_ID"
require_equal "Keyboard profile application-identifier" "$keyboard_profile_application_id" "$EXPECTED_KEYBOARD_APPLICATION_ID"
require_group "$TEMP_DIR/host-profile.plist" "Entitlements:com.apple.security.application-groups" "Host profile"
require_group "$TEMP_DIR/keyboard-profile.plist" "Entitlements:com.apple.security.application-groups" "Keyboard profile"

host_profile_name="$(plist_value "$TEMP_DIR/host-profile.plist" Name)"
host_profile_uuid="$(plist_value "$TEMP_DIR/host-profile.plist" UUID)"
keyboard_profile_name="$(plist_value "$TEMP_DIR/keyboard-profile.plist" Name)"
keyboard_profile_uuid="$(plist_value "$TEMP_DIR/keyboard-profile.plist" UUID)"

rm -rf "$KEYBOARD_APP/_CodeSignature" "$SIGNED_APP/_CodeSignature"

/bin/cp "$KEYBOARD_PROFILE" "$KEYBOARD_APP/embedded.mobileprovision"
chmod 0644 "$KEYBOARD_APP/embedded.mobileprovision"
# SIGN_KEYBOARD_FIRST
/usr/bin/codesign --force --sign "$SIGNING_IDENTITY" \
  --entitlements "$TEMP_DIR/keyboard-entitlements.plist" \
  --generate-entitlement-der \
  "$KEYBOARD_APP"

/bin/cp "$HOST_PROFILE" "$SIGNED_APP/embedded.mobileprovision"
chmod 0644 "$SIGNED_APP/embedded.mobileprovision"
# SIGN_HOST_LAST
/usr/bin/codesign --force --sign "$SIGNING_IDENTITY" \
  --entitlements "$TEMP_DIR/host-entitlements.plist" \
  --generate-entitlement-der \
  "$SIGNED_APP"

/usr/bin/cmp -s "$KEYBOARD_PROFILE" "$KEYBOARD_APP/embedded.mobileprovision" || fail "Keyboard embedded profile changed during signing"
/usr/bin/cmp -s "$HOST_PROFILE" "$SIGNED_APP/embedded.mobileprovision" || fail "Host embedded profile changed during signing"

/usr/bin/codesign -d --entitlements :- "$KEYBOARD_APP" > "$TEMP_DIR/keyboard-codesign-entitlements.plist" 2> "$TEMP_DIR/keyboard-codesign-display.log"
/usr/bin/codesign -d --entitlements :- "$SIGNED_APP" > "$TEMP_DIR/host-codesign-entitlements.plist" 2> "$TEMP_DIR/host-codesign-display.log"
/usr/bin/plutil -lint "$TEMP_DIR/keyboard-codesign-entitlements.plist" >/dev/null
/usr/bin/plutil -lint "$TEMP_DIR/host-codesign-entitlements.plist" >/dev/null

keyboard_codesign_application_id="$(plist_value "$TEMP_DIR/keyboard-codesign-entitlements.plist" application-identifier)"
host_codesign_application_id="$(plist_value "$TEMP_DIR/host-codesign-entitlements.plist" application-identifier)"
require_equal "Keyboard codesign application-identifier" "$keyboard_codesign_application_id" "$EXPECTED_KEYBOARD_APPLICATION_ID"
require_equal "Host codesign application-identifier" "$host_codesign_application_id" "$EXPECTED_HOST_APPLICATION_ID"
require_group "$TEMP_DIR/keyboard-codesign-entitlements.plist" "com.apple.security.application-groups" "Keyboard codesign entitlements"
require_group "$TEMP_DIR/host-codesign-entitlements.plist" "com.apple.security.application-groups" "Host codesign entitlements"

/usr/bin/codesign --verify --strict "$KEYBOARD_APP"
/usr/bin/codesign --verify --deep --strict "$SIGNED_APP"

(
  cd "$SIGNED_ROOT"
  /usr/bin/zip -qry "$SIGNED_IPA" Payload
)

ipa_sha256="$(/usr/bin/shasum -a 256 "$SIGNED_IPA" | /usr/bin/awk '{print $1}')"
host_profile_sha256="$(/usr/bin/shasum -a 256 "$SIGNED_APP/embedded.mobileprovision" | /usr/bin/awk '{print $1}')"
keyboard_profile_sha256="$(/usr/bin/shasum -a 256 "$KEYBOARD_APP/embedded.mobileprovision" | /usr/bin/awk '{print $1}')"

{
  echo "Signed-device validation: PASS"
  echo "Host bundle ID: $host_bundle_id"
  echo "Keyboard bundle ID: $keyboard_bundle_id"
  echo "Host application-identifier: $host_codesign_application_id"
  echo "Keyboard application-identifier: $keyboard_codesign_application_id"
  echo "Shared App Group: $EXPECTED_APP_GROUP"
  echo "Host profile name: $host_profile_name"
  echo "Host profile UUID: $host_profile_uuid"
  echo "Host profile SHA-256: $host_profile_sha256"
  echo "Keyboard profile name: $keyboard_profile_name"
  echo "Keyboard profile UUID: $keyboard_profile_uuid"
  echo "Keyboard profile SHA-256: $keyboard_profile_sha256"
  echo "Embedded extension count: $extension_count"
  echo "codesign verification: PASS"
  echo "Signed IPA: $SIGNED_IPA"
  echo "Signed IPA SHA-256: $ipa_sha256"
} | tee "$LOG_FILE"
