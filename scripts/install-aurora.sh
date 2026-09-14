#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device
require_cmd curl
require_cmd sha256sum
require_cmd apksigner
require_cmd aapt

URL='https://www.auroraoss.com/downloads/AuroraStore/Release/AuroraStore-4.7.5.apk'
APK_SHA256='462b3adfa59f158d786030cbb51c973263390dc8dd25c1f37233e246338252b1'
CERT_SHA256='4c626157ad02bda3401a7263555f68a79663fc3e13a4d4369a12570941aa280f'
APK="$REPO_ROOT/downloads/AuroraStore-4.7.5.apk"
mkdir -p "$REPO_ROOT/downloads"
curl -fL --retry 3 -o "$APK" "$URL"
printf '%s  %s\n' "$APK_SHA256" "$APK" | sha256sum -c -
actual_cert="$(apksigner verify --print-certs "$APK" 2>/dev/null | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' | head -1)"
[[ "$actual_cert" == "$CERT_SHA256" ]] || die "Aurora signer mismatch: $actual_cert"
badging="$(aapt dump badging "$APK")"
[[ "$badging" == *"name='com.aurora.store'"* && "$badging" == *"versionName='4.7.5'"* ]] || die 'Unexpected Aurora package/version'
[[ "$badging" == *"sdkVersion:'21'"* && "$badging" == *"'armeabi-v7a'"* ]] || die 'Aurora APK is not API 21+/ARMv7 compatible'
adb_cmd install -r "$APK"
adb_cmd shell am start -n com.aurora.store/.MainActivity
printf 'Aurora Store 4.7.5 installed and launch requested.\n'

