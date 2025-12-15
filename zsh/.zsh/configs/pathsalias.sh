#!/usr/bin/zsh

#-----------------------
# Path additions
# ----------------------

# Flatpcks
export XDG_DATA_DIRS=/usr/share/plasma:$HOME.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share

#Base
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

#Brew
export PATH="$HOMEBREW_BINARIES:$PATH"
eval "$(brew shellenv)"
export BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"

#Rust Cargo
export PATH="$PATH:$HOME/.cargo/bin"

#Ruby binaries
export GEM_HOME="$HOME/.gem"
export PATH="$PATH:$HOME/.gem/bin"

#GO
export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$GOPATH/bin

#NPM
export PATH=~/.npm-global/bin:$PATH
#NVM (lazy-loaded for faster startup)
export NVM_DIR="$HOME/.nvm"
_lazy_load_nvm() {
    unset -f nvm node npm npx claude
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # Re-add nvm's default node bin to PATH after nvm loads
    [ -s "$NVM_DIR/versions/node/v24.7.0/bin/claude" ] && export PATH="$NVM_DIR/versions/node/v24.7.0/bin:$PATH"
}
nvm() {
    _lazy_load_nvm
    nvm "$@"
}
node() {
    _lazy_load_nvm
    node "$@"
}
npm() {
    _lazy_load_nvm
    npm "$@"
}
npx() {
    _lazy_load_nvm
    npx "$@"
}
claude() {
    _lazy_load_nvm
    claude "$@"
}

#Pyenv (lazy-loaded for faster startup)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
_lazy_load_pyenv() {
    unset -f pyenv python python3 pip pip3
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}
pyenv() {
    _lazy_load_pyenv
    pyenv "$@"
}
python() {
    _lazy_load_pyenv
    python "$@"
}
python3() {
    _lazy_load_pyenv
    python3 "$@"
}
pip() {
    _lazy_load_pyenv
    pip "$@"
}
pip3() {
    _lazy_load_pyenv
    pip3 "$@"
}

export CHROME_INSTALLATION_PATH="$HOME/.var/app/org.chromium.Chromium/config/chromium"

# Developed projects
export PATH="$HOME/Code/bin:$PATH"

# Keys  to Path
append_dirs_to_path $DIRS_TO_PATH

#-----------------------
# Aliases
# ----------------------

# Python (python/python3 lazy-loaded via pyenv above)
# Keep the python->python3 alias for compatibility with scripts that expect 'python'
alias python='python3'
alias pipenv='python3 -m pipenv'

# Television scripts
export TV_SCRIPTS_DIR="$HOME/.config/television/scripts"

# alias ipython='python3 -m IPython'

# Docker
alias docker-compose="docker compose"
alias dc="docker compose"
alias dcup="docker compose up"
alias dcdn="docker compose down"
alias dcrun="docker compose run"

alias ll='eza  -l --icons=always'
# alias ll='eza -l'
# alias la='eza -la'
#
# Custom
_create_aliases "${ALIAS_LIST[@]}"
