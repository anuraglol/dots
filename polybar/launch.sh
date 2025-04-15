#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar
polybar bar & # Replace 'main' with your bar name from the config

# If you have multiple monitors and want a bar on each:
# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar main &
# done
