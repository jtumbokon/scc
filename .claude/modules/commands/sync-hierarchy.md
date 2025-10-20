---
id: command-001
type: command
version: 1.0.0
description: Manually trigger full cascade update and hierarchy synchronization
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Sync Hierarchy Command (command-001)

## Purpose
Triggers comprehensive hierarchy synchronization and cascade updates across the entire modular system.

## Command Syntax

### Basic Usage
```
/sync-hierarchy
```

### With Options
```
/sync-hierarchy [--dry-run] [--force] [--module=<module-id>] [--depth=<number>]
```

### Advanced Usage
```
/sync-hierarchy --validate-only --report-format=<json|yaml|table>
/sync-hierarchy --parallel --batch-size=<number>
/sync-hierarchy --exclude=<module-pattern> --include=<module-pattern>
```

## Command Options

### Core Options
- `--dry-run`: Preview changes without applying them
- `--force`: Force update even if validation fails
- `--validate-only`: Only validate, don't update
- `--parallel`: Process modules in parallel

### Targeting Options
- `--module=<id>`: Target specific module
- `--depth=<number>`: Limit cascade depth
- `--exclude=<pattern>`: Exclude matching modules
- `--include=<pattern>`: Include only matching modules

### Output Options
- `--report-format=<format>`: Output format (json, yaml, table)
- `--verbose`: Detailed output
- `--quiet`: Minimal output
- `--log-file=<path>`: Save log to file

## Implementation Workflow

### 1. Pre-Sync Validation
```python
def pre_sync_validation(options):
    # Check system health
    health_check = validate_system_health()
    if health_check.status != 'healthy' and not options.force:
        raise ValidationError("System not ready for sync")

    # Backup current state
    backup = create_system_backup()

    # Validate dependencies
    dependency_validation = validate_all_dependencies()
    return backup, dependency_validation
```

### 2. Graph Analysis
```python
def analyze_dependency_graph():
    # Build current dependency graph
    graph = build_dependency_graph()

    # Detect circular dependencies
    circular_deps = detect_circular_dependencies(graph)

    # Calculate update order (topological sort)
    update_order = calculate_update_order(graph)

    # Identify affected modules
    affected_modules = identify_affected_modules(graph)

    return graph, update_order, affected_modules
```

### 3. Cascade Execution
```python
def execute_cascade_updates(graph, update_order, options):
    if options.dry_run:
        return simulate_cascade(graph, update_order)

    results = []
    for module_id in update_order:
        try:
            result = update_module(module_id, options)
            results.append(result)

            # Update dependency graph
            graph = update_graph(graph, module_id, result)

        except Exception as e:
            if not options.force:
                rollback_changes(results)
                raise
            results.append({'module': module_id, 'status': 'error', 'error': str(e)})

    return results
```

### 4. Post-Sync Validation
```python
def post_sync_validation(results):
    # Validate updated system
    validation_result = validate_system_integrity()

    # Check for orphaned modules
    orphaned_modules = detect_orphaned_modules()

    # Verify version consistency
    version_check = verify_version_consistency()

    # Generate sync report
    report = generate_sync_report(results, validation_result)

    return report
```

## Output Examples

### Basic Sync Output
```
🔄 Syncing Super-Claude Hierarchy...
✅ Pre-sync validation passed
📊 Analyzing dependency graph...
🔄 Found 12 modules to update
⚡ Executing cascade updates...
   ✅ naming-conventions v1.0.0 → v1.0.1
   ✅ code-style v1.0.0 → v1.0.1
   ✅ error-handling v1.0.0 → v1.0.1
   ✅ security-rules v1.0.0 → v1.0.1
   ✅ documentation-rules v1.0.0 → v1.0.1
   ✅ testing-standards v1.0.0 → v1.0.1
   ⚠️  templates (conditional cascade skipped)
   ℹ️  agents (manual cascade required)
✅ Post-sync validation passed
📋 Sync Summary: 6 modules updated, 0 errors
```

