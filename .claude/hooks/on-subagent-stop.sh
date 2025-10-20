#!/bin/bash
set -euo pipefail

# ============================================================================
# 🔥 CRITICAL: SubagentStop Hook - Dynamic Agent Orchestration
# ============================================================================
# This hook automatically chains agents together by reading the queue
# and suggesting the next agent based on dynamic registry lookup.
#
# Revolutionary Features:
# ✅ Dynamic agent discovery from dependency graph
# ✅ No hardcoded agent names - infinite scalability
# ✅ Automatic workflow progression
# ✅ Status-based agent routing
# ============================================================================

# Read JSON input from Claude Code
INPUT=$(cat)

# Prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // "false"')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# File paths
QUEUE_FILE="$CLAUDE_PROJECT_DIR/Super-Claude/enhancements/_queue.json"
DEPENDENCY_GRAPH="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/dependency-graph.json"

# Check files exist
if [ ! -f "$QUEUE_FILE" ]; then
  exit 0
fi

if [ ! -f "$DEPENDENCY_GRAPH" ]; then
  echo "⚠️ Dependency graph not found" >&2
  exit 0
fi

# Find next item in queue with READY_FOR_* status
NEXT_ITEM=$(jq -r '
  .[]
  | select(.status | startswith("READY_FOR_"))
  | "\(.status)|\(.slug)|\(.title // "Untitled")"
' "$QUEUE_FILE" | head -1)

if [ -z "$NEXT_ITEM" ]; then
  exit 0
fi

# Parse item
IFS='|' read -r STATUS SLUG TITLE <<< "$NEXT_ITEM"

# Dynamic agent lookup from dependency graph
AGENT_INFO=$(jq -r --arg status "$STATUS" '
  .modules
  | to_entries[]
  | select(.value.type == "agent" and
           .value.agent_metadata.triggered_by_status == $status)
  | "\(.key)|\(.value.agent_metadata.description)|\(.value.agent_metadata.output_location)"
' "$DEPENDENCY_GRAPH" | head -1)

if [ -z "$AGENT_INFO" ]; then
  echo "⚠️ No agent found for status: $STATUS" >&2
  exit 0
fi

# Parse agent info
IFS='|' read -r AGENT_NAME AGENT_DESC OUTPUT_LOC <<< "$AGENT_INFO"

# Build suggestion message
MESSAGE="✅ Task ready: '$TITLE' (slug: $SLUG)
Status: $STATUS

🤖 Next step: Use the $AGENT_NAME subagent on '$SLUG'

This agent will:
- $AGENT_DESC
- Save output to: $OUTPUT_LOC

The agent will update the queue status when complete."

# Output using decision: block technique
cat <<EOF
{
  "decision": "block",
  "reason": "$MESSAGE"
}
EOF

exit 0