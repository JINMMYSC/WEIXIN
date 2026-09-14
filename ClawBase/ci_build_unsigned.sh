#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/ClawBase"
ARTIFACTS_DIR="$ROOT_DIR/artifacts/claw-base"
LOG_DIR="$ARTIFACTS_DIR/logs"
SIM_DERIVED_DATA="$ARTIFACTS_DIR/DerivedData-Simulator"
DEVICE_DERIVED_DATA="$ARTIFACTS_DIR/DerivedData-Device"
SYSTEM_DERIVED_ROOT="$ARTIFACTS_DIR/DerivedData-SystemExtensions"
UNSIGNED_DIR="$ARTIFACTS_DIR/unsigned"
IPA_PATH="$ARTIFACTS_DIR/ClawBase-3.5.3-3.5.3-full-unsigned.ipa"

rm -rf "$ARTIFACTS_DIR"
mkdir -p "$LOG_DIR" "$UNSIGNED_DIR/Payload" "$SYSTEM_DERIVED_ROOT"

run_logged() {
  local name="$1"
  shift
  "$@" 2>&1 | tee "$LOG_DIR/$name.log"
}

fail() {
  echo "CLAW BASE BUILD ERROR: $*" | tee -a "$LOG_DIR/package.log" >&2
  exit 1
}

plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null
}

run_logged environment bash -c 'xcodebuild -version; swift --version; xcodegen --version'
run_logged phase3-dependencies "$PROJECT_DIR/ci_prepare_librimekit.sh"

(
  cd "$PROJECT_DIR"
  run_logged xcodegen xcodegen generate --spec project.yml
)

# Build each product independently first so a failure cannot be hidden by Host dependency resolution.
for scheme in ClawBaseShare ClawBaseWidget ClawBaseVoiceActivity; do
  run_logged "device-$scheme" \
    xcodebuild \
      -project "$PROJECT_DIR/ClawBase.xcodeproj" \
      -scheme "$scheme" \
      -configuration Release \
      -sdk iphoneos \
      -destination 'generic/platform=iOS' \
      -derivedDataPath "$SYSTEM_DERIVED_ROOT/$scheme" \
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGN_IDENTITY= \
      DEVELOPMENT_TEAM= \
      build
done

run_logged simulator-ClawBaseHost \
  xcodebuild \
    -project "$PROJECT_DIR/ClawBase.xcodeproj" \
    -scheme ClawBaseHost \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$SIM_DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    DEVELOPMENT_TEAM= \
    build

run_logged device-ClawBaseHost \
  xcodebuild \
    -project "$PROJECT_DIR/ClawBase.xcodeproj" \
    -scheme ClawBaseHost \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DEVICE_DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY= \
    DEVELOPMENT_TEAM= \
    build

APP_PATH="$DEVICE_DERIVED_DATA/Build/Products/Release-iphoneos/ClawBaseHost.app"
KEYBOARD_PATH="$APP_PATH/PlugIns/HamsterKeyboard.appex"
SHARE_PATH="$APP_PATH/PlugIns/ClawBaseShare.appex"
WIDGET_PATH="$APP_PATH/PlugIns/ClawBaseWidget.appex"
VOICE_ACTIVITY_PATH="$APP_PATH/PlugIns/ClawBaseVoiceActivity.appex"
HOST_INFO="$APP_PATH/Info.plist"
KEYBOARD_INFO="$KEYBOARD_PATH/Info.plist"
SHARE_INFO="$SHARE_PATH/Info.plist"
WIDGET_INFO="$WIDGET_PATH/Info.plist"
VOICE_ACTIVITY_INFO="$VOICE_ACTIVITY_PATH/Info.plist"
RIME_RESOURCES="$KEYBOARD_PATH/RimeSharedSupport"

for required in "$APP_PATH" "$KEYBOARD_PATH" "$SHARE_PATH" "$WIDGET_PATH" "$VOICE_ACTIVITY_PATH" "$RIME_RESOURCES"; do
  [[ -d "$required" ]] || fail "required package directory missing: $required"
done
for required in "$HOST_INFO" "$KEYBOARD_INFO" "$SHARE_INFO" "$WIDGET_INFO" "$VOICE_ACTIVITY_INFO"; do
  [[ -f "$required" ]] || fail "required Info.plist missing: $required"
done
[[ -f "$RIME_RESOURCES/claw_pinyin26.schema.yaml" ]] || fail "claw_pinyin26 schema missing"
[[ -f "$RIME_RESOURCES/claw_pinyin9.schema.yaml" ]] || fail "claw_pinyin9 schema missing"
[[ -f "$RIME_RESOURCES/luna_pinyin.dict.yaml" ]] || fail "pinned Luna Pinyin dictionary missing"
[[ -f "$RIME_RESOURCES/CLAW_PHASE3_PROVENANCE.txt" ]] || fail "Phase 3 provenance file missing"

