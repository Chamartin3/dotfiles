#!/bin/bash
# Smart tmux starter that works with continuum restore

# Debug log
DEBUG_LOG="$HOME/.tmux/tmux-smart-start.log"
echo "=== $(date) ===" >> "$DEBUG_LOG"
echo "Script started" >> "$DEBUG_LOG"
echo "HOME=$HOME" >> "$DEBUG_LOG"

# Check if there's a saved tmux resurrect session
if [ -L "$HOME/.tmux/resurrect/last" ] && [ -f "$HOME/.tmux/resurrect/last" ]; then
    LATEST=$(readlink "$HOME/.tmux/resurrect/last")
    echo "Saved session found: $LATEST" >> "$DEBUG_LOG"
    # There's a saved session - start tmux without creating a session
    # continuum will auto-restore the saved session
    echo "Starting tmux (continuum should restore)" >> "$DEBUG_LOG"
    exec tmux
else
    echo "No saved session found" >> "$DEBUG_LOG"
    # No saved session - create a default "main" session
    echo "Creating new 'main' session" >> "$DEBUG_LOG"
    exec tmux new-session -A -s main
fi
