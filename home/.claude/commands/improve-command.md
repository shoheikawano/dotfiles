---
allowed-tools: Read, Write, Edit, Bash, TodoWrite
description: Analyze session usage patterns and improve existing slash commands based on user feedback and workflow gaps
---

## Your task

Analyze the current session's message history to identify opportunities for improving existing slash commands. You should:

1. **Review Session Context**:
   - Examine what the user has asked for in this session
   - Identify any manual steps or repetitive tasks
   - Note workflow gaps or inefficiencies mentioned
   - Look for requests that existing commands don't handle well

2. **Analyze Existing Commands**:
   - Read relevant command files from `~/.claude/commands/`
   - Identify which commands could be enhanced
   - Compare current command capabilities with user needs

3. **Identify Improvement Opportunities**:
   - Missing integrations or tool usage
   - Workflow steps that could be automated
   - User prompts that could be improved
   - Additional allowed-tools that would be helpful
   - Better error handling or edge cases

4. **Generate Enhancement Recommendations**:
   - Specific changes to make commands more effective
   - New features or capabilities to add
   - Better integration patterns
   - Improved user experience suggestions

5. **Propose Updates**:
   - Show before/after comparisons of command definitions
   - Explain the rationale for each improvement
   - Confirm changes with user before implementing
   - Update the relevant command file(s)

## Key Focus Areas

- **Workflow Efficiency**: Reduce manual steps and repetitive tasks
- **Integration Gaps**: Better use of MCP tools and external services  
- **User Experience**: More intuitive prompts and interactions
- **Error Handling**: Better handling of edge cases and failures
- **Tool Utilization**: Leveraging available tools more effectively

## Process

1. Ask user which command(s) they want to improve based on recent usage
2. Analyze the current command definition and user feedback
3. Propose specific enhancements with clear rationale
4. Show before/after comparison of the command
5. Get user approval before implementing changes
6. Update the command file with improvements
7. Suggest testing the improved command

**Focus on practical improvements that will genuinely boost productivity based on real usage patterns.**
