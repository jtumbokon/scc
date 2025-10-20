---
name: visual-diff-checker
version: 1.0.0
description: Compare screenshots using image diff and Playwright MCP for UI changes. Use in PR reviews, visual regression.
type: skill
cascade: automatic
category: visual-testing
author: Super-Claude System
created: 2025-10-20
dependencies: ["playwright_screenshot"]
compatibility:
  min_system_version: 2.2.0
  max_system_version: "*"
tags: [skill, visual-diff, image-comparison, regression-testing, pr-reviews]
---

# Visual Diff Checker Skill

## Overview
Automated visual difference detection capability that compares screenshots using image processing algorithms to identify UI changes, regressions, and inconsistencies during development and review processes.

## Skill Details

### Purpose
To provide comprehensive visual comparison functionality that detects pixel-level differences between screenshots, highlighting changes and supporting informed decisions about UI modifications.

### Use Cases
- Visual regression testing in CI/CD pipelines
- PR review UI change validation
- Design system compliance verification
- Cross-browser visual consistency checking
- Component library change detection

### Triggering Mechanism
- **Automatic**: yes - Triggered during PR reviews, testing cycles, and visual regression workflows
- **Manual**: yes - Can be invoked explicitly for visual comparison
- **Context**: Testing, code review, design validation, regression detection

## Capability Definition

### Core Functionality
Compares pairs of screenshots using advanced image processing algorithms to detect visual differences, generate diff images, and provide detailed analysis of UI changes.

### Input Requirements
- Baseline and current screenshot files
- Comparison parameters and thresholds
- Region of interest specifications
- Output format preferences

### Output Format
- Visual diff images highlighting changes
- Detailed change analysis reports
- Difference metrics and statistics
- Recommendations for approval or rejection

### Performance Characteristics
- **Execution Time**: 2-10 seconds per comparison (varies with image size)
- **Resource Usage**: Moderate CPU, higher memory for image processing
- **Scalability**: Good for individual comparisons, excellent for batch processing

## Implementation Details

### Core Logic
Uses image processing algorithms to perform pixel-by-pixel comparison, applies configurable thresholds for significance detection, and generates comprehensive visual diff reports with actionable insights.

### Algorithm/Method
1. **Image Preprocessing**: Normalize and prepare images for comparison
2. **Alignment**: Ensure proper positioning and scaling
3. **Comparison**: Perform pixel-level difference analysis
4. **Threshold Application**: Apply configurable significance thresholds
5. **Diff Generation**: Create visual diff images with highlighted changes
6. **Analysis**: Categorize and analyze detected differences
7. **Reporting**: Generate comprehensive comparison reports

### Integration Points
- Playwright MCP for screenshot capture
- Image processing libraries
- File system for image storage and retrieval
- Reporting and notification systems

### Error Handling
- Image file format validation
- Comparison failure recovery
- Insufficient memory handling
- File system error management
- Threshold calibration assistance

## Configuration

### Skill Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| comparison_algorithm | string | "pixel-perfect" | Comparison method (pixel-perceptual/structural) |
| diff_threshold | number | 0.05 | Pixel difference threshold (0.0-1.0) |
| ignore_regions | string[] | [] | Array of regions to ignore during comparison |
| output_format | string | "png" | Diff image output format |
| analysis_mode | string | "comprehensive" | Analysis depth (quick/comprehensive) |

### Customization Options
- Custom comparison algorithms for different UI patterns
- Project-specific threshold configurations
- Region-based ignoring for dynamic content
- Integration with design system validation

## Dependencies

### Required Modules
- Playwright MCP server connection
- Image processing libraries
- File system access

### External Dependencies
- Image comparison algorithms
- Visual analysis tools
- Reporting generation utilities

### System Requirements
- Sufficient memory for image processing
- File system storage for images
- Processing capability for comparison algorithms

## Usage Examples

