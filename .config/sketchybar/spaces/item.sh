#!/usr/bin/env bash

left_spacer=(
  icon.drawing=off
  label.drawing=off
  background.padding_left=5
  background.padding_right=0
)

sketchybar --add item space.left_spacer left \
           --set space.left_spacer "${left_spacer[@]}"

space_icons=("1" "2" "3" "4" "5" "6" "7" "8" "9")

sid=0
for i in "${!space_icons[@]}"; do
  sid=$((i+1))

  space=(
    associated_space="$sid"
    icon="${space_icons[i]}"
    icon.highlight_color="$NORD8"
    icon.padding_left=0
    icon.padding_right=0
    label.drawing=off
    background.drawing=off
    script=spaces/script.sh
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

right_spacer=(
  icon.drawing=off
  label.drawing=off
  background.padding_left=0
  background.padding_right=5
)

sketchybar --add item space.right_spacer left \
           --set space.right_spacer "${right_spacer[@]}"

spaces_bracket=(
  background.color="$NORD1"
)

sketchybar --add bracket spaces_bracket '/space\..*/'  \
           --set spaces_bracket "${spaces_bracket[@]}"
