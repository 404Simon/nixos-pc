#!/usr/bin/env bash

mapfile -t music_dirs < <(find ~/Music -type d -not -path '*/\.*' | sed "s|$HOME/Music/||" | grep -v "^$HOME/Music$" | sort)
music_dirs=("Music" "${music_dirs[@]}")

target=$(printf "%s\n" "${music_dirs[@]}" | gum filter)

if [ "$target" == "Music" ]; then
    echo "cd ~/Music/"
else
    echo "cd ~/Music/$target"
fi
