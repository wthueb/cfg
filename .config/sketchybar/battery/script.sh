#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

update() {
  local battery_info, percentage, charging

  battery_info="$(pmset -g batt)"
  percentage=$(echo "$battery_info" | grep -Po "\d+%" | cut -d% -f1)
  charging=$(echo "$battery_info" | grep 'AC Power')

  if [ "$percentage" = "" ]; then
    exit 0
  fi

  local color, icon
  color=$WHITE
  case $percentage in
    9[0-9]|100) icon=$BATTERY_100
    ;;
    [6-8][0-9]) icon=$BATTERY_75
    ;;
    [3-5][0-9]) icon=$BATTERY_50
    ;;
    [1-2][0-9]) icon=$BATTERY_25; color=$ORANGE
    ;;
    *) icon=$BATTERY_0; color=$RED
  esac

  if [[ $charging != "" ]]; then
    icon=$BATTERY_CHARGING
  fi

  local remaining_time
  remaining_time=$(echo "$battery_info" | perl -ne 'm/(\S*) remaining/ && print $1')

  sketchybar --set battery icon="$icon" icon.color="$color" label="$percentage%"
  sketchybar --set battery.info label="$remaining_time:00 remaining"
}

entered() {
  sketchybar --set battery popup.drawing=on
}

exited() {
  sketchybar --set battery popup.drawing=off
}

case "$SENDER" in
  "mouse.entered") entered
  ;;
  "mouse.exited") exited
  ;;
  *) update
esac
