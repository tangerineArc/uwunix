#! /usr/bin/env bash

show_ssid=true
max_len=8

ethernet_connected=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep -E 'ethernet:connected')
if [ -n "$ethernet_connected" ]; then
  echo "󰈀 ethernet"
  exit 0
fi

wifi_status=$(nmcli -t -f WIFI g)
if [ "$wifi_status" != "enabled" ]; then
  echo "󰤮 wi-fi off"
  exit 0
fi

wifi_info=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes')
if [ -z "$wifi_info" ]; then
  echo "󰤮 no wi-fi"
  exit 0
fi

ssid=$(echo "$wifi_info" | cut -d':' -f2)
if [ ${#ssid} -gt $max_len ]; then
  ssid="${ssid:0:$max_len}..."
fi

wifi_icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")

signal_strength=$(echo "$wifi_info" | cut -d':' -f3)
signal_strength=$((signal_strength < 0 ? 0 : (signal_strength > 100 ? 100 : signal_strength)))

icon_index=$((signal_strength / 25))
wifi_icon=${wifi_icons[$icon_index]}

if [ "$show_ssid" = true ]; then
  echo "$wifi_icon $ssid"
else
  echo "$wifi_icon connected"
fi
