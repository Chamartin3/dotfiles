#!/usr/bin/zsh

bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey "$terminfo[kpp]" history-beginning-search-backward
bindkey "$terminfo[knp]" history-beginning-search-forward

