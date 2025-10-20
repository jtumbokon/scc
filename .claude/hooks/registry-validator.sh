#!/bin/bash

# Registry Validator Script
# Comprehensive validation of the dependency graph registry system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
DEPENDENCY_GRAPH="$PROJECT_ROOT/.claude/registry/dependency-graph.json"
VALIDATION_LOG="$PROJECT_ROOT/.claude/registry/validation-log.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Function to log validation results
log_validation() {
    local status="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local log_entry="{
        \"timestamp\": \"$timestamp\",
        \"status\": \"$status\",
        \"message\": \"$message\",
        \"session_start\": true
    }"

    # Add to validation log
    if [ ! -f "$VALIDATION_LOG" ]; then
        echo '{"validations": []}' > "$VALIDATION_LOG"
    fi

    local temp_log=$(mktemp)
    jq ".validations += [$log_entry]" "$VALIDATION_LOG" > "$temp_log" && mv "$temp_log" "$VALIDATION_LOG"
}

# Function to validate JSON structure
validate_json_structure() {
    if [ ! -f "$DEPENDENCY_GRAPH" ]; then
        print_status "$RED" "❌ Dependency graph not found"
        log_validation "error" "Dependency graph not found at $DEPENDENCY_GRAPH"
        return 1
    fi

    # Check if JSON is valid using Python
    if ! python3 -c "import json; json.load(open('$DEPENDENCY_GRAPH'))" 2>/dev/null; then
        print_status "$RED" "❌ Dependency graph has invalid JSON"
        log_validation "error" "Invalid JSON in dependency graph"
        return 1
    fi

    print_status "$GREEN" "✅ JSON structure is valid"
    return 0
}

# Function to validate required sections
validate_required_sections() {
    local errors=0

    # Check required top-level sections
    local required_sections=("modules" "dependencies" "status_mappings" "agent_workflows" "registry_metadata")

    for section in "${required_sections[@]}"; do
        if ! python3 -c "
import json
import sys
try:
    with open('$DEPENDENCY_GRAPH', 'r') as f:
        data = json.load(f)
    if '$section' not in data:
        sys.exit(1)
except:
    sys.exit(1)
" 2>/dev/null; then
            print_status "$RED" "❌ Missing required section: $section"
            log_validation "error" "Missing required section: $section"
            errors=$((errors + 1))
        else
            print_status "$GREEN" "✅ Found section: $section"
        fi
    done

    return $errors
}

# Function to validate agent metadata
validate_agent_metadata() {
    local errors=0

    # Count agents using Python
    local agent_count=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
agents = [k for k, v in data.get('modules', {}).items() if v.get('type') == 'agent']
print(len(agents))
" 2>/dev/null || echo "0")

    print_status "$BLUE" "🤖 Validating $agent_count agents..."

    # Get list of agents
    python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
agents = [k for k, v in data.get('modules', {}).items() if v.get('type') == 'agent']
for agent in agents:
    print(agent)
" 2>/dev/null | while read agent_name; do
        print_status "$BLUE" "   Validating agent: $agent_name"

        # Check required agent_metadata fields
        local required_fields=("description" "triggered_by_status" "updates_status_to" "output_location" "tools")

        for field in "${required_fields[@]}"; do
            if python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
if '$field' in data.get('modules', {}).get('$agent_name', {}).get('agent_metadata', {}):
    exit(0)
else:
    exit(1)
" 2>/dev/null; then
                print_status "$GREEN" "     ✅ $field"
            else
                print_status "$YELLOW" "     ⚠️ Missing $field"
                log_validation "warning" "Agent $agent_name missing field: $field"
            fi
        done

        # Validate file exists
        local agent_path=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(data.get('modules', {}).get('$agent_name', {}).get('path', ''))
" 2>/dev/null)

        if [ -f "$PROJECT_ROOT/$agent_path" ]; then
            print_status "$GREEN" "     ✅ File exists"
        else
            print_status "$RED" "     ❌ File not found: $agent_path"
            log_validation "error" "Agent $agent_name file not found: $agent_path"
            errors=$((errors + 1))
        fi
    done

    return $errors
}

