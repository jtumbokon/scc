---
name: on-playwright-console-error
version: 1.0.0
description: Console error handling hook for Playwright MCP. Logs errors, captures state, suggests UI debugger agent, and escalates when needed.
type: hook
cascade: automatic
category: error-handling
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_evaluate", "playwright_screenshot"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [hook, error-handling, console-errors, debugging, escalation]
---

# Playwright Console Error Hook

## Overview
Event-driven automation hook that detects and responds to browser console errors during Playwright test execution, capturing error states, logging comprehensive information, and triggering appropriate debugging responses.

## Hook Details

### Purpose
To provide immediate and intelligent response to browser console errors, ensuring comprehensive error capture, state preservation, and appropriate escalation to debugging resources.

### Event Type
- **Trigger**: custom event
- **Timing**: immediate upon error detection
- **Frequency**: every-time (for each console error)

### Scope
Applies to all Playwright MCP operations with console monitoring, particularly during test execution, form interactions, and navigation scenarios.

## Hook Definition

### Trigger Event
Fires when browser console errors are detected through Playwright's page.on('console') event handler or through explicit console log analysis.

### Execution Context
- Error details: Console error message and stack trace
- Page state: Current URL, DOM state, and user context
- Test context: Active test scenario and step information
- Browser context: Browser type, version, and configuration

### Expected Behavior
1. Capture and analyze console error details
2. Take screenshot of error state for visual evidence
3. Log comprehensive error information with context
4. Assess error severity and impact
5. Suggest appropriate debugging actions or agent escalation
6. Update queue status if error indicates bug discovery

## Implementation Details

### Hook Logic
```typescript
interface ConsoleErrorEvent {
  error_details: ConsoleError;
  page_state: PageState;
  test_context: TestContext;
  browser_context: BrowserContextInfo;
  timestamp: string;
}

async function executeConsoleErrorHandling(event: ConsoleErrorEvent): Promise<void> {
  // 1. Analyze console error details
  const errorAnalysis = await analyzeConsoleError(event.error_details);

  // 2. Capture error state screenshot
  const screenshotPath = await captureErrorState(event.page_state);

  // 3. Log comprehensive error information
  await logConsoleError(errorAnalysis, event, screenshotPath);

  // 4. Assess error severity and impact
  const severityAssessment = await assessErrorSeverity(errorAnalysis, event.test_context);

  // 5. Determine debugging response
  const debuggingResponse = await determineDebuggingResponse(severityAssessment);

  // 6. Update queue or trigger escalation if needed
  if (debuggingResponse.requires_agent_escalation) {
    await triggerDebuggingEscalation(debuggingResponse, event);
  }

  // 7. Log error handling completion
  await logErrorHandlingCompletion(errorAnalysis, debuggingResponse);
}
```

### Event Data Structure
```typescript
interface ConsoleErrorEvent {
  error_details: {
    type: string;                    // error, warning, etc.
    message: string;                 // Error message
    stack_trace?: string;            // Stack trace if available
    url?: string;                   // URL where error occurred
    line_number?: number;            // Line number if available
    column_number?: number;          // Column number if available
  };
  page_state: {
    url: string;                     // Current page URL
    title: string;                   // Page title
    dom_ready: boolean;              // DOM ready state
    active_elements: string[];       // Active interactive elements
  };
  test_context: {
    feature_slug: string;
    test_scenario: string;
    test_step?: string;
    test_actions: string[];          // Actions taken before error
  };
  browser_context: {
    name: string;                    // Browser name
    version: string;                 // Browser version
    viewport: ViewportInfo;          // Current viewport
    user_agent: string;              // User agent string
  };
  timestamp: string;
  metadata: {
    error_frequency: number;         // How many times this error occurred
    previous_occurrences?: string[]; // Previous timestamps of same error
    test_impact: string;             // Impact on test execution
  };
}
```

