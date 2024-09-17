#!/bin/bash

if i3-msg -t get_tree | grep -q "notion"; then
    i3-msg "[class=Anki] focus"
    exit
fi
i3-msg workspace "anki"

anki=$(i3-msg -t get_tree | jq -r '..|try select(.window)|{name: .window_properties.class, id: .
id}' | jq 'select(.name | contains("Anki"))')
if [ -z "$anki" ]; then 
    i3-msg "exec --no-startup-id anki"
    sleep 0.5
fi
anki_id=$(echo $anki | jq -r '.id')
i3-msg "[con_id=$anki_id] move to workspace anki"

i3-msg "split h"
i3-msg "exec --no-startup-id google-chrome --new-window https://chatgpt.com/g/g-KRfMogVvd-english-learner"
