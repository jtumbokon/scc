---
id: command-002
type: command
version: 1.0.0
description: Validates system integrity and provides detailed health reports
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Validate System Command (command-002)

## Purpose
Comprehensive system validation that checks all modules, dependencies, and system integrity to ensure the Super-Claude hierarchical system is functioning correctly.

## Command Syntax

### Basic Usage
```
/validate-system
```

### With Options
```
/validate-system [--fix] [--verbose] [--module=<module-id>] [--format=<output-format>]
```

### Advanced Usage
```
/validate-system --deep-scan --performance-check --security-scan
/validate-system --export-report=<path> --email-results=<address>
/validate-system --compare-with-baseline=<timestamp>
```

## Command Options

### Core Options
- `--fix`: Automatically fix detected issues
- `--verbose`: Show detailed validation output
- `--quiet`: Minimal output, show only critical issues
- `--module=<id>`: Validate specific module only

### Output Options
- `--format=<format>`: Output format (json, yaml, table, markdown)
- `--export-report=<path>`: Save detailed report to file
- `--email-results=<address>`: Email validation results

### Advanced Options
- `--deep-scan`: Perform comprehensive deep validation
- `--performance-check`: Include performance analysis
- `--security-scan`: Include security vulnerability scan
- `--compare-with-baseline=<timestamp>`: Compare with previous validation

## Validation Categories

### 1. System Integrity Validation
```python
def validate_system_integrity():
    checks = [
        {
            "name": "core_files_integrity",
            "description": "Validate core system files exist and are valid",
            "check": validate_core_files,
            "severity": "critical"
        },
        {
            "name": "directory_structure",
            "description": "Verify required directory structure",
            "check": validate_directory_structure,
            "severity": "critical"
        },
        {
            "name": "configuration_consistency",
            "description": "Check configuration file consistency",
            "check": validate_configuration_consistency,
            "severity": "error"
        }
    ]

    results = []
    for check in checks:
        result = check["check"]()
        results.append({
            "name": check["name"],
            "description": check["description"],
            "severity": check["severity"],
            "status": result.status,
            "details": result.details,
            "fixes": result.fixes if hasattr(result, 'fixes') else []
        })

    return results
```

### 2. Module Validation
```python
def validate_all_modules():
    modules = get_all_modules()
    validation_results = []

    for module in modules:
        result = validate_single_module(module)
        validation_results.append(result)

    return {
        "total_modules": len(modules),
        "valid_modules": sum(1 for r in validation_results if r.status == "valid"),
        "invalid_modules": sum(1 for r in validation_results if r.status == "invalid"),
        "warning_modules": sum(1 for r in validation_results if r.status == "warning"),
        "details": validation_results
    }

def validate_single_module(module):
    checks = [
        check_module_metadata(module),
        check_module_dependencies(module),
        check_module_content(module),
        check_module_version(module),
        check_module_integrity(module)
    ]

    overall_status = determine_overall_status(checks)

    return ModuleValidationResult(
        module_id=module.id,
        module_type=module.type,
        status=overall_status,
        checks=checks,
        recommendations=generate_recommendations(checks)
    )
```

### 3. Dependency Graph Validation
```python
def validate_dependency_graph():
    graph = get_dependency_graph()

    checks = [
        {
            "name": "circular_dependencies",
            "result": detect_circular_dependencies(graph),
            "severity": "critical"
        },
        {
            "name": "orphaned_modules",
            "result": detect_orphaned_modules(graph),
            "severity": "warning"
        },
        {
            "name": "missing_dependencies",
            "result": detect_missing_dependencies(graph),
            "severity": "error"
        },
        {
            "name": "version_conflicts",
            "result": detect_version_conflicts(graph),
            "severity": "warning"
        }
    ]

    return {
        "graph_health_score": calculate_graph_health_score(graph, checks),
        "total_nodes": len(graph.nodes),
        "total_edges": len(graph.edges),
        "checks": checks
    }
```

### 4. Performance Validation
```python
def validate_system_performance():
    metrics = [
        {
            "name": "dependency_graph_size",
            "value": get_graph_size(),
            "threshold": {"warning": 1000, "critical": 5000}
        },
        {
            "name": "cascade_performance",
            "value": measure_cascade_performance(),
            "threshold": {"warning": 5.0, "critical": 10.0}  # seconds
        },
        {
            "name": "validation_performance",
            "value": measure_validation_performance(),
            "threshold": {"warning": 2.0, "critical": 5.0}  # seconds
        },
        {
            "name": "memory_usage",
            "value": get_memory_usage(),
            "threshold": {"warning": 256, "critical": 512}  # MB
        }
    ]

    return analyze_performance_metrics(metrics)
```

### 5. Security Validation
```python
def validate_system_security():
    security_checks = [
        check_file_permissions(),
        check_module_integrity(),
        check_dependency_vulnerabilities(),
        check_configuration_security(),
        check_access_controls()
    ]

    return {
        "security_score": calculate_security_score(security_checks),
        "vulnerabilities_found": count_vulnerabilities(security_checks),
        "critical_issues": get_critical_issues(security_checks),
        "recommendations": generate_security_recommendations(security_checks)
    }
```

## Output Examples

