#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    printf 'Run with sudo: sudo %s\n' "$0" >&2
    exit 1
fi

apt-get update
apt-get install -y --no-install-recommends \
    aapt adb apksigner ca-certificates curl git gcc-arm-linux-gnueabihf make

