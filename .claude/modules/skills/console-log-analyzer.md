---
name: console-log-analyzer
version: 1.0.0
description: Extract and interpret browser console log output using Playwright MCP. Use during debugging and after failed tests.
type: skill
cascade: automatic
category: debugging
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_evaluate"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [skill, console, debugging, logs, browser-automation]
---

# Console Log Analyzer Skill

## Overview
Automated browser console log extraction and analysis capability using Playwright MCP to identify errors, warnings, and important messages during testing and debugging processes.

## Skill Details

### Purpose
To provide comprehensive console log analysis for web applications, extracting and interpreting browser output to identify issues, debug problems, and monitor application health.

### Use Cases
- Error detection during test execution
- Debug information collection for bug reports
- Application health monitoring
- Performance issue identification
- JavaScript error analysis and troubleshooting

### Triggering Mechanism
- **Automatic**: yes - Triggered after test failures, errors, or debugging sessions
- **Manual**: yes - Can be invoked explicitly for log analysis
- **Context**: Testing, debugging, monitoring, error investigation

## Capability Definition

### Core Functionality
Extracts, analyzes, and interprets browser console logs using Playwright MCP evaluation tools, categorizing messages by severity and providing actionable insights.

### Input Requirements
- Browser context or page reference
- Log extraction parameters (time range, severity levels)
- Analysis scope and focus areas
- Output format preferences

### Output Format
- Categorized log messages (errors, warnings, info, debug)
- Error analysis and potential solutions
- Log summary reports
- Actionable debugging recommendations

### Performance Characteristics
- **Execution Time**: 2-10 seconds for analysis
- **Resource Usage**: Low CPU, minimal memory
- **Scalability**: Excellent for single analysis, good for batch processing

## Implementation Details

### Core Logic
Uses Playwright MCP's evaluation capabilities to extract console logs, applies pattern recognition and analysis algorithms to categorize messages, and generates actionable debugging insights.

### Algorithm/Method
1. **Extraction**: Retrieve console logs from browser context
2. **Filtering**: Apply severity and time-based filters
3. **Categorization**: Classify messages by type and importance
4. **Pattern Analysis**: Identify common error patterns and issues
5. **Correlation**: Link related messages and events
6. **Reporting**: Generate comprehensive analysis and recommendations

### Integration Points
- Playwright MCP server for log extraction
- Pattern recognition systems
- Error classification algorithms
- Report generation tools

### Error Handling
- Browser context validation
- Log extraction failure recovery
- Analysis error handling
- Incomplete log management
- Fallback analysis strategies

## Configuration

### Skill Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| log_levels | string[] | ["error", "warning", "info"] | Console log levels to extract |
| time_range | number | 300000 | Time range for log extraction (ms) |
| max_entries | number | 1000 | Maximum log entries to analyze |
| pattern_matching | boolean | true | Enable pattern recognition for common errors |
| output_format | string | "markdown" | Analysis output format (markdown/json) |

### Customization Options
- Custom error pattern definitions
- Project-specific log filtering rules
- Integration with bug tracking systems
- Automated alerting for critical errors

## Dependencies

### Required Modules
- Playwright MCP server connection
- Browser context access
- Log processing algorithms

### External Dependencies
- JavaScript evaluation tools
- Pattern recognition libraries
- Report generation utilities

### System Requirements
- Browser context with console access
- Sufficient processing capacity for log analysis
- File system access for report storage

## Usage Examples

### Basic Usage
```markdown
# Extract console logs after test failure
console_logs = playwright_evaluate({
  page: page,
  expression: "() => console.logs"
})
```

### Advanced Usage
```markdown
# Comprehensive console log analysis
analyze_console_logs({
  time_range: "last_5_minutes",
  severity_levels: ["error", "warning"],
  pattern_matching: true,
  focus_areas: ["javascript_errors", "network_issues", "performance"]
})
```

### Integration Example
```markdown
# Console log analysis in debugging workflow
1. Execute test or reproduce issue
2. Capture console logs with console-log-analyzer skill
3. Analyze errors and identify root causes
4. Generate debugging report with recommendations
5. Implement fixes based on analysis results
```

## Testing

### Test Cases
- Basic log extraction functionality
- Error pattern recognition accuracy
- Log categorization correctness
- Report generation completeness
- Integration with debugging workflows

### Performance Tests
- Analysis speed optimization
- Memory usage during processing
- Large log volume handling
- Real-time analysis capabilities

### Integration Tests
- Playwright MCP tool integration
- Browser console access validation
- Pattern recognition system testing
- Report generation verification

## Monitoring and Metrics

### Success Metrics
- Log extraction accuracy
- Error identification rate
- Pattern recognition precision
- Actionable insight generation

### Performance Metrics
- Analysis processing time
- Memory usage efficiency
- Log volume handling capacity
- Real-time processing capability

### Usage Analytics
- Most common error patterns
- Frequent debugging scenarios
- Peak usage times
- Analysis success rates

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial console log analyzer skill creation |

### Known Issues
- Limited to browser-accessible console logs
- Requires proper browser context setup
- May miss errors from external sources

### Future Improvements
- AI-powered error pattern recognition
- Real-time log monitoring capabilities
- Integration with application performance monitoring
- Advanced correlation analysis

## Troubleshooting

### Common Issues
- **No logs extracted**: Verify browser context and console access
- **Analysis incomplete**: Check time range and filtering parameters
- **Pattern matching fails**: Validate pattern definitions and regex
- **Report generation errors**: Ensure output format compatibility

### Debug Information
- Browser context status verification
- Console access validation
- Log extraction response analysis
- Processing pipeline diagnostics

### Performance Issues
- Optimize log filtering parameters
- Implement efficient pattern matching
- Use appropriate time ranges
- Consider incremental analysis for large logs

### Quality Issues
- Review and update error patterns
- Validate categorization rules
- Improve correlation algorithms
- Enhance recommendation accuracy

## Best Practices

### Usage Guidelines
- Extract logs at appropriate debugging points
- Use targeted filtering for focused analysis
- Correlate logs with user actions and test steps
- Maintain log history for trend analysis

### Performance Tips
- Use specific time ranges to limit processing
- Apply relevant severity level filters
- Implement incremental analysis for large logs
- Cache frequently used patterns

### Integration Guidelines
- Integrate with existing debugging workflows
- Coordinate with other testing and monitoring tools
- Follow project-specific logging standards
- Maintain consistent analysis reporting

## Related Skills
- **browser-screenshot**: Complements log analysis with visual evidence
- **form-filler**: Can trigger log analysis during form interactions
- **ui-debugger**: Uses log analysis as part of comprehensive debugging

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**MCP Dependencies**: playwright_evaluate