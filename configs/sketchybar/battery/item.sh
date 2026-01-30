#!/usr/bin/env bash

battery=(
  script=battery/script.sh
  update_freq=30
  icon.padding_right=3
  icon.y_offset=-1
)

sketchybar --add item battery right \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke mouse.entered mouse.exited \
           --add item battery.info popup.battery
