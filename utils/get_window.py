from i3ipc import Connection
import json

i3 = Connection()
nodes = i3.get_tree().nodes
print(len(nodes))
# for node in nodes:
    # print(node.name)



i3_node = nodes[0]