### Execution Flow
1. **Error Analysis**: Parse and categorize console error details
2. **State Capture**: Take screenshot and preserve page state
3. **Comprehensive Logging**: Record all error context and information
4. **Severity Assessment**: Evaluate error impact and urgency
5. **Response Determination**: Decide on appropriate debugging actions
6. **Escalation Handling**: Trigger agent escalation or queue updates
7. **Completion Logging**: Record error handling outcomes

### Error Handling
- **Screenshot Capture Failures**: Retry with alternative capture methods
- **Logging Errors**: Use fallback logging mechanisms
- **Analysis Failures**: Log raw error data for manual analysis
- **Escalation Issues**: Record escalation attempt for manual review

## Configuration

### Hook Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enabled | boolean | true | Whether this hook is active |
| priority | number | 95 | Highest priority for immediate error response |
| timeout | number | 5000 | Maximum error handling time (ms) |
| auto_screenshot | boolean | true | Automatically capture screenshot on error |
| escalation_threshold | string | "error" | Minimum error level for escalation |
| queue_update_on_bug | boolean | true | Update queue status when bugs are found |

### Trigger Conditions
- Browser console error detection via page.on('console')
- JavaScript errors during test execution
- Network errors affecting page functionality
- Unhandled promise rejections or exceptions

### Filtering Rules
- Only processes actual errors (ignores info and debug messages)
- Filters out known benign errors or warnings
- Handles repeated errors with frequency tracking
- Respects error severity thresholds for escalation

## Dependencies

### Required Modules
- Playwright MCP server connection
- Console error detection capabilities
- Screenshot capture functionality
- Queue management system access

### External Dependencies
- Error analysis and categorization tools
- Screenshot capture and storage systems
- Logging and monitoring infrastructure

### System Requirements
- Browser context with console monitoring
- Sufficient storage for error screenshots
- Access to queue management system

## Integration

### Registration
Automatically registered in the hook system for custom console error events, with integration to Playwright's console monitoring capabilities.

### Lifecycle Management
- Executes immediately upon console error detection
- Maintains error frequency and pattern tracking
- Coordinates with debugging and queue management systems

### Communication
- Logs comprehensive error information to system logs
- Updates queue status when bugs are discovered
- Triggers appropriate debugging agent escalation
- Provides error summaries and recommendations

## Usage Examples

### Basic Hook Implementation
```typescript
// Automatic error handling during test execution
await playwright_navigate({
  url: "https://localhost:3000/dashboard"
});
// If console error occurs, hook automatically handles it
```

### Advanced Hook with Custom Configuration
```typescript
// Configured error handling with custom parameters
const errorHandlingConfig = {
  auto_screenshot: true,
  escalation_threshold: "warning",
  queue_update_on_bug: true,
  custom_error_filters: [
    { pattern: "Non-critical warning", action: "log-only" },
    { pattern: "Critical error", action: "immediate-escalation" }
  ],
  notification_channels: ["slack", "email"]
};

// Hook uses configuration for error handling
await runTestWithErrorConfig(errorHandlingConfig);
```

### Integration Example
```typescript
// Integration with debugging workflow
1. Playwright test encounters console error
2. on-playwright-console-error hook executes immediately
3. Error analyzed and categorized by severity
4. Screenshot captured of error state
5. Comprehensive error information logged
6. Queue updated to "BUGS_FOUND" status if appropriate
7. UI debugger agent suggested or triggered automatically
```

## Testing

### Test Cases
- Console error detection and analysis
- Screenshot capture during error conditions
- Error severity assessment and categorization
- Queue status updates and agent escalation
- Error logging and documentation completeness

