---
name: list-agents
version: 1.0.0
description: List all registered agents from dependency graph with their metadata
type: command
cascade: automatic
category: management
author: Super-Claude System
created: 2025-10-19
dependencies: []
compatibility:
  min_system_version: 1.0.0
  max_system_version: "*"
tags: [command, agent, management, discovery]
---

# List Agents Command

## Overview
Lists all registered agents from the dependency graph with their metadata, workflow mappings, and status triggers.

## Usage

```bash
/list-agents
```

## Command Implementation

```bash
#!/bin/bash

# List all registered agents from dependency graph
DEPENDENCY_GRAPH="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/dependency-graph.json"

if [ ! -f "$DEPENDENCY_GRAPH" ]; then
  echo "❌ Dependency graph not found at $DEPENDENCY_GRAPH"
  exit 1
fi

echo "🤖 Registered Agents:"
echo "===================="
echo ""

# List agents with their metadata
jq -r '
  .modules
  | to_entries[]
  | select(.value.type == "agent")
  | "**\(.key)** (v\(.value.version))
   📝 Description: \(.value.agent_metadata.description)
   🎯 Triggered by: \(.value.agent_metadata.triggered_by_status)
   📈 Updates to: \(.value.agent_metadata.updates_status_to)
   🔄 Next agent: \(.value.agent_metadata.next_agent // "none")
   📁 Output location: \(.value.agent_metadata.output_location)
   🛠️ Tools: \(.value.agent_metadata.tools | join(", "))
   👤 Human review: \(.value.agent_metadata.human_review_required // "false")
   "
' "$DEPENDENCY_GRAPH"

echo ""
echo "📊 Registry Summary:"
echo "=================="

TOTAL_AGENTS=$(jq '[.modules | to_entries[] | select(.value.type == "agent")] | length' "$DEPENDENCY_GRAPH")
TOTAL_WORKFLOWS=$(jq '.agent_workflows | length' "$DEPENDENCY_GRAPH")
TOTAL_STATUSES=$(jq '.status_mappings | length' "$DEPENDENCY_GRAPH")
SCHEMA_VERSION=$(jq -r '._schema_version' "$DEPENDENCY_GRAPH")
LAST_UPDATED=$(jq -r '._last_updated' "$DEPENDENCY_GRAPH")

echo "Total agents: $TOTAL_AGENTS"
echo "Total workflows: $TOTAL_WORKLOWS"
echo "Supported statuses: $TOTAL_STATUSES"
echo "Schema version: $SCHEMA_VERSION"
echo "Last updated: $LAST_UPDATED"

echo ""
echo "🔄 Available Workflows:"
echo "======================"

jq -r '
  .agent_workflows
  | to_entries[]
  | "**\(.key)**"
  | "   📝 \(.value.name): \(.value.description)"
  | "   ⚡ Steps: \(.value.steps | length)"
  | ""
' "$DEPENDENCY_GRAPH"
```

## Output Format

The command provides:

1. **Agent List**: All registered agents with full metadata
2. **Registry Summary**: Statistics about the agent ecosystem
3. **Workflow Overview**: Available workflow templates
4. **Status Mappings**: All supported status transitions

## Examples

### Basic Agent Listing
```bash
/list-agents
```

Output:
```
🤖 Registered Agents:
====================

**pm-spec** (v1.0.0)
 📝 Description: Product manager that creates specifications from requirements using research patterns
 🎯 Triggered by: DRAFT
 📈 Updates to: READY_FOR_ARCH
 🔄 Next agent: architect-review
 📁 Output location: docs/claude/working-notes/[slug].md
 🛠️ Tools: Read, Grep, Glob, Edit, Write, mcp__archon-http__rag_search_knowledge_base, mcp__archon-http__rag_search_code_examples
 👤 Human review: true

**architect-review** (v1.0.0)
 📝 Description: Architect that validates designs and creates Architecture Decision Records (ADRs)
 🎯 Triggered by: READY_FOR_ARCH
 📈 Updates to: READY_FOR_BUILD
 🔄 Next agent: implementer-tester
 📁 Output location: docs/claude/decisions/ADR-[slug].md
 🛠️ Tools: Read, Grep, Glob, Edit, Write, mcp__archon-http__rag_search_knowledge_base, mcp__archon-http__rag_search_code_examples
 👤 Human review: true

... (more agents)
```

### Registry Statistics
```bash
Total agents: 8
Total workflows: 6
Supported statuses: 12
Schema version: 2.0
Last updated: 2025-10-19T20:45:00Z
```

## Integration with Hook System

This command helps you:

1. **Discover Available Agents**: See all agents the system can suggest
2. **Understand Workflows**: Know which agents handle which statuses
3. **Validate Registry**: Check if agents are properly registered
4. **Plan Development**: Choose appropriate agents for your needs
5. **Debug Issues**: Identify missing agents or status mappings

## Related Commands

- `/list-workflows` - Show detailed workflow information
- `/validate-registry` - Validate dependency graph integrity
- `/discover-agents` - Scan directory for unregistered agents