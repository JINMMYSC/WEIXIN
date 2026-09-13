#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/XcodeIntegration"
DERIVED_DATA="${DERIVED_DATA:-$ROOT_DIR/artifacts/DerivedData-SignedDevice}"
DEVICE_UDID="${DEVICE_UDID:?Set DEVICE_UDID to a connected, trusted iPhone UDID}"
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to your Apple Developer Team ID}"
WT_BASE_BUNDLE_ID="${WT_BASE_BUNDLE_ID:-dev.wetype.replica}"

cd "$PROJECT_DIR"
xcodegen generate --spec project.yml
xcodebuild \
  -project WeTypeReplica.xcodeproj \
  -scheme WeTypeReplicaApp \
  -configuration Debug \
  -destination "id=$DEVICE_UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  WT_BASE_BUNDLE_ID="$WT_BASE_BUNDLE_ID" \
  CODE_SIGN_STYLE=Automatic \
  build

echo "Signed device build completed for $DEVICE_UDID"
echo "App: $DERIVED_DATA/Build/Products/Debug-iphoneos/WeTypeReplicaApp.app"
