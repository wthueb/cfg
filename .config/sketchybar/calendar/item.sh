#!/usr/bin/env bash

sketchybar --add item calendar right \
           --set calendar script=calendar/script.sh click_script=calendar/zen.sh update_freq=30 \
           --subscribe calendar system_woke
