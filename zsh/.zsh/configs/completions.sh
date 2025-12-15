#!/usr/bin/zsh
#
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

if type brew &>/dev/null; then
  FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

fpath+=~/.zfunc

# Only regenerate zcompdump once every 24h
autoload -Uz compinit
if [[ -f ${HOME}/.zcompdump && -z $(find ${HOME}/.zcompdump -mtime +1 2>/dev/null) ]]; then
    compinit -C
else
    compinit
fi

function zsh:restart_completions() {
  rm -f ~/.zcompdump
  rm -rf "$ZSH_COMPL_CACHE"
  compinit
}

source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Cached completion generators — regenerate weekly, refresh with zsh:restart_completions
ZSH_COMPL_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
mkdir -p "$ZSH_COMPL_CACHE"

_cached_eval() {
    local name="$1" cmd="$2"
    local cache_file="$ZSH_COMPL_CACHE/$name.zsh"
    if [[ ! -f "$cache_file" || -n "$(find "$cache_file" -mtime +7 2>/dev/null)" ]]; then
        eval "$cmd" > "$cache_file" 2>/dev/null
    fi
    source "$cache_file"
}

_cached_eval "gh"   "gh completion -s zsh"
_cached_eval "jira" "jira completion zsh"
_cached_eval "glow" "glow completion zsh"
_cached_eval "sesh" "sesh completion zsh"
# NOTE: fzf --zsh is loaded in tools/fzf.zsh — not duplicated here

zstyle ':completion:*' menu select
