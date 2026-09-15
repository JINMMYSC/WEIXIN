#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts/claw-base"
UNSIGNED_APP="$ARTIFACTS_DIR/unsigned/Payload/ClawBaseHost.app"
SIGNED_ROOT="$ARTIFACTS_DIR/signed"
SIGNED_APP="$SIGNED_ROOT/Payload/ClawBaseHost.app"
TEMP_DIR="$ARTIFACTS_DIR/signing-temp"
LOG_DIR="$ARTIFACTS_DIR/logs"
LOG_FILE="$LOG_DIR/signed-validation.log"
SIGNED_IPA="$ARTIFACTS_DIR/ClawBase-3.5.3-3.5.3-signed.ipa"

SIGNING_IDENTITY="${WT_SIGNING_IDENTITY:?Set WT_SIGNING_IDENTITY to the imported codesigning identity hash}"
HOST_PROFILE="${WT_HOST_PROFILE_PATH:?Set WT_HOST_PROFILE_PATH to the Host provisioning profile}"
KEYBOARD_PROFILE="${WT_KEYBOARD_PROFILE_PATH:?Set WT_KEYBOARD_PROFILE_PATH to the Keyboard provisioning profile}"
SHARE_PROFILE="${WT_SHARE_PROFILE_PATH:-}"
WIDGET_PROFILE="${WT_WIDGET_PROFILE_PATH:-}"
VOICE_ACTIVITY_PROFILE="${WT_VOICE_ACTIVITY_PROFILE_PATH:-}"
REQUIRE_FULL_PACKAGE="${WT_REQUIRE_FULL_PACKAGE:-0}"

EXPECTED_TEAM_ID="X5G6AN3DYX"
EXPECTED_APP_GROUP="group.7518554"
EXPECTED_VERSION="3.5.3"
EXPECTED_BUILD="3.5.3"
EXPECTED_KEYBOARD_PRINCIPAL="HamsterKeyboard.HamsterKeyboardInputViewController"

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT
fail() { echo "CLAW BASE SIGNING ERROR: $*" >&2; exit 1; }
plist_value() { /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null; }
require_equal() { [[ "$2" == "$3" ]] || fail "$1 mismatch: expected '$3', got '$2'"; }

relative_path() {
  case "$1" in
    keyboard) echo "PlugIns/HamsterKeyboard.appex" ;;
    share) echo "PlugIns/ClawBaseShare.appex" ;;
    widget) echo "PlugIns/ClawBaseWidget.appex" ;;
    voiceactivity) echo "PlugIns/ClawBaseVoiceActivity.appex" ;;
    *) fail "unknown component '$1'" ;;
  esac
}

bundle_id() {
  case "$1" in
    host) echo "app.lgm.7517" ;;
    keyboard) echo "app.lgm.7517.123" ;;
    share) echo "app.lgm.7517.share" ;;
    widget) echo "app.lgm.7517.widget" ;;
    voiceactivity) echo "app.lgm.7517.voiceactivity" ;;
    *) fail "unknown component '$1'" ;;
  esac
}

profile_path() {
  case "$1" in
    host) echo "$HOST_PROFILE" ;;
    keyboard) echo "$KEYBOARD_PROFILE" ;;
    share) echo "$SHARE_PROFILE" ;;
    widget) echo "$WIDGET_PROFILE" ;;
    voiceactivity) echo "$VOICE_ACTIVITY_PROFILE" ;;
    *) fail "unknown component '$1'" ;;
  esac
}

application_id() { echo "$EXPECTED_TEAM_ID.$(bundle_id "$1")"; }

require_group() {
  local plist="$1" key_path="$2" label="$3"
  /usr/libexec/PlistBuddy -c "Print :$key_path" "$plist" 2>/dev/null | /usr/bin/grep -Fq "$EXPECTED_APP_GROUP" \
    || fail "$label does not contain required App Group '$EXPECTED_APP_GROUP'"
}

