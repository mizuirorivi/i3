#!/usr/bin/env bash

set -eu

for battery in /sys/class/power_supply/BAT*; do
    [ -d "$battery" ] || continue

    capacity=$(cat "$battery/capacity" 2>/dev/null || true)
    status=$(cat "$battery/status" 2>/dev/null || true)
    [ -n "$capacity" ] || exit 0

    case "$status" in
        Charging) printf '+%s%%\n' "$capacity" ;;
        Full) printf 'Full\n' ;;
        *) printf '%s%%\n' "$capacity" ;;
    esac
    exit 0
done
