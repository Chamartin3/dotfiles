#!/bin/zsh
# Run python applications stored in a Pipenv environment


function run_from_pipenv() {
  local pipenv_dir=$1
  local script=$2
  PIPENV_PIPFILE="${pipenv_dir}/Pipfile" pipenv run python "$pipenv_dir"/"$script" ${@:3}
}

function run_command_from_pipenv() {
  local pipenv_dir=$1
  local pipenv_command=$2
  PIPFILE_DIR="${pipenv_dir}" PIPENV_PIPFILE="${pipenv_dir}/Pipfile" pipenv run "$pipenv_command" ${@:3}
}
