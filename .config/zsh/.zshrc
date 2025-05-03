# Load aliases
source $HOME/.config/zsh/aliases.zsh

# Enable colors and change prompt
autoload -U colors && colors

# Get git branch for the prompt
autoload -Uz vcs_info # load function
zstyle ':vcs_info:*' enable git # disable all vcs except git
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})hole%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f'
zstyle ':vcs_info:*' formats '%F{9}( %b)%f ' 
precmd () { vcs_info }
setopt prompt_subst

#PS1="\$vcs_info_msg_0_ $PS1"
PS1=' %F{#91C79C}%~ %f${vcs_info_msg_0_}'

# History in zsh dir 
HISTFILE=~/.config/zsh/histfile
HISTSIZE=10000
SAVEHIST=10000

# set vim as prefered editor
bindkey -v
export KEYTIMEOUT=1

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

bindkey -v '^?' backward-delete-char

# ctrl+arrows to move between words
bindkey -M viins '\e[1;5D' backward-word   # Ctrl+Left in insert mode
bindkey -M viins '\e[1;5C' forward-word    # Ctrl+Right in insert mode

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line; zstyle :zle:edit-command-line editor nvim;
bindkey '^e' edit-command-line

# Add reverse seach with ctrl-r
bindkey -v '^R' history-incremental-search-backward

# Load zsh-syntax-highlighting; should be last. (You have to install it: 
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)
# Theme section
source $HOME/.config/zsh/themes/dracula.zsh
# End theme section

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# tmux-sessionizer
bindkey -s ^n "tmux-sessionizer\n"

# Zsh syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