require_profile_keychain_group() {
  local plist="$1" key_path="$2" label="$3" expected="$4" index=0 allowed
  while allowed="$(plist_value "$plist" "$key_path:$index")"; do
    [[ "$allowed" == "$expected" ]] && return 0
    [[ "$allowed" == *"*" && "$expected" == "${allowed%\*}"* ]] && return 0
    index=$((index + 1))
  done
  fail "$label does not allow keychain group '$expected'"
}

build_minimal_entitlements() {
  local output="$1" app_id="$2" keychain_group="$3"
  /usr/bin/plutil -create xml1 "$output"
  /usr/libexec/PlistBuddy -c "Add :application-identifier string $app_id" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.developer.team-identifier string $EXPECTED_TEAM_ID" "$output"
  /usr/libexec/PlistBuddy -c "Add :get-task-allow bool false" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups array" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups:0 string $EXPECTED_APP_GROUP" "$output"
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "$output"
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string $keychain_group" "$output"
  /usr/bin/plutil -lint "$output" >/dev/null
}

validate_bundle_metadata() {
  require_equal "Host CFBundleIdentifier" "$(plist_value "$SIGNED_APP/Info.plist" CFBundleIdentifier)" "$(bundle_id host)"
  require_equal "Host version" "$(plist_value "$SIGNED_APP/Info.plist" CFBundleShortVersionString)" "$EXPECTED_VERSION"
  require_equal "Host build" "$(plist_value "$SIGNED_APP/Info.plist" CFBundleVersion)" "$EXPECTED_BUILD"
  local name path info
  for name in keyboard share widget voiceactivity; do
    path="$SIGNED_APP/$(relative_path "$name")"
    [[ -d "$path" ]] || continue
    info="$path/Info.plist"
    require_equal "$name CFBundleIdentifier" "$(plist_value "$info" CFBundleIdentifier)" "$(bundle_id "$name")"
    require_equal "$name version" "$(plist_value "$info" CFBundleShortVersionString)" "$EXPECTED_VERSION"
    require_equal "$name build" "$(plist_value "$info" CFBundleVersion)" "$EXPECTED_BUILD"
  done
  local keyboard_info="$SIGNED_APP/$(relative_path keyboard)/Info.plist"
  require_equal "Keyboard extension point" "$(plist_value "$keyboard_info" NSExtension:NSExtensionPointIdentifier)" "com.apple.keyboard-service"
  require_equal "Keyboard principal class" "$(plist_value "$keyboard_info" NSExtension:NSExtensionPrincipalClass)" "$EXPECTED_KEYBOARD_PRINCIPAL"
  require_equal "Keyboard RequestsOpenAccess" "$(plist_value "$keyboard_info" NSExtension:NSExtensionAttributes:RequestsOpenAccess)" "true"
  require_equal "Keyboard PrimaryLanguage" "$(plist_value "$keyboard_info" NSExtension:NSExtensionAttributes:PrimaryLanguage)" "zh-Hans"
}

validate_profile() {
  local name="$1" profile="$2" decoded="$TEMP_DIR/$name-profile.plist" expected_app_id
  expected_app_id="$(application_id "$name")"
  [[ -f "$profile" ]] || fail "$name provisioning profile missing"
  security cms -D -i "$profile" > "$decoded"
  require_equal "$name profile application-identifier" "$(plist_value "$decoded" Entitlements:application-identifier)" "$expected_app_id"
  require_equal "$name profile team identifier" "$(plist_value "$decoded" Entitlements:com.apple.developer.team-identifier)" "$EXPECTED_TEAM_ID"
  require_equal "$name profile get-task-allow" "$(plist_value "$decoded" Entitlements:get-task-allow)" "false"
  require_group "$decoded" Entitlements:com.apple.security.application-groups "$name profile"
  require_profile_keychain_group "$decoded" Entitlements:keychain-access-groups "$name profile" "$expected_app_id"
  build_minimal_entitlements "$TEMP_DIR/$name-entitlements.plist" "$expected_app_id" "$expected_app_id"
}

sign_component() {
  local name="$1" path="$2" profile
  profile="$(profile_path "$name")"
  validate_profile "$name" "$profile"
  rm -rf "$path/_CodeSignature"
  /bin/cp "$profile" "$path/embedded.mobileprovision"
  chmod 0644 "$path/embedded.mobileprovision"
  /usr/bin/codesign --force --sign "$SIGNING_IDENTITY" \
    --entitlements "$TEMP_DIR/$name-entitlements.plist" \
    --generate-entitlement-der "$path"
  /usr/bin/codesign --verify --strict "$path"
}

