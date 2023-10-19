#!/usr/bin/env bash

skhd_status=(
  icon.drawing=off
  padding_left=0
  label=''
)

sketchybar --add item skhd_status e        \
           --set skhd_status "${skhd_status[@]}" \
