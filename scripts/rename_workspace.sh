#!/bin/bash

current_workspace=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' -r)

i3-input -F "rename workspace \"$current_workspace\" to \"%s\"" -P 'New workspace name: '
