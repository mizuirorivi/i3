#!/bin/bash
ws=$(/home/r3v321se/.pyenv/shims/python ~/.config/i3/utils/get_workspace.py)
n="$(xrandr | grep " connected " |awk '{print $1}')"

selected=$(echo "$n" | rofi -dmenu -p "Select monitor:")
i3-msg "[workspace=$ws] move workspace to output $selected"
