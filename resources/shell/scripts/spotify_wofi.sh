#!/usr/bin/env bash
# Control Spotify via playerctl + wofi

# Define actions
actions="Play/Pause\nNext\nPrevious"

# Show menu in wofi
choice=$(echo -e "$actions" | wofi --dmenu -i --lines=4 --width=300 --prompt "Spotify control:")

# If user canceled
[ -z "$choice" ] && exit 0

case "$choice" in
  "Play/Pause") playerctl --player=spotify play-pause ;;
  "Next")       playerctl --player=spotify next ;;
  "Previous")   playerctl --player=spotify previous ;;
esac
