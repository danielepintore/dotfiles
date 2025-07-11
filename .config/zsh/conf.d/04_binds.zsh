#!/usr/bin/env zsh
# set vim as prefered editor
bindkey -v
export KEYTIMEOUT=1

# ctrl+arrows to move between words
bindkey -M viins '\e[1;5D' backward-word   # Ctrl+Left in insert mode
bindkey -M viins '\e[1;5C' forward-word    # Ctrl+Right in insert mode

# ctrl+backspace to delete a word
bindkey '^H' backward-kill-word

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line; zstyle :zle:edit-command-line editor nvim;
bindkey '^e' edit-command-line

# Add reverse seach with ctrl-r
bindkey -v '^R' history-incremental-search-backward

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# tmux-sessionizer
bindkey -s ^n "tmux-sessionizer\n"

