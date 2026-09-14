#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device

state_arg="${1:-$REPO_ROOT/state/latest}"
[[ -d "$state_arg" ]] || die "Rollback state directory not found: $state_arg"
state_dir="$(cd "$state_arg" && pwd)"
[[ -f "$state_dir/newly-disabled.txt" ]] || die 'Missing newly-disabled.txt; refusing a broad enable operation'

command='failures=0; '
while IFS= read -r line; do
    package=${line#package:}
    [[ -n "$package" ]] || continue
    command+="pm enable --user 0 $package || failures=\$((failures+1)); "
done < "$state_dir/newly-disabled.txt"

if [[ -f "$state_dir/settings-before.tsv" ]]; then
    while IFS=$'\t' read -r namespace key value; do
        [[ -n "$namespace" && -n "$key" ]] || continue
        if [[ -z "$value" || "$value" == null ]]; then
            command+="settings delete $namespace $key; "
        else
            command+="settings put $namespace $key $(remote_quote "$value"); "
        fi
    done < "$state_dir/settings-before.tsv"
fi
command+='echo PM_FAILURES=$failures; test "$failures" -eq 0'
"$REPO_ROOT/scripts/root-command.sh" "$command"
adb_cmd shell am start -W -a android.intent.action.MAIN -c android.intent.category.HOME >/dev/null
printf 'Rollback applied from %s. Projectivy remains installed.\n' "$state_dir"

