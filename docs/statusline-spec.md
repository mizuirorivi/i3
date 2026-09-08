# Statusline Specification

## Renderer

- Use Polybar with the `colorblocks` theme.
- Start one bar per connected monitor.
- Place the bar at the top with a default height of 30 pixels.
- Restart the bars when monitor configuration changes.
- Do not use i3bar, i3status, or i3blocks for the active statusline.

## Layout

- Left: launcher, workspaces, and separators.
- Center: the Pomodoro timer.
- Right: theme switcher, CPU, memory, volume, battery, network, date, and power menu.

## Workspaces

- Show only the workspaces belonging to the monitor where the bar is displayed.
- Keep numeric workspace labels in the existing i3 order (`1` through `9`).
- Preserve named workspaces such as `virtualBox` and `notion`.
- Empty workspaces remain visible as numeric labels.

## Hardware-dependent modules

- Detect the battery under `/sys/class/power_supply/BAT*`.
- Hide the battery module when no battery exists.
- Detect the first available backlight under `/sys/class/backlight/*`.
- Hide the backlight module when no backlight exists.
- Detect the active network interface from the default route.
- Show `Offline` when no default route exists.

## Theme persistence

Theme scripts update the persisted Polybar color configuration in
`~/.config/polybar/colorblocks/colors.ini`. A selected theme must therefore
remain active after Polybar or the X session is restarted.

## Pomodoro timer

- Use a 25-minute work timer by default.
- Show the remaining time in the center of Polybar.
- Notify the user when the timer finishes.
- Show `Lock`, `Suspend`, and `Ignore` actions with Rofi.
- Keep timer sound disabled by default.
- Toggle timer sound with the i3 binding for `$mod+Shift+o`.
- The same operations are available from `Mod+Shift+d` via `pomodoro.sh`.
