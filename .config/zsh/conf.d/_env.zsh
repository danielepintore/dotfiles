#!/usr/bin/env zsh
# This file has a _ prefix, this means that it is ignored and not automatically
# loaded in .zshrc, in fact is manually loaded in .zprofile
# Environment variable should be setted up here
# export NAME=VALUE
path=(~/.cargo/bin $path)
path+=~/go/bin/

export ANDROID_HOME=~/Android/Sdk
path+=$ANDROID_HOME/tools
path+=$ANDROID_HOME/tools/bin
path+=$ANDROID_HOME/platform-tools

export FPATH="$ZDOTDIR/completions:$FPATH"

export EDITOR=nvim

export QT_QPA_PLATFORMTHEME=qt5ct
