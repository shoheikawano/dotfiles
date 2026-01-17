#!/bin/bash

# Auto-sync script for dotfiles repository (homesick)
# Safely commits and pushes changes with security checks

set -e

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$HOME/.homesick/repos/dotfiles"
CLAUDE_DIR="$HOME/.claude"

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS] [commit_message]"
    echo ""
    echo "Auto-sync dotfiles repository (homesick) with security checks"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Skip sensitivity checks (not recommended)"
    echo "  -n, --dry-run  Show what would be committed without actually committing"
    echo "  -c, --claude   Only sync ~/.claude directory (legacy mode)"
    echo ""
    echo "Examples:"
    echo "  $0 'Update dotfiles configuration'"
    echo "  $0 --dry-run"
    echo "  $0 --claude 'Update Claude commands only'"
    echo "  $0 --force 'Emergency update'"
}

# Parse command line arguments
FORCE=false
DRY_RUN=false
CLAUDE_ONLY=false
COMMIT_MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -c|--claude)
            CLAUDE_ONLY=true
            shift
            ;;
        *)
            COMMIT_MESSAGE="$1"
            shift
            ;;
    esac
done

# Determine working directory
if [ "$CLAUDE_ONLY" = true ]; then
    WORK_DIR="$CLAUDE_DIR"
    echo -e "${BLUE}🔄 Auto-syncing Claude configuration...${NC}"
else
    WORK_DIR="$DOTFILES_DIR"
    echo -e "${BLUE}🔄 Auto-syncing dotfiles repository...${NC}"
fi

# Change to working directory
cd "$WORK_DIR" || {
    echo -e "${RED}❌ Error: Cannot access $WORK_DIR${NC}"
    exit 1
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: $WORK_DIR is not a git repository${NC}"
    exit 1
fi

# Check for unstaged changes
if ! git diff --quiet; then
    echo -e "${YELLOW}📝 Found unstaged changes${NC}"
fi

# Check for untracked files
UNTRACKED=$(git ls-files --others --exclude-standard)
if [ -n "$UNTRACKED" ]; then
    echo -e "${YELLOW}📄 Found untracked files:${NC}"
    echo "$UNTRACKED" | sed 's/^/  /'
fi

# Show current status
echo -e "${BLUE}📊 Current git status:${NC}"
git status --short

# If dry run, show what would be added and exit
if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}🔍 Dry run - files that would be added:${NC}"
    
    # Show what would be staged
    git add --dry-run . 2>/dev/null | grep -v "^$" || echo "  No files to add"
    
    echo -e "${GREEN}✅ Dry run complete - no changes made${NC}"
    exit 0
fi

# Add all changes (respecting .gitignore)
echo -e "${BLUE}➕ Adding changes...${NC}"
git add .

# Check if there are any staged changes
if git diff --cached --quiet; then
    echo -e "${GREEN}✅ No changes to commit${NC}"
    exit 0
fi

# Show what will be committed
echo -e "${BLUE}📋 Files to be committed:${NC}"
git diff --cached --name-status

