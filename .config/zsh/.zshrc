# Load seperated config files
for conf in $(ls "${ZDOTDIR}/conf.d/"[^_]*.zsh | sort); do
  source "${conf}"
done
unset conf

# Load custom functions
for func in $(ls "${ZDOTDIR}/functions/"[^_]*.zsh | sort); do
  source "${func}"
done
unset func

# Load zsh-syntax-highlighting; should be the last thing to do. (You have to install it: 
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)
# Zsh syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
