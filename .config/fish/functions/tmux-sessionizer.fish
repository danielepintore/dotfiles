#!/usr/bin/env fish
function tmux-sessionizer
    # Check if an argument is passed
    if test (count $argv) -eq 1
        set selected $argv[1]
    else
        # Use fzf to select a directory
        set selected (find ~/Documents ~/Documents/projects ~/ -mindepth 1 -maxdepth 1 -type d | fzf)
    end
    
    # Exit if no directory is selected
    if test -z "$selected"
        exit 0
    end
    
    # Get the basename of the selected directory and replace dots with underscores
    #set selected_name (basename "$selected" | tr . _)
    set selected_name angelo
    if set -q TMUX # we are inside tmux
        if not tmux has-session -t=$selected_name 2>/dev/null
            tmux new-session -ds $selected_name -c $selected
        end
        tmux switch-client -t$selected_name
    else
        # outside tmux
        if not tmux has-session -t=$selected_name 2&>/dev/null
            tmux new-session -ds $selected_name -c $selected
        end
        tmux attach-session -t$selected_name
    end
    # Force repaint the prompt/commandline to fix redraw issues after tmux/fzf
    # # fish specific problem
    commandline -f repaint
end
