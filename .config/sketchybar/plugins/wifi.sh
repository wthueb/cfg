#!/usr/bin/env bash

update() {
  source "$CONFIG_DIR/icons.sh"
  local adapter
  local ssid
  local ip
  local has_ip

  adapter=$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }')
  ssid=$(ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}')
  ip=$(ipconfig getifaddr "$adapter")
  has_ip=$?

  local label
  local icon

  if [ $has_ip -ne 0 ]; then
    label="No Wi-Fi"
    icon=$WIFI_DISCONNECTED
  else
    label="$ssid ($ip)"
    icon=$WIFI_CONNECTED
  fi

  sketchybar --set "$NAME" icon="$icon" label="$label"
}

click() {
  local cur_width
  cur_width="$(sketchybar --query "$NAME" | jq -r .label.width)"

  local width=0
  if [ "$cur_width" -eq "0" ]; then
    width=dynamic
  fi

  sketchybar --animate sin 20 --set "$NAME" label.width="$width"
}

case "$SENDER" in
  "wifi_change") update
  ;;
  "mouse.clicked") click
  ;;
esac
