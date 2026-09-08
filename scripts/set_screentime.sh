#!/bin/bash

# Get user input via rofi
timeout=$(rofi -dmenu -p "Enter DPMS timeout (in minutes):" -l 0)

# Convert minutes to seconds
seconds=$((timeout * 60))

# Set DPMS timeout
xset dpms $seconds $seconds $seconds

# Notify user
notify-send "DPMS Timeout Set" "Screen will turn off after $timeout minutes of inactivity"
