#!/bin/bash

DJANGO_MANAGE=${DJANGO_MANAGE:-"python manage.py"}


check_prerequisites() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 1 # Not a git repository
    fi;
    if ! git diff-index --quiet HEAD --; then
        # Uncommitted channges"
        return 1
    fi
}



get_migration_diff() {
    local target_branch="$1"
    git diff --name-only "$target_branch" -- '*/migrations/[0-9]*.py'
}



get_django_migrations() {
    local appname="$1"
    echo $DJANGO_MANAGE showmigrations --plan "$appname" 
}

get_applied_migrations() {
    local appname="$1"
    local migrations_cmd="$(get_django_migrations "$appname")"
    echo $(eval "$migrations_cmd" | grep -v '\[X\]' | awk '{print $NF}')
    #
}

get_unapplied_migrations() {
    local appname="$1"
    local migrations_cmd="$(get_django_migrations "$appname")"
    eval "$migrations_cmd" | grep -v '\[X\]' | awk '{print $NF}'
}

get_applied_migrations() {
    local appname="$1"
    local migrations_cmd="$(get_django_migrations "$appname")"
    eval "$migrations_cmd" | grep '\[X\]' | awk '{print $NF}'
}

migrations_by_app() {
    declare -A migrations_by_app  
    while  IFS=. read -r app name; do
        migrations_by_app[$app]+="$name "
    done < <(cat)
    local apps=(${(k)migrations_by_app})
    for app in "${apps[@]}"; do
        echo "$app: ${migrations_by_app[$app]}"
    done
}


find_in_migrations() {
    local migration_path="$1"
    local found_migration current_app most_recent 
    while  IFS=":" read -r app_name migrations; do
        current_app="$app_name"
        local migration_array=($(echo "$migrations" | xargs -n 1))
        for migration in "${migration_array[@]}"; do
            if [[ 
                "$migration_path" == *"$app_name"*  &&
                "$migration_path" == *"$migration"* 
            ]]; then
                found_migration=$migration
                break 2;
            fi
            most_recent="$migration"
        done
    done 
    if [[ -z "$found_migration" ]]; then
        return 0
    else
        echo "$current_app $found_migration $most_recent"
        return 0
    fi
}


get_applied_migrations_by_app() {
    local appname="$1"
    local applied=$(eval $DJANGO_MANAGE showmigrations --plan $appname | awk '/\[X]/{print $2}')
    declare -A migrations_by_app  # Declare associative array

    while  IFS=. read -r app name; do
        migrations_by_app[$app]+="$name "
    done < <(echo $applied)
    local apps=(${(k)migrations_by_app})
    for app in "${apps[@]}"; do
        echo "$app: ${migrations_by_app[$app]}"
    done
 }


find_path_in_app_migrations() {
    local migration_path="$1"
    local app_name="$2"
    local migrations="$3"
    local last_applied_migration
    local found_migration
    while read -r migration; do
        if [[ 
            "$migration_path" == *"$app_name"*  && 
            "$migration_path" == *"$migration"* 
        ]]; then
            found_migration=$migration
            break
        fi
        last_applied_migration="$migration"
    done < <(echo "$migrations" | xargs -n 1)
    if [[ -z "$found_migration" ]]; then
        return 0
    fi
    echo $found_migration $last_applied_migration
}

find_path_in_django_apps() {
    migration_path="$1"
    migrations_by_app="$2"
    local found_migration
    local src_app
    local migration_name
    local last_applied_migration
    while  IFS=":" read -r app_name migrations; do
        read -r migration_name last_applied_migration <<< $(
            find_path_in_app_migrations "$migration_path" "$app_name" "$migrations"
         )
        if [[ -z "$migration_name" ]]; then
            continue
        else
            echo "$app_name" $migration_name" $last_applied_migration"
            break
        fi
    done < <(echo "$migrations_by_app")
}


get_migration_reverse() { 
    local app_name="$1"
    local migration_name="$2"
    echo "$DJANGO_MANAGE migrate $app_name $migration_name"
}

search_path_in_django_apps() {
    local applied_migrations=$(get_applied_migrations)
    local unapplied_migrations=$(get_unapplied_migrations)

    local target_branch="$1"
    local diff_migrations=($(get_migration_diff "$target_branch"))
    if [[ -z "$diff_migrations" ]]; then
        echo  "No migration differences found."
        return 0
    fi
    local reverse_migrations_cmds=()
    declare -a diff_migrations_applied
    for migration_path in "${diff_migrations[@]}"; do

        read -r app migration_name <<< $(
            echo $unapplied_migrations | \
                migrations_by_app | \
                find_in_migrations "$migration_path"
        )
        if [[ -v $migration_name ]]; then
            # The micreations is not applied passing
            continue
        fi

        read -r src_app migration_name last_applied_migration <<< $(
            echo $applied_migrations | \
                migrations_by_app | \
                find_in_migrations "$migration_path"
        )
        if [[ -z "$src_app" ]]; then
            continue
        fi
        diff_migrations_applied+=("$migration_name")
        previous_migration="${last_applied_migration:-zero}"
        reverse_migrations_cmds+=(
            "$(get_migration_reverse $src_app $previous_migration)"
        )
    done
    total_migrations=${#diff_migrations_applied[@]}
    if [[ $total_migrations -eq 0 ]]; then
        log_success "No unapplied migrations found in the diff."
        return 0
    fi
    echo "Found $total_migrations migrations that are not applied in the '$target_branch'.branch"
    echo "You can revert to the last applied migration using the following commands:"
    for cmd in "${reverse_migrations_cmds[@]}"; do
        echo -e "${C_WARN}$cmd${C_RESET}"
    done
}

get_applied_migrations_from_diff() {
    local target_branch="$1"
    local diff_migrations=($(get_migration_diff "$target_branch"))
    if [[ -z "$diff_migrations" ]]; then
        echo "No migration differences found."
        return 0
    fi
    total_migrations=${#diff_migrations}
    local migrations_by_app=$(get_applied_migrations_by_app)
    declare -a reverse_migrations_cmds
    for migration_path in "${diff_migrations[@]}"; do
        read -r src_app migration_name last_applied_migration <<< $(
            find_path_in_django_apps "$migration_path" "$migrations_by_app"
        )
        if [[ -z "$src_app" ]]; then
            continue
        fi
        previous_migration="${last_applied_migration:-zero}"
        reverse_migrations_cmds+=(
            "$(get_migration_reverse $src_app $previous_migration)"
        )
    done
    echo "Found $total_migrations migrations that are not applied in the '$target_branch'.branch"

    echo "You can revert to the last applied migration using the following commands:"
    for cmd in "${reverse_migrations_cmds[@]}"; do
        echo -e "${C_WARN}$cmd${C_RESET}"
    done

}

safe_switch_branch() {
    local target_branch="$1"
    echo  "Switching to branch '$target_branch'..."
    if ! git checkout "$target_branch"; then
        log_error "Failed to checkout branch '$target_branch'. Please check for errors above."
    fi
    log_success "Successfully checked out '$target_branch'."
}


