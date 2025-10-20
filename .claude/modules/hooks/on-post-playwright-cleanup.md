---
name: on-post-playwright-cleanup
version: 1.0.0
description: Post-test cleanup hook for Playwright MCP testing. Moves artifacts to correct directories, kills browser, and ensures proper resource cleanup.
type: hook
cascade: automatic
category: test-automation
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [hook, playwright, test-cleanup, automation, resource-management]
---

# Post-Playwright Cleanup Hook

## Overview
Event-driven automation hook that performs comprehensive cleanup after Playwright test execution, ensuring proper artifact organization, browser resource management, and system resource recovery.

## Hook Details

### Purpose
To maintain system hygiene and organization by cleaning up testing artifacts, closing browser resources, and restoring system state after Playwright MCP testing operations.

### Event Type
- **Trigger**: post-tool-use
- **Timing**: after
- **Frequency**: every-time

### Scope
Applies to all Playwright MCP tool operations, with special handling for test completion, browser sessions, and artifact management.

## Hook Definition

### Trigger Event
Fires after any Playwright MCP tool operation completes, particularly after test execution, screenshot capture, or browser session termination.

### Execution Context
- Completed tool: The specific Playwright tool that finished execution
- Test results: Outcomes and artifacts from the operation
- Resource state: Browser contexts and system resource usage
- Error information: Any errors or exceptions that occurred

### Expected Behavior
1. Organize and move test artifacts to proper directories
2. Close browser contexts and release browser resources
3. Clean up temporary files and sessions
4. Generate cleanup summaries and reports
5. Log cleanup completion and resource status

## Implementation Details

### Hook Logic
```typescript
interface PostPlaywrightCleanupEvent {
  tool: string;
  execution_result: ToolResult;
  artifacts: ArtifactInfo[];
  browser_contexts: BrowserContextInfo[];
  errors?: ErrorInfo[];
  timestamp: string;
}

async function executePostPlaywrightCleanup(event: PostPlaywrightCleanupEvent): Promise<void> {
  // 1. Organize test artifacts
  await organizeArtifacts(event.artifacts);

  // 2. Clean up browser resources
  await cleanupBrowserResources(event.browser_contexts);

  // 3. Remove temporary files
  await cleanupTemporaryFiles();

  // 4. Generate cleanup report
  await generateCleanupReport(event);

  // 5. Log completion status
  await logCleanupStatus(event);
}
```

### Event Data Structure
```typescript
interface PostPlaywrightCleanupEvent {
  tool: string;                    // Playwright tool that completed
  execution_result: {
    success: boolean;
    duration: number;
    output?: any;
  };
  artifacts: ArtifactInfo[];       // Generated artifacts (screenshots, logs, etc.)
  browser_contexts: BrowserContextInfo[];
  errors?: ErrorInfo[];            // Any errors that occurred
  timestamp: string;
  metadata: {
    test_context: TestContext;
    resource_usage: ResourceUsage;
  };
}
```

### Execution Flow
1. **Artifact Organization**: Move screenshots, logs, and other artifacts to appropriate directories
2. **Browser Cleanup**: Close browser contexts and release browser resources
3. **File Cleanup**: Remove temporary files and cleanup sessions
4. **Resource Recovery**: Release system resources and memory
5. **Report Generation**: Create cleanup summary and artifact inventory
6. **Status Logging**: Record cleanup completion and resource status

### Error Handling
- **Artifact Move Failures**: Attempt alternative locations or retry operations
- **Browser Context Issues**: Force close browser processes if needed
- **Permission Errors**: Log issues and continue with other cleanup tasks
- **Resource Leaks**: Implement aggressive cleanup for stuck resources

## Configuration

### Hook Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enabled | boolean | true | Whether this hook is active |
| priority | number | 80 | High priority for thorough cleanup |
| timeout | number | 15000 | Maximum cleanup time (ms) |
| force_browser_close | boolean | true | Force close browser if normal close fails |
| artifact_retention_days | number | 30 | Days to keep artifacts before cleanup |

### Trigger Conditions
- Completion of any Playwright MCP tool operation
- Test session termination events
- Manual cleanup triggers
- Error or exception scenarios

### Filtering Rules
- Runs for all Playwright operations with cleanup requirements
- Enhanced cleanup for test completion events
- Minimal cleanup for quick status checks

## Dependencies

### Required Modules
- Playwright MCP server connection
- File system access for artifact management
- Browser resource management capabilities

### External Dependencies
- File organization utilities
- Browser process management tools
- System resource monitoring

### System Requirements
- Sufficient permissions for file operations
- Access to browser process management
- Disk space for artifact organization

## Integration

### Registration
Automatically registered in the hook system for post-tool-use events with Playwright tool filtering.

### Lifecycle Management
- Executes after each Playwright operation
- Maintains cleanup state and artifact inventory
- Handles resource recovery and error scenarios

