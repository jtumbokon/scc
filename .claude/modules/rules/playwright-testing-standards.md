---
name: playwright-testing-standards
version: 1.0.0
description: Standards for Playwright E2E/visual testing using MCP. Enforces best practices for selector usage, assertions, and test structure.
type: rule
cascade: automatic
category: testing-standards
author: Super-Claude System
created: 2025-10-20
dependencies: []
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [rule, playwright, testing, e2e, best-practices]
---

# Playwright Testing Standards Rule

## Overview
Enforces comprehensive testing standards for Playwright E2E and visual testing using MCP, ensuring reliable, maintainable, and effective test implementations across the project.

## Rule Details

### Purpose
To establish consistent quality standards for Playwright tests, promoting best practices in selector usage, test structure, assertions, and overall test reliability.

### Scope
Applies to all Playwright test files (.spec.ts), test-related code, and MCP tool usage for browser automation and testing.

### Enforcement Level
- **Level**: error
- **Auto-fix**: partial (for simple structural issues)
- **Cascade**: automatic

## Rule Definition

### Pattern to Match
Detects violations of Playwright testing best practices including:
- Inappropriate selector usage (CSS selectors instead of role-based)
- Missing or inadequate assertions
- Improper test structure and organization
- Insufficient test isolation and cleanup
- Missing error handling and retry logic

### Expected Behavior
Tests should follow Playwright best practices:
- Use role-based selectors (getByRole, getByLabel, etc.)
- Include proper assertions with auto-waiting
- Follow Arrange-Act-Assert pattern
- Implement proper test isolation and cleanup
- Handle errors gracefully with appropriate retry logic

### Examples

#### ❌ Bad Examples
```typescript
// Using CSS selectors instead of role-based
test('login test', async ({ page }) => {
  await page.goto('/login');
  await page.click('#submit-button');  // Bad: CSS selector
  await expect(page.locator('.success-message')).toBeVisible();  // Bad: CSS selector
});

// Missing assertions and poor structure
test('user registration', async ({ page }) => {
  await page.goto('/register');
  await page.fill('#email', 'test@example.com');
  await page.fill('#password', 'password123');
  await page.click('#register');
  // No assertion to verify success
});

// Not using auto-waiting assertions
test('navigation test', async ({ page }) => {
  await page.goto('/');
  await page.click('[href="/about"]');
  // Bad: manual wait instead of auto-waiting assertion
  await page.waitForTimeout(2000);
  expect(page.url()).toContain('/about');
});
```

#### ✅ Good Examples
```typescript
// Using role-based selectors
test('login test', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await expect(page.getByRole('alert')).toBeVisible();  // Auto-waiting assertion
});

// Proper structure with assertions
test('user registration', async ({ page }) => {
  // Arrange
  await page.goto('/register');

  // Act
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Create Account' }).click();

  // Assert
  await expect(page.getByRole('heading', { name: 'Welcome!' })).toBeVisible();
  await expect(page.getByText('Registration successful')).toBeVisible();
});

// Using auto-waiting assertions properly
test('navigation test', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: 'About' }).click();
  // Good: auto-waiting assertion that waits for navigation
  await expect(page).toHaveURL(/.*\/about/);
  await expect(page.getByRole('heading', { name: 'About Us' })).toBeVisible();
});
```

## Implementation Details

### Validation Logic
The rule validates test files through:
1. **Selector Analysis**: Checks for role-based selector usage vs CSS selectors
2. **Assertion Review**: Validates presence and appropriateness of assertions
3. **Structure Assessment**: Ensures proper test organization and AAA pattern
4. **Isolation Verification**: Confirms proper test isolation and cleanup
5. **Error Handling Check**: Validates error handling and retry logic

### Error Messages
- **Primary**: "Playwright testing standards violation detected"
- **Details**: Specific guidance on which standard was violated and how to fix it

### Auto-Fix Logic
- Suggests role-based selector alternatives for CSS selectors
- Recommends appropriate assertions for test validation
- Provides template code for proper test structure
- Suggests cleanup and isolation improvements

## Configuration

### Rule Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enforce_role_selectors | boolean | true | Require role-based selectors over CSS |
| require_assertions | boolean | true | Require proper assertions in tests |
| enforce_aha_pattern | boolean | true | Require Arrange-Act-Assert pattern |
| check_test_isolation | boolean | true | Verify proper test isolation |
| enforce_auto_waiting | boolean | true | Require auto-waiting assertions |

### Customization Options
- Configure selector preferences for specific project needs
- Adjust assertion requirements based on test complexity
- Customize test structure guidelines
- Set project-specific isolation requirements

## Dependencies

### Required Modules
- Playwright MCP server integration
- Test file parsing and analysis capabilities
- Code pattern recognition systems

### Conflicting Rules
- May conflict with rapid prototyping approaches that prioritize speed over structure
- Could conflict with legacy test migration strategies

## Integration

### Tool Integration
- Integrates with ESLint and TypeScript compilers for real-time validation
- Works with IDE extensions for inline suggestions and fixes
- Coordinates with test runners for comprehensive validation

### CI/CD Integration
- Validates test standards during automated testing pipelines
- Prevents merging of tests that don't meet quality standards
- Provides detailed feedback for test quality improvement

## Testing

### Test Cases
- Selector usage validation (role-based vs CSS)
- Assertion presence and appropriateness checking
- Test structure and organization validation
- Test isolation and cleanup verification
- Error handling and retry logic assessment

### Validation Tests
- Verify rule detects all specified violations
- Test auto-fix suggestions are accurate and helpful
- Validate rule doesn't produce false positives
- Ensure rule integrates properly with development tools

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial Playwright testing standards rule |

### Known Issues
- May require adjustments for complex testing scenarios
- Could be too strict for rapid prototyping phases
- May need calibration for different project types

### Future Improvements
- AI-powered suggestions for test improvements
- Integration with visual testing standards
- Advanced pattern recognition for complex test scenarios
- Custom rule configurations for different project types

## Usage

### How to Use
The rule is automatically enforced during:
- Code writing and editing in supported IDEs
- Test file validation in CI/CD pipelines
- Code review processes and quality gates
- Test suite analysis and reporting

### Best Practices
- Use role-based selectors for better test reliability
- Include comprehensive assertions for test validation
- Follow Arrange-Act-Assert pattern for clear test structure
- Implement proper test isolation to prevent interference
- Use auto-waiting assertions to handle timing issues
- Handle errors gracefully with appropriate retry logic

## Related Rules
- **test-file-organization**: Complements this rule with proper file organization
- **screenshot-naming-conventions**: Supports visual testing standards
- **playwright-mcp-usage-rules**: Enforces proper MCP tool usage patterns

---

**Rule Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+