---
name: discover-agents
version: 1.0.0
description: Scan agent directory and suggest agents to register in dependency graph
type: command
cascade: automatic
category: management
author: Super-Claude System
created: 2025-10-19
dependencies: []
compatibility:
  min_system_version: 1.0.0
  max_system_version: "*"
tags: [command, agent, discovery, management]
---

# Discover Agents Command

## Overview
Scans the agent directory for agent files that are not yet registered in the dependency graph and provides registration suggestions.

## Usage

```bash
/discover-agents
```

## Command Implementation

```bash
#!/bin/bash

# Discover unregistered agents and suggest registration
AGENTS_DIR="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/modules/agents"
DEPENDENCY_GRAPH="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/dependency-graph.json"

if [ ! -d "$AGENTS_DIR" ]; then
  echo "❌ Agents directory not found at $AGENTS_DIR"
  exit 1
fi

if [ ! -f "$DEPENDENCY_GRAPH" ]; then
  echo "❌ Dependency graph not found at $DEPENDENCY_GRAPH"
  exit 1
fi

echo "🔍 Discovering Agents:"
echo "======================="
echo ""

# Get all agent files
ALL_AGENT_FILES=$(find "$AGENTS_DIR" -name "*.md" -o -name "*.json" | sort)

# Get registered agents from dependency graph
REGISTERED_AGENTS=$(jq -r '.modules | to_entries[] | select(.value.type == "agent") | .key' "$DEPENDENCY_GRAPH")

# Find unregistered agents
UNREGISTERED_COUNT=0
for agent_file in $ALL_AGENT_FILES; do
  agent_name=$(basename "$agent_file" | sed 's/\.[^.]*$//')

  if ! echo "$REGISTERED_AGENTS" | grep -q "^$agent_name$"; then
    echo "📄 Unregistered Agent: $agent_name"
    echo "   📍 File: $agent_file"

    # Analyze the agent file for metadata suggestions
    if [[ "$agent_file" == *.md ]]; then
      # Extract frontmatter from markdown file
      if grep -q "^triggered_by_hook:" "$agent_file"; then
        TRIGGERED_BY=$(grep "^triggered_by_hook:" "$agent_file" | cut -d':' -f2- | xargs)
        echo "   🎯 Trigger: $TRIGGERED_BY"
      fi

      if grep -q "^updates_queue_status:" "$agent_file"; then
        UPDATES_TO=$(grep "^updates_queue_status:" "$agent_file" | cut -d':' -f2- | xargs)
        echo "   📈 Updates to: $UPDATES_TO"
      fi

      if grep -q "^next_agent_via_hook:" "$agent_file"; then
        NEXT_AGENT=$(grep "^next_agent_via_hook:" "$agent_file" | cut -d':' -f2- | xargs)
        echo "   🔄 Next agent: $NEXT_AGENT"
      fi

      if grep -q "^description:" "$agent_file"; then
        DESCRIPTION=$(grep "^description:" "$agent_file" | cut -d':' -f2- | xargs)
        echo "   📝 Description: $DESCRIPTION"
      fi
    fi

    echo ""
    UNREGISTERED_COUNT=$((UNREGISTERED_COUNT + 1))
  fi
done

echo ""
echo "📊 Discovery Summary:"
echo "===================="

if [ $UNREGISTERED_COUNT -eq 0 ]; then
  echo "✅ All agents are registered!"
else
  echo "🔢 Found $UNREGISTERED_COUNT unregistered agents"
  echo ""
  echo "💡 Registration Tips:"
  echo "==================="
  echo ""
  echo "To register an agent, add it to dependency-graph.json:"
  echo ""
  echo '```json'
  echo '{'
  echo '  "modules": {'
  echo '    "'"$agent_name"'": {'
  echo '      "id": "agent-XXX",'
  echo '      "type": "agent",'
  echo '      "version": "1.0.0",'
  echo '      "path": ".claude/modules/agents/'"$agent_name"'.md",'
  echo '      "hash": "calculated-hash",'
  echo '      "parents": ["CLAUDE.md"],'
  echo '      "agent_metadata": {'
  echo '        "triggered_by_status": "STATUS",'
  echo '        "updates_status_to": "NEXT_STATUS",'
  echo '        "next_agent": "next-agent",'
  echo '        "queue_field": "field_name",'
  echo '        "output_location": "output/path",'
  echo '        "tools": ["list", "of", "tools"],'
  echo '        "human_review_required": true,'
  echo '        "description": "Agent description"'
  echo '      }'
  echo '    }'
  echo '  }'
  echo '}'
  echo '```'
  echo ""
  echo "Or use the /register-agent command:"
  echo "/register-agent $agent_name"
