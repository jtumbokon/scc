#!/bin/bash

# ============================================================================
# Stop Hook - Session Cleanup
# ============================================================================
# Runs when Claude Code session ends.
# Performs cleanup tasks and saves session state.
# ============================================================================

set -euo pipefail

# Read JSON input
INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source')

echo "🧹 Super-Claude session cleanup started..." >&2

# 1. Save current queue state with timestamp
QUEUE_FILE="$CLAUDE_PROJECT_DIR/Super-Claude/enhancements/_queue.json"
QUEUE_BACKUP_DIR="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/backups"

if [ -f "$QUEUE_FILE" ]; then
  mkdir -p "$QUEUE_BACKUP_DIR"
  TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
  cp "$QUEUE_FILE" "$QUEUE_BACKUP_DIR/queue_backup_$TIMESTAMP.json"
  echo "✓ Queue state backed up to queue_backup_$TIMESTAMP.json" >&2
fi

# 2. Clean up temporary files
TEMP_DIR="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/temp"
if [ -d "$TEMP_DIR" ]; then
  find "$TEMP_DIR" -type f -mtime +7 -delete 2>/dev/null || true
  echo "✓ Cleaned temporary files older than 7 days" >&2
fi

# 3. Log session end to registry
REGISTRY_DIR="$CLAUDE_PROJECT_DIR/Super-Claude/.claude/registry"
SESSION_LOG="$REGISTRY_DIR/session-log.json"

mkdir -p "$REGISTRY_DIR"

# Create session entry
SESSION_ENTRY=$(cat <<EOF
{
  "session_type": "stop",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$SOURCE",
  "queue_items": $(jq 'length' "$QUEUE_FILE" 2>/dev/null || echo "0"),
  "ready_items": $(jq '[.[] | select(.status | startswith("READY_FOR_"))] | length' "$QUEUE_FILE" 2>/dev/null || echo "0")
}
EOF
)

# Append to session log
if [ -f "$SESSION_LOG" ]; then
  # Append to existing array
  TMP_FILE=$(mktemp)
  jq --argjson entry "$SESSION_ENTRY" '. += [$entry]' "$SESSION_LOG" > "$TMP_FILE"
  mv "$TMP_FILE" "$SESSION_LOG"
else
  # Create new log file
  echo "[$SESSION_ENTRY]" > "$SESSION_LOG"
fi

echo "✓ Session end logged to registry" >&2

# 4. Generate quick status report
if [ -f "$QUEUE_FILE" ]; then
  TOTAL_ITEMS=$(jq 'length' "$QUEUE_FILE")
  READY_ITEMS=$(jq '[.[] | select(.status | startswith("READY_FOR_"))] | length' "$QUEUE_FILE")
  COMPLETED_ITEMS=$(jq '[.[] | select(.status == "DONE")] | length' "$QUEUE_FILE")
  BLOCKED_ITEMS=$(jq '[.[] | select(.status == "BLOCKED")] | length' "$QUEUE_FILE")

  echo "" >&2
  echo "📊 Session Summary:" >&2
  echo "  Total items: $TOTAL_ITEMS" >&2
  echo "  Ready for work: $READY_ITEMS" >&2
  echo "  Completed: $COMPLETED_ITEMS" >&2
  echo "  Blocked: $BLOCKED_ITEMS" >&2
  echo "" >&2

  if [ "$READY_ITEMS" -gt 0 ]; then
    echo "🔄 Ready items for next session:" >&2
    jq -r '[.[] | select(.status | startswith("READY_FOR_"))] | .[] | "  - \(.slug): \(.title // "Untitled") (\(.status))"' "$QUEUE_FILE" >&2
    echo "" >&2
  fi
fi

echo "✅ Super-Claude session cleanup complete" >&2

exit 0