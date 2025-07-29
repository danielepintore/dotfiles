#!/usr/bin/env zsh

# Auto completition
if [[ -o interactive ]]; then
    autoload -U compinit
    zstyle ':completion:*' menu select
    zmodload zsh/complist
    compinit
    _comp_options+=(globdots) # Include hidden files.

    # dotfiles manager autocompletition trick for add and rm command
    # definition on the config functions file (functions/config.zsh)
    compdef _config config

    # Use vim keys in tab complete menu:
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
fi
