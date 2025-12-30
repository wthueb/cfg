#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"

update() {
  local adapter, ssid, ip, has_ip
  adapter=$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }')
  ssid=$(ipconfig getsummary "$adapter" | awk -F ' SSID : '  '/ SSID : / {print $2}')
  ip=$(ipconfig getifaddr "$adapter")
  has_ip=$?

  local icon, info
  if [ $has_ip -ne 0 ]; then
    info="No Wi-Fi"
    icon=$WIFI_DISCONNECTED
  else
    info="$ssid ($ip)"
    icon=$WIFI_CONNECTED
  fi

  sketchybar --set wifi icon="$icon"
  sketchybar --set wifi.info label="$info"
}

entered() {
  sketchybar --set wifi popup.drawing=on
}

exited() {
  sketchybar --set wifi popup.drawing=off
}

case "$SENDER" in
  "mouse.entered") entered
  ;;
  "mouse.exited") exited
  ;;
  "wifi_change") update
  ;;
  *) update
esac
