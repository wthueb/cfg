#!/usr/bin/env bash

WIDTH=100

volume_change() {
  source "$CONFIG_DIR/icons.sh"
  case $INFO in
    6[7-9]|[7-9][0-9]|100) ICON=$VOLUME_100
    ;;
    3[4-9]|[4-5][0-9]|6[0-6]) ICON=$VOLUME_66
    ;;
    [0-9]|[1-2][0-9]|3[0-3]) ICON=$VOLUME_33
    ;;
    0) ICON=$VOLUME_0
    ;;
    *) ICON=$VOLUME_100
  esac

  sketchybar --set volume_icon label=$ICON

  sketchybar --set $NAME slider.percentage=$INFO \
             --animate tanh 30 --set $NAME slider.width=$WIDTH 

  sleep 2

  # Check wether the volume was changed another time while sleeping
  FINAL_PERCENTAGE=$(sketchybar --query $NAME | jq -r ".slider.percentage")
  if [ "$FINAL_PERCENTAGE" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set $NAME slider.width=0
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
