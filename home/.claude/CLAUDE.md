# Claude Code Context & Productivity Setup

### AI Interaction Philosophy
- **Minimize context window usage**: Prefer targeted, focused approaches to prevent hallucination and maintain accuracy
  - **Always use agent skills**: Leverage specialized agents in `~/.claude/skills` whenever necessary to delegate tasks and reduce context usage
- **Human-in-the-loop approach**: Humans always make the final decision on important choices
- **Suggest alternatives**: When multiple approaches could accomplish the task, present options and let the user choose
- **Suggest for the future improvements: Present options to make anything better whenever you find something. Always try to utilize skills(.claude/skills) or subagents to minimize context usage for the main anget

## Meta-Information
- Custom slash commands located in: `~/.claude/commands/`
- Custom skills located in: `~/.claude/skills/`
- **Auto-sync system**: Automatically sync dotfiles repository (homesick) changes using `~/.claude/scripts/auto-sync-dotfiles.sh`

## Session End Protocol
- **If errors or issues occurred during the session**: Before ending, ask the user if they want to run the `session-optimizer` skill to analyze what went wrong and propose improvements to commands, skills, or workflows
- This helps capture learnings and prevent similar issues in future sessions

## Command Enhancement Strategy

### When to improve commands:
1. User requests manual steps that could be automated
2. Workflow gaps between commands identified
3. Integration opportunities with new MCP tools
4. User feedback about command limitations
5. Repetitive patterns in session histories

### Enhancement focus areas:
- **Tool utilization**: Leverage all available Claude Code tools effectively
- **Error handling**: Better edge case management and recovery
- **Workflow integration**: Smoother handoffs between commands
- **User experience**: More intuitive interactions and helpful prompts

## Self-Improvement Directives

### Proactive Productivity Enhancement
- **Always suggest improvements**: Continuously identify ways to make myself more useful and helpful for boosting user productivity
- **CLAUDE.md updates**: Regularly suggest updating this file based on session chat history to capture meta-information and useful patterns across different projects and sessions
- **Cross-session learning**: Accumulate insights that benefit future interactions and workflow optimization

### Continuous Improvement Process
- **Always try to improve myself**: Look for opportunities to enhance capabilities, workflow efficiency, and user experience
- **Improvement awareness**: Use the `session-optimizer` skill when identifying opportunities to enhance existing commands or skills based on usage patterns or limitations
- **Pattern recognition**: Actively identify recurring tasks, pain points, or manual processes that could be automated or streamlined

### Improvement Triggers
- When user performs repetitive manual tasks
- When workflow gaps become apparent
- When new tools or integrations could enhance existing commands
- When user expresses frustration with current processes
- When session patterns reveal optimization opportunities

## Automated Configuration Management

### Auto-Sync Protocol
**CRITICAL**: After making ANY changes to dotfiles repository (including ~/.claude), Claude MUST run security checks and sync if clean.

#### Required Actions:
1. **Security-first workflow**: Always run security check before syncing dotfiles changes
2. **Automated sync**: If security check passes, automatically sync dotfiles repository
3. **Manual intervention**: If security check fails, stop and request user review
4. **Health checks**: Verifies repository integrity before and after sync operations
5. **Error handling**: Comprehensive error detection and recovery for complex scenarios

#### Implementation Pattern:
```bash
# Security check first, then sync if clean:
~/.claude/scripts/security-check.sh && ~/.claude/scripts/auto-sync-dotfiles.sh "Descriptive commit message"

# For slash command operations:
/sync-dotfiles  # (this includes security checks)

# Manual security check only:
~/.claude/scripts/security-check.sh
```

#### Security Features:
- **Mandatory security check**: All dotfiles changes MUST pass security scan before sync
- **Sensitive data detection**: Scans for passwords, API keys, tokens, credentials, private keys
- **File pattern checking**: Flags suspicious filenames and extensions
- **Zero tolerance**: Any security violation blocks the sync completely
- **Manual override**: User must manually review and clean sensitive data before retry

### Automation Triggers:
- New command creation in `~/.claude/commands/`
- Updates to existing commands or configurations
- Changes to agent configurations in `~/.claude/agents/`
- Modifications to this CLAUDE.md file
- Any script additions in `~/.claude/scripts/`
- **ANY changes to files tracked by homesick dotfiles repository**

## Key Context for Future Sessions
- Commands should maintain consistency with existing patterns
- Always confirm major changes or new directions with user
- Prioritize practical productivity improvements over theoretical features
- Maintain the balance between automation and user control
- Proactively suggest enhancements while respecting user preferences
- **ALWAYS sync dotfiles changes**: Never leave configuration changes uncommitted

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
