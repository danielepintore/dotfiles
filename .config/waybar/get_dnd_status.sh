#!/usr/bin/env bash

# Check if DND (do not disturb) is active using dunstctl and output JSON for Waybar
if dunstctl is-paused | grep -q 'true'; then
    # DND is active
    echo '{"text":"<span size=\"large\"> </span>", "markup":"pango", "tooltip":"Disattiva il non disturbare", "class":"active"}'
else
    # DND is inactive
    echo '{"text":"<span size=\"large\"> </span>", "markup":"pango", "tooltip":"Attiva il non disturbare", "class":"inactive"}'
fi

