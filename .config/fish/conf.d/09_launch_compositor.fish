#!/usr/bin/env fish
if status is-login
    # Commands to run in interactive sessions can go here

    # Launch Hyprland via uwsm
    # Check if we are inside a tmux session
    if not set -q TMUX
	    if uwsm check may-start
	        exec uwsm start hyprland.desktop
        end
    end
end

