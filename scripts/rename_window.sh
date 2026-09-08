#!/bin/bash

# rofi が開く前にフォーカスウィンドウのIDを保存
window_id=$(xdotool getactivewindow)

if [[ -n "$1" ]]; then
    new_title="$1"
else
    new_title=$(rofi -dmenu -p "Window title:" -theme-str 'window {width: 400px;}')
fi

[[ -z "$new_title" ]] && exit 0

xdotool set_window --name "$new_title" "$window_id"
