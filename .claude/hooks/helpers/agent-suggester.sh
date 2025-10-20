#!/bin/bash

# ============================================================================
# Agent Suggester Helper Script
# ============================================================================
# Shared logic for suggesting the next agent based on queue status.
# Used by SubagentStop hook and other utilities.
# ============================================================================

set -euo pipefail

# Source the queue reader for shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUEUE_READER="$SCRIPT_DIR/queue-reader.sh"

if [ ! -f "$QUEUE_READER" ]; then
  echo "Error: queue-reader.sh not found" >&2
  exit 1
fi

# Agent mapping based on status
suggest_agent_for_status() {
  local status="$1"
  local slug="$2"
  local title="$3"

  case "$status" in
    "READY_FOR_ARCH")
      cat <<EOF
{
  "agent": "architect-review",
  "message": "✅ Spec complete for '$title' (slug: $slug).\n\n📐 Next step: Use the architect-review subagent on '$slug'.\n\nThe architect will:\n- Review the spec at docs/claude/working-notes/$slug.md\n- Validate design against platform constraints\n- Produce an ADR with implementation guardrails\n- Flag any breaking changes or risks\n- Set status to READY_FOR_BUILD when complete"
}
EOF
      ;;
    "READY_FOR_BUILD")
      cat <<EOF
{
  "agent": "implementer-tester",
  "message": "✅ Architecture approved for '$title' (slug: $slug).\n\n⚒️ Next step: Use the implementer-tester subagent on '$slug'.\n\nThe implementer will:\n- Read the ADR at docs/claude/decisions/ADR-$slug.md\n- Follow the implementation guardrails\n- Write tests first (TDD)\n- Implement the feature\n- Run full test suite\n- Create PR and set status to DONE"
}
EOF
      ;;
    "READY_FOR_REVIEW")
      cat <<EOF
{
  "agent": "human",
  "message": "✅ Implementation complete for '$title' (slug: $slug).\n\n👀 Next step: Human review\n\nPlease review the PR, verify tests pass, and merge when ready.\nThe implementer has completed the work and is awaiting your approval."
}
EOF
      ;;
    "NEEDS_REVIEW")
      cat <<EOF
{
  "agent": "human",
  "message": "⏸️ Task '$title' (slug: $slug) needs human review before proceeding.\n\nPlease review the current progress and provide guidance on next steps."
}
EOF
      ;;
    *)
      cat <<EOF
{
  "agent": "unknown",
  "message": "⚠️ Unknown status: $status for slug $slug. Manual intervention may be required."
}
EOF
      ;;
  esac
}

# Function to get next suggestion
get_next_suggestion() {
  # Get next ready item
  local next_item=$("$QUEUE_READER" next)

  if [ -z "$next_item" ]; then
    # Check for items needing review
    local review_items=$("$QUEUE_READER" needs_review | jq -r '.[0].slug // empty')

    if [ -n "$review_items" ] && [ "$review_items" != "null" ]; then
      local review_data=$("$QUEUE_READER" find "$review_items")
      local title=$(echo "$review_data" | jq -r '.title // "Untitled"')
      suggest_agent_for_status "NEEDS_REVIEW" "$review_items" "$title"
    else
      cat <<EOF
{
  "agent": "none",
  "message": "✅ Queue is clear - all tasks complete or awaiting review."
}
EOF
    fi
  else
    # Parse the next item
    IFS='|' read -r status slug title <<< "$next_item"
    suggest_agent_for_status "$status" "$slug" "$title"
  fi
}

# Function to format suggestion as decision block
format_suggestion() {
  local suggestion_json="$1"

  local agent=$(echo "$suggestion_json" | jq -r '.agent')
  local message=$(echo "$suggestion_json" | jq -r '.message')

  if [ "$agent" = "none" ]; then
    echo "$message"
    return 0
  fi

  cat <<EOF
{
  "decision": "block",
  "reason": "$message"
}
EOF
}

# Main execution
case "${1:-}" in
  "suggest")
    get_next_suggestion
    ;;
  "format")
    format_suggestion "${2:-}"
    ;;
  "next")
    local suggestion=$(get_next_suggestion)
    format_suggestion "$suggestion"
    ;;
  *)
    echo "Usage: $0 {suggest|format <suggestion_json>|next}" >&2
    exit 1
    ;;
esac