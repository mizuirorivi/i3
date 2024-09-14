#!/bin/bash

# Get the list of workspaces
workspaces=$(i3-msg -t get_workspaces | jq -r '.[].name' | sort -u)

# Use rofi to select a workspace
selected=$(echo "$workspaces" | rofi -dmenu -p "Select workspace:")

i3-msg "move container to workspace $selected"
