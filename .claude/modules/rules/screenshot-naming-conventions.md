---
name: screenshot-naming-conventions
version: 1.0.0
description: Naming scheme standards for all Playwright screenshots. Ensures consistent, searchable, and organized screenshot file names.
type: rule
cascade: automatic
category: naming-standards
author: Super-Claude System
created: 2025-10-20
dependencies: []
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [rule, screenshot-naming, file-naming, visual-testing, organization]
---

# Screenshot Naming Conventions Rule

## Overview
Enforces consistent and descriptive naming conventions for all Playwright screenshots, ensuring organized visual assets that support effective debugging, documentation, and visual regression testing.

## Rule Details

### Purpose
To establish clear naming standards for screenshot files that make them easily identifiable, searchable, and organized for visual testing workflows.

### Scope
Applies to all screenshot files captured during Playwright test execution, including baseline images, current test screenshots, visual diff images, and error screenshots.

### Enforcement Level
- **Level**: error
- **Auto-fix**: yes (for automatic screenshot naming)
- **Cascade**: automatic

## Rule Definition

### Pattern to Match
Detects naming convention violations including:
- Non-descriptive or generic screenshot names
- Inconsistent naming patterns
- Missing context or scenario information
- Improper timestamp formats
- Unclear file organization

### Expected Behavior
Screenshots should follow these naming patterns:

#### Test Run Screenshots
```
[feature]-[action]-[state]-[timestamp].png
Examples:
- login-form-success-20251020-153000.png
- checkout-payment-error-20251020-153100.png
- dashboard-load-complete-20251020-153200.png
```

#### Baseline Images
```
baseline/[feature]-[state].png
Examples:
- baseline/login-form-success.png
- baseline/dashboard-main.png
- baseline/checkout-summary.png
```

#### Visual Diff Images
```
diff/[feature]-[state]-diff.png
Examples:
- diff/login-form-success-diff.png
- diff/dashboard-main-diff.png
- diff/checkout-summary-diff.png
```

#### Error Screenshots
```
errors/[feature]-[error-type]-[timestamp].png
Examples:
- errors/login-validation-failed-20251020-153000.png
- errors/network-timeout-20251020-153100.png
- errors/javascript-error-20251020-153200.png
```

### Examples

#### ❌ Bad Examples
```
// Poor screenshot naming
screenshot1.png
test.png
error.png
login_test_2023-10-20_15-30-00.png
Screenshot (1).png
image.png
```

#### ✅ Good Examples
```
// Proper screenshot naming
login-form-submit-success-20251020-153000.png
user-registration-validation-error-20251020-153100.png
dashboard-navigation-profile-click-20251020-153200.png
checkout-payment-processing-timeout-20251020-153300.png
```

## Implementation Details

### Validation Logic
The rule validates screenshot naming through:
1. **Pattern Recognition**: Checks adherence to defined naming patterns
2. **Descriptiveness Assessment**: Validates names provide meaningful context
3. **Consistency Check**: Ensures naming follows project conventions
4. **Timestamp Validation**: Verifies proper timestamp format
5. **Directory Compliance**: Checks files are in appropriate directories

### Error Messages
- **Primary**: "Screenshot naming convention violation detected"
- **Details**: Specific guidance on naming issues and suggested corrections

### Auto-Fix Logic
- Automatically renames screenshots to follow conventions
- Suggests appropriate names based on test context
- Organizes screenshots in proper directory structure
- Applies consistent timestamp formatting

## Configuration

### Rule Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| naming_pattern | string | "[feature]-[action]-[state]-[timestamp]" | Standard naming pattern |
| timestamp_format | string | "YYYYMMDD-HHmmss" | Timestamp format |
| require_timestamp | boolean | true | Require timestamp in screenshot names |
| enforce_descriptive_names | boolean | true | Require meaningful, descriptive names |
| auto_rename_violations | boolean | true | Automatically rename violating files |

### Customization Options
- Configure naming patterns for different project types
- Adjust timestamp format preferences
- Customize naming rules for different screenshot types
- Set project-specific naming conventions

## Dependencies

### Required Modules
- File system access for validation and renaming
- Pattern recognition for naming compliance
- Test context analysis for automatic naming

### Conflicting Rules
- May conflict with legacy screenshot naming systems
- Could conflict with external tool integration requirements

## Integration

### Tool Integration
- Integrates with Playwright screenshot capture for automatic naming
- Works with visual testing tools for consistent organization
- Coordinates with file management systems for automated organization

### CI/CD Integration
- Validates screenshot naming during test execution
- Ensures consistent naming across test environments
- Provides naming compliance reports

## Testing

### Test Cases
- Naming pattern validation and compliance
- Automatic renaming functionality
- Timestamp format verification
- Directory organization compliance
- Descriptive name validation

### Validation Tests
- Verify rule detects all naming violations
- Test auto-naming accuracy and effectiveness
- Validate rule doesn't break existing functionality
- Ensure rule integrates with screenshot capture workflows

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial screenshot naming conventions rule |

### Known Issues
- May require migration of existing screenshot files
- Could conflict with external tool naming requirements
- Might need customization for special naming scenarios

### Future Improvements
- AI-powered descriptive naming suggestions
- Integration with test context for automatic naming
- Advanced pattern recognition for complex scenarios
- Custom naming templates for different project types

## Usage

### How to Use
The rule is automatically enforced during:
- Screenshot capture operations in Playwright tests
- File system operations involving screenshot files
- Test execution and artifact management
- Visual regression testing workflows

### Best Practices
- Use descriptive names that clearly indicate what the screenshot shows
- Include feature/page context for easy identification
- Add action or state information for test scenario clarity
- Use consistent timestamps for chronological organization
- Organize screenshots in appropriate directory structures
- Follow project-specific naming conventions consistently

## Directory Structure Integration
This rule works with the test-file-organization rule to ensure screenshots are properly named and placed:

```
tests/artifacts/screenshots/
├── baseline/
│   ├── login-form-success.png
│   ├── dashboard-main.png
│   └── checkout-summary.png
├── current/
│   ├── login-form-success-20251020-153000.png
│   ├── dashboard-main-20251020-153100.png
│   └── checkout-summary-20251020-153200.png
├── diff/
│   ├── login-form-success-diff.png
│   ├── dashboard-main-diff.png
│   └── checkout-summary-diff.png
└── errors/
    ├── login-validation-failed-20251020-153000.png
    ├── network-timeout-20251020-153100.png
    └── javascript-error-20251020-153200.png
```

## Related Rules
- **test-file-organization**: Ensures screenshots are in proper directories
- **playwright-testing-standards**: Complements naming with testing quality standards
- **playwright-mcp-usage-rules**: Ensures proper tool usage for screenshot capture

---

**Rule Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+