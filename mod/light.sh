#!/bin/bash
# Pointer-aware brightness control.
# Adjusts the internal panel via `light`, external outputs via xrandr,
# picking the output the mouse pointer is currently on.
#
# Usage: light.sh up|down [step%]
#        light.sh set <percent>
export DISPLAY=${DISPLAY:-:0}
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

action=$1
case "$action" in
    up|down)
        step=${2:-5}
        ;;
    set)
        percent=$2
        if ! [[ $percent =~ ^[0-9]+$ ]]; then
            notify-send "light.sh: set needs a percent (10-100)"
            exit 1
        fi
        ;;
    *)
        echo "usage: $0 up|down [step%] | set <percent>" >&2
        exit 1
        ;;
esac

# Serialize concurrent runs so key repeat can't read a stale brightness.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/i3-light.lock"
flock 9

eval "$(xdotool getmouselocation --shell)"  # sets X, Y

# Geometry field looks like 1366/294x768/165+554+1080 (size includes mm).
display=$(xrandr --listactivemonitors | awk 'NR > 1 {
    geo = $3
    gsub(/\/[0-9]+/, "", geo)
    split(geo, g, /[x+]/)
    print $NF, g[1], g[2], g[3], g[4]
}' | while read -r name w h ox oy; do
    if (( X >= ox && X < ox + w && Y >= oy && Y < oy + h )); then
        printf '%s' "$name"
        break
    fi
done)

if [[ -z $display ]]; then
    display=$(xrandr | awk '/ primary /{print $1; exit}')
fi

if [[ $display == eDP* ]]; then
    case "$action" in
        up)   light -A "$step" ;;
        down) light -U "$step" ;;
        set)  light -S "$percent" ;;
    esac
else
    cur=$(xrandr --verbose | awk -v out="$display" '
        $1 == out { inblk = 1; next }
        inblk && /^[^ \t]/ { exit }
        inblk && $1 == "Brightness:" { print $2; exit }')
    new=$(awk -v c="${cur:-1.0}" -v a="$action" -v s="${step:-0}" -v p="${percent:-0}" 'BEGIN {
        if (a == "set")     n = p / 100
        else if (a == "up") n = c + s / 100
        else                n = c - s / 100
        if (n > 1.0) n = 1.0
        if (n < 0.1) n = 0.1
        printf "%.2f", n
    }')
    xrandr --output "$display" --brightness "$new"
fi
