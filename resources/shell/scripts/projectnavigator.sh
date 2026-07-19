#!/usr/bin/env bash

projects=($(find ~/dev -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))

projects=(dev "${projects[@]}")
target=$(gum filter "${projects[@]}")

if [ "$target" == "dev" ]; then
    echo "cd ~/dev"
else
    echo "cd ~/dev/$target"
fi

