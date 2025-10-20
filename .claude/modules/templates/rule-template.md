---
name: rule-template
version: 1.0.0
description: Standard template for creating rule modules with consistent structure and metadata
type: rule
cascade: automatic
category: standards
author: Super-Claude System
created: 2025-10-19
dependencies: []
compatibility:
  min_system_version: 1.0.0
  max_system_version: "*"
tags: [rule, template, standards, compliance]
---

# Rule Template

## Overview
[Provide a brief description of what this rule enforces and why it's important]

## Rule Details

### Purpose
[Clearly state the primary purpose of this rule]

### Scope
[Define what files, code patterns, or situations this rule applies to]

### Enforcement Level
- **Level**: [error | warning | info]
- **Auto-fix**: [yes | no]
- **Cascade**: automatic

## Rule Definition

### Pattern to Match
[Describe the pattern that this rule detects or enforces]

### Expected Behavior
[Describe what the correct behavior should be]

### Examples

#### ❌ Bad Examples
```typescript
// Show examples that violate this rule
```

#### ✅ Good Examples
```typescript
// Show examples that follow this rule
```

## Implementation Details

### Validation Logic
[Describe how the rule is implemented and validated]

### Error Messages
- **Primary**: [Main error message shown to users]
- **Details**: [Additional context or suggestions]

### Auto-Fix Logic
[If auto-fix is enabled, describe how the rule automatically fixes issues]

## Configuration

### Rule Parameters
[If the rule accepts parameters, describe them here]

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| param1 | string | "default" | Description of parameter |
| param2 | boolean | true | Description of parameter |

### Customization Options
[Describe how users can customize the rule behavior]

## Dependencies

### Required Modules
[List any modules this rule depends on]

### Conflicting Rules
[List any rules that might conflict with this one]

## Integration

### Tool Integration
[Describe how this rule integrates with development tools]

### CI/CD Integration
[Describe how this rule works in automated pipelines]

## Testing

### Test Cases
[Describe the test cases that validate this rule]

### Validation Tests
[How to test that the rule is working correctly]

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-19 | Initial template creation |

### Known Issues
[List any known issues or limitations]

### Future Improvements
[Planned enhancements or modifications]

## Usage

### How to Use
[Instructions for how to apply or activate this rule]

### Best Practices
[Best practices related to this rule]

## Related Rules
[List related or similar rules]

---

**Rule Template Version**: 1.0.0
**Last Updated**: 2025-10-19
**System Compatibility**: Super-Claude v1.0.0+