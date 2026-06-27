#!/bin/sh
pane_tty=$1; pid=$2
case "$pid" in ''|*[!0-9]*) exit 0 ;; esac
[ -z "$pane_tty" ] && exit 0
while [ "$pid" -gt 1 ]; do
    comm=$(cat /proc/$pid/comm 2>/dev/null) || exit 0
    case "$comm" in st|alacritty|kitty|xterm|urxvt|foot) break ;; esac
    pid=$(sed 's/.*) //' /proc/$pid/stat 2>/dev/null | awk '{print $2}')
    case "$pid" in ''|*[!0-9]*) exit 0 ;; esac
done
mkdir -p /tmp/dwm-tty
echo "$pid" > "/tmp/dwm-tty/$(basename "$pane_tty")"
