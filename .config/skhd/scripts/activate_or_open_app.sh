#!/usr/bin/env bash
APP_ID=$(yabai -m query --windows | jq ".[] | select(.app==\"${1}\").id")
if [ -z "$APP_ID" ]; then
  open -a "$1"
  exit 0
fi
yabai -m window --focus $APP_ID
