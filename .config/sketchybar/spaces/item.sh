#!/usr/bin/env bash

space_icons=("1" "2" "3" "4" "5" "6" "7" "8" "9")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sid=0
for i in "${!space_icons[@]}"; do
  sid=$((i+1))

  space=(
    associated_space="$sid"
    icon="${space_icons[i]}"
    icon.highlight_color="$NORD8"
    background.drawing=off
    label.drawing=off
    padding_left=5
    padding_right=5
    script=spaces/script.sh
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

spaces_bracket=(
  background.color="$NORD1"
)

sketchybar --add bracket spaces_bracket '/space\..*/'  \
           --set spaces_bracket "${spaces_bracket[@]}"
