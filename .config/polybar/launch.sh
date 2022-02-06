#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar-main.log
MONITOR="DisplayPort-0" polybar left -r 2>&1 | tee -a /tmp/polybar-main.log & disown
MONITOR="DisplayPort-2" polybar right -r 2>&1 | tee -a /tmp/polybar-main.log & disown

echo "Bars launched..."
