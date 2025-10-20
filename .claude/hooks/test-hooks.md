# Hook System Testing Guide

## Quick Test Commands

```bash
# Test queue validation
cd Super-Claude && source .claude/hooks/helpers/simple-json-validator.sh && validate_json_simple enhancements/_queue.json

# Test queue reader (simple functions without jq)
cd Super-Claude && .claude/hooks/helpers/queue-reader.sh validate

# Test agent suggester (without jq dependency)
cd Super-Claude && .claude/hooks/helpers/agent-suggester.sh suggest

# Test hook scripts are executable
ls -la Super-Claude/.claude/hooks/*.sh

# Test settings.json syntax
cd Super-Claude && python3 -m json.tool .claude/settings.json > /dev/null && echo "Settings JSON is valid"

# Test queue schema syntax
cd Super-Claude && python3 -m json.tool .claude/queue-schema.json > /dev/null && echo "Schema JSON is valid"
```

## Manual Hook Testing

### SubagentStop Hook Test
```bash
# Create test input
cat > test-input.json <<EOF
{
  "session_id": "test-session",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": "false"
}
EOF

# Test the hook
cd Super-Claude && cat test-input.json | .claude/hooks/on-subagent-stop.sh
```

### SessionStart Hook Test
```bash
# Create test input
cat > test-input.json <<EOF
{
  "source": "test",
  "session_id": "test-session"
}
EOF

# Test the hook
cd Super-Claude && cat test-input.json | .claude/hooks/on-session-start.sh
```

### PreBash Hook Test
```bash
# Test dangerous command
cat > test-input.json <<EOF
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /"
  }
}
EOF

# Test the hook
cd Super-Claude && cat test-input.json | .claude/hooks/on-pre-bash.py
```

## Hook System Status

✅ **Completed Components:**
- .claude/hooks/ directory structure
- All 5 core hooks (SubagentStop, PostToolUse, SessionStart, PreToolUse, Stop)
- settings.json configuration
- Queue system (schema + example queue)
- Helper scripts (queue-reader, agent-suggester, json-validator)
- All scripts made executable

✅ **Key Features Implemented:**
- Agent orchestration via SubagentStop hook
- Automatic code formatting via PostToolUse hook
- Session context loading via SessionStart hook
- Bash command validation via PreToolUse hook
- Session cleanup via Stop hook
- Queue management system
- Helper utilities for queue and agent management

✅ **Ready for Integration:**
The complete hook system is now implemented and ready for use with Claude Code agents.