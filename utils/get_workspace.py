import os
import sys
import subprocess
from subprocess import check_output
import json

config_path = os.path.expanduser('~/.config/i3/')
utils_path = os.path.join(config_path, 'utils')
address_get_mouse_cur = os.path.join(utils_path, 'get_mouse_cur.py')
address_python = '/home/r3v321se/.pyenv/shims/python'

def get_cur_monitor():
    output = check_output([address_python,address_get_mouse_cur ]).decode()
    return output
def get_current_workspace():
    command = ["i3-msg", "-t", "get_workspaces"]
    output = subprocess.check_output(command).decode("utf-8")
    workspaces = json.loads(output)
    
    for workspace in workspaces:
        if workspace["focused"]:
            return workspace["name"]
    
    return None
# print(get_cur_monitor())
print(get_current_workspace())
