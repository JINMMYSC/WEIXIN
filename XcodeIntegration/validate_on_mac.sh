#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift test
cd XcodeIntegration
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is required: brew install xcodegen" >&2
  exit 2
fi
xcodegen generate
for scheme in WeTypeReplicaApp WeTypeReplicaKeyboard WeTypeReplicaShare WeTypeReplicaWidget WeTypeReplicaVoiceActivity; do
  echo "==> building $scheme"
  xcodebuild -project WeTypeReplica.xcodeproj -scheme "$scheme" \
    -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
    CODE_SIGNING_ALLOWED=NO DEVELOPMENT_TEAM='' build
done
