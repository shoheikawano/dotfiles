#!/bin/bash

# Suggest command improvements based on session activity
# This script creates a marker file that Claude can check
# to determine if /reflect should be suggested

set -e

# Configuration
SUGGESTION_MARKER="$HOME/.claude/logs/suggest-improvement-marker"
LAST_SUGGESTION_FILE="$HOME/.claude/logs/last-improvement-suggestion"

# Create logs directory if it doesn't exist
mkdir -p "$(dirname "$SUGGESTION_MARKER")"

# Check if we should suggest (don't suggest too frequently - once per day max)
if [ -f "$LAST_SUGGESTION_FILE" ]; then
    LAST_SUGGESTION=$(cat "$LAST_SUGGESTION_FILE")
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_SUGGESTION))

    # Only suggest if more than 24 hours (86400 seconds) have passed
    if [ $TIME_DIFF -lt 86400 ]; then
        exit 0
    fi
fi

# Check session activity indicators
SESSION_DIR="$HOME/.cache/claude-code"
COMMANDS_DIR="$HOME/.claude/commands"

# Simple heuristic: if there have been multiple commands executed in recent sessions
# Create a marker file with timestamp
if [ -d "$SESSION_DIR" ]; then
    # Count recent session files (last 24 hours)
    recent_activity=$(find "$SESSION_DIR" -type f -mtime -1 2>/dev/null | wc -l || echo 0)

    # If there's been significant activity, suggest improvement check
    if [ "$recent_activity" -gt 3 ]; then
        echo "$(date +%s)" > "$SUGGESTION_MARKER"
        echo "$(date +%s)" > "$LAST_SUGGESTION_FILE"
    fi
fi

exit 0
