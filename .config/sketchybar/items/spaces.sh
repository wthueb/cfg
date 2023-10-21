#!/usr/bin/env bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sid=0
spaces=()
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon="${SPACE_ICONS[i]}"
    icon.highlight_color=$GREEN
    icon.padding_left=10
    icon.padding_right=10
    label.font="$FONT:Regular:12.0"
    label.color=$WHITE
    label.highlight_color=$WHITE
    label.padding_right=20
    label.y_offset=0
    background.color=$ALT_BACKGROUND
    background.border_color=$BACKGROUND_2
    background.drawing=off
    label.drawing=off
    padding_left=2
    padding_right=2
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

spaces_bracket=(
  background.color=$ALT_BACKGROUND
  background.border_color=$BACKGROUND_2
)

sketchybar --add bracket spaces_bracket '/space\..*/'  \
           --set spaces_bracket "${spaces_bracket[@]}"
