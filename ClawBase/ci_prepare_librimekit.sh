#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/ClawBase/Vendor"
LIBRIMEKIT_DIR="$VENDOR_DIR/LibrimeKit"
PRELUDE_DIR="$VENDOR_DIR/rime-prelude"
LUNA_DIR="$VENDOR_DIR/rime-luna-pinyin"
RIME_SHARED_DIR="$VENDOR_DIR/RimeSharedSupport"
WORK_DIR="${RUNNER_TEMP:-/tmp}/clawbase-phase3-deps"
ARCHIVE="$WORK_DIR/Frameworks.tgz"

LIBRIMEKIT_REPOSITORY="https://github.com/amorphobia/LibrimeKit.git"
LIBRIMEKIT_COMMIT="d1a4c26aaa6dc2e081f7933ec852fc3732321efa"
LIBRIME_COMMIT="08dd95f5d9282346f0d4a3e8fc6b20811dc3d063"
LIBRIMEKIT_RELEASE="v0.1.0"
FRAMEWORKS_URL="https://github.com/amorphobia/LibrimeKit/releases/download/${LIBRIMEKIT_RELEASE}/Frameworks.tgz"
FRAMEWORKS_BYTES="24815214"
FRAMEWORKS_SHA256="7b3d1d210c5a251a951685b722399c5eeb60f18a39a782a8850511edd12d0398"
RIME_PRELUDE_REPOSITORY="https://github.com/rime/rime-prelude.git"
RIME_PRELUDE_COMMIT="082425ea0684bca36474415d4a0e8db9b016487e"
RIME_LUNA_REPOSITORY="https://github.com/rime/rime-luna-pinyin.git"
RIME_LUNA_COMMIT="56b934b099dfbeab842320f13aa8b461a6ab3e42"

checkout_exact() {
  local repository="$1"
  local commit="$2"
  local destination="$3"
  rm -rf "$destination"
  git init -q "$destination"
  git -C "$destination" remote add origin "$repository"
  git -C "$destination" fetch -q --depth=1 origin "$commit"
  git -C "$destination" checkout -q --detach FETCH_HEAD
  local actual
  actual="$(git -C "$destination" rev-parse HEAD)"
  [[ "$actual" == "$commit" ]] || {
    echo "PHASE3 DEPENDENCY ERROR: expected $commit from $repository, got $actual" >&2
    exit 1
  }
}

rm -rf "$WORK_DIR" "$VENDOR_DIR"
mkdir -p "$WORK_DIR" "$VENDOR_DIR" "$RIME_SHARED_DIR"

checkout_exact "$LIBRIMEKIT_REPOSITORY" "$LIBRIMEKIT_COMMIT" "$LIBRIMEKIT_DIR"
checkout_exact "$RIME_PRELUDE_REPOSITORY" "$RIME_PRELUDE_COMMIT" "$PRELUDE_DIR"
checkout_exact "$RIME_LUNA_REPOSITORY" "$RIME_LUNA_COMMIT" "$LUNA_DIR"

/usr/bin/curl --fail --location --retry 3 --retry-delay 2 --output "$ARCHIVE" "$FRAMEWORKS_URL"
archive_bytes="$(/usr/bin/stat -f '%z' "$ARCHIVE")"
[[ "$archive_bytes" == "$FRAMEWORKS_BYTES" ]] || {
  echo "PHASE3 DEPENDENCY ERROR: Frameworks.tgz size mismatch: $archive_bytes" >&2
  exit 1
}
archive_sha="$(/usr/bin/shasum -a 256 "$ARCHIVE" | /usr/bin/awk '{print $1}')"
[[ "$archive_sha" == "$FRAMEWORKS_SHA256" ]] || {
  echo "PHASE3 DEPENDENCY ERROR: Frameworks.tgz SHA-256 mismatch" >&2
  exit 1
}
archive_sha_grouped="$(printf '%s' "$archive_sha" | /usr/bin/sed 's/../&:/g; s/:$//')"

echo "Phase 3 public dependency pin"
echo "LibrimeKit commit: $LIBRIMEKIT_COMMIT"
echo "librime submodule commit: $LIBRIME_COMMIT"
echo "LibrimeKit release: $LIBRIMEKIT_RELEASE"
echo "Frameworks.tgz bytes: $archive_bytes"
echo "Frameworks.tgz SHA-256 grouped: $archive_sha_grouped"
echo "rime-prelude commit: $RIME_PRELUDE_COMMIT"
echo "rime-luna-pinyin commit: $RIME_LUNA_COMMIT"

/usr/bin/tar -xzf "$ARCHIVE" -C "$LIBRIMEKIT_DIR"

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
  [[ -d "$LIBRIMEKIT_DIR/Frameworks/$framework" ]] || {
    echo "PHASE3 DEPENDENCY ERROR: missing $framework" >&2
    exit 1
  }
done
[[ -f "$LIBRIMEKIT_DIR/Frameworks/librime.xcframework/ios-arm64/Headers/rime_api.h" ]] || {
  echo "PHASE3 DEPENDENCY ERROR: rime_api.h missing" >&2
  exit 1
}

cp -R "$LIBRIMEKIT_DIR/Tests/LibrimeKitTests/Resources/SharedSupport/." "$RIME_SHARED_DIR/"
find "$PRELUDE_DIR" -maxdepth 1 -type f -name '*.yaml' -exec cp {} "$RIME_SHARED_DIR/" \;
find "$LUNA_DIR" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.txt' \) -exec cp {} "$RIME_SHARED_DIR/" \;
cp "$ROOT_DIR/ClawBase/RimeSchemas/claw_pinyin26.schema.yaml" "$RIME_SHARED_DIR/"
cp "$ROOT_DIR/ClawBase/RimeSchemas/claw_pinyin9.schema.yaml" "$RIME_SHARED_DIR/"

cat > "$RIME_SHARED_DIR/CLAW_PHASE3_PROVENANCE.txt" <<EOF
LibrimeKit=$LIBRIMEKIT_COMMIT
librime=$LIBRIME_COMMIT
LibrimeKitRelease=$LIBRIMEKIT_RELEASE
FrameworksBytes=$archive_bytes
FrameworksSHA256=$archive_sha
rime-prelude=$RIME_PRELUDE_COMMIT
rime-luna-pinyin=$RIME_LUNA_COMMIT
EOF

[[ -f "$RIME_SHARED_DIR/luna_pinyin.dict.yaml" ]] || {
  echo "PHASE3 DEPENDENCY ERROR: luna_pinyin.dict.yaml missing" >&2
  exit 1
}
[[ -f "$RIME_SHARED_DIR/default.yaml" ]] || {
  echo "PHASE3 DEPENDENCY ERROR: default.yaml missing" >&2
  exit 1
}
[[ -f "$RIME_SHARED_DIR/claw_pinyin9.schema.yaml" ]] || {
  echo "PHASE3 DEPENDENCY ERROR: claw_pinyin9.schema.yaml missing" >&2
  exit 1
}

echo "Phase 3 dependency preparation: PASS"
