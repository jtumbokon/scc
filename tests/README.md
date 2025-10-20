# Playwright MCP Testing Integration

This directory contains the complete Playwright testing infrastructure integrated with the Super-Claude MCP system.

## 🚀 Overview

The Playwright MCP integration provides:

- **3 Specialized Agents**: E2E testing, visual regression, and UI debugging
- **5 Reusable Skills**: Browser automation capabilities
- **4 Automation Hooks**: Pre/post-test automation and event handling
- **4 Quality Rules**: Testing standards and best practices enforcement

## 📁 Directory Structure

```
tests/
├── e2e/                    # End-to-end tests
│   └── example-login.spec.ts
├── visual/                 # Visual regression tests
│   └── example-dashboard.spec.ts
├── integration/           # Integration tests (empty - ready for use)
├── unit/                  # Unit tests (empty - ready for use)
├── artifacts/             # Test artifacts
│   ├── screenshots/       # Screenshot files
│   │   ├── baseline/     # Baseline images
│   │   ├── current/      # Current test screenshots
│   │   └── diff/         # Visual diff images
│   ├── logs/            # Test logs
│   └── traces/          # Playwright traces
├── fixtures/              # Test data and utilities
│   └── test-data.ts
├── utils/                 # Test helper functions
│   └── test-helpers.ts
├── config/               # Test configuration
│   ├── global-setup.ts
│   └── global-teardown.ts
├── playwright.config.ts   # Playwright configuration
└── README.md             # This file
```

## 🤖 Available Agents

### 1. E2E Tester Agent (`e2e-tester`)
- **Trigger**: Queue status `READY_FOR_E2E_TEST`
- **Purpose**: Comprehensive end-to-end testing using Playwright MCP
- **Output**: `.spec.ts` test files with proper structure
- **Next Agent**: `visual-regression-tester`

### 2. Visual Regression Tester (`visual-regression-tester`)
- **Trigger**: Queue status `READY_FOR_VISUAL_TEST`
- **Purpose**: Screenshot comparison and visual change detection
- **Output**: Visual diff reports and regression analysis
- **Next Agent**: Terminal (marks ready for merge)

### 3. UI Debugger (`ui-debugger`)
- **Trigger**: Queue status `BUGS_FOUND`
- **Purpose**: Bug reproduction, analysis, and resolution
- **Output**: Bug fix reports with visual evidence
- **Next Agent**: `e2e-tester` (for verification)

## 🛠️ Available Skills

### Browser Screenshot (`browser-screenshot`)
- **Purpose**: Capture and organize screenshots via Playwright MCP
- **Usage**: After UI actions, bug reports, visual verification
- **Auto-Trigger**: During testing and debugging workflows

### Console Log Analyzer (`console-log-analyzer`)
- **Purpose**: Extract and analyze browser console logs
- **Usage**: Debugging, error analysis, failed test investigation
- **Auto-Trigger**: After test failures or console errors

### Form Filler (`form-filler`)
- **Purpose**: Automated form filling with test data
- **Usage**: User journey testing, form validation
- **Auto-Trigger**: During form interaction scenarios

### Playwright Test Generator (`playwright-test-generator`)
- **Purpose**: Generate .spec.ts files from test flows
- **Usage**: Test scaffolding, coverage expansion
- **Auto-Trigger**: During test creation workflows

### Visual Diff Checker (`visual-diff-checker`)
- **Purpose**: Compare screenshots for visual changes
- **Usage**: PR reviews, regression testing, UI validation
- **Auto-Trigger**: During visual testing workflows

## 🪝 Available Hooks

### Pre-Playwright Setup (`on-pre-playwright-setup`)
- **Trigger**: Before any Playwright MCP operation
- **Purpose**: Environment preparation, server validation, directory cleanup
- **Auto-Execute**: Before all Playwright tool usage

### Post-Playwright Cleanup (`on-post-playwright-cleanup`)
- **Trigger**: After any Playwright MCP operation
- **Purpose**: Artifact organization, browser cleanup, resource recovery
- **Auto-Execute**: After all Playwright tool usage

### Screenshot Taken (`on-playwright-screenshot-taken`)
- **Trigger**: After screenshot capture
- **Purpose**: Manifest updates, baseline management, visual comparison
- **Auto-Execute**: Immediately after `playwright_screenshot`

### Console Error (`on-playwright-console-error`)
- **Trigger**: On browser console errors
- **Purpose**: Error logging, state capture, agent escalation
- **Auto-Execute**: Immediately on console error detection

## 📋 Available Rules

