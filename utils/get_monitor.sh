#!/bin/bash
# i3-msg コマンドを使用して現在のワークスペース情報を取得
current_workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

# 現在のワークスペースが表示されているモニターを取得
current_monitor=$(i3-msg -t get_workspaces | jq -r ".[] | select(.name==\"$current_workspace\").output")

printf "%s" $current_monitor
