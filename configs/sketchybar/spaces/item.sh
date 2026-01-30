#!/usr/bin/env bash

left_spacer=(
  icon.drawing=off
  label.drawing=off
  background.padding_left=5
  background.padding_right=0
)

sketchybar --add item space.left_spacer left \
           --set space.left_spacer "${left_spacer[@]}"

for i in {1..9}; do
  space=(
    associated_space="$i"
    icon="$i"
    icon.highlight_color="$COLOR_PRIMARY"
    icon.padding_left=0
    icon.padding_right=0
    label.drawing=off
    background.drawing=off
    script=spaces/script.sh
  )

  sketchybar --add space "space.$i" left    \
             --set "space.$i" "${space[@]}" \
             --subscribe "space.$i" mouse.clicked
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
  background.color="$COLOR_MODAL_BG"
)

sketchybar --add bracket spaces_bracket '/space\..*/'  \
           --set spaces_bracket "${spaces_bracket[@]}"
