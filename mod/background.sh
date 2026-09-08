#!/bin/bash


PRIMARY_BG=$1


SECONDARY_BG=$2


MONITOR_COUNT=$(xrandr --query | grep " connected" | wc -l)

if [ $MONITOR_COUNT -eq 1 ]; then
    
    feh --bg-fill "$PRIMARY_BG"
else
    
    feh --bg-fill "$PRIMARY_BG" "$SECONDARY_BG"
fi
