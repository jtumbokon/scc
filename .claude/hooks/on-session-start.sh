#!/bin/bash

# ============================================================================
# SessionStart Hook - Load Project Context
# ============================================================================
# Runs when Claude Code session starts.
# Loads queue status, recent changes, and working notes.
# ============================================================================

set -euo pipefail

# Read JSON input
INPUT=$(cat)

# Build context message
CONTEXT=""

# 1. Load queue status
QUEUE_FILE="$CLAUDE_PROJECT_DIR/Super-Claude/enhancements/_queue.json"
if [ -f "$QUEUE_FILE" ]; then
  QUEUE_COUNT=$(jq 'length' "$QUEUE_FILE" 2>/dev/null || echo "0")
  READY_COUNT=$(jq '[.[] | select(.status | startswith("READY_FOR_"))] | length' "$QUEUE_FILE" 2>/dev/null || echo "0")

  CONTEXT+="📋 Enhancement Queue: $QUEUE_COUNT total, $READY_COUNT ready
"

  if [ "$READY_COUNT" -gt 0 ]; then
    READY_ITEMS=$(jq -r '[.[] | select(.status | startswith("READY_FOR_"))] | .[] | "  • [\(.status)] \(.slug)"' "$QUEUE_FILE" 2>/dev/null)
    CONTEXT+="
Ready items:
$READY_ITEMS
"
  fi
fi

# 2. Load git status
if git -C "$CLAUDE_PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  CONTEXT+="
🌿 Branch: \`$BRANCH\`"

  MODIFIED=$(git -C "$CLAUDE_PROJECT_DIR" status --short 2>/dev/null | wc -l)
  if [ "$MODIFIED" -gt 0 ]; then
    CONTEXT+="
📝 Uncommitted changes: $MODIFIED files"
  fi
fi

# 3. Load agent count
AGENTS_DIR="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/modules/agents"
if [ -d "$AGENTS_DIR" ]; then
  AGENT_COUNT=$(find "$AGENTS_DIR" -type f \( -name "*.md" -o -name "*.json" \) 2>/dev/null | wc -l)
  CONTEXT+="
🤖 Available agents: $AGENT_COUNT"
fi

# 6. Registry validation (auto-run if validation file is old or missing)
DEPENDENCY_GRAPH="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/dependency-graph.json"
VALIDATION_LOG="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/validation-log.json"

# Check if validation is needed (no recent validation or graph updated)
VALIDATION_NEEDED=false
if [ ! -f "$VALIDATION_LOG" ]; then
  VALIDATION_NEEDED=true
elif [ ! -f "$DEPENDENCY_GRAPH" ]; then
  VALIDATION_NEEDED=false  # No registry to validate
else
  LAST_VALIDATION_EPOCH=$(jq -r '.validations[-1].timestamp // "0"' "$VALIDATION_LOG" 2>/dev/null || echo "0")
  LAST_VALIDATION_SECONDS=$(date -d "$LAST_VALIDATION_EPOCH" +%s 2>/dev/null || echo "0")
  CURRENT_SECONDS=$(date +%s)
  # Run validation if last validation was more than 24 hours ago
  if [ $((CURRENT_SECONDS - LAST_VALIDATION_SECONDS)) -gt 86400 ]; then
    VALIDATION_NEEDED=true
  fi
fi

if [ "$VALIDATION_NEEDED" = "true" ] && [ -f "$DEPENDENCY_GRAPH" ]; then
  # Run registry validation in background
  (
    VALIDATION_OUTPUT=$("$CLAUDE_PROJECT_DIR/Super-Claude/.claude/hooks/registry-validator.sh" validate_registry 2>&1)
    echo "$VALIDATION_OUTPUT" > "$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry/last-validation-output.txt"
  ) &

  CONTEXT+="🔍 **Registry Validation:** Running in background...
"
fi

# Output context - will be injected into Claude's context window
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF

exit 0