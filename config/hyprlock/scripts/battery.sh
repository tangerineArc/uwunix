#! /usr/bin/env bash

BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)
if [ -z "$BAT" ]; then
  echo "󰂑 AC"
  exit 0
fi

CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity)
STATUS=$(cat /sys/class/power_supply/$BAT/status)

battery_icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹")
charging_icon="󰂄"

icon_index=$((CAPACITY / 10))

if [ "$CAPACITY" -eq 100 ]; then
  icon_index=9
fi

battery_icon=${battery_icons[$icon_index]}

if [ "$STATUS" = "Charging" ]; then
  battery_icon="$charging_icon"
fi

echo "$CAPACITY% $battery_icon"
