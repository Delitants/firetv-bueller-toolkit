#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device

adb_cmd shell pm path com.spocky.projengmenu >/dev/null || die 'Projectivy is not installed'
adb_cmd shell am start -W -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null
state_dir=''
if [[ -L "$REPO_ROOT/state/latest" ]]; then
    state_dir="$(cd "$REPO_ROOT/state/latest" && pwd)"
fi
was_disabled=0
if adb_cmd shell pm list packages -d | tr -d '\r' | grep -qx 'package:com.amazon.tv.launcher'; then
    was_disabled=1
fi
"$REPO_ROOT/scripts/root-command.sh" 'pm disable-user --user 0 com.amazon.tv.launcher'
if [[ $was_disabled -eq 0 && -n "$state_dir" ]]; then
    printf 'package:com.amazon.tv.launcher\n' >> "$state_dir/newly-disabled.txt"
    sort -u -o "$state_dir/newly-disabled.txt" "$state_dir/newly-disabled.txt"
fi
adb_cmd shell am start -W -a android.intent.action.MAIN -c android.intent.category.HOME
printf 'Stock launcher disabled for user 0; HOME intent sent.\n'

