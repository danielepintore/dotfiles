#!/usr/bin/env fish

# Remove a desktop launcher for a web app
function web2app-remove
    # Check if the correct number of arguments is provided
    if test (count $argv) -ne 1
        echo "Usage: web2app-remove <AppName>"
        return 1
    end

    # Assign arguments to variables
    set APP_NAME $argv[1]
    set ICON_DIR "$HOME/.local/share/applications/icons"
    set DESKTOP_FILE "$HOME/.local/share/applications/$APP_NAME.desktop"
    set ICON_PATH "$ICON_DIR/$APP_NAME.png"

    # Remove the .desktop file and icon
    rm -f $DESKTOP_FILE
    rm -f $ICON_PATH
end
