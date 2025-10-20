---
name: delegate-not-abandon
type: rule
version: 1.0.0
description: Delegate complex tasks to specialized sub-agents rather than attempting to handle them alone
applies_to: Task management, complex problem solving, multi-step workflows
severity: critical
---

# Delegate Complex Tasks - Don't Abandon or Handle Alone

## Purpose
Complex tasks require specialized expertise and should be delegated to appropriate sub-agents rather than attempting to handle them alone or abandoning them due to complexity.

## Requirements

### MUST (Critical)
- **ALWAYS delegate complex tasks** (>10 lines of code, multi-step workflows, specialized domains)
- **NEVER attempt to handle complex debugging alone** - delegate to debugging-specialist
- **NEVER attempt complex research alone** - delegate to documentation-researcher
- **NEVER violate coding standards** - delegate to code-compliance-specialist when unsure

### SHOULD (Important)
- **Assess task complexity** before starting implementation
- **Identify appropriate specialist** based on task requirements
- **Preserve conversation continuity** during delegation
- **Learn from specialist outcomes** for future similar tasks

### MAY (Optional)
- **Coordinate multiple specialists** for highly complex tasks
- **Ask for clarification** if unsure about delegation requirements

## Task Complexity Triggers

### Immediate Delegation Required For:
- **ANY code implementation > 10 lines**
- **ANY new feature development**
- **ANY troubleshooting/debugging tasks**
- **ANY research/documentation requests**
- **ANY system integration work**
- **ANY error analysis/prevention**
- **ANY frontend/UX-UI implementation beyond basic HTML/CSS**
- **ANY accessibility compliance requirements**
- **ANY responsive design implementation**
- **ANY web testing/automation needs**
- **ANY component architecture complexity**

## Specialist Routing Matrix

### Debugging Tasks → @debugging-specialist
**When to delegate:**
- Error diagnosis and troubleshooting
- Performance issues and optimization
- System behavior analysis
- Complex technical problems

**Examples:**
```typescript
// ❌ Bad - Handling debugging alone
"I see there's an error in the API. Let me try to fix it..."

// ✅ Good - Delegating to specialist
"This API error requires specialized debugging. Let me delegate to @debugging-specialist."
```

### Research Tasks → @documentation-researcher
**When to delegate:**
- Documentation research and best practices
- Library investigation and comparison
- Current information lookup
- Multi-source research requirements

**Examples:**
```typescript
// ❌ Bad - Attempting research alone
"I'll search for information about React best practices..."

// ✅ Good - Delegating to specialist
"This requires comprehensive research. Let me delegate to @documentation-researcher."
```

### Code Implementation → @code-compliance-specialist
**When to delegate:**
- Complex coding scenarios
- Compliance validation requirements
- Security analysis and implementation
- Quality assurance and standards enforcement

**Examples:**
```typescript
// ❌ Bad - Risky implementation without validation
"I'll implement this authentication system..."

// ✅ Good - Delegating for compliance
"This requires security compliance. Let me delegate to @code-compliance-specialist."
```

### UX/UI & Frontend Development → @ux-ui-specialist
**When to delegate:**
- Frontend implementation beyond basics
- Accessibility compliance
- Responsive design
- Web testing and automation
- Component architecture

**Examples:**
```typescript
// ❌ Bad - Implementing complex UI without expertise
"I'll create this accessible component..."

// ✅ Good - Delegating to specialist
"This requires accessibility expertise. Let me delegate to @ux-ui-specialist."
```

### Error Prevention → @error-prevention-specialist
**When to delegate:**
- Recurring error patterns
- Prevention strategy development
- Robustness design and implementation
- Error handling optimization

**Examples:**
```typescript
// ❌ Bad - Ignoring prevention patterns
"I see this error pattern keeps happening. I'll just fix it again..."

// ✅ Good - Delegating for prevention
"This recurring error pattern needs prevention. Let me delegate to @error-prevention-specialist."
```

## Delegation Workflow

### Step 1: Assess Complexity
```typescript
// Before starting any task:
function assessComplexity(task: Task): boolean {
  const indicators = [
    task.estimatedLines > 10,
    task.requiresSpecialKnowledge,
    task.involvesMultipleSteps,
    task.hasQualityRequirements,
    task.involvesSecurityConsiderations
  ];

  return indicators.some(indicator => indicator);
}
```

### Step 2: Identify Specialist
```typescript
const specialistMap = {
  debugging: 'debugging-specialist',
  research: 'documentation-researcher',
  coding: 'code-compliance-specialist',
  frontend: 'ux-ui-specialist',
  prevention: 'error-prevention-specialist'
};

function identifySpecialist(taskType: string): string {
  return specialistMap[taskType] || 'general-purpose';
}
```

### Step 3: Execute Delegation
```typescript
// ❌ Bad - Manual implementation
function implementComplexFeature() {
  // 50+ lines of complex code
  // Multiple potential errors
  // Quality compromises
}

// ✅ Good - Delegation
function implementComplexFeature() {
  return Task("Implement complex feature", "Detailed requirements", "@code-compliance-specialist");
}
```

## Delegation Communication

### Effective Delegation Language
```typescript
// ✅ Good delegation examples
"This requires [specialization] expertise. I'm delegating to @specialist for optimal results."

"The complexity of this task exceeds safe manual implementation. Delegating to @specialist."

"To ensure 100% compliance with standards, I'm delegating this to @specialist."

"This specialized domain requires expert attention. @specialist will handle this."
```

### Continuity Preservation
```typescript
// ✅ Good - Seamless delegation
"After @specialist completes the implementation, I'll integrate it into the broader system."

"The @specialist will provide the specialized component, which I'll then integrate with our existing architecture."
```

## Quality Assurance

### Delegation Success Criteria
- [ ] Task complexity assessed before starting
- [ ] Appropriate specialist identified
- [ ] Clear requirements provided to specialist
- [ ] Conversation continuity maintained
- [ ] Results properly integrated
- [ ] Quality standards met

### Common Delegation Mistakes to Avoid
1. **Underestimating task complexity** - leads to poor quality results
2. **Choosing wrong specialist** - leads to suboptimal outcomes
3. **Poor communication** - leads to misunderstandings
4. **Abandoning after delegation** - leads to incomplete integration
5. **Not learning from outcomes** - leads to repeated mistakes

## Enforcement

This rule is enforced through:
- Pre-task complexity assessment checkpoints
- Automatic delegation triggers for specific patterns
- Quality validation of delegation outcomes
- Continuous learning and improvement

Remember: Delegation is not avoidance - it's ensuring optimal results through specialized expertise while maintaining system integration and quality standards.