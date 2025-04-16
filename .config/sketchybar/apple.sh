#!/usr/bin/env bash

POPUP_CLICK_SCRIPT='sketchybar --set apple.logo popup.drawing=toggle'

apple_logo=(
  icon="$APPLE"
  icon.font="$FONT:Regular:18.0"
  icon.color="$MAGENTA"
  label.drawing=off
  padding_right=10
  click_script="$POPUP_CLICK_SCRIPT"
)

sketchybar --add item apple.logo left \
           --set apple.logo "${apple_logo[@]}"

sketchybar --add item apple.prefs popup.apple.logo \
           --set apple.prefs \
                 icon="$PREFERENCES" \
                 label="Preferences" \
                 click_script="open -a 'System Settings'; sketchybar --set apple.logo popup.drawing=off"
