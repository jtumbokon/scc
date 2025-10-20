#!/bin/bash

# ============================================================================
# Simple JSON Validator (No jq dependency)
# ============================================================================
# Basic JSON validation when jq is not available.
# ============================================================================

validate_json_simple() {
  local file="$1"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # Basic JSON syntax check using Python if available
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
import sys
try:
    with open('$file', 'r') as f:
        json.load(f)
    print('JSON is valid')
except json.JSONDecodeError as e:
    print(f'JSON validation failed: {e}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'Error reading file: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null
    return $?
  elif command -v python >/dev/null 2>&1; then
    python -c "
import json
import sys
try:
    with open('$file', 'r') as f:
        json.load(f)
    print('JSON is valid')
except json.JSONDecodeError as e:
    print(f'JSON validation failed: {e}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'Error reading file: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null
    return $?
  else
    # Fallback: just check if it starts with [ and ends with ]
    first_char=$(head -c 1 "$file")
    last_char=$(tail -c 1 "$file")

    if [ "$first_char" = "[" ] && [ "$last_char" = "]" ]; then
      return 0
    else
      return 1
    fi
  fi
}

# Export for use in other scripts
export -f validate_json_simple