### Playwright Testing Standards (`playwright-testing-standards`)
- **Purpose**: Enforce best practices for selectors, assertions, test structure
- **Scope**: `.spec.ts`, `.test.ts`, Playwright-related files
- **Auto-Fix**: Partial fixes for common violations

### Test File Organization (`test-file-organization`)
- **Purpose**: Enforce proper directory structure and file placement
- **Scope**: All test files and artifacts
- **Auto-Fix**: Suggests proper file locations

### Screenshot Naming Conventions (`screenshot-naming-conventions`)
- **Purpose**: Ensure consistent, searchable screenshot names
- **Scope**: All screenshot files
- **Auto-Fix**: Automatic renaming to follow conventions

### Playwright MCP Usage Rules (`playwright-mcp-usage-rules`)
- **Purpose**: Critical do's and don'ts for Playwright MCP usage
- **Scope**: All Playwright-related code
- **Auto-Fix**: Suggestions for common usage issues

## 🔄 Workflow Integration

### Standard Testing Workflow
1. **Implementation Complete** → Status: `READY_FOR_E2E_TEST`
2. **E2E Tester Agent** → Executes comprehensive tests
3. **Tests Pass** → Status: `READY_FOR_VISUAL_TEST`
4. **Visual Regression Tester** → Performs visual comparison
5. **Visual Tests Pass** → Status: `READY_FOR_MERGE`

### Bug Discovery Workflow
1. **Tests/Visual Tests Fail** → Status: `BUGS_FOUND`
2. **UI Debugger Agent** → Investigates and fixes bugs
3. **Fixes Applied** → Status: `READY_FOR_E2E_TEST`
4. **E2E Tester Agent** → Verifies fixes
5. **Fixes Verified** → Continue standard workflow

## 🚦 Usage Guidelines

### Running Tests
```bash
# Run all tests
npx playwright test

# Run E2E tests only
npx playwright test --project=e2e

# Run visual regression tests
npx playwright test --project=visual-regression

# Run tests in debug mode
npx playwright test --project=debug

# Run tests with UI
npx playwright test --headed
```

### Triggering Agents
```json
// Queue item for E2E testing
{
  "slug": "user-login-flow",
  "status": "READY_FOR_E2E_TEST",
  "spec_path": "docs/claude/working-notes/user-login.md"
}

// Queue item for bug investigation
{
  "slug": "login-button-issue",
  "status": "BUGS_FOUND",
  "bug_description": "Login button not responding on mobile",
  "reproduction_steps": ["Navigate to login page", "Click login button"]
}
```

## 📊 Quality Assurance

### Auto-Enforced Standards
- Role-based selectors over CSS selectors
- Proper test structure (Arrange-Act-Assert)
- Consistent naming conventions
- Adequate test coverage
- Proper resource management

### Visual Testing
- Baseline image management
- Automated diff generation
- Cross-browser compatibility checks
- Responsive design validation

### Error Handling
- Comprehensive console log capture
- Automatic screenshot capture on errors
- Detailed error reporting and analysis
- Integration with debugging workflows

## 🔧 Configuration

### Environment Variables
- `BASE_URL`: Base URL for tests (default: http://localhost:3000)
- `CI`: Set to true for CI environments
- `PLAYWRIGHT_SETUP_DEBUG`: Enable detailed setup logging
- `PLAYWRIGHT_SCREENSHOT_DEBUG`: Enable screenshot debug info
- `PLAYWRIGHT_CONSOLE_ERROR_DEBUG`: Enable console error debug info

### Customization
- Modify `playwright.config.ts` for project-specific settings
- Update test fixtures in `tests/fixtures/`
- Extend test helpers in `tests/utils/`
- Configure rules in `.claude/modules/rules/`

## 📈 Metrics and Monitoring

### Success Metrics
- Test execution success rate
- Visual regression accuracy
- Bug detection and resolution rate
- Agent workflow efficiency

### Artifacts Collected
- Screenshots with proper naming
- Console logs and error reports
- Visual diff images
- Test execution traces
- Performance metrics

## 🤝 Contributing

When adding new tests:
1. Follow the established directory structure
2. Use role-based selectors
3. Include proper assertions
4. Add meaningful test descriptions
5. Follow naming conventions
6. Update fixtures and helpers as needed

## 🐛 Troubleshooting

### Common Issues
- **Browser not starting**: Check server status and configuration
- **Test timeouts**: Verify page load times and network conditions
- **Visual test failures**: Check baseline images and update if needed
- **Selector not found**: Verify UI elements and page structure

### Debug Resources
- Use debug project for step-by-step execution
- Check artifact directories for logs and screenshots
- Review console error logs for JavaScript issues
- Validate test data and configuration

---

**Integration Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+