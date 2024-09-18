import i3ipc
from subprocess import check_output

i3 = i3ipc.Connection()

def get_mouse_location():
    output = check_output(['xdotool', 'getmouselocation']).decode()
    parts = output.split()
    x = int(parts[0].split(":")[1])
    y = int(parts[1].split(":")[1])
    return x, y

x, y = get_mouse_location()

for output in i3.get_outputs():
    if output.name == "xroot-0":
        continue
    if output.rect.x <= x < output.rect.x + output.rect.width and \
       output.rect.y <= y < output.rect.y + output.rect.height:
        print(f"{output.name}")
        exit(0)

