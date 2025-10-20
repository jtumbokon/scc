---
name: on-playwright-screenshot-taken
version: 1.0.0
description: Screenshot processing hook for Playwright MCP. Updates visual regression manifest, creates baselines, and organizes screenshots.
type: hook
cascade: automatic
category: visual-testing
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_screenshot"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [hook, screenshot, visual-testing, manifest-management, organization]
---

# Playwright Screenshot Taken Hook

## Overview
Event-driven automation hook that processes screenshots captured by Playwright MCP, updating visual regression manifests, creating baseline images when needed, and organizing screenshots for effective testing workflows.

## Hook Details

### Purpose
To maintain comprehensive visual testing infrastructure by automatically processing, organizing, and tracking screenshots captured during Playwright test execution.

### Event Type
- **Trigger**: post-tool-use
- **Timing**: after
- **Frequency**: every-time (specific to screenshot operations)

### Scope
Applies exclusively to Playwright MCP screenshot capture operations, with integration to visual regression testing systems and manifest management.

## Hook Definition

### Trigger Event
Fires immediately after `playwright_screenshot` tool completes successfully, with access to the captured screenshot file and metadata.

### Execution Context
- Screenshot file: Path and properties of captured image
- Test context: Feature, scenario, and test information
- Visual manifest: Current visual regression manifest state
- Baseline status: Whether baseline images exist for comparison

### Expected Behavior
1. Analyze screenshot metadata and context
2. Update visual regression manifest with screenshot information
3. Create baseline images if they don't exist
4. Organize screenshots in proper directory structure
5. Trigger visual comparison if baseline exists
6. Log screenshot processing status and outcomes

## Implementation Details

### Hook Logic
```typescript
interface ScreenshotTakenEvent {
  screenshot_path: string;
  screenshot_metadata: ScreenshotMetadata;
  test_context: TestContext;
  visual_manifest: VisualManifest;
  timestamp: string;
}

async function executeScreenshotProcessing(event: ScreenshotTakenEvent): Promise<void> {
  // 1. Analyze screenshot and extract metadata
  const analysis = await analyzeScreenshot(event.screenshot_path);

  // 2. Update visual regression manifest
  await updateVisualManifest(event.visual_manifest, analysis);

  // 3. Handle baseline image creation
  await manageBaselineImages(analysis, event.test_context);

  // 4. Organize screenshot in directory structure
  await organizeScreenshot(event.screenshot_path, analysis);

  // 5. Trigger visual comparison if appropriate
  if (await baselineExists(analysis)) {
    await triggerVisualComparison(analysis);
  }

  // 6. Log processing completion
  await logScreenshotProcessing(analysis, event.timestamp);
}
```

### Event Data Structure
```typescript
interface ScreenshotTakenEvent {
  screenshot_path: string;           // Path to captured screenshot file
  screenshot_metadata: {
    width: number;
    height: number;
    file_size: number;
    format: string;
    capture_timestamp: string;
  };
  test_context: {
    feature_slug: string;
    test_scenario: string;
    test_step?: string;
    viewport: ViewportInfo;
    browser_info: BrowserInfo;
  };
  visual_manifest: VisualManifest;   // Current visual regression manifest
  timestamp: string;
  metadata: {
    capture_reason: string;          // Why screenshot was taken
    comparison_needed: boolean;      // Whether visual comparison should be triggered
    baseline_required: boolean;      // Whether this should become a baseline
  };
}
```

### Execution Flow
1. **Screenshot Analysis**: Extract metadata and analyze image properties
2. **Manifest Update**: Update visual regression manifest with screenshot info
3. **Baseline Management**: Create or update baseline images as needed
4. **Directory Organization**: Move screenshots to appropriate organized locations
5. **Visual Comparison**: Trigger diff comparison if baseline exists
6. **Status Logging**: Record processing results and next steps

### Error Handling
- **Screenshot File Issues**: Verify file integrity and accessibility
- **Manifest Update Failures**: Use fallback manifest creation or retry operations
- **Baseline Creation Errors**: Log issues and continue with organization
- **Directory Permission Problems**: Use alternative locations or fix permissions

## Configuration

### Hook Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enabled | boolean | true | Whether this hook is active |
| priority | number | 85 | High priority for immediate processing |
| timeout | number | 8000 | Maximum processing time (ms) |
| auto_baseline_creation | boolean | true | Automatically create baselines when needed |
| trigger_visual_comparison | boolean | true | Trigger visual diff when baseline exists |
| manifest_update_strategy | string | "immediate" | Manifest update approach (immediate/batch) |

### Trigger Conditions
- Successful completion of playwright_screenshot operations
- Manual screenshot capture events
- Test failure screenshot captures

### Filtering Rules
- Only processes files with valid image formats
- Skips processing for screenshots below minimum size threshold
- Handles different screenshot types (full page, element, viewport) appropriately

## Dependencies

### Required Modules
- Playwright MCP server connection
- Visual regression manifest system
- File organization utilities

### External Dependencies
- Image processing and analysis tools
- Visual comparison systems
- File management and organization libraries

### System Requirements
- Sufficient disk space for screenshot organization
- Read/write permissions for screenshot directories
- Access to visual regression manifest files

## Integration

### Registration
Automatically registered in the hook system for post-tool-use events with specific filtering for playwright_screenshot operations.

### Lifecycle Management
- Executes immediately after each screenshot capture
- Maintains manifest state and baseline inventory
- Coordinates with visual regression testing workflows

