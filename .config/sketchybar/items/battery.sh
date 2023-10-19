#!/usr/bin/env bash

battery=(
  script="$PLUGIN_DIR/battery.sh"
  label.drawing=on
  update_freq=60
  updates=on
)

sketchybar --add item battery right      \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
