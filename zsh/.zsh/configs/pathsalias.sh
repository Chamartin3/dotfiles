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

#Rust Cargo
export PATH="$PATH:$HOME/.cargo/bin"
. "$HOME/.cargo/env"

#Ruby binaries
export GEM_HOME="$HOME/.gem"
export PATH="$PATH:$HOME/.gem/bin"

#GO
export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$GOPATH/bin

#NPM
export PATH=~/.npm-global/bin:$PATH
#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

#Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

export CHROME_INSTALLATION_PATH="$HOME/.var/app/org.chromium.Chromium/config/chromium"

# Developed projects
export PATH="$HOME/Code/bin:$PATH"

# Keys  to Path
append_dirs_to_path $DIRS_TO_PATH

#-----------------------
# Aliases
# ----------------------

# Python
alias python='python3'
alias pipenv='python3 -m pipenv'
# alias ipython='python3 -m IPython'

# Docker
alias docker-compose="docker compose"
alias dc="docker compose"
alias dcup="docker compose up"
alias dcdn="docker compose down"
alias dcrun="docker compose run"

# Custom
_create_aliases "${ALIAS_LIST[@]}"
