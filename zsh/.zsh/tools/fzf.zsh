eval "$(fzf --zsh)"
# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --no-ignore --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --hidden --no-ignore --type=d --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --no-ignore --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --no-ignore --type=d --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
  export | unset) fzf --preview "eval 'echo \${}'" "$@" ;;
  ssh) fzf --preview 'dig {}' "$@" ;;
  "git diff") fzf --preview 'git diff --name-only ' "$@" ;;
  *) fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

fzdiff() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf -m --ansi --preview "$preview"
}

fzdir() {
  dir_path="$1"
  if [[ -d $dir_path ]]; then
    fd --full-path "$dir_path" | fzf --multi --preview "$show_file_or_dir_preview"
  else
    echo "$dir_path is not a valid directory." >&2
  fi
}

fzdir_deep() {
  dir_path="$1"
  if [[ -d $dir_path ]]; then
    pushd "$dir_path" || exit
    fzf --multi --preview "$show_file_or_dir_preview"
    popd || exit
  else
    echo "$dir_path is not a valid directory." >&2
  fi
}

fzf_grep() {
  local search_term=$1

  rg --files-with-matches "$search_term" | fzf --preview "rg --color=always --context=5 '$search_term' {}"
}
