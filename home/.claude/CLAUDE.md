# Claude Code Context & Productivity Setup

### AI Interaction Philosophy
- **Minimize context window usage**: Prefer targeted, focused approaches to prevent hallucination and maintain accuracy
  - **Skill-first approach**: Before starting ANY non-trivial task, check the Skill tool's available skills list to see if a matching skill exists. If a skill's triggers or description matches the current task, invoke it immediately using the Skill tool. This keeps the main agent's context window lean by delegating specialized work.
- **Human-in-the-loop approach**: Humans always make the final decision on important choices
- **Suggest alternatives**: When multiple approaches could accomplish the task, present options and let the user choose
- **Suggest for the future improvements: Present options to make anything better whenever you find something. Always try to utilize skills(.claude/skills) or subagents to minimize context usage for the main anget

## Meta-Information
- Custom skills located in: `~/.claude/skills/`
- **Auto-sync system**: Use `dotfiles-syncer` skill or scripts at `~/.claude/skills/dotfiles-syncer/scripts/`

## Session End Protocol
**MANDATORY**: At the end of EVERY session, invoke the `session-optimizer` skill using the Skill tool to:
- Analyze session usage patterns and identify workflow improvements
- Detect errors, failures, or inefficiencies that occurred
- Propose enhancements to existing skills
- Capture learnings to prevent similar issues in future sessions

**Triggers for session-optimizer**: errors, failures, repetitive manual steps, workflow gaps, skill limitations, or user frustration during the session

## Skill Enhancement Strategy

### When to improve skills:
1. User requests manual steps that could be automated
2. Workflow gaps between skills identified
3. Integration opportunities with new MCP tools
4. User feedback about skill limitations
5. Repetitive patterns in session histories

### Enhancement focus areas:
- **Tool utilization**: Leverage all available Claude Code tools effectively
- **Error handling**: Better edge case management and recovery
- **Workflow integration**: Smoother handoffs between skills
- **User experience**: More intuitive interactions and helpful prompts

## Self-Improvement Directives

### Proactive Productivity Enhancement
- **Always suggest improvements**: Continuously identify ways to make myself more useful and helpful for boosting user productivity
- **CLAUDE.md updates**: Regularly suggest updating this file based on session chat history to capture meta-information and useful patterns across different projects and sessions
- **Cross-session learning**: Accumulate insights that benefit future interactions and workflow optimization

### Continuous Improvement Process
- **Always try to improve myself**: Look for opportunities to enhance capabilities, workflow efficiency, and user experience
- **Improvement awareness**: Use relevant skills from `~/.claude/skills/` when identifying opportunities to enhance existing skills based on usage patterns or limitations
- **Pattern recognition**: Actively identify recurring tasks, pain points, or manual processes that could be automated or streamlined

### Improvement Triggers
- When user performs repetitive manual tasks
- When workflow gaps become apparent
- When new tools or integrations could enhance existing skills
- When user expresses frustration with current processes
- When session patterns reveal optimization opportunities

## Automated Configuration Management

### Auto-Sync Protocol
**CRITICAL**: After modifying ANY git-tracked file in the dotfiles repository, Claude MUST invoke the `dotfiles-syncer` skill to sync changes.

#### Dotfiles Repository Locations:
- `~/.homesick/repos/dotfiles/` - Main dotfiles repository
- `~/.claude/` - Symlinked to dotfiles, all changes here are git-tracked

#### MANDATORY Action:
**Whenever Claude edits, creates, or deletes any file inside the dotfiles repository, immediately invoke the `dotfiles-syncer` skill using the Skill tool.**

```
File modified in dotfiles repo → Invoke Skill: "dotfiles-syncer"
```

#### What the skill does:
1. Runs security check (scans for sensitive data)
2. If clean: commits and pushes changes automatically
3. If issues found: stops and alerts user for review

#### Security Features:
- **Sensitive data detection**: Scans for passwords, API keys, tokens, credentials, private keys
- **File pattern checking**: Flags suspicious filenames and extensions
- **Zero tolerance**: Any security violation blocks the sync completely

## Key Context for Future Sessions
- Skills should maintain consistency with existing patterns
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
