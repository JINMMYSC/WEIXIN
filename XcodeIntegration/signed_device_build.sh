#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/XcodeIntegration"
DERIVED_DATA="${DERIVED_DATA:-$ROOT_DIR/artifacts/DerivedData-SignedDevice}"
DEVICE_UDID="${DEVICE_UDID:?Set DEVICE_UDID to a connected, trusted iPhone UDID}"
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to your Apple Developer Team ID}"
WT_HOST_BUNDLE_ID="${WT_HOST_BUNDLE_ID:?Set the registered Host App bundle ID}"
WT_KEYBOARD_BUNDLE_ID="${WT_KEYBOARD_BUNDLE_ID:?Set the registered Keyboard Extension bundle ID}"
WT_SHARE_BUNDLE_ID="${WT_SHARE_BUNDLE_ID:?Set the registered Share Extension bundle ID}"
WT_WIDGET_BUNDLE_ID="${WT_WIDGET_BUNDLE_ID:?Set the registered Widget bundle ID}"
WT_VOICE_ACTIVITY_BUNDLE_ID="${WT_VOICE_ACTIVITY_BUNDLE_ID:?Set the registered Voice Activity bundle ID}"
WT_APP_GROUP_ID="${WT_APP_GROUP_ID:?Set the registered App Group shared by all targets}"

cd "$PROJECT_DIR"
xcodegen generate --spec project.yml
xcodebuild \
  -project WeTypeReplica.xcodeproj \
  -scheme WeTypeReplicaApp \
  -configuration Debug \
  -destination "id=$DEVICE_UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  WT_HOST_BUNDLE_ID="$WT_HOST_BUNDLE_ID" \
  WT_KEYBOARD_BUNDLE_ID="$WT_KEYBOARD_BUNDLE_ID" \
  WT_SHARE_BUNDLE_ID="$WT_SHARE_BUNDLE_ID" \
  WT_WIDGET_BUNDLE_ID="$WT_WIDGET_BUNDLE_ID" \
  WT_VOICE_ACTIVITY_BUNDLE_ID="$WT_VOICE_ACTIVITY_BUNDLE_ID" \
  WT_APP_GROUP_ID="$WT_APP_GROUP_ID" \
  CODE_SIGN_STYLE=Automatic \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  build

echo "Signed device build completed for $DEVICE_UDID"
echo "App: $DERIVED_DATA/Build/Products/Debug-iphoneos/WeTypeReplicaApp.app"
