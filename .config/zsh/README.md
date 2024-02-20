Clone this repo includig it's submodule:

In order to put this config in the .config folder you have to edit /etc/zprofile to include these lines:
```bash
# Change zsh root dir in order to not pollute the home dir
export ZDOTDIR="$HOME/.config/zsh/"
```
