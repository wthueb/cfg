#!/usr/bin/env bash

sketchybar --add item battery right \
           --set battery script=battery/script.sh update_freq=30 \
           --subscribe battery power_source_change system_woke mouse.entered mouse.exited \
           --add item battery.info popup.battery
