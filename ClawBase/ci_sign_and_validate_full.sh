#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts/claw-base-full"
UNSIGNED_APP="$ARTIFACTS_DIR/unsigned/Payload/ClawBaseHost.app"
SIGNED_ROOT="$ARTIFACTS_DIR/signed"
SIGNED_APP="$SIGNED_ROOT/Payload/ClawBaseHost.app"
TEMP_DIR="$ARTIFACTS_DIR/signing-temp"
LOG_DIR="$ARTIFACTS_DIR/logs"
SIGNED_IPA="$ARTIFACTS_DIR/ClawBase-3.0.1-2-full-signed.ipa"

SIGNING_IDENTITY="${WT_SIGNING_IDENTITY:?Set WT_SIGNING_IDENTITY}"
HOST_PROFILE="${WT_HOST_PROFILE_PATH:?Set WT_HOST_PROFILE_PATH}"
KEYBOARD_PROFILE="${WT_KEYBOARD_PROFILE_PATH:?Set WT_KEYBOARD_PROFILE_PATH}"
SHARE_PROFILE="${WT_SHARE_PROFILE_PATH:?Set WT_SHARE_PROFILE_PATH}"
WIDGET_PROFILE="${WT_WIDGET_PROFILE_PATH:?Set WT_WIDGET_PROFILE_PATH}"
VOICE_PROFILE="${WT_VOICE_ACTIVITY_PROFILE_PATH:?Set WT_VOICE_ACTIVITY_PROFILE_PATH}"

TEAM_ID="X5G6AN3DYX"
APP_GROUP="group.7518554"
VERSION="3.0.1"
BUILD="2"

fail() { echo "CLAW FULL SIGNING ERROR: $*" >&2; exit 1; }
plist_value() { /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null; }
require_equal() { [[ "$2" == "$3" ]] || fail "$1 mismatch: expected '$3', got '$2'"; }

require_group() {
  local plist="$1"; local label="$2"
  /usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.security.application-groups" "$plist" 2>/dev/null | /usr/bin/grep -Fq "$APP_GROUP" \
    || fail "$label does not contain App Group $APP_GROUP"
}

require_keychain_group() {
  local plist="$1"; local expected="$2"; local label="$3"; local index=0; local allowed
  while allowed="$(plist_value "$plist" "Entitlements:keychain-access-groups:$index")"; do
    [[ "$allowed" == "$expected" ]] && return 0
    [[ "$allowed" == *"*" && "$expected" == "${allowed%\*}"* ]] && return 0
    index=$((index + 1))
  done
  fail "$label does not allow keychain group $expected"
}

build_entitlements() {
  local output="$1"; local bundle="$2"; local appid="$TEAM_ID.$bundle"
  /usr/bin/plutil -create xml1 "$output"
  /usr/libexec/PlistBuddy -c "Add :application-identifier string $appid" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.developer.team-identifier string $TEAM_ID" "$output"
  /usr/libexec/PlistBuddy -c "Add :get-task-allow bool false" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups array" "$output"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups:0 string $APP_GROUP" "$output"
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "$output"
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string $appid" "$output"
}

validate_profile() {
  local profile="$1"; local bundle="$2"; local label="$3"; local plist="$TEMP_DIR/$label-profile.plist"; local appid="$TEAM_ID.$bundle"
  [[ -f "$profile" ]] || fail "$label provisioning profile missing"
  security cms -D -i "$profile" > "$plist"
  require_equal "$label application-identifier" "$(plist_value "$plist" Entitlements:application-identifier)" "$appid"
  require_equal "$label team identifier" "$(plist_value "$plist" Entitlements:com.apple.developer.team-identifier)" "$TEAM_ID"
  require_equal "$label get-task-allow" "$(plist_value "$plist" Entitlements:get-task-allow)" "false"
  require_group "$plist" "$label profile"
  require_keychain_group "$plist" "$appid" "$label profile"
}

sign_bundle() {
  local path="$1"; local bundle="$2"; local profile="$3"; local label="$4"
  local ent="$TEMP_DIR/$label-entitlements.plist"
  [[ -d "$path" ]] || fail "$label bundle missing at $path"
  require_equal "$label bundle id" "$(plist_value "$path/Info.plist" CFBundleIdentifier)" "$bundle"
  require_equal "$label version" "$(plist_value "$path/Info.plist" CFBundleShortVersionString)" "$VERSION"
  require_equal "$label build" "$(plist_value "$path/Info.plist" CFBundleVersion)" "$BUILD"
  validate_profile "$profile" "$bundle" "$label"
  build_entitlements "$ent" "$bundle"
  rm -rf "$path/_CodeSignature"
  /bin/cp "$profile" "$path/embedded.mobileprovision"
  chmod 0644 "$path/embedded.mobileprovision"
  /usr/bin/codesign --force --sign "$SIGNING_IDENTITY" --entitlements "$ent" --generate-entitlement-der "$path"
  /usr/bin/codesign --verify --strict "$path"
}

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

[[ -d "$UNSIGNED_APP" ]] || fail "full unsigned Host app missing at $UNSIGNED_APP"
rm -rf "$SIGNED_ROOT" "$TEMP_DIR" "$SIGNED_IPA"
mkdir -p "$SIGNED_ROOT/Payload" "$TEMP_DIR" "$LOG_DIR"
/usr/bin/ditto "$UNSIGNED_APP" "$SIGNED_APP"

extension_count="$(find "$SIGNED_APP/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | /usr/bin/wc -l | /usr/bin/tr -d '[:space:]')"
require_equal "embedded extension count" "$extension_count" "4"

# Sign every embedded extension first, then the Host last.
sign_bundle "$SIGNED_APP/PlugIns/HamsterKeyboard.appex" "app.lgm.7517.123" "$KEYBOARD_PROFILE" keyboard
sign_bundle "$SIGNED_APP/PlugIns/ClawBaseShare.appex" "app.lgm.7517.share" "$SHARE_PROFILE" share
sign_bundle "$SIGNED_APP/PlugIns/ClawBaseWidget.appex" "app.lgm.7517.widget" "$WIDGET_PROFILE" widget
sign_bundle "$SIGNED_APP/PlugIns/ClawBaseVoiceActivity.appex" "app.lgm.7517.voiceactivity" "$VOICE_PROFILE" voiceactivity
sign_bundle "$SIGNED_APP" "app.lgm.7517" "$HOST_PROFILE" host

/usr/bin/codesign --verify --deep --strict "$SIGNED_APP"
(
  cd "$SIGNED_ROOT"
  /usr/bin/zip -qry "$SIGNED_IPA" Payload
)
/usr/bin/unzip -t "$SIGNED_IPA" >/dev/null
sha="$(/usr/bin/shasum -a 256 "$SIGNED_IPA" | /usr/bin/awk '{print $1}')"
{
  echo "ClawBase full signed validation: PASS"
  echo "Host + Keyboard + Share + Widget + Voice Activity: signed"
  echo "Embedded extension count: $extension_count"
  echo "Signed IPA: $SIGNED_IPA"
  echo "Signed IPA SHA-256: $sha"
} | tee "$LOG_DIR/full-signed-validation.log"
