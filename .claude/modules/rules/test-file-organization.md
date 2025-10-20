---
name: test-file-organization
version: 1.0.0
description: Organizational standards for Playwright test files and artifacts. Enforces proper directory structure and naming conventions.
type: rule
cascade: automatic
category: organization-standards
author: Super-Claude System
created: 2025-10-20
dependencies: []
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [rule, test-organization, file-structure, naming-conventions]
---

# Test File Organization Rule

## Overview
Enforces consistent organizational standards for Playwright test files, artifacts, and related resources, ensuring maintainable project structure and efficient test management.

## Rule Details

### Purpose
To establish clear guidelines for test file organization, directory structure, and naming conventions that support scalable and maintainable testing practices.

### Scope
Applies to all test-related files including Playwright test files, test data, configuration files, and test artifacts such as screenshots and logs.

### Enforcement Level
- **Level**: error
- **Auto-fix**: partial (for file moves and renaming)
- **Cascade**: automatic

## Rule Definition

### Pattern to Match
Detects organizational violations including:
- Test files in incorrect directories
- Inconsistent naming conventions
- Missing required directory structure
- Improper artifact organization
- Mixed test types in single files

### Expected Behavior
Project should follow this organizational structure:
```
tests/
├── e2e/                    # End-to-end tests
│   ├── auth/              # Authentication tests
│   ├── checkout/          # Checkout flow tests
│   └── dashboard/         # Dashboard tests
├── visual/                 # Visual regression tests
│   ├── components/        # Component visual tests
│   └── pages/            # Page visual tests
├── integration/           # Integration tests
├── unit/                  # Unit tests (if using Playwright)
├── artifacts/             # Test artifacts
│   ├── screenshots/       # Screenshot files
│   │   ├── baseline/     # Baseline images
│   │   ├── current/      # Current test screenshots
│   │   └── diff/         # Visual diff images
│   ├── logs/            # Test logs
│   └── traces/          # Playwright traces
├── fixtures/              # Test data and fixtures
├── utils/                 # Test utilities and helpers
├── config/               # Test configuration
└── playwright.config.ts   # Playwright configuration
```

### Examples

#### ❌ Bad Examples
```
// Poor file organization
src/
  components/
    Button.test.tsx          # Test mixed with source
  forms/
    LoginForm.tsx
    login-test.spec.ts      # Inconsistent naming
tests/
  auth.spec.ts              # Not organized by feature
  visual-tests/
    button.png              # Unclear naming
  temp/                    # Unorganized temporary files
    screenshot1.png
    test-log.txt
```

#### ✅ Good Examples
```
// Proper file organization
tests/
├── e2e/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── registration.spec.ts
│   │   └── password-reset.spec.ts
│   ├── checkout/
│   │   ├── guest-checkout.spec.ts
│   │   └── registered-checkout.spec.ts
│   └── dashboard/
│       ├── navigation.spec.ts
│       └── user-profile.spec.ts
├── visual/
│   ├── components/
│   │   ├── button.spec.ts
│   │   └── form.spec.ts
│   └── pages/
│       ├── login.spec.ts
│       └── dashboard.spec.ts
├── artifacts/
│   ├── screenshots/
│   │   ├── baseline/
│   │   │   ├── auth-login-success.png
│   │   │   └── dashboard-main.png
│   │   ├── current/
│   │   │   ├── auth-login-success-20251020-153000.png
│   │   │   └── dashboard-main-20251020-153100.png
│   │   └── diff/
│   │       ├── auth-login-success-diff.png
│   │       └── dashboard-main-diff.png
│   ├── logs/
│   │   ├── auth-login-20251020-153000.log
│   │   └── dashboard-20251020-153100.log
│   └── traces/
│       ├── auth-login.trace.zip
│       └── dashboard-main.trace.zip
├── fixtures/
│   ├── users.json
│   ├── products.json
│   └── test-data.ts
├── utils/
│   ├── test-helpers.ts
│   ├── auth-helpers.ts
│   └── data-generators.ts
├── config/
│   ├── test-config.ts
│   └── visual-config.ts
└── playwright.config.ts
```

## Implementation Details

### Validation Logic
The rule validates organization through:
1. **Directory Structure Check**: Verifies required directories exist and are properly placed
2. **File Location Validation**: Ensures files are in appropriate directories
3. **Naming Convention Check**: Validates file and directory naming consistency
4. **Artifact Organization**: Verifies proper artifact storage and organization
5. **Test Type Separation**: Ensures different test types are properly separated

### Error Messages
- **Primary**: "Test file organization violation detected"
- **Details**: Specific guidance on organizational issues and how to fix them

### Auto-Fix Logic
- Suggests proper directory locations for misplaced files
- Recommends consistent naming conventions
- Provides templates for required directory structure
- Offers file renaming suggestions for consistency

## Configuration

### Rule Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enforce_directory_structure | boolean | true | Require standard directory structure |
| naming_convention | string | "kebab-case" | File naming convention (kebab-case/camelCase/snake_case) |
| require_artifact_organization | boolean | true | Enforce proper artifact organization |
| separate_test_types | boolean | true | Require separation of test types |
| max_files_per_directory | number | 20 | Maximum files per test directory |

### Customization Options
- Configure directory structure for specific project needs
- Adjust naming conventions for different project types
- Customize artifact organization patterns
- Set project-specific file organization rules

## Dependencies

### Required Modules
- File system access for validation
- Directory structure analysis capabilities
- Pattern recognition for naming conventions

### Conflicting Rules
- May conflict with rapid prototyping approaches that prioritize speed over organization
- Could conflict with legacy project migration strategies

## Integration

### Tool Integration
- Integrates with file system watchers for real-time validation
- Works with IDE extensions for organizational suggestions
- Coordinates with file management tools for automated organization

### CI/CD Integration
- Validates project organization during build processes
- Prevents merging of disorganized test structures
- Provides organizational reports and recommendations

## Testing

### Test Cases
- Directory structure validation
- File location verification
- Naming convention consistency checking
- Artifact organization assessment
- Test type separation validation

### Validation Tests
- Verify rule detects all organizational violations
- Test auto-fix suggestions are accurate and actionable
- Validate rule doesn't produce false positives
- Ensure rule integrates with file system operations

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial test file organization rule |

### Known Issues
- May require adjustments for existing project structures
- Could be too strict for small or simple projects
- May need customization for different project types

### Future Improvements
- AI-powered organization suggestions
- Integration with project-specific organizational patterns
- Advanced pattern recognition for complex structures
- Custom organizational templates for different project types

## Usage

### How to Use
The rule is automatically enforced during:
- File creation and movement operations
- Project structure validation in CI/CD pipelines
- Code review processes and organizational audits
- Project setup and initialization

### Best Practices
- Follow consistent directory structure for scalability
- Use clear, descriptive naming conventions
- Separate different test types for maintainability
- Organize artifacts logically for easy access and analysis
- Keep test files focused and properly scoped
- Use appropriate fixture and utility organization

## Related Rules
- **playwright-testing-standards**: Complements this rule with testing quality standards
- **screenshot-naming-conventions**: Enforces proper artifact naming within organization
- **playwright-mcp-usage-rules**: Ensures proper tool usage within organized structure

---

**Rule Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+