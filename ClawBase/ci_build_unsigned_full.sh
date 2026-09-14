#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/ClawBase"
ARTIFACTS_DIR="$ROOT_DIR/artifacts/claw-base-full"
DERIVED_DATA="$ARTIFACTS_DIR/DerivedData-Device"
LOG_DIR="$ARTIFACTS_DIR/logs"
UNSIGNED_DIR="$ARTIFACTS_DIR/unsigned"
IPA_PATH="$ARTIFACTS_DIR/ClawBase-3.0.1-2-full-unsigned.ipa"

rm -rf "$ARTIFACTS_DIR" "$PROJECT_DIR/ClawBaseFull.xcodeproj"
mkdir -p "$LOG_DIR" "$UNSIGNED_DIR/Payload"

run_logged() {
  local name="$1"; shift
  "$@" 2>&1 | tee "$LOG_DIR/$name.log"
}

fail() { echo "CLAW FULL PACKAGE ERROR: $*" >&2; exit 1; }
plist_value() { /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null; }

run_logged environment bash -c 'xcodebuild -version; swift --version; xcodegen --version'
run_logged phase3-dependencies "$PROJECT_DIR/ci_prepare_librimekit.sh"
(
  cd "$PROJECT_DIR"
  run_logged xcodegen-full xcodegen generate --spec project-full.yml
)

run_logged device-ClawBaseHost-full \
  xcodebuild \
    -project "$PROJECT_DIR/ClawBaseFull.xcodeproj" \
    -scheme ClawBaseHost \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY= \
    DEVELOPMENT_TEAM= \
    build

APP_PATH="$DERIVED_DATA/Build/Products/Release-iphoneos/ClawBaseHost.app"
[[ -d "$APP_PATH" ]] || fail "Host app missing at $APP_PATH"

expected=(
  "HamsterKeyboard.appex|app.lgm.7517.123|com.apple.keyboard-service|15.1"
  "ClawBaseShare.appex|app.lgm.7517.share|com.apple.share-services|16.0"
  "ClawBaseWidget.appex|app.lgm.7517.widget|com.apple.widgetkit-extension|17.0"
  "ClawBaseVoiceActivity.appex|app.lgm.7517.voiceactivity|com.apple.widgetkit-extension|16.1"
)

count="$(find "$APP_PATH/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | wc -l | tr -d '[:space:]')"
[[ "$count" == "4" ]] || fail "Expected 4 embedded extensions, got $count"

for spec in "${expected[@]}"; do
  IFS='|' read -r name bundle point min_os <<< "$spec"
  info="$APP_PATH/PlugIns/$name/Info.plist"
  [[ -f "$info" ]] || fail "$name Info.plist missing"
  [[ "$(plist_value "$info" CFBundleIdentifier)" == "$bundle" ]] || fail "$name bundle mismatch"
  [[ "$(plist_value "$info" CFBundleShortVersionString)" == "3.0.1" ]] || fail "$name version mismatch"
  [[ "$(plist_value "$info" CFBundleVersion)" == "2" ]] || fail "$name build mismatch"
  [[ "$(plist_value "$info" MinimumOSVersion)" == "$min_os" ]] || fail "$name minimum OS mismatch"
  [[ "$(plist_value "$info" NSExtension:NSExtensionPointIdentifier)" == "$point" ]] || fail "$name extension point mismatch"
done

share_info="$APP_PATH/PlugIns/ClawBaseShare.appex/Info.plist"
[[ "$(plist_value "$share_info" CFBundleDisplayName)" == "隔空传送" ]] || fail "Share display name mismatch"
[[ "$(plist_value "$share_info" NSExtension:NSExtensionPrincipalClass)" == "ClawBaseShare.WTQuickSendShareViewController" ]] || fail "Share principal class mismatch"

voice_info="$APP_PATH/PlugIns/ClawBaseVoiceActivity.appex/Info.plist"
[[ "$(plist_value "$voice_info" NSSupportsLiveActivities)" == "true" ]] || fail "Voice Activity flag missing"

keyboard="$APP_PATH/PlugIns/HamsterKeyboard.appex"
[[ -f "$keyboard/RimeSharedSupport/claw_pinyin26.schema.yaml" ]] || fail "Phase 3 Rime resources missing"

/usr/bin/ditto "$APP_PATH" "$UNSIGNED_DIR/Payload/ClawBaseHost.app"
(
  cd "$UNSIGNED_DIR"
  /usr/bin/zip -qry "$IPA_PATH" Payload
)

{
  echo "ClawBase full unsigned package: PASS"
  echo "Embedded extensions: 4"
  printf '  %s\n' "${expected[@]}"
  echo "Unsigned IPA: $IPA_PATH"
  echo "SHA-256: $(/usr/bin/shasum -a 256 "$IPA_PATH" | /usr/bin/awk '{print $1}')"
} | tee "$LOG_DIR/package.log"
