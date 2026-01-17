#!/bin/bash

# Check and sync script for Claude Code hooks
# Automatically runs auto-sync if there are changes in the dotfiles repository
# Includes security check before syncing

# Change to the Claude directory (which is part of homesick dotfiles)
cd ~/.claude || exit 1

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
fi

# Check if there are any changes (modified, added, or untracked files)
if ! git diff --quiet HEAD 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "🔍 Detected changes in dotfiles repository"

    # Run security check first
    if ! ~/.claude/skills/dotfiles-syncer/scripts/security-check.sh; then
        echo "⚠️  Security check failed - skipping sync"
        echo "Please review and manually sync your dotfiles"
        exit 1
    fi

    # Security check passed, run auto-sync
    # No commit message provided - let auto-sync generate a meaningful one based on changed files
    echo "✅ Security check passed - syncing dotfiles"
    ~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh
fi
