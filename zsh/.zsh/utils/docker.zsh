#!/bin/zsh


function multi_file_docker_compose() {
    local compose_files=("$@")
    if [ ${#compose_files[@]} -eq 0 ]; then
        echo "No compose files provided, using default docker-compose.yaml"
        compose_files=("docker-compose.yaml")
    fi
    local cmd="docker compose -f ${compose_files[*]}"
}

function dc:compose_command() {
   local files=$(find . -maxdepth 1 -name "compose*.y*ml" -type f)
   local command="docker compose"
   for file in $files; do
     command+=" -f $file"
   done
   echo "$command"
 }


function run_from_docker_compose() {
    local compose_file="${1:-$PROJECT_COMPOSE_FILE}"
    shift
    local params=$@
    if [ ! -f "$compose_file" ]; then
        echo "Error: Compose file '$compose_file' does not exist."
        return 1
    fi
    local params=$@
    if [ -z "$params" ]; then
        echo "No parameters provided, running default docker-compose up"
        docker compose -f "$compose_file" up -d
    else
        echo "Using compose file: $compose_file with parameters: $params"
        local cmd="docker compose -f $compose_file $params";
        echo "Running command: $cmd" &&
        eval $cmd;
    fi
}

function line_in_compose_file(){
    file_to_check="$1"
    line_to_find="$2"
    if [ -z "$file_to_check" ] || [ -z "$line_to_find" ]; then
        echo "Usage: find_in_compose_file <file_to_check> <line_to_find>"
        return 1
    fi
    echo "🔎 Validating: ${file_to_check}"
   if [ ! -f "$file_to_check" ]; then
     echo "❌ FAILURE: File not found: '${file_to_check}'"
     return 1
   fi

   if grep -Fq -- "${line_to_find}" "$file_to_check"; then
     echo "✅  '${file_to_check}' contains '${line_to_find}'."
     return 0
   else
       echo "⚠️WARNING: '${line_to_find}' not found in compose file '${file_to_check}'."
     return 1
   fi
}

# Finds a specific line in one or more docker-compose files.
# # Usage: find_in_compose_files <line_to_find> [file1 file2 ...]
line_is_in_compose_files(){
    local lookup_string="$1"
    shift;
   local files_with_line=0
   local -a files_to_process
   # Check if arguments were provided. If not, use the default.
   if [ "$#" -eq 0 ]; then
     echo "INFO: No files provided. Using default 'docker-compose.yaml'."
     files_to_process=("docker-compose.yaml")
   else
     echo "INFO: Using provided file(s): $@"
     files_to_process=("$@")
   fi
   for file in "${files_to_process[@]}"; do
        if ! line_in_compose_file "$file" "$lookup_string"; then
            echo "⚠️WARNING: '${line_to_find}' not found in compose file '${file}'."
        else
            files_with_line=$((files_with_line + 1))
        fi
   done

   if [ "$files_with_line" -eq 0 ]; then
       echo "WARNING: No compose files found with the line '${lookup_string}'."
     return 1
   fi
   return 0
}

#Gets the running status from the docker-compose services in a context
function dc_services_running() {
	local services=$(docker compose ps --services | wc -l)
	local running=$(docker compose ps --services --filter "status=running" | wc -l)
	echo "$running/$services"
}

