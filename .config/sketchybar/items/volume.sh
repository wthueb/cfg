#!/usr/bin/env bash

volume_slider=(
  script="$PLUGIN_DIR/volume.sh"
  updates=on
  padding_left=0
  padding_right=5
  label.drawing=off
  icon.drawing=off
  slider.highlight_color=$BLUE
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color=$ALT_BACKGROUND
  slider.knob.drawing=off
)

volume_icon=(
  click_script="$PLUGIN_DIR/volume_click.sh"
  icon.drawing=off
  label.font="$FONT:Regular:18.0"
  popup.drawing=off
)

sketchybar --add slider volume right            \
           --set volume "${volume_slider[@]}"   \
           --subscribe volume volume_change     \
                              mouse.clicked     \
                                                \
           --add item volume_icon right         \
           --set volume_icon "${volume_icon[@]}"
