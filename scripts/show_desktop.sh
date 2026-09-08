#!/bin/bash

MARKER="temp_scratchpad"
WINDOW_INFO_FILE="/tmp/i3_window_info_temp.txt"
DISPLAY_TIME=5

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' -r)

i3-msg -t get_tree | jq -r ".. | select(.type? == \"con\" and .window?) | \"\(.window) \(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height) \(.focused)\"" > $WINDOW_INFO_FILE

i3-msg "[workspace=\"$CURRENT_WORKSPACE\"] mark $MARKER, move scratchpad"

sleep $DISPLAY_TIME

i3-msg "[con_mark=$MARKER] scratchpad show, unmark"

while read window x y width height focused; do
    i3-msg "[id=$window] move to workspace $CURRENT_WORKSPACE, move position $x px $y px, resize set $width px $height px"
    if [ "$focused" = "true" ]; then
        i3-msg "[id=$window] focus"
    fi
done < $WINDOW_INFO_FILE

rm $WINDOW_INFO_FILE

i3-msg "workspace $CURRENT_WORKSPACE"
