#!/bin/bash

workspace=$(hyprctl -j workspaces | jq -r '.[] | select(.id==10) | .monitor')

if [[ -z "$workspace" ]]; then
    echo "Workspace 10 does not exist."
    exit 1
fi

primary=DP-3
secondary=eDP-1

if [[ "$workspace" == "eDP-1" ]]; then
    primary=eDP-1
    secondary=DP-3
fi

current=$(hyprctl activeworkspace | grep -oP 'workspace ID \K[0-9]+')
s=""
s+="dispatch workspace 10 ; "
s+="dispatch moveworkspacetomonitor 10 $secondary ; "
for ws in $(hyprctl workspaces | grep -oP 'workspace ID \K[0-9]'); do
    s+="dispatch moveworkspacetomonitor $ws $primary ; "
done
s+="dispatch workspace $current"

hyprctl --batch $s

