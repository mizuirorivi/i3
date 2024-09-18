#!/bin/bash
log=/tmp/light_down.log
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority

# 一度だけxrandr --verboseを呼び出してその出力をキャッシュ
xrandr_output=$(xrandr --verbose)

# フォーカスされたディスプレイを取得
display=$(/home/r3v321se/.pyenv/shims/python ~/.config/i3/utils/get_mouse_cur.py 2>~/display.log)

# ディスプレイごとの明るさ設定を非同期で実行
case "$display" in
    "eDP-1")
        # lightコマンドを使って明るさを10%減少させる
        light -U 10
        ;;
    "HDMI-2")
        # 一度キャッシュしたxrandrの出力から明るさを抽出
        brightness=$(echo "$xrandr_output" | grep -A 5 "$display" | grep -i brightness | awk '{print $2}')
      
        brightness=$(printf "%.2f" "$brightness")
      
        # bcで計算を行い、明るさを減少させる
        after=$(echo "scale=2; $brightness - 0.1" | bc)
      
        after=$(printf "%0.2f" "$after")
      
        # 明るさの下限を0.1に制限
        if (( $(echo "$after < 0.1" | bc -l) )); then
            after=0.1
        fi

        echo "HDMI-2 is pressed" >> $log
        # xrandrを使って明るさを減少させる
        xrandr --output HDMI-2 --brightness $after &
        ;;
    *)
        notify-send "Unknown display: $display" &
        ;;
esac
