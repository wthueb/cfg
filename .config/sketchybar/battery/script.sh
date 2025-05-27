#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

update() {
  local battery_info, percentage
  battery_info="$(pmset -g batt)"
  percentage=$(echo "$battery_info" | grep -Po "\d+%" | cut -d% -f1)

  if [ "$percentage" = "" ]; then
    exit 0
  fi

  local color, icon
  color=$NORD6
  icon=$BATTERY_0

  if [ "$percentage" -ge 80 ]; then
    icon=$BATTERY_100
  elif [ "$percentage" -ge 60 ]; then
    icon=$BATTERY_75
  elif [ "$percentage" -ge 40 ]; then
    icon=$BATTERY_50
  elif [ "$percentage" -ge 20 ]; then
    icon=$BATTERY_25
  fi

  if [ "$percentage" -le 20 ]; then
    color=$NORD11
  elif [ "$percentage" -le 30 ]; then
    color=$NORD12
  fi

  if echo "$battery_info" | grep 'AC Power'; then
    icon=$BATTERY_CHARGING
  fi

  local battery=(
    icon="$icon"
    icon.color="$color"
    label="$percentage%"
    label.color="$color"
  )

  sketchybar --set battery "${battery[@]}"

  local remaining_time
  remaining_time=$(echo "$battery_info" | perl -ne 'm/(\S*) remaining/ && print $1')

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
