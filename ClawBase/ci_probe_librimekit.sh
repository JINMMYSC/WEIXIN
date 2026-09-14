#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT_DIR/artifacts/claw-base/logs"
WORK_DIR="${RUNNER_TEMP:-/tmp}/clawbase-librimekit-probe"
ARCHIVE="$WORK_DIR/Frameworks.tgz"
EXTRACTED="$WORK_DIR/extracted"
LOG_FILE="$LOG_DIR/librimekit-probe.log"

SOURCE_REPOSITORY="https://github.com/amorphobia/LibrimeKit"
SOURCE_COMMIT="d1a4c26aaa6dc2e081f7933ec852fc3732321efa"
RELEASE_TAG="v0.1.0"
ASSET_URL="https://github.com/amorphobia/LibrimeKit/releases/download/${RELEASE_TAG}/Frameworks.tgz"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR" "$EXTRACTED" "$LOG_DIR"

exec > >(tee "$LOG_FILE") 2>&1

echo "ClawBase Phase 3 LibrimeKit dependency probe"
echo "Source repository: $SOURCE_REPOSITORY"
echo "Source commit: $SOURCE_COMMIT"
echo "Release tag: $RELEASE_TAG"
echo "Asset: Frameworks.tgz"

/usr/bin/curl --fail --location --retry 3 --retry-delay 2 \
  --output "$ARCHIVE" \
  "$ASSET_URL"

archive_sha="$(/usr/bin/shasum -a 256 "$ARCHIVE" | /usr/bin/awk '{print $1}')"
echo "Frameworks.tgz SHA-256: $archive_sha"
echo "Frameworks.tgz bytes: $(/usr/bin/stat -f '%z' "$ARCHIVE")"

/usr/bin/tar -tzf "$ARCHIVE" > "$WORK_DIR/archive-list.txt"

required_frameworks=(
  librime.xcframework
  boost_atomic.xcframework
  boost_filesystem.xcframework
  boost_regex.xcframework
  boost_system.xcframework
  libglog.xcframework
  libleveldb.xcframework
  libmarisa.xcframework
  libopencc.xcframework
  libyaml-cpp.xcframework
)

for framework in "${required_frameworks[@]}"; do
  if ! /usr/bin/grep -qE "(^|/)${framework}(/|$)" "$WORK_DIR/archive-list.txt"; then
    echo "DEPENDENCY PROBE ERROR: missing $framework in Frameworks.tgz" >&2
    exit 1
  fi
  echo "Archive contains: $framework"
done

/usr/bin/tar -xzf "$ARCHIVE" -C "$EXTRACTED"

librime_info="$(/usr/bin/find "$EXTRACTED" -path '*/librime.xcframework/Info.plist' -print -quit)"
[[ -n "$librime_info" ]] || { echo "DEPENDENCY PROBE ERROR: librime.xcframework Info.plist missing" >&2; exit 1; }

echo "librime.xcframework Info.plist: $librime_info"
/usr/libexec/PlistBuddy -c 'Print :AvailableLibraries' "$librime_info" || true

echo "Archive top-level sample:"
/usr/bin/sed -n '1,80p' "$WORK_DIR/archive-list.txt"

echo "ClawBase Phase 3 LibrimeKit dependency probe: PASS"
