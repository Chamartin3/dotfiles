
ghub() {

  ghub_base(){
      # Reset GITHUB_TOKEN to avoid issues with gh commands
      export _GH_TOKENPROXY=$GITHUB_TOKEN
      unset GITHUB_TOKEN; 
      gh "$@";
      export GITHUB_TOKEN=$_GH_TOKENPROXY
      
  }
  
   ghub_checks() {
     ghub_base pr checks
   }
  
   ghub_pr_browse(){
     ghub_base pr view -w
   }
  
  
   ghub_pr_test_env(){
     ghub_raw_env | w3m -T text/html
   }
  
  
  
   ghub_open_pr() {
     ghub_base pr create --base <base_branch> --head <current_branch> --title "<pr_title>"
   }
  
   ghub_latest_comments() {
     ghub_base pr list --comments
   }
  
   ghub_pr_number(){
     ghub_base pr view --json number --jq '.number'
   }
  
   ghub_all_comments(){
     ghub_base pr view --json comments | jq '.comments'
   }
  
  
  
  _format_comments() {
   while read login createdAt body; do
     formatedDate=$(date -d "$createdAt" +"%d-%b,%Y->%I:%M%P")
     echo "$login $formatedDate $body"; 
   done
  }
  
  
  _parse_comments(){
    jq '.[] | "\(.author.login) \(.createdAt) \(.body)"' | tr -d '"'
  }
  
   ghub_fzf_comments(){
     preview='echo "{}" | cut -d" " -f3- |  glow'
     ghub_all_comments |
       _parse_comments | 
       _format_comments | 
       fzf --ansi --preview=$preview
   }

  local silent=false
  local cmd=""

 if [[ $1 == "-s" ]]; then
     silent=true
     shift
     cmd=$1
 else
     cmd=$1
 fi

   case "$1" in
     "status")
       ghub_checks "${@:2}"
       ;;
      "browse")
       ghub_pr_browse  "${@:2}"
       ;;
     "envs")
       ghub_pr_test_env  "${@:2}"
       ;;
      "raw_squansh")
       ghub_raw_env  "${@:2}"
       ;;
     "json-comments")
       ghub_all_comments  "${@:2}"
       ;;
     "comments")
       ;;
     "pr_number")
       ghub_pr_number  "${@:2}"
       ;;
     "comment_explorer")
       ghub_fzf_comments
       ;;
    "pr_number")
       ghub_pr_number
       ;;
     *)
       if [ "$silent" = false ]; then
               echo "using GH api";
      echo "******************"
      echo "browse - open in browser"
      echo "envs - test enviroments"
      echo "json-comments - comments in json format"
      echo "comments - recent comments on the pr"
      echo "pr_number - number of the pr"
      echo "comment-exporer - fuzzyyfind  in the comments"
      echo "******************"

       fi
       ghub_base $@
       ;;
   }
 }

