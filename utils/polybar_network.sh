#!/usr/bin/env bash

set -eu

interface=$(ip -o route show default 2>/dev/null | awk 'NR == 1 { print $5 }')
if [ -z "$interface" ]; then
    printf 'Offline\n'
    exit 0
fi

connection=''
if command -v nmcli >/dev/null 2>&1; then
    connection=$(nmcli -t -f GENERAL.CONNECTION device show "$interface" 2>/dev/null \
        | awk -F: 'BEGIN { OFS=":" } $1 == "GENERAL.CONNECTION" { print $2 }')
fi

if [ -n "$connection" ] && [ "$connection" != "--" ]; then
    printf '%s\n' "$connection"
else
    printf '%s\n' "$interface"
fi
