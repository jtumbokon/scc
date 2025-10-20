---
name: form-filler
version: 1.0.0
description: Use Playwright MCP to fill web forms with test data. Use during user journey testing and UI automation.
type: skill
cascade: automatic
category: browser-automation
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_navigate", "playwright_fill", "playwright_click"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [skill, forms, automation, testing, user-journey]
---

# Form Filler Skill

## Overview
Automated web form filling capability using Playwright MCP to populate forms with test data, validate inputs, and simulate user interactions during testing and automation scenarios.

## Skill Details

### Purpose
To provide reliable and intelligent form filling functionality for web applications, supporting various input types, validation scenarios, and user journey automation.

### Use Cases
- User registration and login form testing
- Checkout and payment form automation
- Survey and feedback form completion
- Data entry form validation
- Multi-step form workflow testing

### Triggering Mechanism
- **Automatic**: yes - Triggered during user journey testing and form validation
- **Manual**: yes - Can be invoked explicitly for form filling tasks
- **Context**: Testing automation, user journey simulation, form validation

## Capability Definition

### Core Functionality
Intelligently fills web forms using Playwright MCP tools, handling various input types, validation rules, and form interactions with proper timing and error handling.

### Input Requirements
- Target form selector or page reference
- Form field data and values
- Validation rules and constraints
- Submission and interaction patterns

### Output Format
- Form completion status and results
- Validation error reports
- Field interaction logs
- Submission response handling

### Performance Characteristics
- **Execution Time**: 3-15 seconds per form (varies with complexity)
- **Resource Usage**: Low CPU, minimal memory
- **Scalability**: Excellent for individual forms, good for batch processing

## Implementation Details

### Core Logic
Uses Playwright MCP's fill and click tools to interact with form elements, implements intelligent field detection, handles validation scenarios, and provides comprehensive interaction logging.

### Algorithm/Method
1. **Form Detection**: Identify target form and its elements
2. **Field Analysis**: Analyze input types and requirements
3. **Data Mapping**: Map test data to appropriate fields
4. **Interaction**: Fill fields with proper timing and validation
5. **Validation**: Check for client-side validation responses
6. **Submission**: Handle form submission and response processing
7. **Logging**: Record all interactions and results

### Integration Points
- Playwright MCP server for form interaction
- Test data management systems
- Validation rule processors
- User journey workflow coordinators

### Error Handling
- Form element detection failures
- Input validation error handling
- Network issue management during submission
- Timeout and retry mechanisms
- Fallback interaction strategies

## Configuration

### Skill Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| fill_strategy | string | "intelligent" | Form filling approach (intelligent/sequential) |
| typing_delay | number | 50 | Delay between keystrokes for realism (ms) |
| validation_wait | number | 1000 | Wait time for validation responses (ms) |
| retry_attempts | number | 3 | Number of retry attempts for failed interactions |
| data_source | string | "test-data" | Source for form data (test-data/generated) |

### Customization Options
- Custom field detection strategies
- Project-specific test data sets
- Form-specific validation handling
- Integration with external data sources

## Dependencies

### Required Modules
- Playwright MCP server connection
- Test data management system
- Form validation logic

### External Dependencies
- Browser automation tools
- Form field detection libraries
- Test data generation utilities

### System Requirements
- Browser context with form access
- Sufficient test data for form scenarios
- Network connectivity for form submission

## Usage Examples

### Basic Usage
```markdown
# Fill a simple login form
playwright_fill({
  selector: "#username",
  value: "testuser@example.com"
})
playwright_fill({
  selector: "#password",
  value: "SecurePassword123!"
})
playwright_click({
  selector: "button[type='submit']"
})
```

### Advanced Usage
```markdown
# Complex multi-step form with validation
fill_form_intelligently({
  form_selector: "#registration-form",
  test_data: {
    personal_info: {
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com"
    },
    address: {
      street: "123 Main St",
      city: "Anytown",
      zip: "12345"
    }
  },
  validation_handling: true,
  submission_handling: true
})
```

### Integration Example
```markdown
# Form filling in user journey testing
1. Navigate to registration page
2. Use form-filler skill to complete registration form
3. Handle validation and error scenarios
4. Submit form and verify success
5. Continue with next steps in user journey
```

## Testing

### Test Cases
- Basic form field filling accuracy
- Validation error handling
- Multi-step form completion
- Various input type support
- Form submission and response handling

### Performance Tests
- Form filling speed optimization
- Large form handling capability
- Complex validation scenario processing
- Batch form processing efficiency

### Integration Tests
- Playwright MCP tool integration
- Test data system coordination
- User journey workflow integration
- Validation system compatibility

## Monitoring and Metrics

### Success Metrics
- Form completion success rate
- Validation handling accuracy
- Field detection precision
- User journey completion rate

### Performance Metrics
- Average form filling time
- Field interaction efficiency
- Validation response handling speed
- Error recovery time

### Usage Analytics
- Most commonly filled forms
- Frequent validation error patterns
- Peak usage during testing cycles
- Form complexity handling trends

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial form filler skill creation |

### Known Issues
- Limited to browser-accessible forms
- Requires proper form structure and selectors
- May need custom handling for complex validation

### Future Improvements
- AI-powered form field detection
- Advanced validation handling
- Integration with CAPTCHA solving services
- Dynamic test data generation

## Troubleshooting

### Common Issues
- **Form not found**: Verify form selector and page load state
- **Field filling fails**: Check field identifiers and accessibility
- **Validation errors**: Review test data and constraint compliance
- **Submission fails**: Verify network connectivity and form requirements

### Debug Information
- Form structure analysis
- Field accessibility verification
- Input validation status
- Network request monitoring

### Performance Issues
- Optimize field detection strategies
- Implement efficient interaction timing
- Use appropriate wait conditions
- Consider parallel field filling where possible

### Quality Issues
- Review and update field detection logic
- Improve validation error handling
- Enhance test data quality
- Refine interaction timing

## Best Practices

### Usage Guidelines
- Use intelligent field detection for reliability
- Implement proper wait conditions for dynamic content
- Handle validation scenarios gracefully
- Log all form interactions for debugging

### Performance Tips
- Optimize field detection and interaction timing
- Use appropriate test data sets
- Implement efficient validation handling
- Consider batch processing for multiple forms

### Integration Guidelines
- Integrate with user journey testing workflows
- Coordinate with validation and testing systems
- Follow project-specific form handling standards
- Maintain comprehensive interaction logging

## Related Skills
- **browser-screenshot**: Can capture form states before and after filling
- **console-log-analyzer**: Can analyze form validation errors
- **playwright-test-generator**: Can generate test cases involving forms

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**MCP Dependencies**: playwright_navigate, playwright_fill, playwright_click