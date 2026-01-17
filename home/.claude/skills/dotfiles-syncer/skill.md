---
name: dotfiles-syncer
description: |
  Sync dotfiles repository (homesick) with security checks.
  Use when: (1) Syncing dotfiles changes, (2) Committing dotfiles, (3) Pushing changes,
  (4) Running security checks, (5) After any file changes in ~/.claude/ or dotfiles repo.
  Triggers: "sync dotfiles", "commit dotfiles", "push changes", "security check",
  "dotfiles sync", "homesick sync", after file modifications in ~/.claude/.
context: fork
agent: general-purpose
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Dotfiles Syncer

Safely sync dotfiles repository (homesick) with automatic security checks.

## When to Use

- After making any changes to `~/.claude/` directory
- After modifying files tracked by homesick dotfiles repository
- When explicitly requested to sync/commit/push dotfiles
- At the end of sessions that modified configuration files

## Security-First Workflow

**CRITICAL**: Always run security check before syncing.

```
Security Check Flow
├─ Run security-check.sh
│  ├─ Pass → Proceed with sync
│  └─ Fail → STOP and alert user
│     ├─ Review flagged content
│     ├─ Remove sensitive data
│     └─ Retry after cleanup
```

## Available Scripts

All scripts are located in `~/.claude/skills/dotfiles-syncer/scripts/`:

### 1. security-check.sh
Scans files for sensitive data patterns:
- API keys, tokens, passwords
- Database connection strings
- AWS/cloud credentials
- SSH private keys
- JWT tokens
- Credit card patterns

```bash
~/.claude/skills/dotfiles-syncer/scripts/security-check.sh
```

### 2. auto-sync-dotfiles.sh
Main sync script with options:

```bash
# Basic sync (auto-generates commit message)
~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh

# With custom commit message
~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh "Update skill configurations"

# Dry run (preview changes)
~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh --dry-run

# Claude directory only (legacy mode)
~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh --claude "Update Claude config"

# Force sync (skip security check - NOT recommended)
~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh --force "Emergency update"
```

### 3. check-and-sync.sh
Convenience script that combines security check + sync:

```bash
~/.claude/skills/dotfiles-syncer/scripts/check-and-sync.sh
```

## Standard Sync Pattern

```bash
# Recommended: Security check then sync
~/.claude/skills/dotfiles-syncer/scripts/security-check.sh && \
~/.claude/skills/dotfiles-syncer/scripts/auto-sync-dotfiles.sh "Descriptive message"
```

## Error Handling

### Push Failures
If push fails due to remote changes:
```bash
cd ~/.homesick/repos/dotfiles
git pull --rebase
# Then retry sync
```

### Security Check Failures
1. Review the flagged content
2. Remove or redact sensitive data
3. Retry the sync

### Merge Conflicts
1. Resolve conflicts manually in the dotfiles repo
2. Commit the resolution
3. Push changes

## Commit Message Guidelines

When auto-generating messages, the script analyzes:
- Modified files by type (commands, skills, scripts)
- Add/modify/delete operations
- Specific file content changes

Manual messages should follow:
- Be descriptive of the change purpose
- Use imperative mood ("Add", "Update", "Fix")
- Keep under 72 characters for the first line

## Integration Notes

- Works with homesick dotfiles repository at `~/.homesick/repos/dotfiles`
- Respects `.gitignore` patterns
- Adds Claude Code co-author attribution to commits
