#!/usr/bin/env bash

calendar=(
    script=calendar/script.sh
    update_freq=10
    icon.drawing=off
)

sketchybar --add item calendar right \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
