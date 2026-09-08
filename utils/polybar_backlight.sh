#!/usr/bin/env bash

set -eu

for backlight in /sys/class/backlight/*; do
    [ -d "$backlight" ] || continue

    brightness=$(cat "$backlight/brightness" 2>/dev/null || true)
    maximum=$(cat "$backlight/max_brightness" 2>/dev/null || true)
    [ -n "$brightness" ] && [ -n "$maximum" ] && [ "$maximum" -gt 0 ] || exit 0

    printf '%s%%\n' "$((brightness * 100 / maximum))"
    exit 0
done
