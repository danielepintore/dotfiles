#!/usr/bin/env bash

tmux-sessionizer() {
    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(find ~/Documents ~/Documents/projects ~/ -mindepth 1 -maxdepth 1 -type d | fzf)
    fi
    
    if [[ -z $selected ]]; then
        return -1 
    fi
    
    selected_name=$(basename "$selected" | tr . _)
    
    if [[ -z $TMUX ]]; then
        if ! tmux has-session -t=$selected_name 2>/dev/null; then
            tmux new-session -ds $selected_name -c $selected
        fi
        tmux attach-session -t$selected_name
    else
        if ! tmux has-session -t=$selected_name 2>/dev/null; then
            tmux new-session -ds $selected_name -c $selected
        fi
        tmux switch-client -t$selected_name
    fi
}