### Communication
- Logs cleanup operations to system logs
- Reports resource recovery status
- Provides artifact inventory and summaries

## Usage Examples

### Basic Hook Implementation
```typescript
// Automatic execution after Playwright test
await playwright_screenshot({
  path: "temp/screenshot.png"
});
// Hook automatically runs cleanup after screenshot capture
```

### Advanced Hook with Custom Configuration
```typescript
// Configured cleanup with custom parameters
const cleanupConfig = {
  force_browser_close: true,
  artifact_retention_days: 7,
  custom_artifact_paths: ["custom-screenshots", "test-logs"],
  generate_reports: true
};

// Hook uses configuration for cleanup
await runPlaywrightTestWithCleanup(cleanupConfig);
```

### Integration Example
```typescript
// Integration with test workflow
1. Playwright test execution completes
2. on-post-playwright-cleanup hook executes automatically
3. Screenshots and logs moved to organized directories
4. Browser resources released and cleaned up
5. Cleanup report generated and logged
```

## Testing

### Test Cases
- Artifact organization and directory management
- Browser resource cleanup and release
- Temporary file removal and session cleanup
- Error handling during cleanup operations
- Resource recovery and system restoration

### Mock Events
```typescript
const mockCleanupEvent = {
  tool: "playwright_screenshot",
  execution_result: {
    success: true,
    duration: 2500,
    output: { screenshot_path: "temp/login-success.png" }
  },
  artifacts: [
    { type: "screenshot", path: "temp/login-success.png", size: 245760 }
  ],
  browser_contexts: [
    { id: "context-1", pages: 1, status: "active" }
  ],
  timestamp: "2025-10-20T15:35:00Z"
};
```

### Integration Tests
- Hook registration and triggering
- Artifact processing and organization
- Browser cleanup effectiveness
- Error scenario handling

## Monitoring and Logging

### Logging Strategy
- Artifact movement and organization details
- Browser cleanup operations and results
- Resource recovery metrics
- Cleanup completion status and timing

### Metrics Collection
- Cleanup execution time
- Artifact organization success rate
- Browser resource release effectiveness
- Temporary file cleanup efficiency

### Debug Information
- Detailed cleanup operation logging
- Artifact inventory and organization details
- Browser context status before/after cleanup
- Resource utilization recovery metrics

## Performance

### Execution Time
- Expected completion: 3-12 seconds
- Varies based on artifact volume and browser complexity
- Optimized through parallel cleanup operations

### Resource Usage
- Moderate CPU for file operations
- Memory for artifact processing
- Disk I/O for file movement and organization

### Optimization Strategies
- Parallelize independent cleanup tasks
- Use efficient file operations
- Implement smart browser cleanup strategies
- Cache organization patterns for repeated use

## Security

### Access Control
- Write permissions only in designated artifact directories
- Browser process management access
- Read access to temporary file locations

### Data Privacy
- Secure handling of test artifacts containing sensitive data
- Proper cleanup of files with potentially sensitive content
- Secure temporary file management

### Security Considerations
- Validate artifact paths and destinations
- Prevent unauthorized file access during cleanup
- Secure browser process termination

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial post-Playwright cleanup hook creation |

### Known Issues
- May require elevated permissions for browser process termination
- Large artifact collections can slow down cleanup
- Complex browser sessions might resist normal cleanup

### Future Improvements
- Intelligent artifact categorization and organization
- Advanced browser resource optimization
- Integration with cloud storage for artifact archiving
- Custom cleanup script support

## Troubleshooting

### Common Issues
- **Artifact move failures**: Check destination permissions and disk space
- **Browser won't close**: Use force close options or process termination
- **Temporary files remain**: Verify cleanup permissions and file locks
- **Resource leaks**: Implement aggressive cleanup procedures

### Debug Mode
Enable detailed logging by setting environment variable:
```
PLAYWRIGHT_CLEANUP_DEBUG=true
```

### Performance Issues
- Optimize artifact organization strategies
- Use parallel cleanup for independent operations
- Consider incremental cleanup for large artifact sets
- Monitor system resource usage during cleanup

## Best Practices

### Hook Design Guidelines
- Ensure thorough cleanup without losing important artifacts
- Provide clear logging of cleanup operations
- Handle errors gracefully without interrupting cleanup
- Maintain system stability and resource availability

### Performance Tips
- Use parallel operations for independent cleanup tasks
- Implement efficient file organization algorithms
- Cache cleanup patterns for repeated operations
- Monitor and optimize resource usage

### Security Guidelines
- Validate all file operations and paths
- Handle potentially sensitive artifacts carefully
- Use secure browser termination methods
- Follow principle of least privilege for cleanup operations

## Related Hooks
- **on-pre-playwright-setup**: Complements this hook with pre-test setup
- **on-playwright-screenshot-taken**: Provides artifacts for this cleanup
- **on-playwright-console-error**: Handles error-specific cleanup scenarios

---

**Hook Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**Dependencies**: playwright