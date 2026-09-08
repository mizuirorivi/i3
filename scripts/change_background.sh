#!/bin/bash

# ログファイルのパスを設定
LOG_FILE="$HOME/.config/i3/change_background.log"

# ログ関数を定義
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "=== change_background.sh 実行開始 ==="

BASE_DIR="$HOME/.config/i3"
IMG_DIR="$BASE_DIR/images/"
FEHBG_FILE="$HOME/.fehbg"

# ~/.fehbg が存在するか確認
if [ ! -f "$FEHBG_FILE" ]; then
    log "Error: ~/.fehbg ファイルが見つかりません。初期背景を feh で設定してください。"
    exit 1
fi

# ~/.fehbg から現在の背景画像を取得（awkを使用）
origin=$(awk -F'"' '/--bg-fill/ {print $2}' "$FEHBG_FILE")
log "origin: $origin"

# 背景画像を配列に読み込む
readarray -t origin_images <<< "$origin"
log "origin_images 配列: ${origin_images[*]}"

# 余分な引用符を削除（万が一の場合）
for i in "${!origin_images[@]}"; do
    origin_images[$i]=$(echo "${origin_images[$i]}" | sed 's/^"//;s/"$//')
done
log "origin_images 配列（引用符削除後）: ${origin_images[*]}"

declare -A image_list

# 接続されているモニターのリストを取得
origin_monitors=($(xrandr --query | grep " connected" | cut -d" " -f1))
log "origin_monitors: ${origin_monitors[*]}"

# モニター数と背景画像数が一致しているか確認
if [ "${#origin_monitors[@]}" -ne "${#origin_images[@]}" ]; then
    log "Warning: 接続されているモニター数 (${#origin_monitors[@]}) と背景画像数 (${#origin_images[@]}) が一致しません。"
fi

# 各モニターに背景画像を割り当て
for i in "${!origin_monitors[@]}"; do
    monitor="${origin_monitors[$i]}"
    image="${origin_images[$i]}"
    image_list["$monitor"]="$image"
    log "モニター '$monitor' に画像 '$image' を割り当てました。"
done

# 現在のモニターを取得
current_monitor=$(~/.config/i3/utils/get_monitor.sh)
log "現在のモニター: $current_monitor"

# 現在のモニターが接続されているモニターリストに含まれているか確認
if [[ ! " ${origin_monitors[*]} " =~ " ${current_monitor} " ]]; then
    log "Error: 現在のモニター '$current_monitor' が接続されているモニターリストに存在しません。"
    exit 1
fi

# 使用可能な画像のリストを取得
list=$(find "$IMG_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) -printf "%f\n")
log "使用可能な画像リスト: $list"

# rofi で新しい画像を選択
selected_image=$(echo "$list" | rofi -dmenu -p "背景に設定する画像を選択" -theme-str 'window {width: 50%;}')
log "選択された画像: $selected_image"

# 画像が選択された場合
if [ -n "$selected_image" ]; then
    full_path="$IMG_DIR/$selected_image"
    image_list["$current_monitor"]="$full_path"
    log "現在のモニター ('$current_monitor') に新しい画像 '$full_path' を割り当てました。"

    # 更新後のモニターと画像のマッピングをログに記録
    log "更新後のモニターと画像のマッピング:"
    for monitor in "${!image_list[@]}"; do
        log "$monitor: ${image_list[$monitor]}"
    done

    # feh コマンドを配列として再構築
    feh_command=("feh")
    for monitor in "${origin_monitors[@]}"; do
        feh_command+=("--bg-fill" "${image_list[$monitor]}")
    done
    log "実行する feh コマンド: ${feh_command[*]}"

    # feh コマンドを実行して背景を更新
    "${feh_command[@]}"
    if [ $? -eq 0 ]; then
        log "feh コマンドを正常に実行しました。"
    else
        log "Error: feh コマンドの実行に失敗しました。"
    fi

    # ~/.fehbg を更新して背景設定を保存
    {
        echo "#!/bin/sh"
        printf "%s " "${feh_command[@]}"
        echo
    } > "$FEHBG_FILE"
    chmod +x "$FEHBG_FILE"
    log "~/.fehbg を更新しました。"

else
    log "画像が選択されませんでした。"
fi

log "=== change_background.sh 実行終了 ==="
