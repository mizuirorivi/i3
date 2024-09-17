#!/usr/bin/env python3
import i3ipc
import subprocess

i3 = i3ipc.Connection()
scratchpad_windows = i3.get_tree().scratchpad().leaves()

window_list = [f"{w.name}" for w in scratchpad_windows]
rofi_input = "\n".join(window_list)

selected = subprocess.run(["rofi", "-dmenu", "-p", "Scratchpad"], input=rofi_input, text=True, capture_output=True).stdout.strip()

if selected:
    for window in scratchpad_windows:
        if window.name == selected:
            window.command("scratchpad show")
            break
