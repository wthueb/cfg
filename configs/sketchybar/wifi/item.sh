#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"

wifi=(
  script=wifi/script.sh
  icon="$WIFI_DISCONNECTED"
  label.width=0
  update_freq=60
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change mouse.entered mouse.exited

sketchybar --add item wifi.info popup.wifi
