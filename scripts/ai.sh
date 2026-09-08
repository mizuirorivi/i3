#!/bin/bash
SDIR="$HOME/.config/polybar/colorblocks/scripts"

MENU="$(rofi -dmenu -p 'RUN local perplexity' -no-config -no-lazy-grab -sep "|" \ <<< "no|yes")"


sites="https://chatgpt.com/ https://openrouter.ai/chat?models=openai/gpt-4o-mini https://www.perplexity.ai/"
if [ $MENU == "yes" ]; then
    sites="http://localhost:3000/ $sites"
    flag_running_local_perplexity=$(docker ps -a | grep perplexica | wc -l)
    if [ $flag_running_local_perplexity -eq 0 ]; then
        cd $HOME/Tools/Perplexica/
        docker-compose up -d
    fi
fi

MENU="$(rofi -dmenu -p 'RUN local gptme?' -no-config -no-lazy-grab -sep "|" \ <<< "no|yes")"

if [ $MENU == "yes" ]; then
  sites="http://127.0.0.1:5000/ $sites"
  source ~/.zshrc
  /home/r3v321se/.local/bin/gptme-server > server_output.log 2>&1
  pid=$!
  if [ -d "/proc/$pid" ]; then
  notify-send 'gptme-server' 'gptme-server is running'
  else
  notify-send 'gptme-server' 'gptme-server is not running'
  fi
fi
# debug sites
rofi -p "RUN sites" -no-config -no-lazy-grab -sep "|" \ <<< "$sites"

i3-msg "workspace ai"
i3-msg "exec --no-startup-id google-chrome --new-window $(echo -e $sites)"
