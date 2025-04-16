#!/usr/bin/env bash

title=(
  icon.drawing=off
  associated_display=active
  script=title/script.sh
)

sketchybar -m --add event window_focus \
              --add event title_change

sketchybar --add item title left \
           --set title "${title[@]}" \
           --subscribe title window_focus front_app_switched space_change title_change
