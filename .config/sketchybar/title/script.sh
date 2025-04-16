#!/usr/bin/env bash

window_info=$(yabai -m query --windows --window)

app_title=$(echo "$window_info" | jq -r '.app')
window_title=$(echo "$window_info" | jq -r '.title')

if [[ $window_title = "" ]]; then
  title=$app_title
else
  title="$app_title - $window_title"
fi

if [[ ${#title} -gt 50 ]]; then
  title=$(echo "$title" | cut -c 1-50)
  exit 0
fi

sketchybar -m --set title label="$title"
