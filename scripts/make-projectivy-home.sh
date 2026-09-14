#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device

adb_cmd shell pm path com.spocky.projengmenu >/dev/null || die 'Projectivy is not installed'
"$REPO_ROOT/scripts/root-command.sh" 'pm enable --user 0 com.amazon.tv.launcher'
adb_cmd shell am start -W -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null
printf 'Stock launcher retained for boot safety; Projectivy started.\n'