### Mock Events
```typescript
const mockConsoleErrorEvent = {
  error_details: {
    type: "error",
    message: "Cannot read property 'value' of undefined",
    stack_trace: "TypeError: Cannot read property 'value' of undefined\n    at handleSubmit (app.js:45:12)",
    url: "https://localhost:3000/login",
    line_number: 45,
    column_number: 12
  },
  page_state: {
    url: "https://localhost:3000/login",
    title: "Login Page",
    dom_ready: true,
    active_elements: ["#username", "#password", "#submit-button"]
  },
  test_context: {
    feature_slug: "user-authentication",
    test_scenario: "login-form-validation",
    test_step: "form-submission",
    test_actions: ["fill-username", "fill-password", "click-submit"]
  },
  browser_context: {
    name: "chrome",
    version: "118.0",
    viewport: { width: 1920, height: 1080 },
    user_agent: "Mozilla/5.0..."
  },
  timestamp: "2025-10-20T15:45:00Z",
  metadata: {
    error_frequency: 1,
    test_impact: "test-failure"
  }
};
```

### Integration Tests
- Hook registration and console error detection
- Error analysis and categorization accuracy
- Screenshot capture effectiveness during errors
- Queue update and agent escalation coordination

## Monitoring and Logging

### Logging Strategy
- Detailed error information and stack traces
- Page state and context at time of error
- Screenshot capture status and file locations
- Error handling actions and outcomes
- Queue updates and agent escalation status

### Metrics Collection
- Console error frequency and patterns
- Error severity distribution and trends
- Screenshot capture success rate
- Agent escalation effectiveness
- Queue update accuracy and timeliness

### Debug Information
- Complete error context and state information
- Hook execution timing and performance
- Error analysis decision logic
- Escalation triggering and outcomes

## Performance

### Execution Time
- Expected completion: 2-6 seconds per error
- Prioritized for immediate error response
- Optimized for minimal test disruption

### Resource Usage
- Low CPU for error analysis
- Memory for screenshot capture and storage
- Disk I/O for error logging and screenshots

### Optimization Strategies
- Use efficient error analysis algorithms
- Implement smart escalation decision logic
- Optimize screenshot capture for error conditions
- Cache error patterns for faster recognition

## Security

### Access Control
- Read access to browser console output
- Screenshot capture permissions
- Queue management access for status updates
- Logging and monitoring system access

### Data Privacy
- Secure handling of potentially sensitive error messages
- Appropriate handling of screenshots with sensitive data
- Secure logging of error information

### Security Considerations
- Validate error information before logging or escalation
- Handle potentially sensitive content in screenshots appropriately
- Use secure queue update mechanisms

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial Playwright console error hook creation |

### Known Issues
- Some errors may not trigger console events consistently
- Screenshot capture might fail during certain error conditions
- Error analysis may be limited by available stack trace information

### Future Improvements
- Advanced error pattern recognition and categorization
- AI-powered error severity assessment
- Integration with external error monitoring services
- Custom error handling workflows and responses

## Troubleshooting

### Common Issues
- **Console errors not detected**: Verify console event handler setup
- **Screenshot capture fails**: Check browser state and permissions
- **Queue updates not working**: Verify queue system access and permissions
- **Agent escalation not triggered**: Check escalation configuration and criteria

### Debug Mode
Enable detailed logging by setting environment variable:
```
PLAYWRIGHT_CONSOLE_ERROR_DEBUG=true
```

### Performance Issues
- Optimize error analysis algorithms
- Use efficient screenshot capture methods
- Implement smart error filtering to reduce false positives
- Monitor and optimize resource usage

## Best Practices

### Hook Design Guidelines
- Respond immediately to console errors for maximum debugging value
- Capture comprehensive error context and state information
- Provide appropriate escalation based on error severity and impact
- Coordinate effectively with debugging and testing workflows

### Performance Tips
- Use efficient error analysis and categorization
- Implement smart screenshot capture strategies
- Cache error patterns for faster recognition
- Optimize escalation decision logic

### Security Guidelines
- Handle potentially sensitive error information appropriately
- Validate error data before logging or escalation
- Use secure methods for queue updates and agent communication
- Follow principle of least privilege

## Related Hooks
- **on-pre-playwright-setup**: Prepares environment for error monitoring
- **on-playwright-screenshot-taken**: May capture screenshots that reveal errors
- **on-post-playwright-cleanup**: Handles cleanup after error scenarios

---

**Hook Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**Dependencies**: playwright_evaluate, playwright_screenshot