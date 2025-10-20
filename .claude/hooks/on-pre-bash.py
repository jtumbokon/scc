#!/usr/bin/env python3

"""
PreToolUse Hook - Bash Command Validation
==========================================
Validates bash commands before execution.
Blocks dangerous commands and suggests safer alternatives.
"""

import json
import re
import sys
import os

# Define validation rules
VALIDATION_RULES = [
    (r'\brm\s+-rf\s+/', "BLOCKED: 'rm -rf /' is extremely dangerous!"),
    (r'\brm\s+-rf\s+~', "BLOCKED: 'rm -rf ~' would delete your home directory!"),
    (r'\brm\s+-rf\s+\$HOME', "BLOCKED: 'rm -rf $HOME' would delete your home directory!"),
    (r'\>\s*/dev/sd[a-z]', "BLOCKED: Writing directly to disk devices is dangerous!"),
    (r'\bdd\s+if=', "WARNING: 'dd' can be destructive. Verify parameters carefully."),
    (r'\bchmod\s+-R\s+777', "WARNING: 'chmod -R 777' gives everyone full access. Very risky!"),
    (r'\bcurl\s+.*\|\s*bash', "WARNING: Piping curl to bash executes untrusted code. Risky!"),
    (r'\bwget\s+.*\|\s*bash', "WARNING: Piping wget to bash executes untrusted code. Risky!"),
    (r'\bsudo\s+rm\s+-rf', "WARNING: 'sudo rm -rf' with recursive delete. Very dangerous!"),
    (r'\bmkfs\.', "BLOCKED: Formatting filesystems will destroy data!"),
    (r'\bfdisk\s+.*w', "WARNING: Writing disk partition table. Very dangerous!"),
]

# Super-Claude specific rules
SUPER_CLAUDE_RULES = [
    (r'\brm\s+-rf\s+.*Super-Claude', "BLOCKED: Attempting to delete Super-Claude system files!"),
    (r'\brm\s+-rf\s+.*\.claude', "BLOCKED: Attempting to delete Claude configuration files!"),
    (r'\bdd\s+if=/dev/zero.*of=.*Super-Claude', "BLOCKED: Attempting to wipe Super-Claude data!"),
]

def validate_command(command: str) -> tuple[bool, list[str]]:
    """
    Validate a bash command.
    Returns (should_block, issues) where issues is a list of warning/error messages.
    """
    issues = []
    should_block = False

    # Check general dangerous commands
    for pattern, message in VALIDATION_RULES:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append(message)
            if "BLOCKED" in message:
                should_block = True

    # Check Super-Claude specific dangerous commands
    for pattern, message in SUPER_CLAUDE_RULES:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append(message)
            should_block = True

    return should_block, issues

def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    # Only validate Bash tool
    if tool_name != "Bash" or not command:
        sys.exit(0)

    # Validate the command
    should_block, issues = validate_command(command)

    if not issues:
        # No issues - allow command
        sys.exit(0)

    # Format issues
    issues_text = "\n".join(f"• {issue}" for issue in issues)

    if should_block:
        # Block the command
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": f"Command validation failed:\n{issues_text}"
            }
        }
        print(json.dumps(output))
        sys.exit(0)
    else:
        # Allow but warn
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": f"Command has potential risks:\n{issues_text}\n\nProceed anyway?"
            }
        }
        print(json.dumps(output))
        sys.exit(0)

if __name__ == "__main__":
    main()