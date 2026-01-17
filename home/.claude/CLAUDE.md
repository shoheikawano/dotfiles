# Claude Code Context & Productivity Setup

### AI Interaction Philosophy
- **Minimize context window usage**: Prefer targeted, focused approaches to prevent hallucination and maintain accuracy
- **Skill-first approach**: Before starting ANY task, check the Skill tool's available skills list. If a skill's triggers or description matches the current task, invoke it immediately. This keeps the main agent's context window lean by delegating specialized work.
- **Human-in-the-loop approach**: Humans always make the final decision on important choices
- **Suggest alternatives**: When multiple approaches could accomplish the task, present options and let the user choose
- **Suggest future improvements**: Present options to make anything better whenever you find something

## Meta-Information
- Custom skills located in: `~/.claude/skills/`
- **Dynamic skill discovery**: Always check the Skill tool's available skills list to find matching skills by triggers/description

## Mandatory Skill Invocations

### After Modifying Dotfiles
**CRITICAL**: After modifying ANY git-tracked file in the dotfiles repository, invoke the appropriate skill.

**Trigger keywords**: "sync dotfiles", "commit dotfiles", "push changes", "security check", file changes in `~/.claude/` or `~/.homesick/repos/dotfiles/`

### At Session End
**MANDATORY**: At the end of EVERY session, invoke the appropriate skill for session optimization.

**Trigger keywords**: errors, failures, repetitive manual steps, workflow gaps, skill limitations, user frustration

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

## Dotfiles Repository Info

- `~/.homesick/repos/dotfiles/` - Main dotfiles repository
- `~/.claude/` - Symlinked to dotfiles, all changes here are git-tracked

When files in these locations are modified, look up and invoke the appropriate sync skill from the Skill tool's available skills list.

## Key Context for Future Sessions
- Skills should maintain consistency with existing patterns
- Always confirm major changes or new directions with user
- Prioritize practical productivity improvements over theoretical features
- Maintain the balance between automation and user control
- Proactively suggest enhancements while respecting user preferences

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