### Communication
- Updates visual regression manifest with screenshot metadata
- Triggers visual comparison processes when appropriate
- Logs processing status and outcomes to system logs

## Usage Examples

### Basic Hook Implementation
```typescript
// Automatic processing after screenshot capture
await playwright_screenshot({
  path: "temp/dashboard-view.png",
  fullPage: true
});
// Hook automatically processes screenshot and updates manifest
```

### Advanced Hook with Custom Configuration
```typescript
// Configured screenshot processing with custom parameters
const screenshotConfig = {
  auto_baseline_creation: true,
  trigger_visual_comparison: true,
  custom_directory_structure: {
    baseline: "visual-tests/baseline/",
    current: "visual-tests/current/",
    diff: "visual-tests/diff/"
  },
  manifest_format: "json"
};

// Hook uses configuration for processing
await captureScreenshotWithConfig(screenshotConfig);
```

### Integration Example
```typescript
// Integration with visual testing workflow
1. Playwright test captures screenshot at key point
2. on-playwright-screenshot-taken hook processes automatically
3. Screenshot analyzed and metadata extracted
4. Visual regression manifest updated with new screenshot info
5. Baseline created if needed or visual comparison triggered
6. Results logged and made available for test reporting
```

## Testing

### Test Cases
- Screenshot metadata extraction and analysis
- Visual regression manifest updates
- Baseline image creation and management
- Directory organization and file movement
- Visual comparison triggering and coordination

### Mock Events
```typescript
const mockScreenshotEvent = {
  screenshot_path: "temp/login-success.png",
  screenshot_metadata: {
    width: 1920,
    height: 1080,
    file_size: 245760,
    format: "png",
    capture_timestamp: "2025-10-20T15:40:00Z"
  },
  test_context: {
    feature_slug: "user-authentication",
    test_scenario: "successful-login",
    viewport: { width: 1920, height: 1080 },
    browser_info: { name: "chrome", version: "118.0" }
  },
  timestamp: "2025-10-20T15:40:00Z",
  metadata: {
    capture_reason: "test-validation",
    comparison_needed: true,
    baseline_required: false
  }
};
```

### Integration Tests
- Hook registration and triggering for screenshot events
- Manifest update accuracy and completeness
- Baseline creation and management effectiveness
- Directory organization and file handling

## Monitoring and Logging

### Logging Strategy
- Screenshot analysis results and metadata
- Manifest update operations and changes
- Baseline creation and management activities
- Directory organization and file movements
- Visual comparison triggering and outcomes

### Metrics Collection
- Screenshot processing success rate
- Manifest update accuracy and timeliness
- Baseline creation frequency and success rate
- Directory organization efficiency
- Visual comparison trigger effectiveness

### Debug Information
- Detailed screenshot analysis logs
- Manifest change tracking and validation
- Baseline management operation details
- File organization and movement tracking
- Visual comparison coordination status

## Performance

### Execution Time
- Expected completion: 1-5 seconds per screenshot
- Varies based on image size and processing complexity
- Optimized through efficient analysis and organization algorithms

### Resource Usage
- Low CPU for metadata extraction
- Memory for image processing and analysis
- Disk I/O for file movement and organization

### Optimization Strategies
- Use efficient image analysis algorithms
- Implement parallel processing for multiple screenshots
- Cache directory organization patterns
- Optimize manifest update operations

## Security

### Access Control
- Read access to captured screenshot files
- Write permissions in designated screenshot directories
- Access to visual regression manifest files

### Data Privacy
- Secure handling of potentially sensitive screenshot content
- Proper access control for screenshot files
- Secure manifest management and updates

### Security Considerations
- Validate screenshot file paths and destinations
- Prevent unauthorized access to screenshot files
- Secure manifest update operations

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial Playwright screenshot taken hook creation |

### Known Issues
- Large screenshots may slow down processing
- Complex directory structures can increase organization time
- Manifest conflicts can occur with concurrent operations

### Future Improvements
- Advanced image analysis and categorization
- Intelligent baseline management strategies
- Integration with AI-powered visual analysis
- Custom manifest format support

## Troubleshooting

### Common Issues
- **Screenshot analysis fails**: Verify image file integrity and format
- **Manifest update errors**: Check file permissions and manifest validity
- **Baseline creation fails**: Verify directory permissions and disk space
- **Directory organization issues**: Check path validity and permissions

### Debug Mode
Enable detailed logging by setting environment variable:
```
PLAYWRIGHT_SCREENSHOT_DEBUG=true
```

### Performance Issues
- Optimize image analysis algorithms
- Use efficient file organization strategies
- Consider parallel processing for multiple screenshots
- Monitor and optimize resource usage

## Best Practices

### Hook Design Guidelines
- Process screenshots quickly and efficiently
- Maintain accurate and up-to-date manifest information
- Handle various screenshot types and sizes appropriately
- Coordinate effectively with visual regression testing workflows

### Performance Tips
- Use efficient image processing libraries
- Implement smart directory organization strategies
- Cache frequently used patterns and configurations
- Optimize manifest update operations

### Security Guidelines
- Validate all screenshot file operations
- Handle potentially sensitive content appropriately
- Use secure file management practices
- Follow principle of least privilege

## Related Hooks
- **on-pre-playwright-setup**: Prepares environment for screenshot capture
- **on-post-playwright-cleanup**: Handles final cleanup after screenshot processing
- **on-playwright-console-error**: May trigger error-specific screenshots

---

**Hook Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**Dependencies**: playwright_screenshot