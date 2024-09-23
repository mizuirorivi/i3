#!/bin/bash

MARKER="temp_scratchpad"
WINDOW_INFO_FILE="/tmp/i3_window_info_temp.txt"
DISPLAY_TIME=5

# 現在のワークスペース名を取得
CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' -r)

# ウィンドウ情報を保存
i3-msg -t get_tree | jq -r ".. | select(.type? == \"con\" and .window?) | \"\(.window) \(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height) \(.focused)\"" > $WINDOW_INFO_FILE

# 現在のワークスペースのウィンドウをマークしてスクラッチパッドに移動
i3-msg "[workspace=\"$CURRENT_WORKSPACE\"] mark $MARKER, move scratchpad"

# 待機時間
sleep $DISPLAY_TIME

# マークされたウィンドウをスクラッチパッドから戻す
i3-msg "[con_mark=$MARKER] scratchpad show, unmark"

# ウィンドウの位置とサイズを復元
while read window x y width height focused; do
    i3-msg "[id=$window] move to workspace $CURRENT_WORKSPACE, move position $x px $y px, resize set $width px $height px"
    if [ "$focused" = "true" ]; then
        i3-msg "[id=$window] focus"
    fi
done < $WINDOW_INFO_FILE

# 一時ファイルを削除
rm $WINDOW_INFO_FILE

# 現在のワークスペースにフォーカスを戻す
i3-msg "workspace $CURRENT_WORKSPACE"
