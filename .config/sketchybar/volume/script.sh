#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"

volume_change() {
  local icon
  case $INFO in
    6[7-9]|[7-9][0-9]|100) icon=$VOLUME_100
    ;;
    3[4-9]|[4-5][0-9]|6[0-6]) icon=$VOLUME_66
    ;;
    [0-9]|[1-2][0-9]|3[0-3]) icon=$VOLUME_33
    ;;
    0) icon=$VOLUME_0
    ;;
    *) icon=$VOLUME_100
  esac

  sketchybar --set volume_icon icon="$icon"

  sketchybar --set volume slider.percentage="$INFO" \
             --animate tanh 30 --set volume slider.width=100

  sleep 2

  # Check wether the volume was changed another time while sleeping
  local final_percentage
  final_percentage=$(sketchybar --query volume | jq -r ".slider.percentage")
  if [ "$final_percentage" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set volume slider.width=0
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

case "$SENDER" in
  "volume_change") volume_change
  ;;
  "mouse.clicked") mouse_clicked
  ;;
esac
