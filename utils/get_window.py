from i3ipc import Connection
import json
import argparse

def parser():
    parser = argparse.ArgumentParser(description='Get the current window')
    parser.add_argument('-p', '--print', action='store_true', help='Print the current window')
    parser.add_argument('-m','--monitor',help='Get the current window on the monitor')
    return parser.parse_args()
def main():
    args = parser()
    monitor = args.monitor
    i3 = Connection()
    nodes = i3.get_tree().nodes
    cw = None
    for node in nodes:
        print(node)
        print(node.name)
        if monitor:
            if node.name == monitor:
                cw = node
    i3_node = nodes[0]
    if not cw:
        for node in cw:
            print(node)
if __name__ == "__main__":
    main()
