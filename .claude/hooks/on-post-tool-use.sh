#!/bin/bash

# PostToolUse Hook - Automatic Module Registration
# Triggered after any file write operation to auto-register modules in dependency graph

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
DEPENDENCY_GRAPH="$PROJECT_ROOT/.claude/registry/dependency-graph.json"
UPDATE_LOG="$PROJECT_ROOT/.claude/registry/update-log.json"

# Ensure registry directory exists
mkdir -p "$(dirname "$DEPENDENCY_GRAPH")"

# Initialize log file if it doesn't exist
if [ ! -f "$UPDATE_LOG" ]; then
    echo '{"updates": []}' > "$UPDATE_LOG"
fi

# Function to log updates
log_update() {
    local module_name="$1"
    local module_type="$2"
    local action="$3"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local log_entry="{
        \"timestamp\": \"$timestamp\",
        \"module_name\": \"$module_name\",
        \"module_type\": \"$module_type\",
        \"action\": \"$action\",
        \"auto_registered\": true
    }"

    # Add to update log
    local temp_log=$(mktemp)
    jq ".updates += [$log_entry]" "$UPDATE_LOG" > "$temp_log" && mv "$temp_log" "$UPDATE_LOG"
}

# Function to detect module type from file path and content
detect_module_type() {
    local file_path="$1"
    local relative_path="${file_path#$PROJECT_ROOT/}"

    # Check if it's in modules directory
    if [[ "$relative_path" == .claude/modules/* ]]; then
        local module_dir=$(dirname "$relative_path")

        case "$module_dir" in
            ".claude/modules/rules")
                echo "rule"
                ;;
            ".claude/modules/agents")
                echo "agent"
                ;;
            ".claude/modules/skills")
                echo "skill"
                ;;
            ".claude/modules/commands")
                echo "command"
                ;;
            ".claude/modules/hooks")
                echo "hook"
                ;;
            ".claude/modules/templates")
                echo "template"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "external"
    fi
}

# Function to extract module name from file
extract_module_name() {
    local file_path="$1"
    local basename=$(basename "$file_path")

    # Remove extension
    echo "${basename%.*}"
}

# Function to create module entry for dependency graph
create_module_entry() {
    local file_path="$1"
    local module_type="$2"
    local module_name="$3"
    local relative_path="${file_path#$PROJECT_ROOT/}"

    # Read file content for metadata extraction
    local content=$(cat "$file_path" 2>/dev/null || echo "")

    # Basic module entry
    local entry="{
      \"id\": \"module-$(date +%s)-$$\",
      \"type\": \"$module_type\",
      \"version\": \"1.0.0\",
      \"path\": \"$relative_path\",
      \"hash\": \"$(echo "$content" | sha256sum | cut -d' ' -f1)\",
      \"created\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
      \"parents\": [\"CLAUDE.md\"]
    }"

    # Add type-specific metadata
    case "$module_type" in
        "agent")
            # Extract agent metadata from frontmatter
            local description=$(echo "$content" | grep "^description:" | cut -d':' -f2- | xargs || echo "Auto-registered agent")
            local triggered_by=$(echo "$content" | grep "^triggered_by_hook:" | cut -d':' -f2- | xargs || echo "")
            local updates_to=$(echo "$content" | grep "^updates_queue_status:" | cut -d':' -f2- | xargs || echo "")
            local next_agent=$(echo "$content" | grep "^next_agent_via_hook:" | cut -d':' -f2- | xargs || echo "none")
            local output_loc=$(echo "$content" | grep "^output_location:" | cut -d':' -f2- | xargs || echo "")
            local tools=$(echo "$content" | grep "^tools:" | cut -d':' -f2- | xargs || echo "Read, Write, Edit")

            entry=$(jq "$entry | .agent_metadata = {
                \"description\": \"$description\",
                \"triggered_by_status\": \"$triggered_by\",
                \"updates_status_to\": \"$updates_to\",
                \"next_agent\": \"$next_agent\",
                \"output_location\": \"$output_loc\",
                \"tools\": [\"$(echo "$tools" | sed 's/, */\",\"/g')\"],
                \"auto_registered\": true
            }" <<< "$entry")
            ;;
        "command")
            # Extract command metadata
            local command_name=$(echo "$content" | grep "^name:" | cut -d':' -f2- | xargs || echo "$module_name")
            local description=$(echo "$content" | grep "^description:" | cut -d':' -f2- | xargs || echo "Auto-registered command")

            entry=$(jq "$entry | .command_metadata = {
                \"name\": \"$command_name\",
                \"description\": \"$description\",
                \"auto_registered\": true
            }" <<< "$entry")
            ;;
        "rule")
            # Extract rule metadata
            local rule_name=$(echo "$content" | grep "^name:" | cut -d':' -f2- | xargs || echo "$module_name")
            local description=$(echo "$content" | grep "^description:" | cut -d':' -f2- | xargs || echo "Auto-registered rule")

            entry=$(jq "$entry | .rule_metadata = {
                \"name\": \"$rule_name\",
                \"description\": \"$description\",
                \"auto_registered\": true
            }" <<< "$entry")
            ;;
    esac

    echo "$entry"
}

# Function to register module in dependency graph
register_module() {
    local file_path="$1"

    # Detect module type and name
    local module_type=$(detect_module_type "$file_path")
    local module_name=$(extract_module_name "$file_path")

    # Skip if unknown module type or already registered
    if [ "$module_type" = "unknown" ] || [ "$module_type" = "external" ]; then
        return 0
    fi

    # Check if already registered
    if [ -f "$DEPENDENCY_GRAPH" ]; then
        local already_registered=$(jq -e ".modules.\"$module_name\"" "$DEPENDENCY_GRAPH" && echo "true" || echo "false")
        if [ "$already_registered" = "true" ]; then
            return 0
        fi
    fi

    # Initialize dependency graph if it doesn't exist
    if [ ! -f "$DEPENDENCY_GRAPH" ]; then
        echo '{
            "_schema_version": "2.0",
            "_last_updated": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
            "modules": {},
            "dependencies": {},
            "status_mappings": {},
            "agent_workflows": {},
            "registry_metadata": {
                "auto_registration_enabled": true,
                "last_auto_register": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
            }
        }' > "$DEPENDENCY_GRAPH"
    fi

    # Create module entry
    local module_entry=$(create_module_entry "$file_path" "$module_type" "$module_name")

    # Add to dependency graph
    local temp_graph=$(mktemp)
    jq ".modules.\"$module_name\" = $module_entry | ._last_updated = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"" "$DEPENDENCY_GRAPH" > "$temp_graph" && mv "$temp_graph" "$DEPENDENCY_GRAPH"

    # Log the registration
    log_update "$module_name" "$module_type" "registered"

    echo "✅ Auto-registered $module_type: $module_name"
}

# Function to process multiple files
process_files() {
    local files=("$@")

    for file_path in "${files[@]}"; do
        # Skip if file doesn't exist
        if [ ! -f "$file_path" ]; then
            continue
        fi

        # Skip certain file patterns
        local basename=$(basename "$file_path")
        case "$basename" in
            *.tmp|*.temp|*.bak|*~|.DS_Store)
                continue
                ;;
        esac

        # Register the module
        register_module "$file_path"
    done
}

# Main execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # If called as script, process arguments
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <file1> [file2] ..."
        exit 1
    fi

    process_files "$@"
fi

# When called by Claude as a hook, the files will be passed as arguments
# This script automatically registers any new modules in the dependency graph