[[ -d "$UNSIGNED_APP" ]] || fail "unsigned Host app missing at $UNSIGNED_APP"
[[ -f "$HOST_PROFILE" && -f "$KEYBOARD_PROFILE" ]] || fail "Host/Keyboard provisioning profiles missing"

full_profile_count=0
for p in "$SHARE_PROFILE" "$WIDGET_PROFILE" "$VOICE_ACTIVITY_PROFILE"; do [[ -n "$p" ]] && full_profile_count=$((full_profile_count + 1)); done
[[ "$full_profile_count" == "0" || "$full_profile_count" == "3" ]] || fail "Share/Widget/VoiceActivity profiles must be provided together"
FULL_PACKAGE=0
[[ "$full_profile_count" == "3" ]] && FULL_PACKAGE=1
[[ "$REQUIRE_FULL_PACKAGE" != "1" || "$FULL_PACKAGE" == "1" ]] || fail "full package signing required but extension profiles are missing"

rm -rf "$SIGNED_ROOT" "$TEMP_DIR" "$SIGNED_IPA"
mkdir -p "$SIGNED_ROOT/Payload" "$TEMP_DIR" "$LOG_DIR"
ditto "$UNSIGNED_APP" "$SIGNED_APP"

unsigned_extension_count="$(find "$SIGNED_APP/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | /usr/bin/wc -l | /usr/bin/tr -d '[:space:]')"
require_equal "unsigned embedded extension count" "$unsigned_extension_count" "4"

if [[ "$FULL_PACKAGE" != "1" ]]; then
  rm -rf "$SIGNED_APP/$(relative_path share)" "$SIGNED_APP/$(relative_path widget)" "$SIGNED_APP/$(relative_path voiceactivity)"
fi
validate_bundle_metadata

# Extensions must be signed before the containing Host app.
sign_component keyboard "$SIGNED_APP/$(relative_path keyboard)"
if [[ "$FULL_PACKAGE" == "1" ]]; then
  sign_component share "$SIGNED_APP/$(relative_path share)"
  sign_component widget "$SIGNED_APP/$(relative_path widget)"
  sign_component voiceactivity "$SIGNED_APP/$(relative_path voiceactivity)"
fi
sign_component host "$SIGNED_APP"

/usr/bin/codesign --verify --deep --strict "$SIGNED_APP"
validate_bundle_metadata

extension_count="$(find "$SIGNED_APP/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | /usr/bin/wc -l | /usr/bin/tr -d '[:space:]')"
expected_count=1
package_mode="engineering-two-profile"
if [[ "$FULL_PACKAGE" == "1" ]]; then expected_count=4; package_mode="full-four-extension"; fi
require_equal "signed embedded extension count" "$extension_count" "$expected_count"

(
  cd "$SIGNED_ROOT"
  /usr/bin/zip -qry "$SIGNED_IPA" Payload
)

ipa_sha256="$(/usr/bin/shasum -a 256 "$SIGNED_IPA" | /usr/bin/awk '{print $1}')"
{
  echo "ClawBase signed validation: PASS"
  echo "Package mode: $package_mode"
  echo "Host bundle ID: $(bundle_id host)"
  echo "Keyboard bundle ID: $(bundle_id keyboard)"
  [[ "$FULL_PACKAGE" == "1" ]] && echo "Share/Widget/VoiceActivity signing: PASS" || echo "Share/Widget/VoiceActivity signing: BLOCKED_BY_MISSING_PROFILES"
  echo "Version/build: $EXPECTED_VERSION ($EXPECTED_BUILD)"
  echo "Shared App Group: $EXPECTED_APP_GROUP"
  echo "Embedded extension count: $extension_count"
  echo "codesign verification: PASS"
  echo "Signed IPA: $SIGNED_IPA"
  echo "Signed IPA SHA-256: $ipa_sha256"
} | tee "$LOG_FILE"
