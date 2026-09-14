#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device
require_cmd curl
require_cmd sha256sum

URL='https://github.com/spocky/miproja1/releases/download/4.36/ProjectivyLauncher-4.36-c64-xda-release.apk'
EXPECTED_SHA256='e1652b7321ffb8b3c7f7b7eb5e388e4735ba48858bb3d7afb01f19a2915bf482'
APK="$REPO_ROOT/downloads/ProjectivyLauncher-4.36-c64-xda-release.apk"
mkdir -p "$REPO_ROOT/downloads"
curl -fL --retry 3 -o "$APK" "$URL"
printf '%s  %s\n' "$EXPECTED_SHA256" "$APK" | sha256sum -c -

if [[ "${1:-}" == --replace-existing ]]; then
    adb_cmd uninstall com.spocky.projengmenu >/dev/null 2>&1 || true
elif [[ $# -ne 0 ]]; then
    die 'Usage: install-projectivy.sh [--replace-existing]'
fi

if ! adb_cmd install -r -d "$APK"; then
    die 'Install failed. If this is a signer conflict, --replace-existing erases Projectivy data before installing.'
fi
adb_cmd shell am start -W -n com.spocky.projengmenu/.ui.home.MainActivity
printf 'Projectivy 4.36 started. Complete its on-screen onboarding before changing HOME.\n'

