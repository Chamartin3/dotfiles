#!/bin/bash
# Helper script for opencode-sessions television channel preview

SESSION_LINE="$1"
SESSION_ID=$(echo "$SESSION_LINE" | cut -f1)
SESSION_TITLE=$(echo "$SESSION_LINE" | cut -f2)
SESSION_DIR=$(echo "$SESSION_LINE" | cut -f3)
SESSION_UPDATED=$(echo "$SESSION_LINE" | cut -f4)

if [ "$SESSION_ID" = "__NEW_SESSION__" ]; then
  echo -e "\033[1m📁 Create a new OpenCode session\033[0m"
  echo ""
  echo "Press Enter to launch a new session"
  exit 0
fi

echo -e "\033[1mSession: $SESSION_TITLE\033[0m"
echo ""
echo -e "\033[36mID:\033[0m        $SESSION_ID"
echo -e "\033[36mDirectory:\033[0m $SESSION_DIR"
echo ""
echo "─────────────────────────────────────────"
echo "Directory Contents:"
echo ""

if command -v eza >/dev/null 2>&1; then
  eza -la --color=always --group-directories-first "$SESSION_DIR" 2>/dev/null || echo "(directory not accessible)"
else
  ls -la --color=always "$SESSION_DIR" 2>/dev/null || echo "(directory not accessible)"
fi

echo ""
echo "─────────────────────────────────────────"
echo "Last Activity:"

if [ -n "$SESSION_UPDATED" ] && [ "$SESSION_UPDATED" != "-" ]; then
  NOW=$(date +%s%3N)
  DIFF=$(( (NOW - SESSION_UPDATED) / 1000 ))
  
  if [ $DIFF -lt 60 ]; then
    echo "  Updated: $DIFF seconds ago"
  elif [ $DIFF -lt 3600 ]; then
    MINS=$((DIFF / 60))
    echo "  Updated: $MINS minute$([ $MINS -eq 1 ] || echo 's') ago"
  elif [ $DIFF -lt 86400 ]; then
    HOURS=$((DIFF / 3600))
    echo "  Updated: $HOURS hour$([ $HOURS -eq 1 ] || echo 's') ago"
  else
    DAYS=$((DIFF / 86400))
    echo "  Updated: $DAYS day$([ $DAYS -eq 1 ] || echo 's') ago"
  fi
else
  echo "  Updated: unknown"
fi
