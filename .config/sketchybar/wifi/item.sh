#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"

sketchybar --add item wifi right \
           --set wifi script=wifi/script.sh icon="$WIFI_DISCONNECTED" label.width=0 \
           --subscribe wifi wifi_change mouse.entered mouse.exited

sketchybar --add item wifi.info popup.wifi