# Generate commit message if not provided
if [ -z "$COMMIT_MESSAGE" ]; then
    # Get detailed file information
    MODIFIED_FILES=$(git diff --cached --name-only --diff-filter=M)
    ADDED_FILES=$(git diff --cached --name-only --diff-filter=A)
    DELETED_FILES=$(git diff --cached --name-only --diff-filter=D)
    
    MODIFIED=$(echo "$MODIFIED_FILES" | grep -c . || echo "0")
    ADDED=$(echo "$ADDED_FILES" | grep -c . || echo "0")
    DELETED=$(echo "$DELETED_FILES" | grep -c . || echo "0")
    
    # Function to generate smart commit message based on file analysis
    generate_smart_message() {
        local context=""
        local action=""
        local subject=""
        
        # Analyze specific file types and patterns
        if echo "$MODIFIED_FILES $ADDED_FILES" | grep -q "commands/"; then
            if echo "$MODIFIED_FILES $ADDED_FILES" | grep -q "\.md$"; then
                local cmd_files=$(echo "$MODIFIED_FILES $ADDED_FILES" | tr ' ' '\n' | grep "commands/" | grep "\.md$" | head -3)
                local cmd_names=$(echo "$cmd_files" | sed 's|.*/||; s|\.md$||' | tr '\n' ', ' | sed 's|, $||')
                action="Update"
                subject="/$cmd_names command"
                context="Improve command functionality and documentation"
            fi
        elif echo "$MODIFIED_FILES $ADDED_FILES" | grep -q "CLAUDE\.md"; then
            action="Update"
            subject="Claude configuration"
            context="Refine workflow patterns and productivity settings"
        elif echo "$MODIFIED_FILES $ADDED_FILES" | grep -q "scripts/"; then
            local script_files=$(echo "$MODIFIED_FILES $ADDED_FILES" | tr ' ' '\n' | grep "scripts/" | head -2)
            local script_names=$(echo "$script_files" | sed 's|.*/||; s|\.sh$||' | tr '\n' ', ' | sed 's|, $||')
            action="Enhance"
            subject="$script_names automation"
            context="Improve script reliability and functionality"
        elif echo "$MODIFIED_FILES $ADDED_FILES" | grep -q "agents/"; then
            action="Update"
            subject="agent configurations"
            context="Refine agent capabilities and tool access"
        else
            # Fallback to file type analysis
            if [ "$CLAUDE_ONLY" = true ]; then
                if [ "$ADDED" -gt 0 ] && [ "$MODIFIED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
                    action="Add"
                    subject="Claude configuration files"
                elif [ "$MODIFIED" -gt 0 ] && [ "$ADDED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
                    action="Update"
                    subject="Claude configuration"
                elif [ "$DELETED" -gt 0 ]; then
                    action="Clean up"
                    subject="Claude configuration files"
                else
                    action="Update"
                    subject="Claude configuration"
                    context="Multiple file changes (+$ADDED ~$MODIFIED -$DELETED)"
                fi
            else
                if [ "$ADDED" -gt 0 ] && [ "$MODIFIED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
                    action="Add"
                    subject="dotfiles configuration"
                elif [ "$MODIFIED" -gt 0 ] && [ "$ADDED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
                    action="Update"
                    subject="dotfiles configuration"
                elif [ "$DELETED" -gt 0 ]; then
                    action="Clean up"
                    subject="dotfiles configuration"
                else
                    action="Update"
                    subject="dotfiles configuration"
                    context="Multiple file changes (+$ADDED ~$MODIFIED -$DELETED)"
                fi
            fi
        fi
        
        # Construct final message
        if [ -n "$context" ]; then
            echo "$action $subject: $context"
        else
            echo "$action $subject"
        fi
    }
    
    COMMIT_MESSAGE=$(generate_smart_message)
fi

# Security check (unless forced)
if [ "$FORCE" = false ]; then
    echo -e "${BLUE}🔒 Running security checks...${NC}"
    
    # The pre-commit hook will run automatically and block if sensitive info is found
    # But we can also run additional checks here if needed
fi

# Commit changes
echo -e "${BLUE}💾 Committing changes...${NC}"
if [ "$FORCE" = true ]; then
    git commit --no-verify -m "$COMMIT_MESSAGE

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
else
    git commit -m "$COMMIT_MESSAGE

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
fi

# Check if commit was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Changes committed successfully${NC}"
else
    echo -e "${RED}❌ Commit failed${NC}"
    exit 1
fi

# Push to remote
echo -e "${BLUE}🚀 Pushing to remote...${NC}"
if git push; then
    echo -e "${GREEN}✅ Successfully synced to remote repository${NC}"
    echo -e "${BLUE}📝 Commit: $(git log -1 --oneline)${NC}"
else
    echo -e "${RED}❌ Failed to push to remote${NC}"
    echo -e "${YELLOW}💡 You may need to pull changes first: git pull${NC}"
    exit 1
fi

if [ "$CLAUDE_ONLY" = true ]; then
    echo -e "${GREEN}🎉 Claude configuration sync complete!${NC}"
else
    echo -e "${GREEN}🎉 Dotfiles repository sync complete!${NC}"
fi
