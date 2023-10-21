#!/usr/bin/env bash

WINDOW_INFO=$(yabai -m query --windows --window)

APP_TITLE=$(echo $WINDOW_INFO | jq -r '.app')
WINDOW_TITLE=$(echo $WINDOW_INFO | jq -r '.title')

if [[ $WINDOW_TITLE = "" ]]; then
  TITLE=$APP_TITLE
else
  TITLE="$APP_TITLE - $WINDOW_TITLE"
fi

if [[ ${#TITLE} -gt 50 ]]; then
  TITLE=$(echo "$TITLE" | cut -c 1-50)
  sketchybar -m --set title label="$TITLE"…
  exit 0
fi

sketchybar -m --set title label="$TITLE"
