from i3ipc import Connection
import json

i3 = Connection()
tree = i3.get_tree()
scratchpad = tree.scratchpad()
windows = []
for window in scratchpad.leaves():
    windows.append({"name": window.name, "id": window.id})
#print windows as json
print(json.dumps(windows,indent=4))