fi

echo ""
echo "📋 Registry Status:"
echo "=================="

TOTAL_FILES=$(echo "$ALL_AGENT_FILES" | wc -l)
REGISTERED_COUNT=$(echo "$REGISTERED_AGENTS" | wc -l)

echo "Total agent files: $TOTAL_FILES"
echo "Registered agents: $REGISTERED_COUNT"
echo "Unregistered agents: $UNREGISTERED_COUNT"

echo ""
echo "🔄 Workflow Status:"
echo "=================="

# Check for common workflow patterns
DRAFT_AGENTS=$(jq -r '.modules | to_entries[] | select(.value.type == "agent" and .value.agent_metadata.triggered_by_status == "DRAFT") | .key' "$DEPENDENCY_GRAPH")
READY_FOR_ARCH_AGENTS=$(jq -r '.modules | to_entries[] | select(.value.type == "agent" and .value.agent_metadata.triggered_by_status == "READY_FOR_ARCH") | .key' "$DEPENDENCY_GRAPH")
READY_FOR_BUILD_AGENTS=$(jq -r '.modules | to_entries[] | select(.value.type == "agent" and .value.agent_metadata.triggered_by_status == "READY_FOR_BUILD") | .key' "$DEPENDENCY_GRAPH")

echo "DRAFT handlers: $(echo "$DRAFT_AGENTS" | wc -l) ($(echo "$DRAFT_AGENTS" | tr '\n' ' '))"
echo "READY_FOR_ARCH handlers: $(echo "$READY_FOR_ARCH_AGENTS" | wc -l) ($(echo "$READY_FOR_ARCH_AGENTS" | tr '\n' ' '))"
echo "READY_FOR_BUILD handlers: $(echo "$READY_FOR_BUILD_AGENTS" | wc -l) ($(echo "$READY_FOR_BUILD_AGENTS" | tr '\n' ' '))"
```

## Examples

### All Agents Registered
```bash
/discover-agents
```

Output:
```
🔍 Discovering Agents:
=======================

✅ All agents are registered!

📊 Discovery Summary:
====================
🔢 Found 0 unregistered agents

📋 Registry Status:
==================
Total agent files: 8
Registered agents: 8
Unregistered agents: 0
```

### Unregistered Agents Found
```bash
/discover-agents
```

Output:
```
🔍 Discovering Agents:
=======================

📄 Unregistered Agent: security-auditor
   📍 File: /path/to/.claude/modules/agents/security-auditor.md
   🎯 Trigger: READY_FOR_SECURITY_AUDIT
   📈 Updates to: SECURITY_APPROVED
   🔄 Next agent: implementer-tester
   📝 Description: Security specialist that audits designs for vulnerabilities

📊 Discovery Summary:
====================
🔢 Found 1 unregistered agents

💡 Registration Tips:
===================[registration instructions]
```

## Integration with Registry System

This command helps you:

1. **Maintain Registry Consistency**: Ensure all agents are properly registered
2. **Discover New Agents**: Find agents that need registration
3. **Validate Agent Metadata**: Check if agents have proper frontmatter
4. **Monitor Agent Growth**: Track agent ecosystem expansion
5. **Debug Agent Issues**: Identify registration problems

## Related Commands

- `/list-agents` - Show all registered agents
- `/validate-registry` - Validate dependency graph integrity
- `/register-agent` - Register a specific agent
- `/update-registry` - Update dependency graph with changes