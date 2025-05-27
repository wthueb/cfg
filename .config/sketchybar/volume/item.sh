#!/usr/bin/env bash

volume_slider=(
  script=volume/script.sh
  updates=on
  padding_left=0
  padding_right=5
  label.drawing=off
  icon.drawing=off
  slider.highlight_color="$NORD7"
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color="$NORD1"
  slider.knob.drawing=off
)

volume_icon=(
  click_script=volume/click.sh
  icon.font="$FONT:Regular:18.0"
  label.drawing=off
  popup.drawing=off
)

sketchybar --add slider volume right \
           --set volume "${volume_slider[@]}" \
           --subscribe volume volume_change mouse.clicked

sketchybar --add item volume_icon right \
           --set volume_icon "${volume_icon[@]}"
