#!/usr/bin/env fish

# Create a desktop launcher for a web app
function web2app
    # Check if the correct number of arguments is provided
    if test (count $argv) -ne 3
        echo "Usage: web2app <AppName> <AppURL> <IconURL> (IconURL must be in PNG -- use https://dashboardicons.com)"
        return 1
    end

    # Assign arguments to variables
    set APP_NAME $argv[1]
    set APP_URL $argv[2]
    set ICON_URL $argv[3]
    set ICON_DIR "$HOME/.local/share/applications/icons"
    set DESKTOP_FILE "$HOME/.local/share/applications/$APP_NAME.desktop"
    set ICON_PATH "$ICON_DIR/$APP_NAME.png"

    # Create the icon directory if it doesn't exist
    mkdir -p $ICON_DIR

    # Download the icon
    if not curl -sL -o $ICON_PATH $ICON_URL
        echo "Error: Failed to download icon."
        return 1
    end

    # Create the .desktop file
    echo "[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=chromium --new-window --ozone-platform=wayland --app=\"$APP_URL\" --name=\"$APP_NAME\" --class=\"$APP_NAME\"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true" > $DESKTOP_FILE

    # Make the .desktop file executable
    chmod +x $DESKTOP_FILE
end

