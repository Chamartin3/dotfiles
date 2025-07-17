#!/usr/bin/zsh

#-----------------------
#Starship
#-----------------------

# TODO: Creo que esto hay que pasarlo a una variable de entoeno
# get_starship_config="/home/hugginn/Code/Shell/dotfiles/config/starship/combined_config.py"


source "$ZSH_UTILS_DIR/validation.zsh"

# export BASE_STARSHIP_CONFIG="$DOTFILES_SRC/starship.toml"
# export STARSHIP_OVERRIDES="$DOTFILES_SRC/config/starship/substitutions.toml"
export STARSHIP_CACHE=~/.starship/cache
export STARSHIP_RUN_FUCTION="$DOTFILES_SRC/bin/exec_function"

# export STARSHIP_CONFIG=$(get_starship_config)
# export STARSHIP_CONFIG="$BASE_STARSHIP_CONFIG"

eval "$(starship init zsh)"

#--------------
# Highlighting
# -------------


export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$HOMEBREW_SHARE/zsh-syntax-highlighting/highlighters
source $HOMEBREW_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

FAST_ALIAS_TIPS_PREFIX="💡 $(tput bold)"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

typeset -A ZSH_HIGHLIGHT_PATTERNS

# To have commands starting with `rm -rf` in red:
ZSH_HIGHLIGHT_PATTERNS+=('docker' 'fg=white,bold,bg=blue')
ZSH_HIGHLIGHT_PATTERNS+=('npm' 'fg=white,bold,bg=green')
ZSH_HIGHLIGHT_PATTERNS+=('python' 'fg=blue,bg=yellow,standout,bold')

ZSH_HIGHLIGHT_STYLES[cursor]='bg=blue'
ZSH_HIGHLIGHT_STYLES[alias]=fg=yellow,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
