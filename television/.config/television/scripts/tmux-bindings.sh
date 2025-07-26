#!/bin/bash
# Parse tmux.conf and output keybindings in a searchable format

TMUX_CONF="${1:-$HOME/.tmux.conf}"

# Get target pane from environment (set by tmux binding)
TARGET_PANE="${TARGET_PANE:-#{pane_id}}"

# If tmux.conf is a symlink, resolve it
if [ -L "$TMUX_CONF" ]; then
    TMUX_CONF=$(readlink -f "$TMUX_CONF")
fi

# Create a temp file with line continuations resolved
temp_file=$(mktemp)
# Read file and handle line continuations (lines ending with \)
awk '{
    if (/\\$/) {
        printf "%s", substr($0, 1, length($0)-1)
    } else {
        print
    }
}' "$TMUX_CONF" > "$temp_file"

# Parse bind commands and extract keybindings with descriptions
# Format: ICON │ key │ description │ full command │ action to execute

grep -E '^\s*bind' "$temp_file" 2>/dev/null | while IFS= read -r line; do
    # Skip comment lines and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue
    
    # Extract the key and the rest of the command
    # Handle different bind formats:
    # bind r run '...'
    # bind -r h select-pane -L
    # bind -T copy-mode-vi v send -X begin-selection
    # bind-key C-s run-shell '...'
    
    # Remove leading whitespace
    line=$(echo "$line" | sed 's/^[[:space:]]*//')
    
    # Check if it's a bind or bind-key command
    if [[ "$line" =~ ^bind(-key)?[[:space:]] ]]; then
        # Remove 'bind' or 'bind-key' prefix
        rest=$(echo "$line" | sed 's/^bind-key[[:space:]]*//; s/^bind[[:space:]]*//')
        
        # Extract flags and key
        flags=""
        key=""
        cmd=""
        
        # Parse flags (-r, -T table, etc.)
        while [[ "$rest" =~ ^- ]]; do
            if [[ "$rest" =~ ^-T[[:space:]]+([^[:space:]]+) ]]; then
                table="${BASH_REMATCH[1]}"
                flags="${flags} -T ${table}"
                rest=$(echo "$rest" | sed "s/-T[[:space:]]*${table}[[:space:]]*//")
            elif [[ "$rest" =~ ^-r ]]; then
                flags="${flags} -r"
                rest=$(echo "$rest" | sed 's/-r[[:space:]]*//')
            elif [[ "$rest" =~ ^-n ]]; then
                flags="${flags} -n"
                rest=$(echo "$rest" | sed 's/-n[[:space:]]*//')
            else
                # Unknown flag, break
                break
            fi
            rest=$(echo "$rest" | sed 's/^[[:space:]]*//')
        done
        
        # Now extract the key (first word)
        key=$(echo "$rest" | awk '{print $1}')
        cmd=$(echo "$rest" | cut -d' ' -f2-)
        
        # Clean up quotes around the key
        key=$(echo "$key" | sed 's/^"//; s/"$//; s/^'"'"'//; s/'"'"'$//')
        
        # Skip if no key found
        [ -z "$key" ] && continue
        
        # Generate description based on the command
        description=""
        
        # Determine the action to execute
        # For copy-mode bindings, we need to enter copy mode first
        if [[ "$flags" =~ copy-mode-vi ]]; then
            prefix_icon="📋"
            # For copy mode bindings, action targets the original pane
            case "$key" in
                "v") description="Begin selection" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X begin-selection" ;;
                "C-v") description="Rectangle toggle" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X rectangle-toggle" ;;
                "Escape") description="Cancel/exit copy mode" ; action="tmux send-keys -t $TARGET_PANE -X cancel" ;;
                "H") description="Start of line" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X start-of-line" ;;
                "L") description="End of line" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X end-of-line" ;;
                "k") description="Cursor up" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X cursor-up" ;;
                "j") description="Cursor down" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X cursor-down" ;;
                "J") description="Move down 5 lines" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X cursor-down; tmux send-keys -t $TARGET_PANE -X cursor-down; tmux send-keys -t $TARGET_PANE -X cursor-down; tmux send-keys -t $TARGET_PANE -X cursor-down; tmux send-keys -t $TARGET_PANE -X cursor-down" ;;
                "K") description="Move up 5 lines" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X cursor-up; tmux send-keys -t $TARGET_PANE -X cursor-up; tmux send-keys -t $TARGET_PANE -X cursor-up; tmux send-keys -t $TARGET_PANE -X cursor-up; tmux send-keys -t $TARGET_PANE -X cursor-up" ;;
                "y") description="Yank selection and cancel" ; action="tmux send-keys -t $TARGET_PANE -X copy-selection-and-cancel" ;;
                "Enter") description="Copy to clipboard and cancel" ; action="tmux send-keys -t $TARGET_PANE -X copy-pipe-and-cancel 'xclip -selection clipboard -in'" ;;
                *) description="Copy mode command" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE -X $key" ;;
            esac
        elif [[ "$flags" =~ copy-mode ]]; then
            prefix_icon="📋"
            case "$key" in
                "y") description="Yank selection and cancel" ; action="tmux send-keys -t $TARGET_PANE -X copy-selection-and-cancel" ;;
                "Enter") description="Copy to clipboard and cancel" ; action="tmux send-keys -t $TARGET_PANE -X copy-pipe-and-cancel 'xclip -selection clipboard -in'" ;;
                *) description="Copy mode command" ; action="tmux copy-mode -t $TARGET_PANE; sleep 0.1; tmux send-keys -t $TARGET_PANE $key" ;;
            esac
        else
            prefix_icon="⌘"
            # For normal bindings, use direct tmux commands targeting the original pane
            case "$key" in
                "C-a") description="Send prefix to nested tmux" ; action="tmux send-keys -t $TARGET_PANE C-a C-a" ;;
                "r") description="Reload tmux config" ; action="tmux source-file \"$TMUX_CONF\"" ;;
                "C-c") description="Create new session" ; action="tmux new-session" ;;
                "C-f") description="Find and switch to session" ; action="tmux command-prompt -p find-session 'switch-client -t %%'" ;;
                "BTab") description="Switch to last session" ; action="tmux switch-client -l" ;;
                "-") description="Split window horizontally" ; action="tmux split-window -v -t $TARGET_PANE" ;;
                "_") description="Split window vertically" ; action="tmux split-window -h -t $TARGET_PANE" ;;
                "h") description="Select pane left" ; action="tmux select-pane -L -t $TARGET_PANE" ;;
                "j") description="Select pane down" ; action="tmux select-pane -D -t $TARGET_PANE" ;;
                "k") description="Select pane up" ; action="tmux select-pane -U -t $TARGET_PANE" ;;
                "l") description="Select pane right" ; action="tmux select-pane -R -t $TARGET_PANE" ;;
                ">") description="Swap pane with next" ; action="tmux swap-pane -D -t $TARGET_PANE" ;;
                "<") description="Swap pane with previous" ; action="tmux swap-pane -U -t $TARGET_PANE" ;;
                "C-h") description="Previous window" ; action="tmux previous-window -t $TARGET_PANE" ;;
                "C-l") description="Next window" ; action="tmux next-window -t $TARGET_PANE" ;;
                "Tab") description="Last active window" ; action="tmux last-window -t $TARGET_PANE" ;;
                "+") description="Maximize current pane" ; action="tmux resize-pane -Z -t $TARGET_PANE" ;;
                "H") description="Resize pane left" ; action="tmux resize-pane -L 2 -t $TARGET_PANE" ;;
                "J") description="Resize pane down" ; action="tmux resize-pane -D 2 -t $TARGET_PANE" ;;
                "K") description="Resize pane up" ; action="tmux resize-pane -U 2 -t $TARGET_PANE" ;;
                "L") description="Resize pane right" ; action="tmux resize-pane -R 2 -t $TARGET_PANE" ;;
                "U") description="Open URL view" ; action="tmux run-shell -t $TARGET_PANE 'cut -c3- \"$TMUX_CONF\" | sh -s _urlview \"#{pane_id}\"'" ;;
                "F") description="Open Facebook PathPicker" ; action="tmux run-shell -t $TARGET_PANE 'cut -c3- \"$TMUX_CONF\" | sh -s _fpp \"#{pane_id}\" \"#{pane_current_path}\"'" ;;
                "Enter") description="Enter copy mode" ; action="tmux copy-mode -t $TARGET_PANE" ;;
                "b") description="List paste buffers" ; action="tmux list-buffers" ;;
                "p") description="Paste from top buffer" ; action="tmux paste-buffer -p -t $TARGET_PANE" ;;
                "P") description="Choose buffer to paste from" ; action="tmux choose-buffer" ;;
                "C-s") description="Save session with resurrect" ; action="tmux run-shell '~/.tmux/plugins/tmux-resurrect/scripts/save.sh && tmux display-message \"Session saved!\"'" ;;
                "C-r") description="Restore session with resurrect" ; action="tmux run-shell '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh && tmux display-message \"Session restored!\"'" ;;
                "K") description="Open sesh (session manager)" ; action="tv sesh" ;;
                "T") description="Open sesh with fzf" ; action="~/.tmux/scripts/tmux-sesh-fzf.sh" ;;
                "?") description="Show keybindings help" ; action="tmux send-keys -t $TARGET_PANE C-a ?" ;;
                *) 
                    # Try to extract description from command
                    if [[ "$cmd" =~ display-popup ]]; then
                        description="Open popup"
                        action="tmux $cmd"
                    elif [[ "$cmd" =~ run-shell ]]; then
                        description="Run shell command"
                        action="tmux $cmd"
                    elif [[ "$cmd" =~ new-session ]]; then
                        description="Create new session"
                        action="tmux $cmd"
                    elif [[ "$cmd" =~ split-window ]]; then
                        description="Split window"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ select-pane ]]; then
                        description="Select pane"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ resize-pane ]]; then
                        description="Resize pane"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ swap-pane ]]; then
                        description="Swap pane"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ previous-window ]]; then
                        description="Previous window"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ next-window ]]; then
                        description="Next window"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ last-window ]]; then
                        description="Last active window"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ switch-client ]]; then
                        description="Switch session"
                        action="tmux $cmd"
                    elif [[ "$cmd" =~ copy-mode ]]; then
                        description="Enter copy mode"
                        action="tmux copy-mode -t $TARGET_PANE"
                    elif [[ "$cmd" =~ paste-buffer ]]; then
                        description="Paste from buffer"
                        action="tmux $cmd -t $TARGET_PANE"
                    elif [[ "$cmd" =~ list-buffers ]]; then
                        description="List buffers"
                        action="tmux $cmd"
                    elif [[ "$cmd" =~ choose-buffer ]]; then
                        description="Choose buffer"
                        action="tmux $cmd"
                    else
                        description="Tmux command"
                        action="tmux send-keys -t $TARGET_PANE C-a $key"
                    fi
                    ;;
            esac
        fi
        
        # Output format: icon│key│description│full command│action
        # Using │ as delimiter (unlikely to appear in normal text)
        printf "%s│%-12s│%-40s│%s│%s\n" "$prefix_icon" "$key" "$description" "$line" "$action"
    fi
