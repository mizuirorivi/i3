#!/bin/bash

SCRIPT_DIR="$HOME/.config/i3/scripts"
LOG="/tmp/rofi_run_scripts.log"

# rofi を開く前に、現在フォーカスされている出力（モニター）を取得しておく。
# 各スクリプトはこの $I3_TARGET_OUTPUT を見て、そのモニターで環境を開く。
I3_TARGET_OUTPUT="$(i3-msg -t get_workspaces \
  | python3 -c 'import json,sys; print(next(w["output"] for w in json.load(sys.stdin) if w["focused"]))' 2>/dev/null)"

scripts=$(find "$SCRIPT_DIR" -type f -executable)
scripts=$(echo "$scripts" | sed "s|$SCRIPT_DIR/||g")
selected_script=$(echo "$scripts" | rofi -dmenu -p "Select a script to run")

if [[ -n "$selected_script" ]]; then
    # スクリプトをi3のexec環境から切り離してバックグラウンド実行する
    # （make dc-up 等の完了待ちでブロックしないように）。
    # 出力は $LOG に残すのでトラブル時に確認できる。
    echo "=== $(date) run: $selected_script (output=$I3_TARGET_OUTPUT) ===" >>"$LOG"
    I3_TARGET_OUTPUT="$I3_TARGET_OUTPUT" \
        setsid bash -c "'$SCRIPT_DIR/$selected_script'" </dev/null >>"$LOG" 2>&1 &
fi
