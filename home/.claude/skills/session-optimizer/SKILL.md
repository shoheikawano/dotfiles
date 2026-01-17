---
name: session-optimizer
description: |
  Analyze session usage patterns and improve existing skills based on user feedback and workflow gaps.
  Use when: (1) Errors or failures occur during task execution, (2) Workflow inefficiencies are detected,
  (3) Manual repetitive steps are identified, (4) Skill limitations are encountered,
  (5) User expresses frustration with current processes.
  Triggers: "error", "failed", "issue", "problem", "doesn't work", "not working",
  "repetitive", "manual steps", "workflow gap", "inefficient", "frustrating",
  "skill limitation", "improve skill", "enhance workflow".
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

Analyze session patterns and optimize workflows by improving skills and processes.

## Auto-Trigger Conditions

This skill activates when detecting:
- **Errors/Failures**: Task failures, skill errors, unexpected behavior
- **Inefficiencies**: Repetitive manual steps, workflow gaps
- **Limitations**: Skills that don't handle edge cases well
- **Frustration signals**: User expressing difficulty with current processes

## Proactive Session Activity Detection

Monitor session activity for optimization opportunities:

### Activity Indicators
- Multiple similar tasks performed in succession
- Repeated error patterns requiring manual intervention
- Long sequences of manual steps that could be automated
- User corrections or retries on similar operations

### Detection Heuristics
- Track task types and frequencies within session
- Identify patterns across multiple sessions
- Flag when automation could reduce manual effort
- Suggest skill improvements based on observed pain points

## Analysis Process

```
Session Issue Detected
├─ Error/Failure
│  ├─ Identify root cause
│  ├─ Check if existing skill could handle this
│  └─ Propose skill enhancement or new skill
├─ Repetitive Task
│  ├─ Count occurrences in session
│  ├─ Identify automation opportunity
│  └─ Propose new skill or enhancement
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
5. **Implement**: Update skills/CLAUDE.md
6. **Sync**: Use dotfiles-syncer skill to sync changes

## Key Focus Areas

| Area | What to Look For |
|------|------------------|
| Error Handling | Missing edge cases, better recovery |
| Tool Utilization | Underused tools, better integrations |
| Workflow Efficiency | Manual steps that could be automated |
| User Experience | Confusing prompts, missing feedback |

## Output Actions

After analysis, propose one or more:

- **Skill Enhancement**: Update existing skill in `~/.claude/skills/`
- **New Skill**: Create skill in `~/.claude/skills/` for domain expertise
- **CLAUDE.md Update**: Add patterns/context for future sessions

## Implementation Checklist

- [ ] Read relevant skill files
- [ ] Analyze session context for patterns
- [ ] Show before/after comparison
- [ ] Get user approval
- [ ] Implement changes
- [ ] Sync dotfiles: invoke `dotfiles-syncer` skill or run `~/.claude/skills/dotfiles-syncer/scripts/check-and-sync.sh`
