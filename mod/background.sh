#!/bin/bash

# プライマリモニターの背景画像
PRIMARY_BG=$1

# セカンダリモニターの背景画像
SECONDARY_BG=$2

# 接続されているモニターの数を取得
MONITOR_COUNT=$(xrandr --query | grep " connected" | wc -l)

if [ $MONITOR_COUNT -eq 1 ]; then
    # 1つのモニターの場合
    feh --bg-fill "$PRIMARY_BG"
else
    # 2つ以上のモニターの場合
    feh --bg-fill "$PRIMARY_BG" "$SECONDARY_BG"
fi
