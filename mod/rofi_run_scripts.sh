#!/bin/bash

SCRIPT_DIR="$HOME/.config/i3/scripts"

selected_script=$(ls "$SCRIPT_DIR" | rofi -dmenu -p "Select a script to run")

if [[ -n "$selected_script" ]]; then
    "$SCRIPT_DIR/$selected_script"
fi
