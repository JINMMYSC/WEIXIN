#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts/claw-base"
UNSIGNED_APP="$ARTIFACTS_DIR/unsigned/Payload/ClawBaseHost.app"
SIGNED_ROOT="$ARTIFACTS_DIR/signed"
SIGNED_APP="$SIGNED_ROOT/Payload/ClawBaseHost.app"
KEYBOARD_RELATIVE="PlugIns/HamsterKeyboard.appex"
KEYBOARD_SOURCE="$UNSIGNED_APP/$KEYBOARD_RELATIVE"
KEYBOARD_APP="$SIGNED_APP/$KEYBOARD_RELATIVE"
TEMP_DIR="$ARTIFACTS_DIR/signing-temp"
LOG_DIR="$ARTIFACTS_DIR/logs"
LOG_FILE="$LOG_DIR/signed-validation.log"
SIGNED_IPA="$ARTIFACTS_DIR/ClawBase-3.0.1-2-signed.ipa"

SIGNING_IDENTITY="${WT_SIGNING_IDENTITY:?Set WT_SIGNING_IDENTITY to the imported codesigning identity hash}"
HOST_PROFILE="${WT_HOST_PROFILE_PATH:?Set WT_HOST_PROFILE_PATH to the Host provisioning profile}"
KEYBOARD_PROFILE="${WT_KEYBOARD_PROFILE_PATH:?Set WT_KEYBOARD_PROFILE_PATH to the Keyboard provisioning profile}"

EXPECTED_HOST_BUNDLE_ID="app.lgm.7517"
EXPECTED_KEYBOARD_BUNDLE_ID="app.lgm.7517.123"
EXPECTED_TEAM_ID="X5G6AN3DYX"
EXPECTED_HOST_APPLICATION_ID="X5G6AN3DYX.app.lgm.7517"
EXPECTED_KEYBOARD_APPLICATION_ID="X5G6AN3DYX.app.lgm.7517.123"
EXPECTED_HOST_KEYCHAIN_GROUP="$EXPECTED_HOST_APPLICATION_ID"
EXPECTED_KEYBOARD_KEYCHAIN_GROUP="$EXPECTED_KEYBOARD_APPLICATION_ID"
EXPECTED_APP_GROUP="group.7518554"
EXPECTED_VERSION="3.0.1"
EXPECTED_BUILD="2"
EXPECTED_KEYBOARD_PRINCIPAL="HamsterKeyboard.HamsterKeyboardInputViewController"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

fail() {
  echo "CLAW BASE SIGNING ERROR: $*" >&2
  exit 1
}

plist_value() {
  local plist="$1"
  local key_path="$2"
  /usr/libexec/PlistBuddy -c "Print :$key_path" "$plist" 2>/dev/null
}

require_equal() {
  local label="$1"
  local actual="$2"
  local expected="$3"
  [[ "$actual" == "$expected" ]] || fail "$label mismatch: expected '$expected', got '$actual'"
}

require_group() {
  local plist="$1"
  local key_path="$2"
  local label="$3"
  /usr/libexec/PlistBuddy -c "Print :$key_path" "$plist" 2>/dev/null | /usr/bin/grep -Fq "$EXPECTED_APP_GROUP" \
    || fail "$label does not contain required App Group '$EXPECTED_APP_GROUP'"
}

require_profile_keychain_group() {
  local plist="$1"
  local key_path="$2"
  local label="$3"
  local expected="$4"
  local index=0
  local allowed
  while allowed="$(plist_value "$plist" "$key_path:$index")"; do
    if [[ "$allowed" == "$expected" ]]; then
      return 0
    fi
    if [[ "$allowed" == *"*" && "$expected" == "${allowed%\*}"* ]]; then
      return 0
    fi
    index=$((index + 1))
  done
  fail "$label does not allow keychain group '$expected'"
}

build_minimal_entitlements() {
  local output="$1"
  local application_id="$2"
  local keychain_group="$3"
  /usr/bin/plutil -create xml1 "$output"
  /usr/libexec/PlistBuddy -c "Add :application-identifier string $application_id" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.developer.team-identifier string $EXPECTED_TEAM_ID" "$output"
  /usr/libexec/PlistBuddy -c "Add :get-task-allow bool false" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups array" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups:0 string $EXPECTED_APP_GROUP" "$output"
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "$output"
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string $keychain_group" "$output"
  /usr/bin/plutil -lint "$output" >/dev/null
}

