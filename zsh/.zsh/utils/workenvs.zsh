#!/bin/zsh

# Load the enviroments from the enviroments folder
function enviroment:load_vars() {
  echo $1 | tr "," "\n" | while read -r filename; do
    local envfile="$ENV_VARS_DIR/$filename"
    if [ -f $envfile ]; then
      source $envfile
    else
      echo "$envfile Not found"
    fi
  done
}


# Sources enviroments using env variables
function compose_enviroment_from_vars() {
  local loadenv=${1:-${COMPOSED_ZSH_ENV_FROM}}
  enviroment:load_vars $loadenv
}

# Select the enviromets to load interactively
function compose_custom_enviroment() {
  local only_array=$(gum choose --no-limit $(ls $ENV_VARS_DIR))
  only=$(echo -n $only_array | tr '\n' ',')
  enviroment:load_vars  $only
}


function _tmux_get_or_create() {

	# TODO MOVE This to a Workenv util

	# Check if there are any existing tmux sessions
	if [ $(tmux ls | grep -v attached | wc -l) -gt 0 ]; then
		local first_free_session=$(tmux list-sessions -F "#{session_name} #{session_attached}" | awk '$2 == 0 {print $1; exit}')
		tmux attach -t $first_free_session
	else
		tmux new-session
	fi
}

function initialize_tmux_session() {
	local verbose=0
	for arg in "$@"; do
		if [[ $arg == '-v' || $arg == '--verbose' ]]; then
			verbose=1
		fi
	done
	if [[ -n $TMUX ]]; then
		if ((verbose)); then
			echo "TMUX: Session name: $TMUX | Session ID: $TMUX_PANE"
			echo "Total active sessions $(tmux list-sessions | wc -l)"
			tmux display-message -p "TMUX: Session name: #{session_name}(ID:#{session_id})"

		fi
	else
		if ((verbose)); then
			echo "No TMUX session $TMUX"
		fi
		_tmux_get_or_create
	fi
}






