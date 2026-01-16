---
name: session-optimizer
description: |
  Analyze session usage patterns and improve existing slash commands based on user feedback and workflow gaps.
  Use when: (1) Errors or failures occur during task execution, (2) Workflow inefficiencies are detected,
  (3) Manual repetitive steps are identified, (4) Command limitations are encountered,
  (5) User expresses frustration with current processes.
  Triggers: "error", "failed", "issue", "problem", "doesn't work", "not working",
  "repetitive", "manual steps", "workflow gap", "inefficient", "frustrating",
  "command limitation", "improve command", "enhance workflow".
context: fork
agent: general-purpose
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - TodoWrite
---

# Session Optimizer

Analyze session patterns and optimize workflows by improving commands, skills, and processes.

## Auto-Trigger Conditions

This skill activates when detecting:
- **Errors/Failures**: Task failures, command errors, unexpected behavior
- **Inefficiencies**: Repetitive manual steps, workflow gaps
- **Limitations**: Commands that don't handle edge cases well
- **Frustration signals**: User expressing difficulty with current processes

## Analysis Process

```
Session Issue Detected
├─ Error/Failure
│  ├─ Identify root cause
│  ├─ Check if existing command could handle this
│  └─ Propose command enhancement or new skill
├─ Repetitive Task
│  ├─ Count occurrences in session
│  ├─ Identify automation opportunity
│  └─ Propose new command or skill
└─ Workflow Gap
   ├─ Map current vs ideal workflow
   ├─ Identify missing integration
   └─ Propose enhancement
```

## Improvement Workflow

1. **Detect**: Identify the issue or inefficiency
2. **Analyze**: Understand the root cause and context
3. **Propose**: Suggest specific improvements with rationale
4. **Confirm**: Get user approval before changes
5. **Implement**: Update commands/skills/CLAUDE.md
6. **Sync**: Auto-sync dotfiles after changes

## Key Focus Areas

| Area | What to Look For |
|------|------------------|
| Error Handling | Missing edge cases, better recovery |
| Tool Utilization | Underused tools, better integrations |
| Workflow Efficiency | Manual steps that could be automated |
| User Experience | Confusing prompts, missing feedback |

## Output Actions

After analysis, propose one or more:

- **Command Enhancement**: Update existing command in `~/.claude/commands/`
- **New Skill**: Create skill in `~/.claude/skills/` for domain expertise
- **CLAUDE.md Update**: Add patterns/context for future sessions
- **New Command**: Create command for task-oriented workflows

## Implementation Checklist

- [ ] Read relevant command/skill files
- [ ] Analyze session context for patterns
- [ ] Show before/after comparison
- [ ] Get user approval
- [ ] Implement changes
- [ ] Run security check and sync: `~/.claude/scripts/security-check.sh && ~/.claude/scripts/auto-sync-dotfiles.sh "message"`
