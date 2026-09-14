#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device

adb_cmd shell pm path com.spocky.projengmenu >/dev/null || die 'Projectivy is not installed'
if adb_cmd shell pm list packages -d | tr -d '\r' | grep -qx 'package:com.amazon.tv.launcher'; then
    "$REPO_ROOT/scripts/root-command.sh" 'pm enable --user 0 com.amazon.tv.launcher'
fi
boot_completed="$(adb_cmd shell getprop sys.boot_completed | tr -d '\r')"
[[ "$boot_completed" == 1 ]] || die 'Fire OS has not completed boot; do not stop its launcher handoff yet'
adb_cmd shell am start -W -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null
adb_cmd shell am force-stop com.amazon.tv.launcher
adb_cmd shell am start -W -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null
printf 'Stock launcher package retained for boot safety; background process stopped; Projectivy started.\n'
