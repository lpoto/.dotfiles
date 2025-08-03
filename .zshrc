# ------------------------------------------------------------------------- ZSH

export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
    macos
    zsh-vi-mode
)
export ZSH_THEME="robbyrussell"
source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------- NEOVIM/KITTY

export TERM_PROGRAM=kitty
export EDITOR="nvim"
export VISUAL="nvim"

# ------------------------------------------------------------------------ LESS

export GIT_PAGER="less"
export PAGER="less"
export LESS=FRX

# -------------------------------------------------------------------- HOMEBREW

export HOMEBREW_PATH=/opt/homebrew
export PATH=$PATH:$HOMEBREW_PATH/bin

# ---------------------------------------------------------------------- DOCKER

source <(docker completion zsh)

# ---------------------------------------------------------------------- PYTHON

alias python='python3'
alias py3='python3'
alias py='python'

# -------------------------------------------------------------------------- GO

export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# ------------------------------------------------------------------------ JAVA

export set_java_version() {
    if [ -z "$1" ]; then
        echo "Usage: set_java_version <JavaVersion>"
        return 1
    fi
    old_version=$JAVA_VERSION
    old_home=$JAVA_HOME
    export JAVA_VERSION=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v$JAVA_VERSION)

    if [ "$JAVA_HOME" = "$old_home" ] && [ "$old_version" != "$JAVA_VERSION" ];
    then
        export JAVA_VERSION=$old_version
        export JAVA_HOME=$old_home
        echo "Error: Java version $JAVA_VERSION not found."
        return 1
    fi
}
export clear_jdtls_cache() {
    rm -rf "$HOME/.cache/nvim/jdtls"
}

# set_java_version 21
set_java_version 23
# set_java_version 24
