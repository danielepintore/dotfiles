#!/bin/sh
swaybg -i $(find ~/.config/hypr/wallpapers/ -type f | shuf -n1) &
OLD_PID=$!
while true; do
    sleep 600
	swaybg -i $(find ~/.config/hypr/wallpapers/ -type f | shuf -n1) &
    NEXT_PID=$!
    sleep 5
    kill $OLD_PID
    OLD_PID=$NEXT_PID
done
