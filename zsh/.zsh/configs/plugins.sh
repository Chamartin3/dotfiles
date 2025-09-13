#! bin/zsh
#
source "$ZSH_UTILS_DIR/validation.zsh"



function _install_oh_my_zsh_plugin() {
  local plugin_name="$1"
  local custom_plugin_path="$OMZ_CUSTOM_PLUGINS/$plugin/$plugin.plugin.zsh"
  local default_plugin_path="$OMZ_PLUGINS/$plugin/$plugin.plugin.zsh"
  validate:source_if_exists -e "$custom_plugin_path"\
  || validate:source_if_exists "$default_plugin_path"; 
  
}


function _install_oh_my_zsh_component() {
  local component_name="$1"
  local component_path="$OH_MY_ZSH_PATH/lib/$component_name.zsh"
  validate:source_if_exists  "$component_path";
}

omz_lib=(
  history
  compfix
  completion
  functions
  correction
  diagnostics
  key-bindings
  git
)

for comp ($omz_lib); do
  _install_oh_my_zsh_component "$comp"
done


plugins=(
    git
    github
    python
    pip
    pyenv
    aliases
    alias-finder
    ubuntu 
    web-search
    firebase
    emoji
)

for plugin ($plugins); do
  _install_oh_my_zsh_plugin "$plugin"
done

function install_history_search(){
  local HSS_SRC="$HOMEBREW_SHARE/zsh-history-substring-search/zsh-history-substring-search.zsh"
  validate:source_if_exists  "$HSS_SRC" || $(echo "Could not load `zsh-history-substring-search`" && return 2)
}


function _alias_finder_configs(){
  zstyle ':omz:plugins:alias-finder' autoload yes; # disabled by default
  zstyle ':omz:plugins:alias-finder' longer yes ; # disabled by default
  zstyle ':omz:plugins:alias-finder' exact yes; # disabled by default
  zstyle ':omz:plugins:alias-finder' cheaper yes; 
}


source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh
install_history_search
_alias_finder_configs
