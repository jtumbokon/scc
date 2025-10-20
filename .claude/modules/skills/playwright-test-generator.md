---
name: playwright-test-generator
version: 1.0.0
description: Generate Playwright .spec.ts files from interactive test flows. Use for scaffolding new E2E tests.
type: skill
cascade: automatic
category: code-generation
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_navigate", "playwright_click", "playwright_fill", "playwright_screenshot"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [skill, test-generation, playwright, scaffolding, automation]
---

# Playwright Test Generator Skill

## Overview
Automated Playwright test file generation capability that creates comprehensive .spec.ts files from recorded user interactions, test flows, and requirements analysis.

## Skill Details

### Purpose
To generate production-ready Playwright test files that follow best practices, include proper assertions, and provide comprehensive test coverage for web applications.

### Use Cases
- E2E test scaffolding from user flows
- Test case generation from requirements
- Regression test creation for existing features
- Test suite expansion and coverage improvement
- Documentation-driven test development

### Triggering Mechanism
- **Automatic**: yes - Triggered during test creation workflows and coverage analysis
- **Manual**: yes - Can be invoked explicitly for test generation
- **Context**: Test development, coverage expansion, documentation analysis

## Capability Definition

### Core Functionality
Generates Playwright test files using Arrange-Act-Assert pattern, includes proper selectors, assertions, and error handling based on recorded user interactions and requirements.

### Input Requirements
- Test requirements and user stories
- Target application URLs and flows
- Test data and validation criteria
- Expected outcomes and assertions

### Output Format
- Playwright .spec.ts test files
- Test documentation and comments
- Fixture and utility file suggestions
- Test data structures and examples

### Performance Characteristics
- **Execution Time**: 5-30 seconds per test file (varies with complexity)
- **Resource Usage**: Low CPU, minimal memory
- **Scalability**: Excellent for individual tests, good for batch generation

## Implementation Details

### Core Logic
Analyzes user interactions, application flows, and requirements to generate comprehensive Playwright test files with proper structure, assertions, and best practices compliance.

### Algorithm/Method
1. **Requirements Analysis**: Parse test requirements and user stories
2. **Flow Identification**: Identify key user flows and interaction paths
3. **Element Detection**: Analyze UI elements and selector strategies
4. **Test Structure**: Design Arrange-Act-Assert test structure
5. **Assertion Generation**: Create appropriate validation and assertions
6. **File Generation**: Generate complete .spec.ts test files
7. **Documentation**: Add comprehensive comments and descriptions

### Integration Points
- Playwright MCP server for interaction recording
- Requirements analysis systems
- Code generation templates
- Test file management systems

### Error Handling
- Test generation failure recovery
- Invalid interaction handling
- Selector generation error management
- Template processing error handling

## Configuration

### Skill Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| test_pattern | string | "aaa" | Test structure pattern (Arrange-Act-Assert) |
| selector_strategy | string | "role-based" | Primary selector approach |
| assertion_level | string | "comprehensive" | Assertion coverage level (basic/comprehensive) |
| documentation_style | string | "detailed" | Test comment and documentation style |
| file_organization | string | "feature-based" | Test file organization approach |

### Customization Options
- Custom test templates and patterns
- Project-specific selector strategies
- Assertion libraries and frameworks
- Integration with testing standards and guidelines

## Dependencies

### Required Modules
- Playwright MCP server connection
- Code generation templates
- Test pattern libraries

### External Dependencies
- Code generation utilities
- Template processing engines
- File system management tools

### System Requirements
- Access to application under test
- Test requirements documentation
- File system write permissions

## Usage Examples

### Basic Usage
```markdown
# Generate test from user flow
generate_playwright_test({
  feature: "user-login",
  flow: ["navigate-to-login", "enter-credentials", "submit-form", "verify-success"],
  assertions: ["login-success-visible", "user-authenticated"]
})
```

### Advanced Usage
```markdown
# Comprehensive test suite generation
generate_test_suite({
  feature: "ecommerce-checkout",
  test_scenarios: [
    "guest-checkout",
    "registered-user-checkout",
    "multiple-items-checkout",
    "payment-processing"
  ],
  test_data: {
    users: "test-users.json",
    products: "test-products.json",
    payment_methods: ["credit-card", "paypal"]
  },
  coverage_requirements: {
    happy_path: true,
    error_scenarios: true,
    edge_cases: true
  }
})
```

### Integration Example
```markdown
# Test generation in development workflow
1. Analyze feature requirements and user stories
2. Use playwright-test-generator skill to create test files
3. Review and customize generated tests
4. Run tests to validate functionality
5. Add tests to CI/CD pipeline
```

## Testing

### Test Cases
- Basic test file generation accuracy
- Complex interaction flow handling
- Assertion generation correctness
- Selector strategy effectiveness
- Template compliance validation

### Performance Tests
- Test generation speed optimization
- Large test suite handling capability
- Complex scenario processing efficiency
- Memory usage during generation

### Integration Tests
- Playwright MCP tool integration
- Template system compatibility
- File generation and organization
- Code quality and standards compliance

## Monitoring and Metrics

### Success Metrics
- Test generation accuracy and completeness
- Code quality and standards compliance
- Assertion effectiveness and coverage
- Generated test execution success rate

### Performance Metrics
- Average test generation time
- File processing efficiency
- Template rendering speed
- Resource usage during generation

### Usage Analytics
- Most commonly generated test types
- Feature coverage expansion trends
- Template usage patterns
- Generation success rates

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial Playwright test generator skill creation |

### Known Issues
- Limited to browser-accessible interactions
- Requires clear requirements and flow definitions
- May need manual customization for complex scenarios

### Future Improvements
- AI-powered test case generation
- Advanced requirement analysis capabilities
- Integration with visual testing tools
- Automated test maintenance and updates

## Troubleshooting

### Common Issues
- **Test generation fails**: Verify requirements clarity and application accessibility
- **Selector errors**: Check element accessibility and detection strategies
- **Assertion gaps**: Review test requirements and expected outcomes
- **Template errors**: Validate template syntax and structure

### Debug Information
- Requirements analysis results
- Interaction flow detection
- Element selection verification
- Template processing diagnostics

### Performance Issues
- Optimize template processing
- Implement efficient analysis algorithms
- Use appropriate caching strategies
- Consider parallel generation for multiple tests

### Quality Issues
- Review and update test templates
- Improve assertion generation logic
- Enhance selector strategies
- Refine documentation generation

## Best Practices

### Usage Guidelines
- Provide clear and detailed test requirements
- Use consistent naming conventions for tests
- Include comprehensive assertion coverage
- Follow Playwright best practices and standards

### Performance Tips
- Use efficient template processing
- Implement appropriate caching strategies
- Optimize analysis algorithms
- Consider batch generation for multiple tests

### Integration Guidelines
- Integrate with existing development workflows
- Coordinate with test management systems
- Follow project-specific testing standards
- Maintain consistent code organization

## Related Skills
- **form-filler**: Can generate tests involving form interactions
- **browser-screenshot**: Can be included in generated tests for visual validation
- **visual-diff-checker**: Can complement generated tests with visual regression

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**MCP Dependencies**: playwright_navigate, playwright_click, playwright_fill, playwright_screenshot