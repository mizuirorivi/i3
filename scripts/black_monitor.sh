#!/bin/bash
n="$(xrandr | grep " connected " |awk '{print $1}')"

selected=$(echo "$n" | rofi -dmenu -p "Select monitor:")
xrandr --output $selected --off
