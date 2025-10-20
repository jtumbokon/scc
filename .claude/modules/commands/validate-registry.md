---
name: validate-registry
version: 1.0.0
description: Validate dependency graph integrity and agent metadata consistency
type: command
cascade: automatic
category: management
author: Super-Claude System
created: 2025-10-19
dependencies: []
compatibility:
  min_system_version: 1.0.0
  max_system_version: "*"
tags: [command, validation, registry, integrity]
---

# Validate Registry Command

## Overview
Validates the dependency graph for structural integrity, agent metadata consistency, and workflow completeness.

## Usage

```bash
/validate-registry
```

## Command Implementation

```bash
#!/bin/bash

# Validate dependency graph integrity and agent metadata
DEPENDENCY_GRAPH="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/dependency-graph.json"
AGENTS_DIR="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/modules/agents"

if [ ! -f "$DEPENDENCY_GRAPH" ]; then
  echo "❌ Dependency graph not found at $DEPENDENCY_GRAPH"
  exit 1
fi

echo "🔍 Validating Registry:"
echo "======================="
echo ""

VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

# 1. Validate JSON structure
echo "1️⃣ JSON Structure Validation:"
if python3 -c "import json; json.load(open('$DEPENDENCY_GRAPH'))" 2>/dev/null; then
  echo "   ✅ JSON is valid"
else
  echo "   ❌ JSON syntax error"
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# 2. Validate required sections
echo ""
echo "2️⃣ Required Sections Validation:"

REQUIRED_SECTIONS=("modules" "agent_workflows" "status_mappings" "registry_metadata")
for section in "${REQUIRED_SECTIONS[@]}"; do
  if jq -e ".$section" "$DEPENDENCY_GRAPH" >/dev/null; then
    echo "   ✅ $section section exists"
  else
    echo "   ❌ $section section missing"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
  fi
done

# 3. Validate agent metadata
echo ""
echo "3️⃣ Agent Metadata Validation:"

AGENT_COUNT=$(jq '[.modules | to_entries[] | select(.value.type == "agent")] | length' "$DEPENDENCY_GRAPH")
echo "   Found $AGENT_COUNT agents"

AGENT_METADATA_ERRORS=0

jq -r '.modules | to_entries[] | select(.value.type == "agent") | .key' "$DEPENDENCY_GRAPH" | while read agent_name; do
  echo "   Validating: $agent_name"

  # Check required agent_metadata fields
  REQUIRED_FIELDS=("triggered_by_status" "updates_status_to" "description" "output_location" "tools")
  for field in "${REQUIRED_FIELDS[@]}"; do
    if jq -e ".modules[\"$agent_name\"].agent_metadata.$field" "$DEPENDENCY_GRAPH" >/dev/null; then
      echo "     ✅ $field"
    else
      echo "     ❌ Missing $field"
      AGENT_METADATA_ERRORS=$((AGENT_METADATA_ERRORS + 1))
    fi
  done

  # Validate status mappings exist
  TRIGGERED_STATUS=$(jq -r ".modules[\"$agent_name\"].agent_metadata.triggered_by_status" "$DEPENDENCY_GRAPH")
  if jq -e ".status_mappings[\"$TRIGGERED_STATUS\"]" "$DEPENDENCY_GRAPH" >/dev/null; then
    echo "     ✅ Status mapping exists for $TRIGGERED_STATUS"
  else
    echo "     ❌ No status mapping for $TRIGGERED_STATUS"
    AGENT_METADATA_ERRORS=$((AGENT_METADATA_ERRORS + 1))
  fi

  # Validate next agent exists (if specified)
  NEXT_AGENT=$(jq -r ".modules[\"$agent_name\"].agent_metadata.next_agent // \"none\"" "$DEPENDENCY_GRAPH")
  if [ "$NEXT_AGENT" != "none" ] && [ "$NEXT_AGENT" != "null" ]; then
    if jq -e ".modules[\"$NEXT_AGENT\"]" "$DEPENDENCY_GRAPH" >/dev/null; then
      echo "     ✅ Next agent $NEXT_AGENT exists"
    else
      echo "     ❌ Next agent $NEXT_AGENT not found"
      AGENT_METADATA_ERRORS=$((AGENT_METADATA_ERRORS + 1))
    fi
  fi
done

if [ $AGENT_METADATA_ERRORS -eq 0 ]; then
  echo "   ✅ All agent metadata is valid"
else
  echo "   ❌ Found $AGENT_METADATA_ERRORS agent metadata errors"
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + AGENT_METADATA_ERRORS))
fi

# 4. Validate status mappings
echo ""
echo "4️⃣ Status Mapping Validation:"

STATUS_MAPPING_ERRORS=0
jq -r '.status_mappings | keys[]' "$DEPENDENCY_GRAPH" | while read status; do
  mapping=$(jq -r ".status_mappings[\"$status\"]" "$DEPENDENCY_GRAPH")
  agent=$(echo "$mapping" | jq -r '.agent')
  next_status=$(echo "$mapping" | jq -r '.next_status')

  # Check agent exists
  if jq -e ".modules[\"$agent\"]" "$DEPENDENCY_GRAPH" >/dev/null; then
    echo "   ✅ $status → $agent ($next_status)"
  else
    echo "   ❌ $status → $agent (agent not found)"
    STATUS_MAPPING_ERRORS=$((STATUS_MAPPING_ERRORS + 1))
  fi
done

if [ $STATUS_MAPPING_ERRORS -eq 0 ]; then
  echo "   ✅ All status mappings are valid"
else
  echo "   ❌ Found $STATUS_MAPPING_ERRORS status mapping errors"
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + STATUS_MAPPING_ERRORS))
fi

# 5. Validate workflow completeness
echo ""
echo "5️⃣ Workflow Validation:"

WORKFLOW_ERRORS=0
jq -r '.agent_workflows | to_entries[] | .key' "$DEPENDENCY_GRAPH" | while read workflow; do
  echo "   Validating workflow: $workflow"

  # Check if workflow has steps
  step_count=$(jq ".agent_workflows[\"$workflow\"].steps | length" "$DEPENDENCY_GRAPH")
  if [ "$step_count" -gt 0 ]; then
    echo "     ✅ Has $step_count steps"
  else
    echo "     ❌ No steps defined"
    WORKFLOW_ERRORS=$((WORKFLOW_ERRORS + 1))
  fi

  # Validate workflow steps
  jq -r ".agent_workflows[\"$workflow\"].steps[] | .agent" "$DEPENDENCY_GRAPH" | while read workflow_agent; do
    if jq -e ".modules[\"$workflow_agent\"]" "$DEPENDENCY_GRAPH" >/dev/null; then
      echo "     ✅ Agent $workflow_agent exists"
    else
      echo "     ❌ Agent $workflow_agent not found"
      WORKFLOW_ERRORS=$((WORKFLOW_ERRORS + 1))
    fi
  done
done

if [ $WORKFLOW_ERRORS -eq 0 ]; then
  echo "   ✅ All workflows are valid"
else
  echo "   ❌ Found $WORKFLOW_ERRORS workflow errors"
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + WORKFLOW_ERRORS))
fi

# 6. Check for orphaned agents (agents not used in workflows)
echo ""
echo "6️⃣ Orphaned Agent Check:"

USED_AGENTS=$(jq -r '[.agent_workflows[].steps[].agent] | unique[] | .[]' "$DEPENDENCY_GRAPH")
ALL_AGENTS=$(jq -r '[.modules | to_entries[] | select(.value.type == "agent") | .key] | .[]' "$DEPENDENCY_GRAPH")

ORPHANED_COUNT=0
for agent in $ALL_AGENTS; do
  if ! echo "$USED_AGENTS" | grep -q "^$agent$"; then
    echo "   ⚠️ Agent $agent is not used in any workflow"
    ORPHANED_COUNT=$((ORPHANED_COUNT + 1))
    VALIDATION_WARNINGS=$((VALIDATION_WARNINGS + 1))
  fi
done

if [ $ORPHANED_COUNT -eq 0 ]; then
  echo "   ✅ All agents are used in workflows"
else
  echo "   ⚠️ Found $ORPHANED_COUNT orphaned agents"
fi

# 7. Validate file paths
echo ""
echo "7️⃣ File Path Validation:"

PATH_ERRORS=0
jq -r '.modules | to_entries[] | select(.value.type == "agent") | .key' "$DEPENDENCY_GRAPH" | while read agent_name; do
  agent_path=$(jq -r ".modules[\"$agent_name\"].path" "$DEPENDENCY_GRAPH")

  if [ -f "$CLAUDE_PROJECT_DIR/Super-Claude/$agent_path" ]; then
    echo "   ✅ $agent_name: file exists"
  else
    echo "   ❌ $agent_name: file not found at $agent_path"
    PATH_ERRORS=$((PATH_ERRORS + 1))
  fi
done

if [ $PATH_ERRORS -eq 0 ]; then
  echo "   ✅ All agent files exist"
else
  echo "   ❌ Found $PATH_ERRORS missing files"
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + PATH_ERRORS))
fi

# Summary
echo ""
echo "📊 Validation Summary:"
echo "====================="

if [ $VALIDATION_ERRORS -eq 0 ]; then
  echo "✅ Registry validation PASSED"
  echo "   No critical errors found"
else
  echo "❌ Registry validation FAILED"
  echo "   Found $VALIDATION_ERRORS critical errors"
fi

if [ $VALIDATION_WARNINGS -gt 0 ]; then
  echo "⚠️ $VALIDATION_WARNINGS warnings found"
  echo "   Review warnings for optimal performance"
fi

echo ""
echo "📈 Registry Health:"
echo "=================="
echo "Total agents: $AGENT_COUNT"
echo "Total workflows: $(jq '.agent_workflows | length' "$DEPENDENCY_GRAPH')"
echo "Total status mappings: $(jq '.status_mappings | length' "$DEPENDENCY_GRAPH')"
echo "Schema version: $(jq -r '._schema_version' "$DEPENDENCY_GRAPH")"
echo "Last updated: $(jq -r '._last_updated' "$DEPENDENCY_GRAPH')"
echo "Health score: $((100 - VALIDATION_ERRORS * 10 - VALIDATION_WARNINGS * 2))%"

# Exit with appropriate code
if [ $VALIDATION_ERRORS -eq 0 ]; then
  exit 0
else
  exit 1
fi
```

