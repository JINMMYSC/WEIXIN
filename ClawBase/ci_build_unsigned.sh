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
IPA_PATH="$ARTIFACTS_DIR/ClawBase-3.0.1-2-unsigned.ipa"

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

# Phase 5/7: compile every final system-extension target unsigned. They are intentionally not
# embedded in the two-profile engineering IPA until dedicated provisioning profiles are supplied.
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
HOST_INFO="$APP_PATH/Info.plist"
KEYBOARD_INFO="$KEYBOARD_PATH/Info.plist"
RIME_RESOURCES="$KEYBOARD_PATH/RimeSharedSupport"

[[ -d "$APP_PATH" ]] || fail "Host app missing at $APP_PATH"
[[ -d "$KEYBOARD_PATH" ]] || fail "Keyboard extension missing at $KEYBOARD_PATH"
[[ -f "$HOST_INFO" ]] || fail "Host Info.plist missing"
[[ -f "$KEYBOARD_INFO" ]] || fail "Keyboard Info.plist missing"
[[ -d "$RIME_RESOURCES" ]] || fail "RimeSharedSupport resources missing from Keyboard extension"
[[ -f "$RIME_RESOURCES/claw_pinyin26.schema.yaml" ]] || fail "claw_pinyin26 schema missing"
[[ -f "$RIME_RESOURCES/claw_pinyin9.schema.yaml" ]] || fail "claw_pinyin9 schema missing"
[[ -f "$RIME_RESOURCES/luna_pinyin.dict.yaml" ]] || fail "pinned Luna Pinyin dictionary missing"
[[ -f "$RIME_RESOURCES/CLAW_PHASE3_PROVENANCE.txt" ]] || fail "Phase 3 provenance file missing"

host_bundle_id="$(plist_value "$HOST_INFO" CFBundleIdentifier)"
keyboard_bundle_id="$(plist_value "$KEYBOARD_INFO" CFBundleIdentifier)"
host_executable="$(plist_value "$HOST_INFO" CFBundleExecutable)"
keyboard_executable="$(plist_value "$KEYBOARD_INFO" CFBundleExecutable)"
host_package_type="$(plist_value "$HOST_INFO" CFBundlePackageType)"
keyboard_package_type="$(plist_value "$KEYBOARD_INFO" CFBundlePackageType)"
host_version="$(plist_value "$HOST_INFO" CFBundleShortVersionString)"
keyboard_version="$(plist_value "$KEYBOARD_INFO" CFBundleShortVersionString)"
host_build="$(plist_value "$HOST_INFO" CFBundleVersion)"
keyboard_build="$(plist_value "$KEYBOARD_INFO" CFBundleVersion)"
keyboard_extension_point="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionPointIdentifier)"
keyboard_principal_class="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionPrincipalClass)"
keyboard_open_access="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionAttributes:RequestsOpenAccess)"
keyboard_primary_language="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionAttributes:PrimaryLanguage)"
keyboard_ascii_capable="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionAttributes:IsASCIICapable)"
keyboard_rtl="$(plist_value "$KEYBOARD_INFO" NSExtension:NSExtensionAttributes:PrefersRightToLeft)"

[[ "$host_bundle_id" == "app.lgm.7517" ]] || fail "Host bundle ID mismatch: $host_bundle_id"
[[ "$keyboard_bundle_id" == "app.lgm.7517.123" ]] || fail "Keyboard bundle ID mismatch: $keyboard_bundle_id"
[[ "$host_executable" == "ClawBaseHost" ]] || fail "Host executable mismatch: $host_executable"
[[ "$keyboard_executable" == "HamsterKeyboard" ]] || fail "Keyboard executable mismatch: $keyboard_executable"
[[ "$host_package_type" == "APPL" ]] || fail "Host package type mismatch: $host_package_type"
[[ "$keyboard_package_type" == "XPC!" ]] || fail "Keyboard package type mismatch: $keyboard_package_type"
[[ "$host_version" == "3.0.1" && "$host_build" == "2" ]] || fail "Host version/build must be 3.0.1 (2), got $host_version ($host_build)"
[[ "$keyboard_version" == "3.0.1" && "$keyboard_build" == "2" ]] || fail "Keyboard version/build must be 3.0.1 (2), got $keyboard_version ($keyboard_build)"
[[ "$keyboard_extension_point" == "com.apple.keyboard-service" ]] || fail "Keyboard extension point mismatch: $keyboard_extension_point"
[[ "$keyboard_principal_class" == "HamsterKeyboard.HamsterKeyboardInputViewController" ]] || fail "Keyboard principal class mismatch: $keyboard_principal_class"
[[ "$keyboard_open_access" == "true" ]] || fail "RequestsOpenAccess must be true"
[[ "$keyboard_primary_language" == "zh-Hans" ]] || fail "PrimaryLanguage mismatch: $keyboard_primary_language"
[[ "$keyboard_ascii_capable" == "true" ]] || fail "IsASCIICapable must be true"
[[ "$keyboard_rtl" == "false" ]] || fail "PrefersRightToLeft must be false"

extension_count="$(find "$APP_PATH/PlugIns" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | wc -l | tr -d '[:space:]')"
[[ "$extension_count" == "1" ]] || fail "Expected exactly one embedded extension in the two-profile engineering IPA, got $extension_count"

ditto "$APP_PATH" "$UNSIGNED_DIR/Payload/ClawBaseHost.app"
(
  cd "$UNSIGNED_DIR"
  /usr/bin/zip -qry "$IPA_PATH" Payload
)

{
  echo "ClawBase unsigned validation: PASS"
  echo "Host bundle ID: $host_bundle_id"
  echo "Keyboard bundle ID: $keyboard_bundle_id"
  echo "Version/build: $host_version ($host_build)"
  echo "Keyboard extension point: $keyboard_extension_point"
  echo "Keyboard principal class: $keyboard_principal_class"
  echo "Phase 3 real librime resources: PASS"
  echo "Phase 5 system-extension unsigned compilation: PASS"
  echo "Embedded engineering extension count: $extension_count"
  echo "Unsigned IPA: $IPA_PATH"
  echo "Unsigned IPA SHA-256: $(/usr/bin/shasum -a 256 "$IPA_PATH" | /usr/bin/awk '{print $1}')"
} | tee "$LOG_DIR/package.log"
