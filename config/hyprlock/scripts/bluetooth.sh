#! /usr/bin/env bash

bt_mode=true
max_len=8 # Tweak to match Wi-Fi length

if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
  echo "󰂲 Bluetooth Off"
  exit 0
fi

bluez_state=$(busctl call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects --json=short 2>/dev/null)

if [ -z "$bluez_state" ]; then
  echo "󰂲 Bluetooth Off"
  exit 0
fi

adapter_powered=$(echo "$bluez_state" | jq -r '
  .data[0] | to_entries[] |
  select(.value["org.bluez.Adapter1"] != null) |
  .value["org.bluez.Adapter1"]["Powered"].data
' | grep -q "true" && echo "yes" || echo "no")

if [ "$adapter_powered" = "no" ]; then
  echo "󰂲 Bluetooth Off"
  exit 0
fi

connected_devices=$(echo "$bluez_state" | jq -r '
  .data[0] | to_entries[] |
  select(.value["org.bluez.Device1"] != null) |
  select(.value["org.bluez.Device1"]["Connected"].data == true) |
  (.value["org.bluez.Device1"]["Alias"].data // "Unknown Device")
')

if [ -z "$connected_devices" ]; then
  echo "󰂲 No Devices"
else
  device_list=$(echo "$connected_devices" | paste -sd ", " -)

  # --- TRUNCATION LOGIC ---
  if [ ${#device_list} -gt $max_len ]; then
    device_list="${device_list:0:$max_len}..."
  fi

  if [ "$bt_mode" = "true" ]; then
    echo "󰂯 $device_list"
  else
    echo "󰂯 Connected"
  fi
fi
