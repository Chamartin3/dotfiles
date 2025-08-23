


function pickers:prefiltered_list() {
	local -A search_items=()
	if [[ ! -z $1 ]]; then
		local seach_term=${(L)1}
		shift
	fi
	if [[ ! -z "${@}" ]]; then
		for arg in "${@}"; do
			search_items["${(L)arg}"]=$arg
		done
	# else
		# echo "No search terms args, using default search terms."
	fi
	while IFS= read -r line; do
		search_items["${(L)line}"]=$line
	done;
	if [[ -z $seach_term ]]; then
		for item in "${search_items[@]}"; do
			echo $item
		done
		return 0
	fi

	local search_keys=("${(k)search_items[@]}")
	local matchs=(${(M)search_keys##*$seach_term*})

	if [[ ${#matchs} -eq 0 ]]; then 
		return 1
	fi
	for match in "${matchs[@]}"; do
		echo "${search_items[$match]}"
	done
}


function picker:gum() {
	local my_array=()
	local  prefiltered=$(pickers:prefiltered_list $@)
	while read -r line; do 
		my_array+=("$line")
	done < <(echo $prefiltered)
	if [[ ${#my_array} -eq 0 ]]; then 
		gum style --foreground "#FF0000" \
			--border-foreground "#FF0000"\
			--border double \
			--align center \
			"No protocol matchs the pattern $1" >&2;
		return 1
	fi

  
	gum style --foreground "#8d9beb" \
		--border-foreground "#8d9beb" \
		--border double \
		--align center --margin "1 1" \
		--padding "1 1" \
		"Select an element from the list below:" >&2;
	
	local selection=$(gum choose $my_array )
	if [[ -z $selection ]]; then
		gum style --foreground "#FF0000" \
			--border-foreground "#FF0000"\
			--border double \
			--align center \
			"No element selected, exiting." >&2;
		return 1
	fi
	echo $selection



}


