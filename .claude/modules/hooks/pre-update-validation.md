---
id: hook-001
type: hook
version: 1.0.0
description: Validates all modules before any update operation to ensure system integrity
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Pre-Update Validation Hook (hook-001)

## Purpose
Automatically validates all system components before any update operation to prevent breaking changes and maintain system integrity.

## Trigger Events

### Primary Triggers
- **Module Update**: Before any module version change
- **Dependency Change**: Before dependency modifications
- **System Sync**: Before hierarchy synchronization
- **Manual Command**: Before manual update commands

### Secondary Triggers
- **File Changes**: Before file system modifications
- **Configuration Updates**: Before system configuration changes
- **Import/Export**: Before data import/export operations

## Validation Pipeline

### 1. System Health Check
```python
def system_health_check():
    checks = [
        check_file_system_integrity(),
        check_dependency_graph_consistency(),
        check_version_compatibility(),
        check_metadata_validity(),
        check_configuration_consistency()
    ]

    return {
        'overall_health': calculate_health_score(checks),
        'checks': checks,
        'recommendations': generate_recommendations(checks)
    }
```

### 2. Module Validation
```python
def validate_module(module_id, changes):
    # Validate module metadata
    metadata_validation = validate_metadata(module_id)

    # Check dependencies
    dependency_check = check_module_dependencies(module_id)

    # Validate content integrity
    content_validation = validate_content_integrity(module_id)

    # Check version compatibility
    version_check = validate_version_compatibility(module_id, changes)

    return ValidationResult(
        module_id=module_id,
        metadata_valid=metadata_validation.is_valid,
        dependencies_valid=dependency_check.is_valid,
        content_valid=content_validation.is_valid,
        version_compatible=version_check.is_compatible,
        overall_valid=all([metadata_validation.is_valid,
                          dependency_check.is_valid,
                          content_validation.is_valid,
                          version_check.is_compatible])
    )
```

### 3. Dependency Analysis
```python
def validate_dependencies(module_id, changes):
    # Get current dependency graph
    graph = get_dependency_graph()

    # Analyze impact of changes
    impact_analysis = analyze_change_impact(module_id, changes, graph)

    # Check for circular dependencies
    circular_check = detect_circular_dependencies_with_changes(graph, module_id, changes)

    # Validate version constraints
    version_constraints = validate_version_constraints(graph, module_id, changes)

    return DependencyValidationResult(
        impact_analysis=impact_analysis,
        circular_dependencies=circular_check,
        version_constraints=version_constraints,
        can_safely_update=not circular_check.has_cycles and version_constraints.satisfied
    )
```

### 4. Cascade Impact Assessment
```python
def assess_cascade_impact(module_id, changes):
    # Calculate cascade depth
    cascade_depth = calculate_cascade_depth(module_id)

    # Identify affected modules
    affected_modules = get_affected_modules(module_id, changes)

    # Estimate update complexity
    complexity_score = estimate_update_complexity(affected_modules)

    # Check resource requirements
    resource_check = validate_resource_requirements(affected_modules)

    return CascadeImpactResult(
        cascade_depth=cascade_depth,
        affected_modules=affected_modules,
        complexity_score=complexity_score,
        resource_requirements=resource_check,
        recommended_approach=determine_approach(complexity_score, resource_check)
    )
```

## Validation Rules

### Core Validation Rules
1. **Metadata Integrity**: All modules must have valid, complete metadata
2. **Dependency Consistency**: Dependencies must be bidirectional and consistent
3. **Version Compatibility**: Version constraints must be satisfiable
4. **Content Integrity**: Module content must match declared type and structure
5. **Circular Dependency Prevention**: No circular dependencies allowed

### Module-Specific Rules

#### Rules Validation
```yaml
rules_validation:
  required_fields:
    - id
    - type
    - version
    - description
    - parents
    - children
  format_checks:
    - id_format: "rule-\\d{3}"
    - version_format: "semantic"
    - parent_references: "valid_module_ids"
  content_validation:
    - rule_definition_present: true
    - examples_provided: true
    - integration_points_defined: true
```

#### Templates Validation
```yaml
templates_validation:
  required_fields:
    - id
    - type
    - version
    - description
    - template_structure
    - usage_instructions
  format_checks:
    - id_format: "template-\\d{3}"
    - template_syntax: "valid_template_language"
    - examples_valid: true
  compatibility_checks:
    - framework_compatibility: "declared_versions"
    - dependency_availability: "all_dependencies_exist"
```

