#!/bin/bash
# 
# PrintIP information of the current machine
#
#
_validate_keys() {
  local response_keys=$1
  local filters=$2
  local invalid_keys=""
  for filter in $(echo "$filters" | tr ',' '\n'); do
    if ! echo "$response_keys" | grep -q "^$filter$"; then
       invalid_keys="$invalid_keys$filter,"
    fi
  done
  echo $invalid_keys
}

_print_filtered_json(){
  local response=$1
  local filters=$2
  local response_keys=$(echo "$response" | jq -r 'keys_unsorted[]')
  local invalid_filters=$(_validate_keys "$response_keys" "$filters")
 
 # if no filters foun print full result 
  if [[ -z $filters ]]; then
    echo $response | jq
    return
  fi 

  # if invalid filters found print error message
  # Ans also print the valid keys and full resutt
  if [[ -n "$invalid_filters" ]]; then
    valid_keys=$(echo $response_keys | paste -sd"," -)
    echo "Invalid key filters provided: $invalid_filters"
    echo "Valid keys are: $valid_keys"
    echo $response | jq
    return 
  fi
  
  # if only one filter found, print the result without key
  if [[ $filter_count -eq 1 ]]; then
     local rparser=".\"$(echo $filters)\""
     echo $response | jq -r $rparser
  else
     local rparser="{ $(echo $filters) }"
     echo $response | jq -r $rparser
  fi
 

}

onde_ando() {  
  local filters=${@} 
  local my_ip="$(curl -s https://ifconfig.io/)"
  local info_url="http://ipinfo.io/${my_ip}?token=${IP_INFO_TOKEN}"
  local response=$(curl -s "$info_url")
  local filter_count=$(echo $filters | tr ',' '\n' | wc -l)
  _print_filtered_json "$response" "$filters"
 }


