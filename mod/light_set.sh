#!/bin/bash
value=$(i3-input -P 'brightness % (10-100): ' | sed -n 's/^command = //p')
[[ -n $value ]] && exec "$(dirname "$0")/light.sh" set "$value"