#### Agents Validation
```yaml
agents_validation:
  required_fields:
    - id
    - type
    - version
    - description
    - capabilities
    - configuration
  format_checks:
    - id_format: "agent-\\d{3}"
    - capabilities_valid: true
    - configuration_schema: "valid_json_schema"
  security_checks:
    - permissions_appropriate: true
    - no_malicious_patterns: true
    - secure_configuration: true
```

## Error Handling

### Validation Failure Categories
1. **Critical Failures**: Block update operation
2. **Major Issues**: Require explicit confirmation
3. **Minor Warnings**: Allow update with notifications
4. **Info Messages**: Provide recommendations

### Failure Response Strategies
```python
def handle_validation_failure(validation_result):
    if validation_result.has_critical_failures:
        return {
            'action': 'block_update',
            'message': 'Critical validation failures detected',
            'failures': validation_result.critical_failures,
            'suggestions': generate_fix_suggestions(validation_result.critical_failures)
        }
    elif validation_result.has_major_issues:
        return {
            'action': 'require_confirmation',
            'message': 'Major issues detected - confirmation required',
            'issues': validation_result.major_issues,
            'risks': assess_risks(validation_result.major_issues)
        }
    elif validation_result.has_minor_warnings:
        return {
            'action': 'proceed_with_warnings',
            'message': 'Minor warnings detected',
            'warnings': validation_result.minor_warnings,
            'recommendations': validation_result.recommendations
        }
    else:
        return {
            'action': 'proceed',
            'message': 'Validation passed'
        }
```

## Integration Points

### Required Components
- Dependency Graph System
- Version Management
- Module Registry
- Configuration System

### External Integrations
- **File System**: Monitor file changes
- **Git**: Track version changes
- **CI/CD**: Integrate with pipeline validation
- **Monitoring**: Report validation metrics

## Performance Optimization

### Caching Strategy
- **Validation Results Cache**: Cache validation results for unchanged modules
- **Dependency Cache**: Cache dependency analysis results
- **Rule Cache**: Cache compiled validation rules
- **Metadata Cache**: Cache parsed module metadata

### Parallel Processing
- **Multi-threaded Validation**: Validate multiple modules in parallel
- **Concurrent Dependency Checks**: Run dependency checks concurrently
- **Parallel Content Validation**: Validate content in parallel when possible

## Monitoring and Alerts

### Validation Metrics
- **Validation Success Rate**: Percentage of validations that pass
- **Validation Duration**: Time to complete validations
- **Failure Types Distribution**: Breakdown of failure categories
- **False Positive Rate**: Validation errors that don't cause actual issues

### Alert Conditions
- **High Failure Rate**: Validation success rate below threshold
- **Slow Validation**: Validation taking longer than expected
- **Recurring Failures**: Same modules repeatedly failing validation
- **System Degradation**: Overall validation health declining

## Configuration

### Validation Configuration
```json
{
  "validation_settings": {
    "strict_mode": true,
    "parallel_validation": true,
    "cache_results": true,
    "timeout_seconds": 300,
    "max_concurrent_validations": 10
  },
  "thresholds": {
    "validation_failure_rate": 0.05,
    "validation_duration_warning": 60,
    "complexity_threshold": 100,
    "dependency_depth_limit": 10
  },
  "notifications": {
    "on_failure": "immediate",
    "on_warning": "summary",
    "on_success": "none",
    "channels": ["console", "log_file"]
  }
}
```

## Usage Examples

### Before Module Update
```python
# Update naming-conventions rule
update_result = pre_update_validation_hook(
    module_id="naming-conventions",
    changes={"version": "1.0.1", "content": "updated_content"},
    options={"strict_mode": true}
)

if update_result.action == "proceed":
    apply_module_update("naming-conventions", update_result)
else:
    handle_validation_block(update_result)
```

### During System Sync
```python
# Validate entire system before sync
sync_validation = pre_update_validation_hook(
    module_id="system",
    changes={"operation": "full_sync"},
    options={"validate_all_modules": true}
)

if sync_validation.system_health.overall_health > 90:
    execute_system_sync()
else:
    address_system_health_issues(sync_validation)
```

---

**This hook ensures system integrity by validating all changes before they're applied, preventing breaking changes and maintaining system stability.**