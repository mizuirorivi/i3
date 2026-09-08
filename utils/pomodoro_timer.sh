#!/usr/bin/env bash

set -eu

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/i3"
STATE_FILE="$STATE_DIR/pomodoro.state"
LOCK_FILE="$STATE_DIR/pomodoro.lock"
DURATION=1500

mkdir -p "$STATE_DIR"

running=0
end=0
sound=off

load_state() {
    running=0
    end=0
    sound=off

    if [ -f "$STATE_FILE" ]; then
        while IFS='=' read -r key value; do
            case "$key" in
                running) running="$value" ;;
                end) end="$value" ;;
                sound) sound="$value" ;;
            esac
        done < "$STATE_FILE"
    fi
}

save_state() {
    local temporary="$STATE_FILE.$$"
    printf 'running=%s\nend=%s\nsound=%s\n' "$running" "$end" "$sound" > "$temporary"
    mv "$temporary" "$STATE_FILE"
}

format_time() {
    local seconds="$1"
    printf '%02d:%02d' "$((seconds / 60))" "$((seconds % 60))"
}

play_sound() {
    [ "$sound" = on ] || return 0
    if command -v canberra-gtk-play >/dev/null 2>&1; then
        canberra-gtk-play -i bell >/dev/null 2>&1 &
    fi
}

finish_timer() {
    local choice

    play_sound
    notify-send 'Pomodoro finished' 'Take a break. Choose what to do next.'
    choice=$(printf 'Lock\nSuspend\nIgnore\n' | rofi -dmenu -i -p 'Pomodoro finished' || true)
    case "$choice" in
        Lock) i3lock -i "$HOME/.config/i3/images/rick_and_morty.png" ;;
        Suspend) systemctl suspend ;;
        Ignore) notify-send 'Pomodoro' 'No action taken.' ;;
    esac
}

start_timer() {
    load_state
    if [ "$running" -eq 1 ]; then
        notify-send 'Pomodoro' 'A timer is already running.'
        exit 0
    fi

    running=1
    end=$(( $(date +%s) + DURATION ))
    save_state
    notify-send 'Pomodoro started' '25 minutes of focused work.'
    "$0" watch >/dev/null 2>&1 &
}

stop_timer() {
    load_state
    running=0
    end=0
    save_state
    notify-send 'Pomodoro stopped' 'The timer has been stopped.'
}

set_sound() {
    load_state
    case "${1:-toggle}" in
        on) sound=on ;;
        off) sound=off ;;
        toggle) [ "$sound" = on ] && sound=off || sound=on ;;
        *) exit 2 ;;
    esac
    save_state
    notify-send 'Pomodoro sound' "Sound: $sound"
}

show_status() {
    load_state
    if [ "$running" -eq 1 ]; then
        local remaining=$((end - $(date +%s)))
        if [ "$remaining" -gt 0 ]; then
            printf 'Pomodoro %s\n' "$(format_time "$remaining")"
        else
            printf 'Pomodoro DONE\n'
        fi
    else
        printf 'Pomodoro --:--\n'
    fi
}

watch_timer() {
    while :; do
        load_state
        [ "$running" -eq 1 ] || exit 0

        if [ "$end" -le "$(date +%s)" ]; then
            exec 9>"$LOCK_FILE"
            flock -n 9 || exit 0
            load_state
            if [ "$running" -eq 1 ] && [ "$end" -le "$(date +%s)" ]; then
                running=0
                end=0
                save_state
                flock -u 9
                finish_timer
            else
                flock -u 9
            fi
            exit 0
        fi
        sleep 1
    done
}

case "${1:-status}" in
    start) start_timer ;;
    stop|reset) stop_timer ;;
    sound) set_sound "${2:-toggle}" ;;
    status) show_status ;;
    watch) watch_timer ;;
    *) printf 'Usage: %s {start|stop|sound toggle|status}\n' "$0" >&2; exit 2 ;;
esac
