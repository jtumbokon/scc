---
name: playwright-mcp-usage-rules
version: 1.0.0
description: Critical do's and don'ts for using Playwright MCP. Enforces proper resource management, security practices, and reliability patterns.
type: rule
cascade: automatic
category: usage-standards
author: Super-Claude System
created: 2025-10-20
dependencies: []
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [rule, playwright-mcp, usage-patterns, resource-management, security]
---

# Playwright MCP Usage Rules

## Overview
Enforces critical usage patterns and resource management practices for Playwright MCP tools, ensuring reliable, secure, and efficient browser automation operations.

## Rule Details

### Purpose
To establish essential guidelines for Playwright MCP usage that prevent resource leaks, security issues, and unreliable test execution.

### Scope
Applies to all code using Playwright MCP tools including test files, automation scripts, and any browser automation operations.

### Enforcement Level
- **Level**: error
- **Auto-fix**: partial (for common pattern fixes)
- **Cascade**: automatic

## Rule Definition

### Pattern to Match
Detects critical usage violations including:
- Browser contexts not properly closed
- Unhandled console errors and warnings
- Missing cleanup after test execution
- Inappropriate resource usage patterns
- Security vulnerabilities in automation

### MUST (Required Practices)
- **Always close browser after runs**: Ensure proper browser cleanup
- **Save console logs on error**: Capture diagnostic information
- **Use headless in CI, headed for debugging**: Appropriate browser modes
- **Isolate browser contexts**: Prevent test interference
- **Handle timeouts gracefully**: Proper timeout management
- **Validate navigation success**: Ensure page loads properly
- **Clean up resources**: Release all allocated resources

### NEVER (Prohibited Practices)
- **Leave browsers open**: Prevent resource leaks
- **Ignore console errors**: Address all issues
- **Use hardcoded waits**: Prefer auto-waiting assertions
- **Skip error handling**: Always handle potential failures
- **Mix test data**: Ensure test isolation
- **Bypass security measures**: Follow security best practices

### Examples

#### ❌ Bad Examples
```typescript
// Bad: Not closing browser context
test('bad browser management', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('test@example.com');
  // Missing: browser context cleanup
});

// Bad: Ignoring console errors
test('ignoring console errors', async ({ page }) => {
  page.on('console', () => {
    // Ignoring all console messages
  });
  await page.goto('/page-with-errors');
});

// Bad: Hardcoded waits
test('using hardcoded waits', async ({ page }) => {
  await page.goto('/slow-page');
  await page.waitForTimeout(5000); // Bad: hardcoded wait
  await expect(page.getByText('Loaded')).toBeVisible();
});

// Bad: No error handling
test('no error handling', async ({ page }) => {
  await page.goto('/unstable-page');
  await page.getByRole('button', { name: 'Submit' }).click();
  // No error handling for potential failures
});
```

#### ✅ Good Examples
```typescript
// Good: Proper browser management
test('good browser management', async ({ page }) => {
  try {
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign In' }).click();
    await expect(page.getByRole('alert')).toBeVisible();
  } catch (error) {
    // Handle errors appropriately
    console.error('Test failed:', error);
    throw error;
  }
  // Context automatically cleaned up by Playwright
});

// Good: Handling console errors
test('handling console errors', async ({ page }) => {
  const consoleMessages = [];
  page.on('console', (msg) => {
    consoleMessages.push({
      type: msg.type(),
      text: msg.text(),
      location: msg.location()
    });
  });

  await page.goto('/page-with-errors');

  // Check for errors after navigation
  const errors = consoleMessages.filter(msg => msg.type === 'error');
  if (errors.length > 0) {
    console.error('Console errors detected:', errors);
    // Take screenshot for debugging
    await page.screenshot({
      path: `error-debug-${Date.now()}.png`
    });
  }
});

// Good: Using auto-waiting assertions
test('using auto-waiting assertions', async ({ page }) => {
  await page.goto('/slow-page');
  // Good: auto-waiting assertion instead of hardcoded wait
  await expect(page.getByText('Loaded')).toBeVisible({ timeout: 10000 });
});

// Good: Proper error handling
test('proper error handling', async ({ page }) => {
  await page.goto('/unstable-page');

  try {
    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page.getByText('Success')).toBeVisible({ timeout: 5000 });
  } catch (error) {
    // Capture error state
    await page.screenshot({
      path: `submit-error-${Date.now()}.png`
    });

    // Log page state for debugging
    console.log('Page URL:', page.url());
    console.log('Page title:', await page.title());

    // Re-throw with additional context
    throw new Error(`Submit failed: ${error.message}`);
  }
});
```

