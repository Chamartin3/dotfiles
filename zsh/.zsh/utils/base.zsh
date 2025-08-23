#!/bin/zsh

# Recover a lost git file

# Returns a list of all the functions declared on a file
function _all_functions_in() {
	awk '/^#/{doc=$0} /^function /{print "\033[1m • " $2 "\033[0m - " doc; doc=""}' $1 |
		sed 's/[(){}#]//g'
}

function zsh:all_functions_in() {
	awk '/^#/{doc=$0} /^function /{print "\033[1m • " $2 "\033[0m - " doc; doc=""}' $1 |
		sed 's/[(){}#]//g'
}

function locally_declared_vars() {
	typeset -m |
		grep '^local ' |
		sed 's/^local //g' |
		while IFS="=" read -r key value; do
			echo "$key $value"
		done
}

function _remove_folder_verbose() {
	echo "looking for $1"
	if [ -d $1 ]; then
		echo "Removing $1 folder" &&
			sudo rm -R $1
	else
		echo "No $1 folder found"
	fi
}

function _load_ssh_keys() {
	local keys=("$@")
	if [ -z "$SSH_AUTH_SOCK" ]; then
		eval $(ssh-agent -s) >/dev/null 2>&1
	fi

	if [ ${#keys[@]} -eq 0 ]; then
		echo "No SSH keys specified."
		return 1
	fi
	for key in "${keys[@]}"; do
		local key_path="$SSH_KEYS_PATH/$key"
		if [[ -f "$key_path" ]]; then
			ssh-add "$key_path" >/dev/null 2>&1
		fi
	done
}

function append_dirs_to_path() {
	local tool_dirs=("$@")
	for tool_dir in "${tool_dirs[@]}"; do
		local tool_path="$DIRS_TO_PATH/$tool_dir"
		if [[ -d "$tool_path" && ":$PATH:" != *":$tool_path:"* ]]; then
			PATH="$tool_path:$PATH"
		fi
	done
}

function __zsh_get_filepaths_from_dir() {
	local dir="$1"
	local files=("${@:2}")
	# Verify that the directory exists
	if [[ ! -d $dir ]]; then
		echo "Error: Directory $dir does not exist." >&2
		return 1
	fi
	# If no files were given, get all files in the directory
	typeset -a paths=()
	if [[ ${#files[@]} -eq 0 ]]; then
		files=($(ls $dir))

	fi
	for file in "${files[@]}"; do
		local found="$(ls -l $dir | grep '^-' | grep $file | awk '{print $9}')"
		if [ -z $found ]; then
			echo "Error: No match found for $file in $dir (only files are considered not dirs or links)" >&2
			exit 1
		fi
		count=$(echo "$found" | wc -l)
		if [ "$count" -ne 1 ]; then
			echo "Error: $found Expected one file or link, but found $count" >&2
			exit 1
		fi
		paths+=("$dir/$found")
	done
	echo $paths
}

function _source_from_folder() {
	local dir="$1"
	local filenames=("${@:2}")
	local filepaths=($(__zsh_get_filepaths_from_dir $dir ${filenames[@]}))
	for filepath in ${filepaths[@]}; do
		source "$filepath"
	done
}

function _create_aliases() {
	local alias_list=("$@")
	for alias_entry in "${alias_list[@]}"; do
		local alias_name="${alias_entry%%:*}"
		local alias_command="${alias_entry#*:}"
		alias "${alias_name// /}"="${alias_command}"
	done
}

function get_declarations() {
  declarations=""
  local existing_env=$(
    env |
      cut -d= -f1 |
      sed ':a;N;$!ba;s/\n/ /g'
  )
  echo $1 | tr "," "\n" | while read -r filename; do
    (
      local envfile="$ENV_VARS_DIR/$filename"
      echo existing_env
      unset $(echo $existing_env)
      set -a
      source "$envfile" 2>/dev/null
    for var in ${(k)parameters}; do
         [[ $var =~ ^[A-Z_][A-Z0-9_]*$ ]] && echo "$var=${(P)var}"
    done
    ) | grep '^[A-Z_][A-Z0-9_]*=' >>temp_declarations
  done
  echo $temp_declarations
}

