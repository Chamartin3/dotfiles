#!/usr/bin/zsh

# myjira - A simple wrapper around the jira command line tool
#

__current_branch(){
  git branch --show-current | sed -E 's/([[:alpha:]]+)_/\U\1-/g'
}


myjira:issues(){
  jira issue list   -a$(jira me) $@
}





myjira:watched(){
  jira issue list  -w $@
}

myjira:current_ticket(){
  local cmd=$1
  case "$1" in
    "view")
      jira issue view $(__current_branch) --comments 25 ${@:2}
    ;;
    "open")
      jira open $(__current_branch)  ${@:2}
    ;;
  *)
    echo "$(__current_branch)"
    echo "open - to see in browser"
    echo "view - to see the ticket here"
  ;;
}
}


_query_open_issues(){
  echo "status != Done AND type != Epic AND status != Discarded"
}
_query_done_issues(){
     echo "status = Done"
}

_from_person(){
  "assignee=$1"
}


myjira() {
  local cmd=$1
   case "$1" in
     "open_issues")
       myjira_issues -q "$(_query_open_issues)"
       ;;
     "watching")
       myjira_watched -q "$(_query_open_issues)"
       ;;
     "current")
       myjira_current_ticket ${@:2}
       ;;
     *)

       echo "open_issues - To see all your open tickets on jira";
       echo "watching - To see all your watched tickets on jira";
       echo "current - To see the information about your current ticket";
       jira $@
       ;;
     }
}
