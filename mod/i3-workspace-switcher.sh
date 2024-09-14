#!/bin/bash

# Get the list of workspaces
workspaces=$(i3-msg -t get_workspaces | jq -r '.[].name' | sort -u)

# Use rofi to select a workspace
selected=$(echo "$workspaces" | rofi -dmenu -p "Select workspace:")

# If a workspace was selected, switch to it
if [ -n "$selected" ]; then
    i3-msg workspace "$selected"
fi
