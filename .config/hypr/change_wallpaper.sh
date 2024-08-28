#!/bin/sh
mkdir -p ~/.config/hypr/hyprlock/
wallpaper=$(find ~/.config/hypr/wallpapers/ -type f | shuf -n1)
swaybg -i $wallpaper &
# Update hyprlock background
cp $wallpaper ~/.config/hypr/hyprlock/background.jpg
OLD_PID=$!
while true; do
		wallpaper=$(find ~/.config/hypr/wallpapers/ -type f | shuf -n1)
    sleep 600
		swaybg -i $wallpaper &
		# Update hyprlock background
		cp $wallpaper ~/.config/hypr/hyprlock/background.jpg
    NEXT_PID=$!
    sleep 5
    kill $OLD_PID
    OLD_PID=$NEXT_PID
done