host_bundle_id="$(plist_value "$HOST_INFO" CFBundleIdentifier)"
keyboard_bundle_id="$(plist_value "$KEYBOARD_INFO" CFBundleIdentifier)"
share_bundle_id="$(plist_value "$SHARE_INFO" CFBundleIdentifier)"
widget_bundle_id="$(plist_value "$WIDGET_INFO" CFBundleIdentifier)"
voice_activity_bundle_id="$(plist_value "$VOICE_ACTIVITY_INFO" CFBundleIdentifier)"
host_version="$(plist_value "$HOST_INFO" CFBundleShortVersionString)"
host_build="$(plist_value "$HOST_INFO" CFBundleVersion)"
keyboard_extension_point="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionPointIdentifier)"
share_extension_point="$(plist_value "$SHARE_INFO" NSExtension:NSExtensionPointIdentifier)"
widget_extension_point="$(plist_value "$WIDGET_INFO" NSExtension:NSExtensionPointIdentifier)"
voice_activity_extension_point="$(plist_value "$VOICE_ACTIVITY_INFO" NSExtension:NSExtensionPointIdentifier)"

[[ "$host_bundle_id" == "app.lgm.7517" ]] || fail "Host bundle ID mismatch: $host_bundle_id"
[[ "$keyboard_bundle_id" == "app.lgm.7517.123" ]] || fail "Keyboard bundle ID mismatch: $keyboard_bundle_id"
[[ "$share_bundle_id" == "app.lgm.7517.share" ]] || fail "Share bundle ID mismatch: $share_bundle_id"
[[ "$widget_bundle_id" == "app.lgm.7517.widget" ]] || fail "Widget bundle ID mismatch: $widget_bundle_id"
[[ "$voice_activity_bundle_id" == "app.lgm.7517.voiceactivity" ]] || fail "Voice Activity bundle ID mismatch: $voice_activity_bundle_id"
[[ "$host_version" == "3.5.3" && "$host_build" == "3.5.3" ]] || fail "Host version/build must be 3.5.3 (3.5.3), got $host_version ($host_build)"
[[ "$keyboard_extension_point" == "com.apple.keyboard-service" ]] || fail "Keyboard extension point mismatch: $keyboard_extension_point"
[[ "$share_extension_point" == "com.apple.share-services" ]] || fail "Share extension point mismatch: $share_extension_point"
[[ "$widget_extension_point" == "com.apple.widgetkit-extension" ]] || fail "Widget extension point mismatch: $widget_extension_point"
[[ "$voice_activity_extension_point" == "com.apple.widgetkit-extension" ]] || fail "Voice Activity extension point mismatch: $voice_activity_extension_point"
[[ "$(plist_value "$SHARE_INFO" CFBundleDisplayName)" == "隔空传送" ]] || fail "Share display name mismatch"
[[ "$(plist_value "$WIDGET_INFO" CFBundleDisplayName)" == "微信输入法" ]] || fail "Widget display name mismatch"
[[ "$(plist_value "$VOICE_ACTIVITY_INFO" CFBundleDisplayName)" == "语音输入" ]] || fail "Voice Activity display name mismatch"

extension_count="$(find "$APP_PATH/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | wc -l | tr -d '[:space:]')"
[[ "$extension_count" == "4" ]] || fail "Expected exactly four embedded extensions, got $extension_count"

ditto "$APP_PATH" "$UNSIGNED_DIR/Payload/ClawBaseHost.app"
(
  cd "$UNSIGNED_DIR"
  /usr/bin/zip -qry "$IPA_PATH" Payload
)

{
  echo "ClawBase unsigned validation: PASS"
  echo "Host bundle ID: $host_bundle_id"
  echo "Keyboard bundle ID: $keyboard_bundle_id"
  echo "Share bundle ID: $share_bundle_id"
  echo "Widget bundle ID: $widget_bundle_id"
  echo "Voice Activity bundle ID: $voice_activity_bundle_id"
  echo "Version/build: $host_version ($host_build)"
  echo "Phase 3 real librime resources: PASS"
  echo "Full extension embedding: PASS"
  echo "Embedded extension count: $extension_count"
  echo "Unsigned IPA: $IPA_PATH"
  echo "Unsigned IPA SHA-256: $(/usr/bin/shasum -a 256 "$IPA_PATH" | /usr/bin/awk '{print $1}')"
} | tee "$LOG_DIR/package.log"