## Implementation Details

### Validation Logic
The rule validates usage patterns through:
1. **Resource Management Check**: Verifies proper cleanup and resource handling
2. **Error Handling Validation**: Ensures errors are properly caught and handled
3. **Security Assessment**: Checks for security best practices
4. **Reliability Pattern Check**: Validates usage of auto-waiting and proper assertions
5. **Isolation Verification**: Ensures tests are properly isolated

### Error Messages
- **Primary**: "Playwright MCP usage rule violation detected"
- **Details**: Specific guidance on which rule was violated and how to fix it

### Auto-Fix Logic
- Suggests proper resource cleanup patterns
- Provides templates for error handling
- Recommends auto-waiting assertion alternatives
- Offers security improvement suggestions

## Configuration

### Rule Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enforce_browser_cleanup | boolean | true | Require proper browser context cleanup |
| require_error_handling | boolean | true | Require error handling for operations |
| enforce_auto_waiting | boolean | true | Require auto-waiting over hardcoded waits |
| check_console_errors | boolean | true | Require console error handling |
| enforce_isolation | boolean | true | Require test isolation practices |

### Customization Options
- Configure rule strictness for different project phases
- Adjust security requirements based on project needs
- Customize resource management requirements
- Set project-specific usage patterns

## Dependencies

### Required Modules
- Playwright MCP tool usage analysis
- Resource management validation
- Security pattern recognition

### Conflicting Rules
- May conflict with rapid prototyping approaches
- Could conflict with legacy migration strategies

## Integration

### Tool Integration
- Integrates with IDE extensions for real-time usage validation
- Works with test runners for comprehensive usage checking
- Coordinates with code review tools for pattern validation

### CI/CD Integration
- Validates usage patterns during automated testing
- Prevents merging of code with usage violations
- Provides usage compliance reports

## Security Considerations

### Critical Security Rules
- **Never expose sensitive data**: Avoid capturing screenshots with sensitive information
- **Validate all inputs**: Ensure form inputs are properly validated
- **Use secure navigation**: Validate URLs and handle redirects safely
- **Handle authentication securely**: Don't hardcode credentials in tests
- **Protect test data**: Use appropriate test data management

## Performance Considerations

### Resource Management Rules
- **Limit concurrent browser instances**: Prevent resource exhaustion
- **Use appropriate timeouts**: Balance reliability and performance
- **Optimize screenshot usage**: Avoid unnecessary captures
- **Manage test data efficiently**: Prevent memory leaks

## Testing

### Test Cases
- Browser cleanup validation
- Error handling pattern checking
- Auto-waiting usage verification
- Console error handling assessment
- Security pattern validation

### Validation Tests
- Verify rule detects all usage violations
- Test auto-fix suggestions are accurate
- Validate rule doesn't break existing functionality
- Ensure rule integrates with development workflows

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial Playwright MCP usage rules |

### Known Issues
- May require adjustment for complex automation scenarios
- Could be too strict for rapid prototyping phases
- Might need customization for different project types

### Future Improvements
- AI-powered usage pattern suggestions
- Advanced security vulnerability detection
- Performance optimization recommendations
- Custom usage templates for different scenarios

## Usage

### How to Use
The rule is automatically enforced during:
- Code writing and editing in supported IDEs
- Test execution and validation
- Code review processes and quality gates
- CI/CD pipeline validation

### Best Practices
- Always use proper resource cleanup and management
- Implement comprehensive error handling
- Prefer auto-waiting assertions over hardcoded waits
- Handle console errors and logging appropriately
- Follow security best practices for test automation
- Maintain proper test isolation to prevent interference
- Use appropriate browser modes for different environments

## Related Rules
- **playwright-testing-standards**: Complements this rule with testing quality standards
- **screenshot-naming-conventions**: Ensures proper usage of screenshot functionality
- **test-file-organization**: Supports proper resource management through organization

---

**Rule Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+