### Basic Validation Output
```
🔍 Validating Super-Claude System...

✅ System Integrity: PASSED
   • Core files present and valid
   • Directory structure correct
   • Configuration consistent

✅ Module Validation: PASSED
   • 14 modules validated
   • 14 valid, 0 invalid, 0 warnings

✅ Dependency Graph: PASSED
   • Graph health score: 100%
   • No circular dependencies
   • No missing dependencies

✅ Performance: PASSED
   • Graph size: 14 nodes (optimal)
   • Cascade performance: 0.15s (excellent)
   • Memory usage: 45MB (optimal)

🎉 System Validation: PASSED
   Overall Health Score: 100%
   Ready for operations
```

### Detailed JSON Output
```json
{
  "validation_result": {
    "status": "passed",
    "timestamp": "2025-10-19T10:30:00Z",
    "duration_seconds": 2.3,
    "overall_health_score": 100,
    "validation_categories": {
      "system_integrity": {
        "status": "passed",
        "checks_passed": 3,
        "checks_failed": 0,
        "issues_found": []
      },
      "module_validation": {
        "status": "passed",
        "total_modules": 14,
        "valid_modules": 14,
        "invalid_modules": 0,
        "warning_modules": 0
      },
      "dependency_graph": {
        "status": "passed",
        "health_score": 100,
        "circular_dependencies": 0,
        "orphaned_modules": 0,
        "missing_dependencies": 0
      },
      "performance": {
        "status": "passed",
        "metrics": {
          "graph_size": {"value": 14, "status": "optimal"},
          "cascade_performance": {"value": 0.15, "status": "excellent"},
          "memory_usage": {"value": 45, "status": "optimal"}
        }
      }
    }
  },
  "recommendations": [],
  "next_validation_due": "2025-10-20T10:30:00Z"
}
```

### Validation with Issues
```
⚠️  System Validation: WARNING
   Overall Health Score: 85%

🔍 Issues Found:
❌ Module Validation: FAILED
   • 1 invalid module found:
     → agent-001: Missing required field 'configuration'
   • 2 modules with warnings:
     → template-001: Deprecated syntax detected
     → skill-001: Performance optimization available

⚠️  Dependency Graph: WARNING
   • 1 orphaned module found:
     → unused-template.md
   • 2 version conflicts detected:
     → template-001 requires v2.0.0, but v1.0.0 is installed

💡 Recommendations:
1. Fix agent-001 configuration issue
2. Update template-001 to latest version
3. Remove unused-template.md or update dependencies
4. Optimize skill-001 for better performance

🔧 Auto-Fix Available: Run with --fix to automatically resolve issues
```

## Auto-Fix Capabilities

### Auto-Fix Rules
```python
AUTO_FIX_RULES = {
    "missing_frontmatter": fix_missing_frontmatter,
    "invalid_id_format": fix_id_format,
    "missing_dependencies": add_missing_dependencies,
    "version_conflicts": resolve_version_conflicts,
    "orphaned_modules": reconnect_orphaned_modules,
    "file_permissions": fix_file_permissions,
    "configuration_errors": fix_configuration_errors
}
```

### Fix Execution Flow
```python
def execute_auto_fixes(issues, dry_run=False):
    fixes_applied = []
    fixes_failed = []

    for issue in issues:
        if issue.auto_fixable:
            try:
                if not dry_run:
                    result = apply_fix(issue)
                    fixes_applied.append(result)
                else:
                    fixes_applied.append({"issue": issue, "status": "would_fix"})
            except Exception as e:
                fixes_failed.append({"issue": issue, "error": str(e)})

    return {
        "fixes_applied": fixes_applied,
        "fixes_failed": fixes_failed,
        "success_rate": len(fixes_applied) / len(issues) if issues else 100
    }
```

## Integration Points

### Required Components
- Dependency Graph System
- Module Registry
- Validation Rules Engine
- Performance Monitoring

### External Integrations
- **File System**: Validate file integrity and permissions
- **Git**: Check version control consistency
- **CI/CD**: Integrate with pipeline validation
- **Monitoring**: Report validation metrics

## Performance Optimization

### Caching Strategy
- **Validation Results Cache**: Cache validation results for unchanged modules
- **Performance Metrics Cache**: Cache performance measurements
- **Dependency Cache**: Cache dependency analysis results

### Parallel Processing
- **Multi-threaded Validation**: Validate modules in parallel
- **Concurrent Checks**: Run multiple validation categories simultaneously
- **Async Operations**: Use async I/O for file operations

## Monitoring and Alerts

### Validation Metrics
- **Validation Success Rate**: Percentage of validations that pass
- **Validation Duration**: Time to complete validations
- **Issue Detection Rate**: Number of issues found per validation
- **Fix Success Rate**: Success rate of auto-fix operations

### Alert Conditions
- **Critical Issues**: Immediate alert for critical validation failures
- **Performance Degradation**: Alert when validation performance degrades
- **Recurring Issues**: Alert when same issues persist across validations

## Best Practices

### Validation Frequency
- **Before Operations**: Always validate before making changes
- **Regular Schedule**: Daily/weekly scheduled validations
- **After Changes**: Validate after any system modifications
- **Performance Monitoring**: Monitor validation performance over time

### Issue Resolution
- **Prioritize Critical Issues**: Address critical issues immediately
- **Track Issue Trends**: Monitor recurring issues
- **Document Fixes**: Document issue resolution procedures
- **Preventive Measures**: Implement preventive measures for common issues

---

**This command ensures system reliability through comprehensive validation and automatic issue resolution.**