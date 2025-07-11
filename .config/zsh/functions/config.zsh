config() {
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

# 3) custom completer
_config() {
    local context state line
    
    if ! (( $+functions[_git] )); then
        autoload -U _git
    fi
    
    if [[ $words[2] == "add" || $words[2] == "rm" ]]; then
        _files
    else
        # Set up git completion context
        local -x GIT_DIR="$HOME/.cfg"
        local -x GIT_WORK_TREE="$HOME"
        service=git
        _git "$@"
    fi
}
