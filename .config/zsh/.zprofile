# Profile file. Runs at login. Environmental variables are set here
# Exaples:
# export NAME="VALUE"
# export PATH="$PATH:/newPath"
export PATH="$PATH:/opt/flutter/bin/"
export PATH="$PATH:/home/daniele/go/bin/"

export PATH="$PATH:$HOME/.local/scripts/"

export CAPACITOR_ANDROID_STUDIO_PATH="/home/daniele/.local/share/JetBrains/Toolbox/apps/android-studio/bin/studio.sh"

# Launch Hyprland via uwsm
if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi
