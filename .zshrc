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
    local input="$1"
    local input_version=$(echo "$input" | awk -F'+' '{print $1}')
    local old_version=$JAVA_VERSION
    local old_home=$JAVA_HOME

    local java_path=$(/usr/libexec/java_home -v"$input_version" 2>/dev/null)
    local java_bin_path=${java_path}/bin/java
    local version_str=$("$java_bin_path" -version 2>&1)
    local full_version=$(echo "$version_str" | awk -F'"' '/version/ {print $2}')
    local build_number=$(echo "$version_str" \
        | awk -F'+' '/build/ {print $2; exit}' | awk -F'[- )]' '{print $1}')
    local is_jdk=$(echo "$version_str" \
        | grep -iq 'jdk\|development kit' && echo "jdk")
    
    local full_version_with_build=""
    if [[ -n "$full_version" && -n "$build_number" ]]; then
        full_version_with_build="${full_version}+${build_number}"
    elif [[ -n "$full_version" ]]; then
        full_version_with_build="$full_version"
    fi
    if [[ -n "$is_jdk" && -n "$full_version_with_build" ]]; then
        full_version_with_build="jdk-${full_version_with_build}"
    fi
    if [ -z "$full_version_with_build" ]; then
        echo "Error: Java version $input_version not found."
        return 1
    fi
    export JAVA_VERSION="$full_version_with_build"
    export JAVA_HOME="$java_path"
}

set_java_version 21
# set_java_version 23
# set_java_version 24
