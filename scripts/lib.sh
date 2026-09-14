#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADB="${ADB:-adb}"
ADB_ARGS=()

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
note() { printf '%s\n' "$*" >&2; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"; }

select_device() {
    require_cmd "$ADB"
    if [[ -z "${ADB_SERIAL:-}" ]]; then
        mapfile -t _serials < <("$ADB" devices | awk 'NR > 1 && $2 == "device" {print $1}')
        [[ ${#_serials[@]} -eq 1 ]] || die "Set ADB_SERIAL; found ${#_serials[@]} authorized devices"
        ADB_SERIAL="${_serials[0]}"
    fi
    ADB_ARGS=(-s "$ADB_SERIAL")
    [[ "$("$ADB" "${ADB_ARGS[@]}" get-state 2>/dev/null)" == device ]] || die "ADB device is not ready: $ADB_SERIAL"
}

adb_cmd() { "$ADB" "${ADB_ARGS[@]}" "$@"; }
prop() { adb_cmd shell getprop "$1" | tr -d '\r'; }

guard_device() {
    select_device
    local model device sdk build
    model="$(prop ro.product.model)"
    device="$(prop ro.product.device)"
    sdk="$(prop ro.build.version.sdk)"
    build="$(prop ro.build.version.incremental)"
    [[ "$model" == AFTB ]] || die "Expected model AFTB, got: $model"
    [[ "$device" == bueller ]] || die "Expected device bueller, got: $device"
    [[ "$sdk" == 22 ]] || die "Expected Android API 22, got: $sdk"
    if [[ "$build" != 656639420 && "${ALLOW_UNTESTED_BUILD:-0}" != 1 ]]; then
        die "Untested Bueller build $build; set ALLOW_UNTESTED_BUILD=1 only after checking compatibility"
    fi
    note "Target: $model/$device API $sdk build $build, ADB $ADB_SERIAL"
}

remote_quote() {
    local value=$1
    printf "'%s'" "$(printf '%s' "$value" | sed "s/'/'\\\\''/g")"
}

