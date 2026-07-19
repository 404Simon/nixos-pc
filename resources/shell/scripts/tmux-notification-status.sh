#!/usr/bin/env bash

mode=$(makoctl mode 2>/dev/null)

if [ "$mode" = "do-not-disturb" ]; then
    echo "#[fg=#ff5555,bg=#282a36] 󰂛 DND"
else
    echo ""
fi
