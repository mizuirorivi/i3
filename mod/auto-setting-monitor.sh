#!/bin/bash
n="$(xrandr | grep " connected " | wc -l)"
if [ "$n" -eq "2" ]; then
    $HOME/.screenlayout/second_monitor.sh
else
    $HOME/.screenlayout/one_monitor.sh
fi
killall -q polybar
$HOME/.config/polybar/colorblocks/launch.sh

