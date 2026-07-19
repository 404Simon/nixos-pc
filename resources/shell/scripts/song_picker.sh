#!/usr/bin/env bash

songs=$(rmpc listall)

choice=$(echo "$songs" | wofi --dmenu -i -p "Choose song:")

[ -z "$choice" ] && exit 0

if [ -z "$(rmpc queue)" ]; then
  rmpc add "$choice"
else
  rmpc add --position +0 "$choice"
fi
