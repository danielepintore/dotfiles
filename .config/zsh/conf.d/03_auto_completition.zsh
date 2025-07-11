#!/usr/bin/env zsh

# Auto completition
if [[ -o interactive ]]; then
  function setup_completion {
    autoload -U compinit
    zstyle ':completion:*' menu select
    zmodload zsh/complist
    compinit
    _comp_options+=(globdots)		# Include hidden files.
    unset -f setup_completion  # cleanup the function
    # Use vim keys in tab complete menu:
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
}
  precmd_functions+=(setup_completion)
fi

