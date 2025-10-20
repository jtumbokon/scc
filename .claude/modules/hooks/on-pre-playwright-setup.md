---
name: on-pre-playwright-setup
version: 1.0.0
description: Pre-test setup hook for Playwright MCP testing. Ensures test server is started, artifacts directory is clean, and environment is ready.
type: hook
cascade: automatic
category: test-automation
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [hook, playwright, test-setup, automation, pre-condition]
---

# Pre-Playwright Setup Hook

## Overview
Event-driven automation hook that prepares the testing environment before Playwright test execution, ensuring proper server status, clean artifact directories, and optimal test conditions.

## Hook Details

### Purpose
To establish a reliable and consistent testing environment by performing necessary setup tasks before any Playwright MCP testing operations begin.

### Event Type
- **Trigger**: pre-tool-use
- **Timing**: before
- **Frequency**: every-time

### Scope
Applies to all Playwright MCP tool operations including navigation, clicking, form filling, screenshot capture, and test execution.

## Hook Definition

### Trigger Event
Fires before any Playwright MCP tool is used, specifically when tools like `playwright_navigate`, `playwright_click`, `playwright_fill`, or `playwright_screenshot` are invoked.

### Execution Context
- Available tool: The specific Playwright tool being invoked
- Test context: Current test scenario and requirements
- Environment status: Server state and directory conditions
- Previous results: Any prior test execution outcomes

### Expected Behavior
1. Verify test server accessibility and status
2. Clean and prepare artifact directories
3. Validate browser context and dependencies
4. Check system resources and availability
5. Log setup status and any issues found

## Implementation Details

### Hook Logic
```typescript
interface PrePlaywrightSetupEvent {
  tool: string;
  target_url?: string;
  test_context: TestContext;
  timestamp: string;
}

async function executePrePlaywrightSetup(event: PrePlaywrightSetupEvent): Promise<void> {
  // 1. Validate test server status
  await validateTestServer();

  // 2. Prepare artifact directories
  await prepareArtifactDirectories();

  // 3. Check browser context availability
  await validateBrowserContext();

  // 4. Verify system resources
  await checkSystemResources();

  // 5. Log setup completion
  await logSetupStatus(event);
}
```

### Event Data Structure
```typescript
interface PrePlaywrightSetupEvent {
  tool: string;                    // Playwright tool being invoked
  target_url?: string;             // Target URL for navigation
  test_context: {
    feature_slug: string;
    test_scenario: string;
    test_data?: Record<string, any>;
  };
  timestamp: string;
  metadata: {
    previous_results?: TestResult[];
    environment_config: EnvironmentConfig;
  };
}
```

### Execution Flow
1. **Server Validation**: Check if test server is running and accessible
2. **Directory Setup**: Create/clean artifact directories as needed
3. **Browser Check**: Verify browser context and Playwright availability
4. **Resource Validation**: Ensure sufficient system resources
5. **Environment Setup**: Configure test environment variables
6. **Status Logging**: Record setup completion and any issues

### Error Handling
- **Server Unavailable**: Attempt automatic server start or fail gracefully
- **Directory Permissions**: Fix permission issues or create alternative directories
- **Resource Shortage**: Optimize resource usage or delay execution
- **Browser Context Issues**: Reset browser context or use alternative browser

## Configuration

### Hook Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enabled | boolean | true | Whether this hook is active |
| priority | number | 90 | High priority for critical setup |
| timeout | number | 10000 | Maximum setup time (ms) |
| auto_start_server | boolean | true | Automatically start test server if needed |
| cleanup_artifacts | boolean | true | Clean artifact directories before tests |

### Trigger Conditions
- Any Playwright MCP tool invocation
- Test execution start events
- Manual test triggering

### Filtering Rules
- Only runs for Playwright-related operations
- Skips if setup was recently completed (within 5 minutes)
- Bypasses for quick status checks or dry runs

## Dependencies

### Required Modules
- Playwright MCP server connection
- File system access for directory management
- Server status checking capabilities

### External Dependencies
- Test server management tools
- Browser context validation
- System resource monitoring

### System Requirements
- Sufficient disk space for artifacts
- Network connectivity for server access
- Appropriate permissions for directory operations

## Integration

### Registration
Automatically registered in the hook system for pre-tool-use events with Playwright tool filtering.

