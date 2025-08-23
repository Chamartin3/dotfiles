source "$ZSH_UTILS_DIR/validation.zsh"
source "$ZSH_UTILS_DIR/base.zsh"
source "$ZSH_UTILS_DIR/workenvs.zsh"
compose_enviroment_from_vars 


_load_ssh_keys "${SSH_KEYS_TO_LOAD[@]}"



# Load zsh configurations
CONFIGS_DIR="$HOME/.zsh/configs"
active_configs=(
	"pathsalias"
	"theming"
	"hooks"
	"completions"
	"plugins"

)
_source_from_folder "$CONFIGS_DIR" "${active_configs[@]}"


# Load shell tools
shell_tools=(
	"ghub"
	"yazi"
	"zoxide"
	"fzf"
	"piprun"
	"web"
	"jira"
	"keyboard_config"
	"whereami"
	"mymake"
	"nvim"

)
_source_from_folder $SHELL_TOOLS_SRC ${shell_tools[@]}

