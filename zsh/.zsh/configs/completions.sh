#!/usr/bin/zsh
#
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

autoload -Uz compinit && compinit

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

fpath+=~/.zfunc

function zsh:restart_completions() {
  rm -f ~/.zcompdump
  compinit
}


source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"


eval "$(gh completion -s zsh)"
eval "$(jira completion zsh)"
eval "$(glow completion zsh)"
eval "$(fzf --zsh)"
#
#
# zstyle ':completion:*' menu select
fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select

