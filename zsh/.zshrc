compose_enviroment_from_vars 


_load_ssh_keys "${SSH_KEYS_TO_LOAD[@]}"

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
