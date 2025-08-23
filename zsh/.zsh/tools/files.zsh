#! /bin/zsh



function nvim:open_files(){
   nvim . -p $(fzdir .)  -c 'lua require("telescope.builtin").buffers()'
}

function nvim:open_grep(){
   nvim . -c 'lua require("telescope.builtin").live_grep()'
}

function dircopy:progress() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <source_folder>"
        return 1
    fi

    # Check if tar and pv are installed
    if ! command -v tar &> /dev/null; then
        echo "Error: tar is not installed. Please install it first."
        return 1
    fi

    if ! command -v pv &> /dev/null; then
        echo "Error: pv is not installed. Please install it first."
        return 1
    fi

    if [[ ! -d "$1" ]]; then
        echo "Error: Source directory '$1' does not exist."
        return 1
    fi

    echo "Estimating source folder size..."
    local size=$(du -sh "$1" | cut -f1)
    echo "Source folder size: $size"

    read -q "REPLY?Do you want to proceed with the copy? (y/n) "
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tar -C "$(dirname "$1")" -cf - "$(basename "$1")" | pv -s $(du -sb "$1" | awk '{print $1}') | tar -xf - -C ./

    else
        echo "Copy operation cancelled."
    fi
}

function sudo_cpdir_progress() {
    sudo zsh -c "$(declare -f cpdir_progress); cpdir_progress '$1'"
}

