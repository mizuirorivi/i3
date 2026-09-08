#!/usr/bin/env bash

set -eu

TIMER="$HOME/.config/i3/utils/pomodoro_timer.sh"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/i3/pomodoro.state"

sound=off
if [ -f "$STATE_FILE" ]; then
    sound=$(awk -F= '$1 == "sound" { print $2 }' "$STATE_FILE")
fi

choice=$(printf 'Start\nStop\nSound on\nSound off\n' \
    | rofi -dmenu -i -p "$("$TIMER" status) [sound: $sound]")

case "$choice" in
    Start) "$TIMER" start ;;
    Stop) "$TIMER" stop ;;
    'Sound on') "$TIMER" sound on ;;
    'Sound off') "$TIMER" sound off ;;
esac
