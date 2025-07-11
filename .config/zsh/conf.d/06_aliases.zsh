#!/usr/bin/env zsh
# nvim alias
alias vim=nvim

## Colorize the ls output
alias ls='ls --color=auto'

## Use a long listing format
alias ll='ls -la'

## secure run program via podman run
#alias podrun='podman run -v $(pwd):/chall/ --rm -it registry.fedoraproject.org/fedora:latest  $@'
alias podrun='podman run -v $(pwd):/chall/ --rm -it registry.fedoraproject.org/fedora:latest  $@'

## pwninit alias
alias pwninit='pwninit --template-path /home/daniele/.config/pwninit/pwninit-template.py'

## alias for managing dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
