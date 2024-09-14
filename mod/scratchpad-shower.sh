scratchpad=$(python ~/.config/i3/utils/scratchpad-shower.py)

scratchpad_name=$(echo $scratchpad | jq -r '.name')
