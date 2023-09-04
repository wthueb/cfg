#!/usr/bin/env bash

front_app=(
  icon.drawing=off
  associated_display=active
  script="$PLUGIN_DIR/title.sh"
)

sketchybar -m --add event window_focus \
              --add event title_change

sketchybar --add item title left         \
           --set title "${front_app[@]}" \
           --subscribe title window_focus front_app_switched space_change title_change