require_single_array_value() {
  local plist="$1"
  local key_path="$2"
  local label="$3"
  local expected="$4"
  require_equal "$label" "$(plist_value "$plist" "$key_path:0")" "$expected"
  if plist_value "$plist" "$key_path:1" >/dev/null 2>&1; then
    fail "$label contains more than one value"
  fi
}

require_minimal_signed_entitlements() {
  local plist="$1"
  local label="$2"
  local application_id="$3"
  local keychain_group="$4"
  local key_count
  require_equal "$label application-identifier" "$(plist_value "$plist" application-identifier)" "$application_id"
  require_equal "$label team-identifier" "$(plist_value "$plist" com.apple.developer.team-identifier)" "$EXPECTED_TEAM_ID"
  require_equal "$label get-task-allow" "$(plist_value "$plist" get-task-allow)" "false"
  require_single_array_value "$plist" com.apple.security.application-groups "$label App Group" "$EXPECTED_APP_GROUP"
  require_single_array_value "$plist" keychain-access-groups "$label keychain group" "$keychain_group"
  key_count="$(/usr/bin/grep -o '<key>' "$plist" | /usr/bin/wc -l | /usr/bin/tr -d '[:space:]')"
  require_equal "$label entitlement key count" "$key_count" "5"
}

validate_bundle_metadata() {
  local host_info="$SIGNED_APP/Info.plist"
  local keyboard_info="$KEYBOARD_APP/Info.plist"
  require_equal "Host CFBundleIdentifier" "$(plist_value "$host_info" CFBundleIdentifier)" "$EXPECTED_HOST_BUNDLE_ID"
  require_equal "Keyboard CFBundleIdentifier" "$(plist_value "$keyboard_info" CFBundleIdentifier)" "$EXPECTED_KEYBOARD_BUNDLE_ID"
  require_equal "Host version" "$(plist_value "$host_info" CFBundleShortVersionString)" "$EXPECTED_VERSION"
  require_equal "Host build" "$(plist_value "$host_info" CFBundleVersion)" "$EXPECTED_BUILD"
  require_equal "Keyboard version" "$(plist_value "$keyboard_info" CFBundleShortVersionString)" "$EXPECTED_VERSION"
  require_equal "Keyboard build" "$(plist_value "$keyboard_info" CFBundleVersion)" "$EXPECTED_BUILD"
  require_equal "Keyboard extension point" "$(plist_value "$keyboard_info" NSExtension:NSExtensionPointIdentifier)" "com.apple.keyboard-service"
  require_equal "Keyboard principal class" "$(plist_value "$keyboard_info" NSExtension:NSExtensionPrincipalClass)" "$EXPECTED_KEYBOARD_PRINCIPAL"
  require_equal "Keyboard RequestsOpenAccess" "$(plist_value "$keyboard_info" NSExtension:NSExtensionAttributes:RequestsOpenAccess)" "true"
  require_equal "Keyboard PrimaryLanguage" "$(plist_value "$keyboard_info" NSExtension:NSExtensionAttributes:PrimaryLanguage)" "zh-Hans"
}

[[ -d "$UNSIGNED_APP" ]] || fail "unsigned Host app missing at $UNSIGNED_APP"
[[ -d "$KEYBOARD_SOURCE" ]] || fail "Keyboard extension missing at $KEYBOARD_SOURCE"
[[ -f "$HOST_PROFILE" ]] || fail "Host provisioning profile missing"
[[ -f "$KEYBOARD_PROFILE" ]] || fail "Keyboard provisioning profile missing"

extension_count="$(find "$UNSIGNED_APP/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | /usr/bin/wc -l | /usr/bin/tr -d '[:space:]')"
require_equal "embedded extension count" "$extension_count" "1"

rm -rf "$SIGNED_ROOT" "$TEMP_DIR" "$SIGNED_IPA"
mkdir -p "$SIGNED_ROOT/Payload" "$TEMP_DIR" "$LOG_DIR"
ditto "$UNSIGNED_APP" "$SIGNED_APP"
validate_bundle_metadata

security cms -D -i "$HOST_PROFILE" > "$TEMP_DIR/host-profile.plist"
security cms -D -i "$KEYBOARD_PROFILE" > "$TEMP_DIR/keyboard-profile.plist"