### Lifecycle Management
- Executes before each Playwright operation
- Maintains setup state between operations
- Handles cleanup and resource management

### Communication
- Logs setup status to system logs
- Reports errors to monitoring systems
- Provides status feedback to test runners

## Usage Examples

### Basic Hook Implementation
```typescript
// Automatic execution before Playwright test
await playwright_navigate({
  url: "https://localhost:3000/login"
});
// Hook automatically runs setup before navigation
```

### Advanced Hook with Custom Configuration
```typescript
// Configured setup with custom parameters
const setupConfig = {
  auto_start_server: true,
  cleanup_artifacts: true,
  custom_directories: ["custom-artifacts", "logs"],
  server_health_check: true
};

// Hook uses configuration for setup
await runPlaywrightTestWithConfig(setupConfig);
```

### Integration Example
```typescript
// Integration with test workflow
1. Test runner triggers Playwright test
2. on-pre-playwright-setup hook executes automatically
3. Environment validated and prepared
4. Test execution proceeds with confidence
5. Artifacts collected in prepared directories
```

## Testing

### Test Cases
- Server startup and validation
- Directory creation and cleanup
- Browser context verification
- Resource availability checking
- Error handling and recovery

### Mock Events
```typescript
const mockSetupEvent = {
  tool: "playwright_navigate",
  target_url: "https://localhost:3000",
  test_context: {
    feature_slug: "user-login",
    test_scenario: "successful-login"
  },
  timestamp: "2025-10-20T15:30:00Z"
};
```

### Integration Tests
- Hook registration and triggering
- Event data processing
- Error scenario handling
- Performance impact validation

## Monitoring and Logging

### Logging Strategy
- Server status checks and results
- Directory operations and permissions
- Resource availability metrics
- Setup completion status and timing

### Metrics Collection
- Setup execution time
- Server startup success rate
- Directory operation performance
- Error frequency and types

### Debug Information
- Detailed setup step logging
- Environment configuration details
- Resource utilization metrics
- Error stack traces and diagnostics

## Performance

### Execution Time
- Expected completion: 2-8 seconds
- Varies based on server startup needs
- Optimized through caching and state management

### Resource Usage
- Low CPU overhead for setup operations
- Moderate memory for directory operations
- Network I/O for server status checks

### Optimization Strategies
- Cache setup status between operations
- Parallelize independent setup tasks
- Use efficient directory operations
- Implement smart server health checking

## Security

### Access Control
- Read-only access to system status information
- Write permissions only in designated directories
- Network access limited to test servers

### Data Privacy
- No capture of sensitive test data
- Secure handling of server configuration
- Proper cleanup of temporary files

### Security Considerations
- Validate server URLs and endpoints
- Prevent unauthorized directory access
- Secure handling of test environment variables

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial pre-Playwright setup hook creation |

### Known Issues
- May require manual server configuration for complex environments
- Directory cleanup might remove needed files in shared environments
- Resource checking might be conservative in constrained environments

### Future Improvements
- Intelligent server type detection
- Advanced resource optimization
- Integration with container orchestration
- Custom setup script support

## Troubleshooting

### Common Issues
- **Server not starting**: Check server configuration and port availability
- **Directory permission errors**: Verify file system permissions and ownership
- **Resource shortages**: Close unnecessary applications or increase resources
- **Browser context issues**: Reset browser or check Playwright installation

### Debug Mode
Enable detailed logging by setting environment variable:
```
PLAYWRIGHT_SETUP_DEBUG=true
```

### Performance Issues
- Optimize server startup configuration
- Use SSD storage for artifact directories
- Close unnecessary background applications
- Consider increasing system resources

## Best Practices

### Hook Design Guidelines
- Keep setup operations fast and efficient
- Provide clear error messages and recovery suggestions
- Maintain compatibility with different server types
- Handle edge cases gracefully

### Performance Tips
- Cache setup status when possible
- Use asynchronous operations for independent tasks
- Implement proper timeout handling
- Optimize directory operations

### Security Guidelines
- Validate all inputs and configurations
- Use secure defaults for server settings
- Implement proper error handling without information leakage
- Follow principle of least privilege

## Related Hooks
- **on-post-playwright-cleanup**: Handles cleanup after test completion
- **on-playwright-screenshot-taken**: Processes screenshot captures
- **on-playwright-console-error**: Handles console error events

---

**Hook Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**Dependencies**: playwright