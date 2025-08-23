#!/bin/bash
source "$ZSH_UTILS_DIR/pickers.zsh"
function mymake() {
	local selection=$(
		ls "$MY_MAKEFILES_DIR" |
			grep "mk" |
			picker:gum "$1"
	)
	if [ -z "${selection}" ]; then
		echo "No selection made."
		return 1
	else
		make -f "$MY_MAKEFILES_DIR"/"$selection" "${@:2}"
	fi

}