require_equal "Host profile application-identifier" "$(plist_value "$TEMP_DIR/host-profile.plist" Entitlements:application-identifier)" "$EXPECTED_HOST_APPLICATION_ID"
require_equal "Keyboard profile application-identifier" "$(plist_value "$TEMP_DIR/keyboard-profile.plist" Entitlements:application-identifier)" "$EXPECTED_KEYBOARD_APPLICATION_ID"
require_equal "Host profile team identifier" "$(plist_value "$TEMP_DIR/host-profile.plist" Entitlements:com.apple.developer.team-identifier)" "$EXPECTED_TEAM_ID"
require_equal "Keyboard profile team identifier" "$(plist_value "$TEMP_DIR/keyboard-profile.plist" Entitlements:com.apple.developer.team-identifier)" "$EXPECTED_TEAM_ID"
require_equal "Host profile get-task-allow" "$(plist_value "$TEMP_DIR/host-profile.plist" Entitlements:get-task-allow)" "false"
require_equal "Keyboard profile get-task-allow" "$(plist_value "$TEMP_DIR/keyboard-profile.plist" Entitlements:get-task-allow)" "false"
require_group "$TEMP_DIR/host-profile.plist" Entitlements:com.apple.security.application-groups "Host profile"
require_group "$TEMP_DIR/keyboard-profile.plist" Entitlements:com.apple.security.application-groups "Keyboard profile"
require_profile_keychain_group "$TEMP_DIR/host-profile.plist" Entitlements:keychain-access-groups "Host profile" "$EXPECTED_HOST_KEYCHAIN_GROUP"
require_profile_keychain_group "$TEMP_DIR/keyboard-profile.plist" Entitlements:keychain-access-groups "Keyboard profile" "$EXPECTED_KEYBOARD_KEYCHAIN_GROUP"

build_minimal_entitlements "$TEMP_DIR/host-entitlements.plist" "$EXPECTED_HOST_APPLICATION_ID" "$EXPECTED_HOST_KEYCHAIN_GROUP"
build_minimal_entitlements "$TEMP_DIR/keyboard-entitlements.plist" "$EXPECTED_KEYBOARD_APPLICATION_ID" "$EXPECTED_KEYBOARD_KEYCHAIN_GROUP"

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
require_minimal_signed_entitlements "$TEMP_DIR/keyboard-codesign-entitlements.plist" "Keyboard codesign entitlements" "$EXPECTED_KEYBOARD_APPLICATION_ID" "$EXPECTED_KEYBOARD_KEYCHAIN_GROUP"
require_minimal_signed_entitlements "$TEMP_DIR/host-codesign-entitlements.plist" "Host codesign entitlements" "$EXPECTED_HOST_APPLICATION_ID" "$EXPECTED_HOST_KEYCHAIN_GROUP"

/usr/bin/codesign --verify --strict "$KEYBOARD_APP"
/usr/bin/codesign --verify --deep --strict "$SIGNED_APP"
validate_bundle_metadata

(
  cd "$SIGNED_ROOT"
  /usr/bin/zip -qry "$SIGNED_IPA" Payload
)

ipa_sha256="$(/usr/bin/shasum -a 256 "$SIGNED_IPA" | /usr/bin/awk '{print $1}')"
host_profile_sha256="$(/usr/bin/shasum -a 256 "$SIGNED_APP/embedded.mobileprovision" | /usr/bin/awk '{print $1}')"
keyboard_profile_sha256="$(/usr/bin/shasum -a 256 "$KEYBOARD_APP/embedded.mobileprovision" | /usr/bin/awk '{print $1}')"

{
  echo "ClawBase signed validation: PASS"
  echo "Host bundle ID: $EXPECTED_HOST_BUNDLE_ID"
  echo "Keyboard bundle ID: $EXPECTED_KEYBOARD_BUNDLE_ID"
  echo "Version/build: $EXPECTED_VERSION ($EXPECTED_BUILD)"
  echo "Shared App Group: $EXPECTED_APP_GROUP"
  echo "Host profile SHA-256: $host_profile_sha256"
  echo "Keyboard profile SHA-256: $keyboard_profile_sha256"
  echo "Embedded extension count: $extension_count"
  echo "codesign verification: PASS"
  echo "Signed IPA: $SIGNED_IPA"
  echo "Signed IPA SHA-256: $ipa_sha256"
} | tee "$LOG_FILE"
