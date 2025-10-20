---
name: agent-template
version: 1.0.0
description: Standard template for creating specialized sub-agent modules
type: agent
cascade: manual
category: specialist
author: Super-Claude System
created: 2025-10-19
dependencies: []
compatibility:
  min_system_version: 1.0.0
  max_system_version: "*"
tags: [agent, template, specialist, sub-agent]
---

# Agent Template

## Overview
[Provide a brief description of what this agent specializes in and its primary function]

## Agent Details

### Purpose
[Clearly state the primary purpose and specialization of this agent]

### Specialization Domain
- **Domain**: [e.g., code-review, debugging, documentation, security]
- **Expertise Level**: [beginner | intermediate | advanced | expert]
- **Scope**: [specific | broad | comprehensive]

### Triggering Mechanism
- **Automatic**: [yes | no] - Does this agent trigger automatically?
- **Manual**: [yes | no] - Can this agent be invoked manually?
- **Delegation**: [yes | no] - Can other agents delegate to this agent?

## Agent Capabilities

### Core Competencies
[List the main capabilities and areas of expertise]

### Primary Functions
[Describe the primary functions this agent performs]

### Secondary Functions
[Describe additional or supporting functions]

### Limitations
[Describe what this agent cannot or should not do]

## Agent Configuration

### Agent Parameters
[List configurable parameters for this agent]

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| mode | string | "standard" | Operating mode of the agent |
| thoroughness | number | 80 | Thoroughness level (0-100) |
| timeout | number | 300000 | Maximum execution time (ms) |
| auto_fix | boolean | false | Whether to automatically fix issues |

### Personality Traits
[Define the personality and communication style]

```json
{
  "communication_style": "professional",
  "approach": "systematic",
  "verbosity": "detailed",
  "helpfulness": "high"
}
```

### Decision Making
[Describe how this agent makes decisions]

## Implementation Details

### Core Logic
[Describe the main implementation approach]

### Algorithm/Method
[If applicable, describe the algorithm or method used]

### Knowledge Base
[What knowledge or data does this agent rely on?]

### Learning Capability
[Can this agent learn from experience?]

### Integration Points
[What systems, APIs, or modules does this agent integrate with?]

## Agent Interface

### Input Format
[Describe the expected input format for this agent]

```typescript
interface AgentInput {
  task: string;
  context: any;
  parameters: Record<string, any>;
  requirements: string[];
}
```

### Output Format
[Describe the output format this agent produces]

```typescript
interface AgentOutput {
  result: any;
  confidence: number;
  explanation: string;
  recommendations: string[];
  metadata: Record<string, any>;
}
```

### Communication Protocol
[How does this agent communicate with users and other agents?]

## Delegation Pattern

### When to Delegate
[Under what conditions should tasks be delegated to this agent?]

### Delegation Criteria
[List criteria for determining when to use this agent]

### Coordination with Other Agents
[How does this agent coordinate with other specialized agents?]

## Usage Examples

### Basic Agent Invocation
```markdown
[Example of basic agent usage]
```

### Advanced Agent Usage
```markdown
[Example of complex agent usage with custom parameters]
```

### Multi-Agent Coordination
```markdown
[Example of coordinating this agent with other agents]
```

### Integration Example
```markdown
[Example of integrating this agent with workflows]
```

## Performance Characteristics

### Execution Metrics
[Describe the performance characteristics]

- **Average Execution Time**: [Expected time to complete]
- **Success Rate**: [Expected success rate]
- **Resource Usage**: [CPU, memory, other resource requirements]
- **Scalability**: [How well does this agent scale with complex tasks?]

### Quality Metrics
[How is the quality of agent output measured?]

## Testing and Validation

### Test Cases
[Describe the test cases that validate this agent]

### Performance Tests
[How to test the performance characteristics]

### Quality Assurance
[How to ensure the agent produces high-quality results]

### Validation Methods
[How to validate agent outputs]

## Monitoring and Analytics

### Success Metrics
[How do we measure if this agent is working well?]

### Performance Monitoring
[What metrics should be tracked?]

### Usage Analytics
[What usage data should be collected?]

### Feedback Mechanisms
[How can users provide feedback on agent performance?]

## Security and Safety

### Access Control
[What permissions does this agent need?]

### Safety Constraints
[What safety constraints are in place?]

### Data Privacy
[How does this agent handle sensitive data?]

### Ethical Considerations
[What ethical guidelines apply to this agent?]

## Maintenance and Improvement

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-19 | Initial template creation |

### Known Issues
[List any known issues or limitations]

### Future Improvements
[Planned enhancements or modifications]

### Training Data Updates
[How is the agent's knowledge updated?]

## Troubleshooting

### Common Issues
[List common problems and their solutions]

### Debug Information
[What information is useful for debugging this agent?]

### Performance Issues
[How to identify and resolve performance problems]

### Quality Issues
[How to address low-quality outputs]

## Best Practices

### Usage Guidelines
[Best practices for using this agent effectively]

### Performance Tips
[Tips for optimizing agent performance]

### Integration Guidelines
[Best practices for integrating this agent with workflows]

## Related Agents
[List related or complementary agents]

---

**Agent Template Version**: 1.0.0
**Last Updated**: 2025-10-19
**System Compatibility**: Super-Claude v1.0.0+