#!/usr/bin/env bash

# You can run this script with the random parameter to select a random wallpaper
# from the active wallpaper directory. Otherwise a prompt will appear asking
# for a wallpaper

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers/"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

if [[ $1 == "random" ]];then
	# Get a random wallpaper that is not the current one
	WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
else
	CHOICE=$(find $WALLPAPER_DIR -maxdepth 1 -type f -printf "%f\n" | sort | rofi -dmenu -p "Wallpaper: ")
	WALLPAPER="$WALLPAPER_DIR$CHOICE"
	# if we quit rofi then WALLPAPER == WALLPAPER_DIR then we need to quit without
	# changing the wallpaper
	if [[ $WALLPAPER_DIR == $WALLPAPER ]];then
		exit 0
	fi
fi

# Apply the selected wallpaper
hyprctl hyprpaper reload ,"$WALLPAPER"
# set background for hyprlock
ln -sf $WALLPAPER $HOME/.config/hypr/wallpapers/background.jpg
