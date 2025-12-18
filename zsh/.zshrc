#! bin/zsh

# Skip Ubuntu's default compinit ( resolved in completions.sh)
skip_global_compinit=1

# Load shell tools
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_current_category="tool"
typeset -A shell_tools=(
    perf            "Startup profiler"
    ghub            "GitHub CLI helpers"
    yazi            "File manager"
    zoxide          "Smart cd"
    fzf             "Fuzzy finder"
    piprun          "Python pip runner"
    web             "Web search"
    jira            "Jira CLI"
    keyboard_config "Keyboard setup"
    whereami        "Location utils"
    mymake          "Custom make"
    nvim            "Neovim config"
    lazygit         "Git TUI"
    obsidian        "Obsidian CLI"
)
for tool in ${(k)shell_tools}; do
    source "$SHELL_TOOLS_SRC/$tool.zsh"
done

_zsh_perf_setup

source "$ZSH_UTILS_DIR/validation.zsh"
source "$ZSH_UTILS_DIR/base.zsh"
source "$ZSH_UTILS_DIR/workenvs.zsh"

[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_current_category="env"
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_point compose_enviroment_from_vars || compose_enviroment_from_vars
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_point _load_ssh_keys "${SSH_KEYS_TO_LOAD[@]}" || _load_ssh_keys "${SSH_KEYS_TO_LOAD[@]}"


# Load scoped zsh configurations
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_current_category="config"
CONFIGS_DIR="$HOME/.zsh/configs"
zsh_configs=(
    pathsalias
    theming
    hooks
    completions
    plugins
)
for conf in $zsh_configs; do
    source "$CONFIGS_DIR/$conf.sh"
done


#  ------------------------------------
# Tmux session
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_current_category="session"
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_point initialize_tmux_session || initialize_tmux_session
#  ------------------------------------
#
# Load shell scripts from the context
[[ -n "$ZSH_PROFILE" ]] && _zsh_profile_current_category="context"
for script ($SHELL_SCRIPTS_TO_LOAD); do
    validate:source_if_exists  "$script" ;
done


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

_zsh_perf_finalize