### Dry Run Output
```
🔍 Dry Run: Preview sync changes
📊 Analysis Results:
   • 6 modules require updates
   • 2 modules require manual cascade
   • 1 module has version conflicts
   • 0 circular dependencies detected

🔄 Planned Updates:
   → naming-conventions v1.0.0 → v1.0.1 (automatic)
   → code-style v1.0.0 → v1.0.1 (automatic)
   → error-handling v1.0.0 → v1.0.1 (automatic)
   → security-rules v1.0.0 → v1.0.1 (automatic)
   → documentation-rules v1.0.0 → v1.0.1 (automatic)
   → testing-standards v1.0.0 → v1.0.1 (automatic)

⚠️  Manual Action Required:
   → code-reviewer agent: Review changes before cascade
   → test-generator agent: Confirm compatibility

🚫 Version Conflicts:
   → component-template: Requires v1.1.0, but v1.0.0 is latest

Run without --dry-run to apply these changes.
```

### JSON Report Format
```json
{
  "sync_result": {
    "status": "success",
    "timestamp": "2025-10-19T10:30:00Z",
    "duration_seconds": 45,
    "modules_updated": 6,
    "modules_failed": 0,
    "modules_skipped": 3
  },
  "validation": {
    "pre_sync": "passed",
    "post_sync": "passed",
    "circular_dependencies": 0,
    "version_conflicts": 0
  },
  "modules": [
    {
      "id": "naming-conventions",
      "type": "rule",
      "version_from": "1.0.0",
      "version_to": "1.0.1",
      "status": "updated",
      "cascade_type": "automatic"
    }
  ],
  "metrics": {
    "graph_health_score": 98,
    "dependency_completeness": 100,
    "version_consistency": 100
  }
}
```

## Error Handling

### Common Error Scenarios
1. **Circular Dependencies**: Detected during graph analysis
2. **Version Conflicts**: Incompatible version requirements
3. **Validation Failures**: Modules fail validation checks
4. **Update Failures**: Individual module update failures

### Recovery Strategies
```python
def handle_sync_error(error, context):
    if error.type == 'circular_dependency':
        return resolve_circular_dependency(error.cycle)
    elif error.type == 'version_conflict':
        return resolve_version_conflict(error.conflict)
    elif error.type == 'validation_failure':
        return fix_validation_errors(error.violations)
    elif error.type == 'update_failure':
        return retry_with_fallback(error.module)
```

## Integration Points

### Required Components
- Dependency Graph System
- Version Management
- Validation Framework
- Update Log System

### Compatible Tools
- Git (for version control)
- File System Watchers (for change detection)
- CI/CD Systems (for automated syncs)
- Monitoring Systems (for sync metrics)

## Performance Optimization

### Parallel Processing
- **Module Updates**: Process independent modules in parallel
- **Validation**: Parallel validation where possible
- **Graph Analysis**: Multi-threaded graph algorithms
- **File I/O**: Async file operations

### Caching Strategy
- **Graph Cache**: Cache dependency graphs
- **Validation Cache**: Cache validation results
- **Module Cache**: Cache module metadata
- **Update Cache**: Cache successful updates

## Monitoring and Metrics

### Sync Performance Metrics
- **Sync Duration**: Time to complete sync
- **Success Rate**: Percentage of successful syncs
- **Error Rate**: Frequency of sync errors
- **Throughput**: Modules processed per second

### System Health Metrics
- **Graph Health**: Dependency graph health score
- **Version Consistency**: Module version consistency
- **Validation Pass Rate**: Validation success rate
- **Cascade Efficiency**: Cascade update efficiency

## Best Practices

### When to Run Sync
- **After Module Changes**: After updating any module
- **Regular Maintenance**: Schedule periodic syncs
- **Before Deployments**: Ensure system is consistent
- **After Conflicts**: After resolving dependency conflicts

### Sync Optimization
- **Selective Sync**: Sync only affected modules when possible
- **Batch Processing**: Process modules in batches for large systems
- **Incremental Updates**: Use incremental updates for better performance
- **Parallel Execution**: Use parallel processing when safe

---

**This command ensures the entire hierarchical system remains synchronized and consistent across all modules.**