### Basic Usage
```markdown
# Compare two screenshots for visual differences
compare_screenshots({
  baseline: "tests/artifacts/screenshots/baseline/dashboard-v1.png",
  current: "tests/artifacts/screenshots/current/dashboard-v2.png",
  output: "tests/artifacts/screenshots/diff/dashboard-diff.png"
})
```

### Advanced Usage
```markdown
# Comprehensive visual diff analysis with custom settings
perform_visual_diff({
  baseline_image: "baseline/component-library.png",
  current_image: "current/component-library.png",
  comparison_settings: {
    algorithm: "perceptual",
    threshold: 0.1,
    ignore_regions: [
      {"x": 0, "y": 0, "width": 200, "height": 50}, // Ignore header timestamps
      {"x": 300, "y": 150, "width": 100, "height": 30} // Ignore dynamic content
    ]
  },
  analysis_options: {
    categorize_changes: true,
    generate_metrics: true,
    create_highlighted_diff: true
  }
})
```

### Integration Example
```markdown
# Visual diff in PR review workflow
1. Capture screenshots of updated components
2. Use visual-diff-checker skill to compare with baseline
3. Analyze detected differences and categorize changes
4. Generate visual diff report for PR review
5. Provide recommendations for approval or changes needed
```

## Testing

### Test Cases
- Basic image comparison accuracy
- Different algorithm effectiveness
- Threshold configuration validation
- Region ignoring functionality
- Diff generation quality

### Performance Tests
- Comparison speed optimization
- Memory usage during processing
- Large image handling capability
- Batch processing efficiency

### Integration Tests
- Playwright MCP integration for screenshot capture
- File system interaction for image storage
- Report generation and delivery
- Threshold calibration and tuning

## Monitoring and Metrics

### Success Metrics
- Visual difference detection accuracy
- False positive/negative rates
- Processing speed and efficiency
- User satisfaction with diff reports

### Performance Metrics
- Average comparison time
- Memory usage patterns
- Algorithm effectiveness scores
- Report generation speed

### Usage Analytics
- Most commonly compared components
- Frequency of significant differences
- Peak usage during development cycles
- Algorithm preference patterns

## Maintenance

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-20 | Initial visual diff checker skill creation |

### Known Issues
- Sensitive to minor rendering variations
- Requires consistent screenshot capture conditions
- May need custom thresholds for different UI patterns

### Future Improvements
- AI-powered change significance assessment
- Advanced perceptual difference algorithms
- Integration with design system validation
- Automated threshold tuning

## Troubleshooting

### Common Issues
- **False positives**: Adjust comparison thresholds or ignore regions
- **Comparison fails**: Verify image formats and accessibility
- **Processing slow**: Optimize image sizes or algorithm selection
- **Inconsistent results**: Ensure consistent capture conditions

### Debug Information
- Image preprocessing validation
- Algorithm parameter analysis
- Threshold effectiveness assessment
- Memory and performance diagnostics

### Performance Issues
- Optimize image preprocessing
- Use appropriate comparison algorithms
- Implement efficient memory management
- Consider parallel processing for batch operations

### Quality Issues
- Review and adjust comparison thresholds
- Validate ignore region configurations
- Enhance algorithm selection logic
- Improve categorization accuracy

## Best Practices

### Usage Guidelines
- Maintain consistent screenshot capture conditions
- Use appropriate thresholds for different UI types
- Configure ignore regions for dynamic content
- Review diff results in context of intended changes

### Performance Tips
- Optimize image sizes and formats
- Use efficient comparison algorithms
- Implement appropriate threshold settings
- Consider batch processing for multiple comparisons

### Integration Guidelines
- Integrate with CI/CD pipelines for automated testing
- Coordinate with code review workflows
- Follow project-specific visual standards
- Maintain consistent baseline management

## Related Skills
- **browser-screenshot**: Provides images for comparison
- **visual-regression-tester**: Uses diff results for regression analysis
- **playwright-test-generator**: Can include visual diff assertions in tests

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-20
**System Compatibility**: Super-Claude v2.2.0+
**MCP Dependencies**: playwright_screenshot