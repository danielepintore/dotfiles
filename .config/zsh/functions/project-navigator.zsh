#!/usr/bin/env bash

project-navigator() {
    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(find ~/Documents ~/Documents/projects ~/ -mindepth 1 -maxdepth 1 -type d | fzf)
    fi
    
    if [[ -z $selected ]]; then
        return -1 
    fi
    
    selected_name=$(basename "$selected" | tr . _)
    cd "$selected" || return -1
}

