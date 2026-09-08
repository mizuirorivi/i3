#!/bin/bash 
BASE_DIR="$HOME/.config/i3"
MOD_DIR="$BASE_DIR/mod"
value=$(yad --scale --text="setup value of bar" --min-value=0 --max-value=100 --value=30 --step=1)

if [ $? = 0 ]; then
  export POLYBAR_HEIGHT=$value
  source $MOD_DIR/auto-setting-monitor.sh
else
    exit 1
fi

