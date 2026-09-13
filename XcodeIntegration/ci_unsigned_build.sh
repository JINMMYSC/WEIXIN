#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/XcodeIntegration"
ARTIFACTS_DIR="$ROOT_DIR/artifacts"
LOG_DIR="$ARTIFACTS_DIR/logs"
SIM_DERIVED_DATA="$ARTIFACTS_DIR/DerivedData-Simulator"
DEVICE_DERIVED_DATA="$ARTIFACTS_DIR/DerivedData-Device"
UNSIGNED_DIR="$ARTIFACTS_DIR/unsigned"
IPA_PATH="$ARTIFACTS_DIR/WeTypeReplicaApp-sideload-diagnostic-unsigned.ipa"

rm -rf "$ARTIFACTS_DIR"
mkdir -p "$LOG_DIR" "$UNSIGNED_DIR/Payload"

run_logged() {
  local name="$1"
  shift
  "$@" 2>&1 | tee "$LOG_DIR/$name.log"
}

run_logged environment bash -c 'xcodebuild -version; swift --version; xcodegen --version'
run_logged core-tests swift test --package-path "$ROOT_DIR"

(
  cd "$PROJECT_DIR"
  run_logged xcodegen xcodegen generate --spec project.yml
)

schemes=(
  WeTypeReplicaApp
  WeTypeReplicaKeyboard
  WeTypeReplicaShare
  WeTypeReplicaWidget
  WeTypeReplicaVoiceActivity
)

for scheme in "${schemes[@]}"; do
  run_logged "simulator-$scheme" \
    xcodebuild \
      -project "$PROJECT_DIR/WeTypeReplica.xcodeproj" \
      -scheme "$scheme" \
      -configuration Debug \
      -sdk iphonesimulator \
      -destination 'generic/platform=iOS Simulator' \
      -derivedDataPath "$SIM_DERIVED_DATA" \
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGNING_REQUIRED=NO \
      DEVELOPMENT_TEAM= \
      build
done

run_logged device-WeTypeReplicaApp \
  xcodebuild \
    -project "$PROJECT_DIR/WeTypeReplica.xcodeproj" \
    -scheme WeTypeReplicaApp \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DEVICE_DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY= \
    DEVELOPMENT_TEAM= \
    build

APP_PATH="$DEVICE_DERIVED_DATA/Build/Products/Release-iphoneos/WeTypeReplicaApp.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected device app was not produced at $APP_PATH" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi

HOST_INFO="$APP_PATH/Info.plist"
KEYBOARD_INFO="$APP_PATH/PlugIns/WeTypeReplicaKeyboard.appex/Info.plist"
if [[ ! -f "$HOST_INFO" ]]; then
  echo "Expected Host Info.plist was not produced at $HOST_INFO" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ ! -f "$KEYBOARD_INFO" ]]; then
  echo "Expected Keyboard extension Info.plist was not produced at $KEYBOARD_INFO" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi

plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null
}

host_bundle_id="$(plist_value "$HOST_INFO" 'CFBundleIdentifier')"
host_executable="$(plist_value "$HOST_INFO" 'CFBundleExecutable')"
host_package_type="$(plist_value "$HOST_INFO" 'CFBundlePackageType')"
host_version="$(plist_value "$HOST_INFO" 'CFBundleShortVersionString')"
host_build="$(plist_value "$HOST_INFO" 'CFBundleVersion')"
keyboard_bundle_id="$(plist_value "$KEYBOARD_INFO" 'CFBundleIdentifier')"
keyboard_executable="$(plist_value "$KEYBOARD_INFO" 'CFBundleExecutable')"
keyboard_package_type="$(plist_value "$KEYBOARD_INFO" 'CFBundlePackageType')"
keyboard_version="$(plist_value "$KEYBOARD_INFO" 'CFBundleShortVersionString')"
keyboard_build="$(plist_value "$KEYBOARD_INFO" 'CFBundleVersion')"
keyboard_extension_point="$(plist_value "$KEYBOARD_INFO" 'NSExtension:NSExtensionPointIdentifier')"
keyboard_principal_class="$(plist_value "$KEYBOARD_INFO" 'NSExtension:NSExtensionPrincipalClass')"
keyboard_open_access="$(plist_value "$KEYBOARD_INFO" 'NSExtension:NSExtensionAttributes:RequestsOpenAccess')"
keyboard_primary_language="$(plist_value "$KEYBOARD_INFO" 'NSExtension:NSExtensionAttributes:PrimaryLanguage')"

if [[ "$host_bundle_id" != "app.lgm.7517" ]]; then
  echo "Invalid built Host bundle identifier: '$host_bundle_id'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$keyboard_bundle_id" != "app.lgm.7517.123" ]]; then
  echo "Invalid built Keyboard bundle identifier: '$keyboard_bundle_id'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$host_executable" != "WeTypeReplicaApp" || "$host_package_type" != "APPL" ]]; then
  echo "Invalid built Host executable/package type: '$host_executable' / '$host_package_type'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$keyboard_executable" != "WeTypeReplicaKeyboard" || "$keyboard_package_type" != "XPC!" ]]; then
  echo "Invalid built Keyboard executable/package type: '$keyboard_executable' / '$keyboard_package_type'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$host_version" != "$keyboard_version" || "$host_build" != "$keyboard_build" ]]; then
  echo "Host/Keyboard version mismatch: '$host_version ($host_build)' vs '$keyboard_version ($keyboard_build)'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$keyboard_extension_point" != "com.apple.keyboard-service" ]]; then
  echo "Invalid built Keyboard extension point: '$keyboard_extension_point'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$keyboard_principal_class" != "WeTypeReplicaKeyboard.WTKeyboardInputViewController" ]]; then
  echo "Invalid built Keyboard principal class: '$keyboard_principal_class'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$keyboard_open_access" != "true" ]]; then
  echo "Invalid built Keyboard RequestsOpenAccess: '$keyboard_open_access'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi
if [[ "$keyboard_primary_language" != "zh-Hans" ]]; then
  echo "Invalid built Keyboard PrimaryLanguage: '$keyboard_primary_language'" | tee "$LOG_DIR/package.log" >&2
  exit 1
fi

ditto "$APP_PATH" "$UNSIGNED_DIR/Payload/WeTypeReplicaApp.app"
(
  cd "$UNSIGNED_DIR"
  /usr/bin/zip -qry "$IPA_PATH" Payload
)

{
  echo "Unsigned IPA: $IPA_PATH"
  echo "SHA-256: $(shasum -a 256 "$IPA_PATH" | awk '{print $1}')"
  echo "Embedded extensions:"
  find "$UNSIGNED_DIR/Payload/WeTypeReplicaApp.app/PlugIns" -maxdepth 1 -type d -name '*.appex' -print | sort
  echo "IPA contents:"
  unzip -l "$IPA_PATH"
} | tee "$LOG_DIR/package.log"
