#!/bin/bash

# ============================================================================
# Queue Reader Helper Script
# ============================================================================
# Shared logic for reading and parsing the enhancement queue.
# Used by hooks and other utilities.
# ============================================================================

set -euo pipefail

# Default queue file location
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
  QUEUE_FILE="${QUEUE_FILE:-$CLAUDE_PROJECT_DIR/Super-Claude/enhancements/_queue.json}"
else
  QUEUE_FILE="${QUEUE_FILE:-enhancements/_queue.json}"
fi

# Function to validate queue file exists and is valid JSON
validate_queue() {
  if [ ! -f "$QUEUE_FILE" ]; then
    echo "Error: Queue file not found at $QUEUE_FILE" >&2
    return 1
  fi

  if ! jq empty "$QUEUE_FILE" 2>/dev/null; then
    echo "Error: Queue file is not valid JSON" >&2
    return 1
  fi

  return 0
}

# Function to get queue statistics
get_queue_stats() {
  if ! validate_queue; then
    echo '{"total": 0, "ready": 0, "done": 0, "blocked": 0, "needs_review": 0}'
    return 1
  fi

  jq '{
    total: length,
    ready: [.[] | select(.status | startswith("READY_FOR_"))] | length,
    done: [.[] | select(.status == "DONE")] | length,
    blocked: [.[] | select(.status == "BLOCKED")] | length,
    needs_review: [.[] | select(.status == "NEEDS_REVIEW")] | length
  }' "$QUEUE_FILE"
}

# Function to get items by status
get_items_by_status() {
  local status_filter="$1"

  if ! validate_queue; then
    return 1
  fi

  case "$status_filter" in
    "ready")
      jq '[.[] | select(.status | startswith("READY_FOR_"))]' "$QUEUE_FILE"
      ;;
    "ready_for_arch")
      jq '[.[] | select(.status == "READY_FOR_ARCH")]' "$QUEUE_FILE"
      ;;
    "ready_for_build")
      jq '[.[] | select(.status == "READY_FOR_BUILD")]' "$QUEUE_FILE"
      ;;
    "ready_for_review")
      jq '[.[] | select(.status == "READY_FOR_REVIEW")]' "$QUEUE_FILE"
      ;;
    "needs_review")
      jq '[.[] | select(.status == "NEEDS_REVIEW")]' "$QUEUE_FILE"
      ;;
    "blocked")
      jq '[.[] | select(.status == "BLOCKED")]' "$QUEUE_FILE"
      ;;
    "done")
      jq '[.[] | select(.status == "DONE")]' "$QUEUE_FILE"
      ;;
    "draft")
      jq '[.[] | select(.status == "DRAFT")]' "$QUEUE_FILE"
      ;;
    *)
      jq "[.[] | select(.status == \"$status_filter\")]" "$QUEUE_FILE"
      ;;
  esac
}

# Function to get next ready item
get_next_ready() {
  if ! validate_queue; then
    return 1
  fi

  jq -r '
    .[]
    | select(.status | startswith("READY_FOR_"))
    | "\(.status)|\(.slug)|\(.title // "Untitled")"
  ' "$QUEUE_FILE" | head -1
}

# Function to find item by slug
find_item_by_slug() {
  local slug="$1"

  if ! validate_queue; then
    return 1
  fi

  jq ".[] | select(.slug == \"$slug\")" "$QUEUE_FILE"
}

# Function to update item status
update_item_status() {
  local slug="$1"
  local new_status="$2"
  local agent="${3:-}"

  if ! validate_queue; then
    return 1
  fi

  local temp_file=$(mktemp)

  # Build update object
  local update_obj="{\"status\": \"$new_status\", \"updated\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}"

  if [ -n "$agent" ]; then
    update_obj=$(echo "$update_obj" | jq ". + {\"assigned_agent\": \"$agent\"}")
  fi

  # Update the item
  jq --arg slug "$slug" --argjson update "$update_obj" '
    map(if .slug == $slug then . + $update else . end)
  ' "$QUEUE_FILE" > "$temp_file"

  mv "$temp_file" "$QUEUE_FILE"
  echo "Updated item '$slug' status to '$new_status'"
}

# Function to add new item
add_item() {
  local slug="$1"
  local title="$2"
  local priority="${3:-5}"

  if ! validate_queue; then
    return 1
  fi

  # Check if item already exists
  if jq -e ".[] | select(.slug == \"$slug\")" "$QUEUE_FILE" >/dev/null; then
    echo "Error: Item with slug '$slug' already exists" >&2
    return 1
  fi

  local temp_file=$(mktemp)
  local new_item=$(cat <<EOF
{
  "slug": "$slug",
  "title": "$title",
  "status": "DRAFT",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "priority": $priority,
  "tags": [],
  "notes": []
}
EOF
)

  jq --argjson new_item "$new_item" '. + [$new_item]' "$QUEUE_FILE" > "$temp_file"
  mv "$temp_file" "$QUEUE_FILE"
  echo "Added new item '$slug' to queue"
}

# Main execution - handle command line arguments
case "${1:-}" in
  "stats")
    get_queue_stats
    ;;
  "ready")
    get_items_by_status "ready"
    ;;
  "next")
    get_next_ready
    ;;
  "find")
    find_item_by_slug "${2:-}"
    ;;
  "update")
    update_item_status "${2:-}" "${3:-}" "${4:-}"
    ;;
  "add")
    add_item "${2:-}" "${3:-}" "${4:-}"
    ;;
  "validate")
    validate_queue && echo "Queue file is valid"
    ;;
  *)
    echo "Usage: $0 {stats|ready|next|find <slug>|update <slug> <status> [agent]|add <slug> <title> [priority]|validate}" >&2
    exit 1
    ;;
esac