done

rm -f "$temp_file"

# Also add some essential tmux commands that aren't explicit binds
# Use double quotes so TARGET_PANE gets expanded
cat << EOF
⌘│?           │List all keybindings                      │bind ? list-keys│tmux send-keys -t $TARGET_PANE C-a ?
⌘│:           │Command prompt                            │bind : command-prompt│tmux send-keys -t $TARGET_PANE C-a :
⌘│d           │Detach from session                       │bind d detach-client│tmux detach-client
⌘│\$           │Rename current session                    │bind '\$' command-prompt -I'#S' 'rename-session -- %%'│tmux command-prompt -I'#S' 'rename-session -- %%'
⌘│,           │Rename current window                     │bind , command-prompt -I'#W' 'rename-window -- %%'│tmux command-prompt -I'#W' 'rename-window -- %%'
⌘│c           │Create new window                         │bind c new-window│tmux new-window
⌘│&           │Kill current window                       │bind & confirm-before -p'kill-window #W? (y/n)' kill-window│tmux confirm-before -p'kill-window #W? (y/n)' kill-window
⌘│x           │Kill current pane                         │bind x confirm-before -p'kill-pane #P? (y/n)' kill-pane│tmux confirm-before -p'kill-pane #P? (y/n)' kill-pane -t $TARGET_PANE
⌘│z           │Zoom current pane                         │bind z resize-pane -Z│tmux resize-pane -Z -t $TARGET_PANE
⌘│q           │Display pane numbers                      │bind q display-panes│tmux display-panes
⌘│w           │Choose window interactively               │bind w choose-window│tmux choose-window
⌘│s           │Choose session interactively              │bind s choose-session│tmux choose-session
⌘│t           │Show big clock                            │bind t clock-mode│tmux clock-mode
⌘│[           │Enter copy mode                           │bind [ copy-mode│tmux copy-mode -t $TARGET_PANE
⌘│]           │Paste buffer                              │bind ] paste-buffer│tmux paste-buffer -t $TARGET_PANE
EOF