# Function to validate status mappings
validate_status_mappings() {
    local errors=0

    # Count status mappings
    local status_count=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(len(data.get('status_mappings', {})))
" 2>/dev/null || echo "0")

    print_status "$BLUE" "🔄 Validating $status_count status mappings..."

    # Get list of status mappings
    python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
for status in data.get('status_mappings', {}):
    print(status)
" 2>/dev/null | while read status; do
        # Get mapping details
        local mapping=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
import json
print(json.dumps(data.get('status_mappings', {}).get('$status', {})))
" 2>/dev/null)

        local agent=$(echo "$mapping" | python3 -c "
import json
import sys
try:
    data = json.load(sys.stdin)
    print(data.get('agent', ''))
except:
    pass
" 2>/dev/null)

        local next_status=$(echo "$mapping" | python3 -c "
import json
import sys
try:
    data = json.load(sys.stdin)
    print(data.get('next_status', ''))
except:
    pass
" 2>/dev/null)

        # Check agent exists
        if python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
if '$agent' in data.get('modules', {}):
    exit(0)
else:
    exit(1)
" 2>/dev/null; then
            print_status "$GREEN" "   ✅ $status → $agent ($next_status)"
        else
            print_status "$RED" "   ❌ $status → $agent (agent not found)"
            log_validation "error" "Status mapping $status references non-existent agent: $agent"
            errors=$((errors + 1))
        fi
    done

    return $errors
}

# Function to validate workflow completeness
validate_workflows() {
    local errors=0

    # Count workflows
    local workflow_count=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(len(data.get('agent_workflows', {})))
" 2>/dev/null || echo "0")

    print_status "$BLUE" "📋 Validating $workflow_count workflows..."

    # Get list of workflows
    python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
for workflow in data.get('agent_workflows', {}):
    print(workflow)
" 2>/dev/null | while read workflow; do
        local step_count=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(len(data.get('agent_workflows', {}).get('$workflow', {}).get('steps', [])))
" 2>/dev/null)

        if [ "$step_count" -gt 0 ]; then
            print_status "$GREEN" "   ✅ $workflow has $step_count steps"
        else
            print_status "$YELLOW" "   ⚠️ $workflow has no steps"
            log_validation "warning" "Workflow $workflow has no steps"
        fi

        # Validate workflow steps
        python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
for step in data.get('agent_workflows', {}).get('$workflow', {}).get('steps', []):
    print(step.get('agent', ''))
" 2>/dev/null | while read workflow_agent; do
            if [ -n "$workflow_agent" ]; then
                if python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
if '$workflow_agent' in data.get('modules', {}):
    exit(0)
else:
    exit(1)
" 2>/dev/null; then
                    print_status "$GREEN" "     ✅ Agent $workflow_agent exists"
                else
                    print_status "$RED" "     ❌ Agent $workflow_agent not found"
                    log_validation "error" "Workflow $workflow references non-existent agent: $workflow_agent"
                    errors=$((errors + 1))
                fi
            fi
        done
    done

    return $errors
}

# Function to check for orphaned agents
check_orphaned_agents() {
    # Get used agents and all agents
    local used_agents=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
used = set()
for workflow in data.get('agent_workflows', {}).values():
    for step in workflow.get('steps', []):
        used.add(step.get('agent', ''))
for agent in used:
    if agent:
        print(agent)
" 2>/dev/null)

    local all_agents=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
for name, module in data.get('modules', {}).items():
    if module.get('type') == 'agent':
        print(name)
" 2>/dev/null)

    local orphaned_count=0
    for agent in $all_agents; do
        if ! echo "$used_agents" | grep -q "^$agent$"; then
            print_status "$YELLOW" "   ⚠️ Agent $agent is not used in any workflow"
            log_validation "warning" "Orphaned agent: $agent"
            orphaned_count=$((orphaned_count + 1))
        fi
    done

    if [ $orphaned_count -eq 0 ]; then
        print_status "$GREEN" "✅ All agents are used in workflows"
    else
        print_status "$YELLOW" "⚠️ Found $orphaned_count orphaned agents"
    fi
}

# Function to auto-fix common issues
auto_fix_issues() {
    print_status "$BLUE" "🔧 Attempting auto-fix for common issues..."

    # Fix missing registry_metadata section
    if ! python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
if 'registry_metadata' in data:
    exit(0)
else:
    exit(1)
" 2>/dev/null; then
        python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
data['registry_metadata'] = {
    'auto_registration_enabled': True,
    'last_auto_register': '$(date -u +"%Y-%m-%dT%H:%M:%SZ")',
    'validation_enabled': True
}
with open('$DEPENDENCY_GRAPH', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
        print_status "$GREEN" "✅ Added missing registry_metadata section"
        log_validation "fixed" "Added missing registry_metadata section"
    fi

    # Update last validation timestamp
    python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
if 'registry_metadata' not in data:
    data['registry_metadata'] = {}
data['registry_metadata']['last_validation'] = '$(date -u +"%Y-%m-%dT%H:%M:%SZ")'
with open('$DEPENDENCY_GRAPH', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
}

# Function to display system health summary
display_health_summary() {
    print_status "$BLUE" "📊 System Health Summary"
    print_status "$BLUE" "======================"

    local total_agents=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(len([k for k, v in data.get('modules', {}).items() if v.get('type') == 'agent']))
" 2>/dev/null || echo "0")

    local total_workflows=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(len(data.get('agent_workflows', {})))
" 2>/dev/null || echo "0")

    local total_statuses=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(len(data.get('status_mappings', {})))
" 2>/dev/null || echo "0")

    local schema_version=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(data.get('_schema_version', 'unknown'))
" 2>/dev/null)

    local last_updated=$(python3 -c "
import json
with open('$DEPENDENCY_GRAPH', 'r') as f:
    data = json.load(f)
print(data.get('_last_updated', 'unknown'))
" 2>/dev/null)

    echo "Total agents: $total_agents"
    echo "Total workflows: $total_workflows"
    echo "Supported statuses: $total_statuses"
    echo "Schema version: $schema_version"
    echo "Last updated: $last_updated"

    # Calculate health score based on validation results
    local validation_errors=$(python3 -c "
import json
try:
    with open('$VALIDATION_LOG', 'r') as f:
        data = json.load(f)
    errors = [v for v in data.get('validations', []) if v.get('status') == 'error']
    print(len(errors))
except:
    print(0)
" 2>/dev/null || echo "0")

    local validation_warnings=$(python3 -c "
import json
try:
    with open('$VALIDATION_LOG', 'r') as f:
        data = json.load(f)
    warnings = [v for v in data.get('validations', []) if v.get('status') == 'warning']
    print(len(warnings))
except:
    print(0)
" 2>/dev/null || echo "0")

    local health_score=$((100 - validation_errors * 10 - validation_warnings * 2))
    if [ $health_score -lt 0 ]; then
        health_score=0
    fi

    echo "Health score: ${health_score}%"

    if [ $health_score -ge 90 ]; then
        print_status "$GREEN" "🟢 System health: Excellent"
    elif [ $health_score -ge 70 ]; then
        print_status "$YELLOW" "🟡 System health: Good"
    else
        print_status "$RED" "🔴 System health: Needs attention"
    fi

    # Update health score in validation log
    python3 -c "
import json
try:
    with open('$VALIDATION_LOG', 'r') as f:
        data = json.load(f)
    if 'validations' not in data:
        data['validations'] = []
    data['validations'].append({
        'timestamp': '$(date -u +"%Y-%m-%dT%H:%M:%SZ")',
        'status': 'health_score',
        'message': 'Health score calculated: $health_score',
        'health_score': $health_score
    })
    with open('$VALIDATION_LOG', 'w') as f:
        json.dump(data, f, indent=2)
except:
    pass
" 2>/dev/null
}

# Main validation function
run_validation() {
    print_status "$BLUE" "🔍 Starting Registry Validation"
    print_status "$BLUE" "==============================="
    echo ""

    local total_errors=0

    # Run validation checks
    validate_json_structure
    total_errors=$((total_errors + $?))

    validate_required_sections
    total_errors=$((total_errors + $?))

    validate_agent_metadata
    total_errors=$((total_errors + $?))

    validate_status_mappings
    total_errors=$((total_errors + $?))

    validate_workflows
    total_errors=$((total_errors + $?))

    check_orphaned_agents

    # Auto-fix common issues
    auto_fix_issues

    echo ""
    display_health_summary

    if [ $total_errors -eq 0 ]; then
        print_status "$GREEN" ""
        print_status "$GREEN" "🎉 Registry validation PASSED"
        print_status "$GREEN" "System is ready for use!"
        log_validation "success" "Registry validation passed"
        return 0
    else
        print_status "$RED" ""
        print_status "$RED" "❌ Registry validation FAILED"
        print_status "$RED" "Found $total_errors critical errors"
        print_status "$YELLOW" "💡 Run /validate-registry --fix to auto-fix issues"
        log_validation "error" "Registry validation failed with $total_errors errors"
        return 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    "validate_registry")
        run_validation
        ;;
    "")
        # Default behavior when called as hook
        run_validation
        ;;
    *)
        echo "Usage: $0 [validate_registry]"
        exit 1
        ;;
esac