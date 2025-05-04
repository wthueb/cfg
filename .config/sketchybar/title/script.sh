#!/usr/bin/env bash

window_info=$(yabai -m query --windows --window)

app_title=$(echo "$window_info" | jq -r '.app')
window_title=$(echo "$window_info" | jq -r '.title')

if [[ $window_title = "" ]]; then
  title=$app_title
else
  title="$app_title - $window_title"
fi

title=$(echo "$title" | cut -c 1-75)

sketchybar -m --set title label="$title"
