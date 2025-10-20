#!/bin/bash
set -euo pipefail

# Read JSON input
INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process Write/Edit
if [[ ! "$TOOL_NAME" =~ ^(Write|Edit)$ ]]; then
  exit 0
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Format based on file type
case "$EXT" in
  js|jsx|ts|tsx)
    if command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE_PATH" 2>&1 >/dev/null
      echo "✓ Formatted with Prettier" >&2
    fi
    ;;

  py)
    if command -v black >/dev/null 2>&1; then
      black "$FILE_PATH" 2>&1 >/dev/null
      echo "✓ Formatted with Black" >&2
    fi
    ;;

  go)
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w "$FILE_PATH" 2>&1 >/dev/null
      echo "✓ Formatted with gofmt" >&2
    fi
    ;;
esac

exit 0