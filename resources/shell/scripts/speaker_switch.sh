#!/usr/bin/env bash

sinks=$(pw-dump | jq -r '
  [.[] | select(.type == "PipeWire:Interface:Node" and .info.props."media.class" == "Audio/Sink")] 
  | .[] 
  | "\(.info.props."node.name") \(.info.props."node.description")"
')

choice=$(echo "$sinks" | wofi --dmenu -i -p "Choose audio output:")

[ -z "$choice" ] && exit 0

sink_name=$(echo "$choice" | awk '{print $1}')
pactl set-default-sink "$sink_name"
