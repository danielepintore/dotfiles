# Profile file. Runs at login. Environmental variables are set here
# Exaples:
# export NAME="VALUE"
# export PATH="$PATH:/newPath"
source "${ZDOTDIR}/conf.d/_env.zsh"

# Launch Hyprland via uwsm
# Check if we are inside a tmux session
if [ -z "$TMUX" ]; then
	if uwsm check may-start; then
	    exec uwsm start hyprland.desktop
	fi
fi

