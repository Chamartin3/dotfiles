#!/bin/bash

_is_git_repository() {
  if [ -d .git ]; then
    return 0
  else
    return 1
  fi
}


_is_git_branch() {
  if git rev-parse --verify "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

_gitignore_exists() {
  if [ -f .gitignore ]; then
    return 0
  else
    return 1
  fi
}

function _git_recover() {
	git show $1:$2
	if [ $? -eq 0 ]; then
		echo "File ready to be copied"
		if [ ! -f $2 ]; then
			echo "File not found! on current branch" >&2
			exit 1
		fi
	else
		echo "git status exited with error code"
	fi
}
add_to_gitignore() {
    if ! _is_git_repository; then
        echo "Cant add $@ to .gitignore, not a git repository"
        return 1
    fi
  if _gitignore_exists; then
    echo "$@" >> .gitignore
  else
    echo "$@" > .gitignore
  fi
}



function _git_update() {
  local branch="$1"
  if [[ ! -z "$branch" ]]; then
    git checkout "$branch" || {
			echo "Failed to checkout branch $branch"
			return 1
		      }
  fi
  git pull | {
        read msg
        if [[ $? = 1 ]]; then
            echo "There was a problem"
            exit 1
        fi
        echo ${msg}
        if [[ "${msg}" = *"Already up to date"* ]]; then
            echo "NOTHING TO DO 🤷‍♂️"
        fi
    }
}

alias gitroot='cd "$(git rev-parse --show-toplevel)"'
