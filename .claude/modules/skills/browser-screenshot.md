---
name: browser-screenshot
version: 1.0.0
description: Capture and organize browser screenshots via Playwright MCP. Use after UI actions, for bug reports, and visual verification.
type: skill
cascade: automatic
category: browser-automation
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_screenshot"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [skill, screenshot, browser, playwright, visual-evidence]
---

# Browser Screenshot Skill

## Overview
Automated browser screenshot capture capability using Playwright MCP to create organized visual evidence for testing, debugging, and documentation purposes.

## Skill Details

### Purpose
To provide reliable and organized screenshot capture functionality for web applications during testing, debugging, and documentation processes.

### Use Cases
- Visual evidence collection after UI interactions
- Bug report documentation with visual proof
- Visual regression testing baseline creation
- Test result documentation and verification
- UI state capture for analysis

### Triggering Mechanism
- **Automatic**: yes - Triggered after UI actions, test failures, or visual states
- **Manual**: yes - Can be invoked explicitly for screenshot capture
- **Context**: Browser automation, testing, debugging, documentation

## Capability Definition

### Core Functionality
Captures high-quality browser screenshots using Playwright MCP tools with automatic file organization, proper naming conventions, and metadata management.

### Input Requirements
- Target URL or page reference
- Screenshot capture coordinates or full page option
- Desired filename or naming pattern
- Output directory specification
- Capture timing and conditions

### Output Format
- PNG/JPEG screenshot files
- Metadata files with capture context
- Organized directory structure
- Naming convention compliance

### Performance Characteristics
- **Execution Time**: 1-5 seconds per screenshot
- **Resource Usage**: Low CPU, moderate memory for image processing
- **Scalability**: Excellent for individual captures, good for batch operations

## Implementation Details

### Core Logic
Uses Playwright MCP's screenshot functionality with enhanced file organization, automatic naming, and metadata management to provide comprehensive screenshot capture services.

### Algorithm/Method
1. **Validation**: Verify browser context and target element/page
2. **Preparation**: Set up capture conditions and parameters
3. **Capture**: Execute screenshot using Playwright MCP
4. **Processing**: Apply naming conventions and file organization
5. **Metadata**: Add contextual information and tags
6. **Storage**: Save to appropriate directory with proper structure

### Integration Points
- Playwright MCP server for screenshot capture
- File system for organized storage
- Directory structure management
- Metadata and tagging systems

### Error Handling
- Browser context validation
- File system permission checks
- Screenshot failure recovery
- Automatic retry mechanisms
- Fallback capture strategies

## Configuration

### Skill Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| capture_format | string | "png" | Screenshot image format (png/jpeg) |
| quality | number | 90 | Image quality for JPEG format (0-100) |
| full_page | boolean | false | Capture full page or viewport only |
| naming_pattern | string | "[feature]-[state]-[timestamp]" | Filename naming pattern |
| output_directory | string | "tests/artifacts/screenshots/current/" | Default output location |

### Customization Options
- Custom naming conventions for different project types
- Conditional capture based on page state or element visibility
- Automatic resizing and optimization for storage efficiency
- Integration with cloud storage for remote access

## Dependencies

### Required Modules
- Playwright MCP server connection
- File system access permissions
- Directory structure management

### External Dependencies
- Playwright browser automation tools
- Image processing libraries
- File management utilities

### System Requirements
- Browser context access
- Sufficient storage space for screenshots
- File system write permissions

## Usage Examples

### Basic Usage
```markdown
# Capture screenshot after UI action
playwright_screenshot({
  path: "tests/artifacts/screenshots/current/login-success-2025-10-20T15-30-00.png",
  fullPage: true
})
```

### Advanced Usage
```markdown
# Organized screenshot capture with metadata
capture_screenshot({
  feature: "user-registration",
  state: "form-validation-error",
  selector: "#registration-form",
  metadata: {
    browser: "chrome",
    viewport: "1920x1080",
    test_case: "REG-001"
  }
})
```

### Integration Example
```markdown
# Screenshot capture within test workflow
1. Navigate to target page
2. Execute UI interaction
3. Capture screenshot with browser-screenshot skill
4. Analyze results or continue testing
5. Organize screenshots in proper directory structure
```

## Testing

### Test Cases
- Basic screenshot capture functionality
- File naming convention compliance
- Directory structure organization
- Error handling and recovery
- Multiple capture scenarios

### Performance Tests
- Capture speed optimization
- Memory usage during capture
- Batch processing efficiency
- File I/O performance validation

### Integration Tests
- Playwright MCP tool integration
- File system interaction
- Directory creation and management
- Metadata generation and storage

## Monitoring and Metrics

### Success Metrics
- Screenshot capture success rate
- File organization accuracy
- Naming convention compliance
- Integration reliability

### Performance Metrics
- Average capture time
- File size optimization
- Storage utilization efficiency
- Error recovery time

### Usage Analytics
- Most captured features/pages
- Common capture patterns
- Peak usage times
- Storage growth trends

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial browser screenshot skill creation |

### Known Issues
- Limited to visible browser viewport unless full page specified
- Requires proper browser context setup
- May need custom selectors for dynamic content

### Future Improvements
- Automatic optimization for different use cases
- Integration with cloud storage services
- Advanced image processing capabilities
- AI-powered screenshot analysis

## Troubleshooting

### Common Issues
- **Screenshot capture fails**: Verify browser context and page state
- **File not saved**: Check directory permissions and disk space
- **Naming convention errors**: Validate pattern parameters and special characters
- **Poor image quality**: Adjust format and quality settings

### Debug Information
- Browser context status
- Page load state verification
- File system accessibility checks
- Screenshot tool response analysis

### Performance Issues
- Optimize image quality settings
- Use appropriate file formats
- Implement capture timing optimization
- Consider batch processing for multiple captures

### Quality Issues
- Adjust capture timing for page load completion
- Verify element visibility before capture
- Use appropriate viewport settings
- Implement wait strategies for dynamic content

## Best Practices

### Usage Guidelines
- Follow consistent naming conventions
- Capture screenshots at meaningful test points
- Organize files in logical directory structures
- Include relevant metadata for context

### Performance Tips
- Use appropriate image formats for different needs
- Implement efficient file organization
- Optimize capture timing and conditions
- Consider storage optimization strategies

### Integration Guidelines
- Integrate with existing test workflows
- Follow project-specific naming conventions
- Coordinate with other testing and debugging tools
- Maintain consistent file organization standards

## Related Skills
- **console-log-analyzer**: Complements screenshot capture with log analysis
- **visual-diff-checker**: Uses screenshots for visual comparison
- **form-filler**: Can trigger screenshot capture after form interactions

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**MCP Dependencies**: playwright_screenshot