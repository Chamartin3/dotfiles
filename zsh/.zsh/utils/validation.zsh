


#require that the funtion has at leas one argument 
function __require_at_least_one_arg(){
  if [[ ! -n $1 ]] then
    return $(throw_exception "at least one argument is required");
  fi
}

#finds is a variable is defined
function var_is_defined(){
  __require_at_least_one_arg $@ || return 1;
  found=$(set | while IFS="=" read -r varname value;
  do 
    echo $varname
  done | grep "$1")
  [[ $found != '' ]] || return 1;
}

# Verifies is the passedarcuments exists as variables
function fail_if_undefined_var() {
  __require_at_least_one_arg $@ || return 1;
  for varname in "$@"; do
    var_is_defined $varname || return $(throw_exception "Variable $varname is not defined");
  done
}


function validate:source_if_exists {
  local error verbose
  zparseopts -D -F -K  \
  {e,-error-silent}=error \
  {v,-verbose}=verbose \
  || return 1;

  local file="$@"
   if [[ -f "$file" ]]; then
     if [[ ! -z "${verbose}" ]]; then
       echo "Sourcing file: $file"
     fi

     source "$file"
   elif [[ -z "${error}" ]]; then
     echo "File not found: $file" >&2
     return 1
   fi
 }

