#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
guard_device

PACKAGE_FILE="$REPO_ROOT/packages/aggressive.txt"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
state_dir="$REPO_ROOT/state/$stamp"
mkdir -p "$state_dir"
adb_cmd shell pm list packages -d | tr -d '\r' | sort > "$state_dir/disabled-before.txt"
: > "$state_dir/settings-before.tsv"
for item in \
    'global amazon:device_metrics_opt_in' \
    'global limit_ad_tracking' \
    'global amazon:interest_based_ads' \
    'secure usage_stats'; do
    namespace=${item%% *}
    key=${item#* }
    value="$(adb_cmd shell settings get "$namespace" "$key" | tr -d '\r\n')"
    printf '%s\t%s\t%s\n' "$namespace" "$key" "$value" >> "$state_dir/settings-before.tsv"
done

mapfile -t packages < <(awk 'NF && $1 !~ /^#/' "$PACKAGE_FILE")
for ((start=0; start<${#packages[@]}; start+=6)); do
    command=''
    end=$((start + 6))
    ((end > ${#packages[@]})) && end=${#packages[@]}
    for ((index=start; index<end; index++)); do
        command+="pm disable-user --user 0 ${packages[index]}; "
    done
    "$REPO_ROOT/scripts/root-command.sh" "$command"
done
"$REPO_ROOT/scripts/root-command.sh" \
    'settings put global amazon:device_metrics_opt_in 0; settings put global limit_ad_tracking 1; settings put global amazon:interest_based_ads 0; settings put secure usage_stats 0'

adb_cmd shell pm list packages -d | tr -d '\r' | sort > "$state_dir/disabled-after.txt"
comm -13 "$state_dir/disabled-before.txt" "$state_dir/disabled-after.txt" > "$state_dir/newly-disabled.txt"
ln -sfn "$stamp" "$REPO_ROOT/state/latest"
printf 'Debloat state and rollback data: %s\n' "$state_dir"