## Output Examples

### Successful Validation
```bash
/validate-registry
```

Output:
```
🔍 Validating Registry:
=======================

1️⃣ JSON Structure Validation:
   ✅ JSON is valid

2️⃣ Required Sections Validation:
   ✅ modules section exists
   ✅ agent_workflows section exists
   ✅ status_mappings section exists
   ✅ registry_metadata section exists

3️⃣ Agent Metadata Validation:
   Found 8 agents
   Validating: pm-spec
     ✅ triggered_by_status
     ✅ updates_status_to
     ✅ description
     ✅ output_location
     ✅ tools
     ✅ Status mapping exists for DRAFT
     ✅ Next agent architect-review exists
   ... (other agents)
   ✅ All agent metadata is valid

📊 Validation Summary:
=====================
✅ Registry validation PASSED
   No critical errors found

📈 Registry Health:
==================
Total agents: 8
Total workflows: 6
Total status mappings: 12
Schema version: 2.0
Last updated: 2025-10-19T20:45:00Z
Health score: 100%
```

### Validation with Errors
```bash
/validate-registry
```

Output:
```
🔍 Validating Registry:
=======================

1️⃣ JSON Structure Validation:
   ✅ JSON is valid

2️⃣ Required Sections Validation:
   ✅ modules section exists
   ✅ agent_workflows section exists
   ❌ status_mappings section missing

📊 Validation Summary:
=====================
❌ Registry validation FAILED
   Found 1 critical errors

📈 Registry Health:
==================
Total agents: 8
Total workflows: 6
Total status mappings: 0
Schema version: 2.0
Last updated: 2025-10-19T20:45:00Z
Health score: 90%
```

## Integration Points

This command validates:

1. **JSON Structure**: Syntax and basic format
2. **Required Sections**: All mandatory top-level sections
3. **Agent Metadata**: Complete and consistent agent information
4. **Status Mappings**: Valid status-to-agent relationships
5. **Workflow Completeness**: Proper workflow definitions
6. **File Existence**: Agent files exist at specified paths
7. **Agent Usage**: All agents are used in workflows

## Related Commands

- `/list-agents` - Show all registered agents
- `/discover-agents` - Find unregistered agents
- `/register-agent` - Register a new agent
- `/update-registry` - Update dependency graph