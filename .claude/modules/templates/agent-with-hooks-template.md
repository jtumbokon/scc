---
name: agent-template
description: [ACTION-ORIENTED] Use PROACTIVELY when [condition]
tools: [TOOLS INCLUDING MCP]
model: [sonnet|opus|haiku]

# 🔗 HOOK INTEGRATION
triggered_by_hook: "[Which hook/status triggers this agent]"
updates_queue_status: "[Status this agent sets when done]"
next_agent_via_hook: "[Which agent hook will suggest next]"
queue_file: "Super-Claude/enhancements/_queue.json"
output_location: "[Where this agent saves its work]"
---

# Agent Template

## Overview
[Provide a brief description of what this agent specializes in and its primary function]

## When Invoked

When invoked:
1. [First action - gather context]
2. Read queue file: `jq '.[] | select(.slug == "[slug]")' Super-Claude/enhancements/_queue.json`
3. Find your assigned task by slug
4. [Begin main task]

## Core Methodology

[Task] process:
- [Step 1]
- [Step 2]
- [Step 3]

Reference hierarchy rules:
- `Super-Claude/.claude/modules/rules/[relevant-rules].md`

Use hierarchy templates:
- `Super-Claude/.claude/modules/templates/[relevant-templates].md`

## Output Format

For each task, produce:
- [Output 1 - main deliverable]
- [Output 2 - supporting docs]
- [Output 3 - test results if applicable]

Save deliverables to: `[specified location]`

## Constraints & Rules

Requirements:
- **MUST** update queue file with new status
- **MUST** save work to specified location
- **MUST** set `assigned_agent` to next agent in queue
- **NEVER** [prohibited actions]
- **ALWAYS** [required actions]

## MCP Tool Usage

MCP Tools available:
- `[mcp_tool]`: [when to use]
- `[mcp_tool]`: [when to use]

## Verification Checklist

Before completing:
- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]
- [ ] Queue file updated with correct status
- [ ] assigned_agent field updated
- [ ] Deliverables saved to correct location

## 🔗 Queue File Integration (CRITICAL SECTION)

**Queue File Location**: `Super-Claude/enhancements/_queue.json`

**Your Task Identification**:
```bash
# Read queue to find your task
SLUG="[slug]"
TASK=$(jq ".[] | select(.slug == \"$SLUG\")" Super-Claude/enhancements/_queue.json)
```

**Update Queue on Completion**:
```bash
# Update status and hand off to next agent
jq "(.[] | select(.slug == \"$SLUG\")) |= {
  status: \"[NEW_STATUS]\",
  updated: \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  assigned_agent: \"[NEXT_AGENT]\",
  [your_output_field]: \"[path_to_your_deliverable]\"
}" Super-Claude/enhancements/_queue.json > temp.json
mv temp.json Super-Claude/enhancements/_queue.json
```

**Status Values You Work With**:
- Input status: `[STATUS_THAT_TRIGGERS_YOU]`
- Output status: `[STATUS_YOU_SET_WHEN_DONE]`

**Next Agent**:
After you set status to `[NEW_STATUS]`, the `SubagentStop` hook will automatically suggest the `[next-agent]` agent to the parent context.

**You don't need to manually suggest the next agent** - the hook handles workflow orchestration.

## Handoff & Status Management

After completion:

1. **Update Queue File**:
```bash
jq "(.[] | select(.slug == \"$SLUG\")) |= {
  status: \"[NEW_STATUS]\",
  updated: \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  assigned_agent: \"[NEXT_AGENT]\",
  [your_output_field]: \"[path_to_your_deliverable]\"
}" Super-Claude/enhancements/_queue.json > temp.json && mv temp.json Super-Claude/enhancements/_queue.json
```

2. **Save Your Deliverables**:
- Main output: `[path]`
- Supporting docs: `[path]`

3. **Summary for Human**:
Provide a brief summary of:
- What you completed
- Where you saved it
- What the next agent will do
- Any issues or blockers

**The SubagentStop hook will automatically**:
- Read the queue file
- See your status update
- Suggest the next agent
- Provide instructions to parent

---

## Integration Notes

**Triggered By**:
- Hook: `SubagentStop`
- When queue status: `[TRIGGER_STATUS]`
- Via: Hook reads queue and suggests this agent

**Updates Queue To**: `[NEW_STATUS]`

**Next Agent**: `[next-agent]` (triggered via SubagentStop hook)

**Workflow Position**:
`[previous-agent]` → **YOU** → `[next-agent]`

**Human-in-Loop Point**:
[Describe when human should review before proceeding]

## Template Customization Guide

### Required Fields to Customize

**Frontmatter:**
- `name`: Unique agent identifier
- `description`: Action-oriented description of when to use
- `tools`: List of available tools (including MCP tools)
- `model`: Which Claude model to use

**Hook Integration:**
- `triggered_by_hook`: Which status triggers this agent
- `updates_queue_status`: What status this agent sets
- `next_agent_via_hook`: Which agent comes next
- `queue_file`: Path to queue file
- `output_location`: Where to save deliverables

### Workflow Status Mapping

Common status flows:
```
DRAFT → READY_FOR_ARCH → READY_FOR_BUILD → DONE
       ↓               ↓               ↓
    pm-spec        architect-review  implementer-tester
```

### Agent Specialization Examples

**PM Spec Agent**:
- triggered_by_hook: "Manual invocation or DRAFT"
- updates_queue_status: "READY_FOR_ARCH"
- next_agent_via_hook: "architect-review"

**Architect Agent**:
- triggered_by_hook: "READY_FOR_ARCH"
- updates_queue_status: "READY_FOR_BUILD"
- next_agent_via_hook: "implementer-tester"

**Implementer Agent**:
- triggered_by_hook: "READY_FOR_BUILD"
- updates_queue_status: "DONE"
- next_agent_via_hook: "none (workflow complete)"

## Testing Your Agent

1. **Manual Test**: Invoke agent with a test slug
2. **Queue Update**: Verify queue file is updated correctly
3. **Hook Trigger**: Verify SubagentStop hook fires
4. **Next Agent**: Verify hook suggests correct next agent
5. **End-to-End**: Test complete workflow if possible

## Best Practices

- **Clear Status Definitions**: Define exactly what each status means
- **Comprehensive Documentation**: Include examples and edge cases
- **Error Handling**: Define what to do when tasks fail
- **Quality Gates**: Include verification checklists
- **Tool Integration**: Leverage MCP tools effectively
- **Security**: Follow security best practices
- **Performance**: Consider performance implications