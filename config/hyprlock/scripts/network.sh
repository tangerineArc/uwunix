#! /usr/bin/env bash

show_ssid=true
max_len=8 # Tweak this based on your hyprlock layout

# Check if any Ethernet connection is active
ethernet_connected=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep -E 'ethernet:connected')

if [ -n "$ethernet_connected" ]; then
  echo "󰈀 Ethernet"
  exit 0
fi

# Get Wi-Fi connection status
wifi_status=$(nmcli -t -f WIFI g)

if [ "$wifi_status" != "enabled" ]; then
  echo "󰤮 Wi-Fi Off"
  exit 0
fi

# Get active Wi-Fi connection details
wifi_info=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes')

if [ -z "$wifi_info" ]; then
  echo "󰤮 No Wi-Fi"
  exit 0
fi

# Extract SSID
ssid=$(echo "$wifi_info" | cut -d':' -f2)

# --- TRUNCATION LOGIC ---
if [ ${#ssid} -gt $max_len ]; then
  ssid="${ssid:0:$max_len}..."
fi

# Extract signal strength
signal_strength=$(echo "$wifi_info" | cut -d':' -f3)

# Define Wi-Fi icons based on signal strength
wifi_icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")

# Clamp signal strength
signal_strength=$((signal_strength < 0 ? 0 : (signal_strength > 100 ? 100 : signal_strength)))
icon_index=$((signal_strength / 25))
wifi_icon=${wifi_icons[$icon_index]}

# Output
if [ "$show_ssid" = true ]; then
  echo "$wifi_icon $ssid"
else
  echo "$wifi_icon Connected"
fi
