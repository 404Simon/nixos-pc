#!/usr/bin/env bash

AIRPODS_MAC="EC:46:54:29:9D:A7"
CARD="bluez_card.EC_46_54_29_9D_A7"

if ! bluetoothctl show | grep -q "Powered: yes"; then
    bluetoothctl power on
    sleep 1
fi

if bluetoothctl info "$AIRPODS_MAC" | grep -q "Connected: yes"; then
    bluetoothctl disconnect "$AIRPODS_MAC"
    notify-send -t 2000 "AirPods" "Disconnected"
else
    bluetoothctl connect "$AIRPODS_MAC" >/dev/null 2>&1
    sleep 3
    if bluetoothctl info "$AIRPODS_MAC" | grep -q "Connected: yes"; then
        pactl set-card-profile "$CARD" a2dp-sink
        notify-send -t 2000 "AirPods" "Connected (AAC)"
    else
        notify-send -t 2000 "AirPods" "Connection failed" -u critical
    fi
fi
