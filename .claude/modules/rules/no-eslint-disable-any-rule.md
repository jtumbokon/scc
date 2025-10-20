---
id: rule-025
type: rule
version: 1.0.0
description: NEVER use ANY ESLint disable comments - ZERO TOLERANCE policy for maintaining code quality and preventing bugs
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No ESLint Disable Any Rule (rule-025)

## Purpose
ESLint rules exist to catch real issues, enforce consistent code patterns, and prevent bugs. Using ANY form of `eslint-disable` comment bypasses these important checks instead of addressing the underlying problems. This creates technical debt, hides real issues, and makes the codebase less maintainable.

**This is a ZERO TOLERANCE policy** - there are NO acceptable exceptions for disabling ESLint rules.

## Requirements

### MUST (Critical)
- **NEVER use ANY ESLint disable directives** under any circumstances
- **NEVER use `/* eslint-disable */`** for file-wide disabling
- **NEVER use `/* eslint-disable-next-line */`** for next line disabling
- **NEVER use `// eslint-disable-next-line */`** for single line disabling
- **NEVER use `/* eslint-disable rule-name */`** for specific rule disabling
- **ALWAYS fix the root cause** instead of disabling the rule

### SHOULD (Important)
- **Read ESLint error messages** to understand the actual issue
- **Research rule documentation** to understand the rule's purpose
- **Apply proper fixes** that address the underlying problem
- **Refactor code structure** when rules indicate architectural issues
- **Use proper alternatives** that satisfy the rule's requirements

### MAY (Optional)
- **Adjust ESLint configuration** project-wide if rules are misconfigured
- **Document edge cases** for team discussion when rules seem inappropriate
- **Research community solutions** for complex ESLint issues
- **Consult team consensus** for architectural decisions

## Forbidden ESLint Disable Patterns

### ❌ ALL FORMS ARE FORBIDDEN
```jsx
// ❌ FORBIDDEN - All variations of eslint-disable

// Block comments
/* eslint-disable */
/* eslint-disable rule-name */
/* eslint-disable rule1, rule2 */

// Line comments
// eslint-disable-next-line
// eslint-disable-next-line rule-name
// eslint-disable-next-line rule1, rule2

// Inline disable
/* eslint-disable-line */
/* eslint-disable-line rule-name */

// Combined with specific rules
/* eslint-disable react-hooks/exhaustive-deps */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
/* eslint-disable jsx-a11y/alt-text */
```

## Common ESLint Rules and Proper Fixes

### `react-hooks/exhaustive-deps`
```jsx
// ❌ FORBIDDEN
useEffect(() => {
  processData();
// eslint-disable-next-line react-hooks/exhaustive-deps
}, []);

// ✅ CORRECT FIXES

// Option 1: Add missing dependencies
useEffect(() => {
  processData();
}, [processData]);

// Option 2: Move function inside effect
useEffect(() => {
  function processData() {
    // logic here that uses local state/props
  }
  processData();
}, [/* actual dependencies */]);

// Option 3: Use useCallback to stabilize
const processData = useCallback(() => {
  // logic here
}, [actualDependencies]);

useEffect(() => {
  processData();
}, [processData]);

// Option 4: Extract stable values
const memoizedValue = useMemo(() => computeValue(data), [data]);
useEffect(() => {
  processData(memoizedValue);
}, [memoizedValue]);
```

### `react/no-unescaped-entities`
```jsx
// ❌ FORBIDDEN
// eslint-disable-next-line react/no-unescaped-entities
<p>Sarah's workflow</p>

// ✅ CORRECT FIXES

// Option 1: Use HTML entities
<p>Sarah&rsquo;s workflow</p>
<p>&ldquo;Important&rdquo; message</p>

// Option 2: Use JavaScript expressions
<p>{"Sarah's workflow"}</p>
<p>{`"Important" message`}</p>

// Option 3: Restructure sentence
<p>The workflow for Sarah</p>
<p>Important message details</p>
```

### `@typescript-eslint/no-explicit-any`
```tsx
// ❌ FORBIDDEN
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const data: any = response;

// ✅ CORRECT FIXES

// Option 1: Define proper interface
interface UserResponse {
  id: string;
  name: string;
  email: string;
}

const data: UserResponse = response;

// Option 2: Use utility types
interface APIResponse<T> {
  data: T;
  status: number;
}

type User = {
  id: string;
  name: string;
};

const response: APIResponse<User> = await fetchUser();

// Option 3: Use generics
function processData<T>(data: T): T {
  return data;
}

const result = processData<UserData>(input);
```

### `jsx-a11y/alt-text`
```jsx
// ❌ FORBIDDEN
// eslint-disable-next-line jsx-a11y/alt-text
<img src="photo.jpg" />

// ✅ CORRECT FIXES

// Option 1: Add descriptive alt text
<img src="photo.jpg" alt="Sarah working on her laptop" />

// Option 2: Mark as decorative
<img src="decorative-pattern.jpg" alt="" aria-hidden="true" />

// Option 3: Use functional alt text
<img src="user-avatar.jpg" alt={`${userName}'s profile picture`} />

// Option 4: Use ARIA labels for complex images
<img
  src="chart.jpg"
  alt="Sales performance chart showing 25% growth in Q3"
  role="img"
/>
```

### `@typescript-eslint/no-unused-vars`
```tsx
// ❌ FORBIDDEN
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const unusedVar = getValue();

// ✅ CORRECT FIXES

// Option 1: Remove if truly unused
// const unusedVar = getValue(); // Delete this line

// Option 2: Prefix with underscore for intentionally unused
const _unusedVar = getValue();

// Option 3: Actually use the variable
const neededVar = getValue();
doSomethingWith(neededVar);

// Option 4: Destructure with ignore
const { data: _, metadata } = getResponse();
useMetadata(metadata);
```

### `react-hooks/rules-of-hooks`
```jsx
// ❌ FORBIDDEN
// eslint-disable-next-line react-hooks/rules-of-hooks
if (condition) {
  useEffect(() => {
    // effect logic
  }, []);
}

// ✅ CORRECT FIXES

// Option 1: Move hooks outside conditional
const data = useFetchData();
useEffect(() => {
  if (condition) {
    // effect logic that depends on data
  }
}, [condition, data]);

// Option 2: Use custom hook
function useConditionalEffect(condition: boolean) {
  useEffect(() => {
    if (condition) {
      // effect logic
    }
  }, [condition]);
}

// Component usage
useConditionalEffect(condition);
```

## Root Cause Analysis Process

When ESLint flags an issue, follow this systematic approach:

### Step 1: Understand the Error
```bash
# Read the full error message
# ESLint provides detailed explanations
Error: [react-hooks/exhaustive-deps]
React Hook useEffect has missing dependencies: 'processData'.
Either include them or remove the dependency array.
```

### Step 2: Research the Rule
```bash
# Look up the rule documentation
# https://eslint.org/docs/rules/
# Understand what problem the rule prevents
```

### Step 3: Identify the Real Problem
- **Performance issues** - unnecessary re-renders, memory leaks
- **Bugs** - missing dependencies cause stale closures
- **Type safety** - `any` types remove TypeScript benefits
- **Accessibility** - missing alt text excludes screen reader users
- **Code quality** - unused variables indicate dead code

### Step 4: Apply the Proper Fix
```jsx
// Choose the appropriate fix strategy:
// 1. Add missing dependencies
// 2. Refactor code structure
// 3. Use proper type definitions
// 4. Add accessibility attributes
// 5. Remove unused code
```

### Step 5: Verify the Solution
```bash
# Run linter to confirm fix
npm run lint

# Run tests to ensure no regressions
npm test

# Test functionality manually if needed
```

## Advanced Fix Patterns

### Complex Dependencies in Hooks
```jsx
// ❌ FORBIDDEN
useEffect(() => {
  const processItems = () => {
    items.forEach(item => processItem(item));
  };
  processItems();
// eslint-disable-next-line react-hooks/exhaustive-deps
}, [items]);

// ✅ CORRECT - Multiple strategies

// Strategy 1: useCallback with proper dependencies
const processItems = useCallback(() => {
  items.forEach(item => processItem(item));
}, [items, processItem]);

useEffect(() => {
  processItems();
}, [processItems]);

// Strategy 2: Memoize expensive computation
const processedItems = useMemo(() => {
  return items.map(item => processItem(item));
}, [items]);

useEffect(() => {
  processedItems.forEach(item => console.log(item));
}, [processedItems]);

// Strategy 3: Split into multiple effects
useEffect(() => {
  // Effect that only depends on items
  items.forEach(item => console.log(item.id));
}, [items]);

useEffect(() => {
  // Effect that only depends on processItem
  if (processItem) {
    console.log('Process function available');
  }
}, [processItem]);
```

### Type-Safe API Responses
```tsx
// ❌ FORBIDDEN
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const fetchUsers = async (): Promise<any> => {
  const response = await fetch('/api/users');
  return response.json();
};

// ✅ CORRECT - Proper typing

// Option 1: Define response interface
interface User {
  id: string;
  name: string;
  email: string;
}

interface UsersResponse {
  users: User[];
  total: number;
}

const fetchUsers = async (): Promise<UsersResponse> => {
  const response = await fetch('/api/users');
  return response.json();
};

// Option 2: Use generic API wrapper
interface APIResponse<T> {
  data: T;
  success: boolean;
  message?: string;
}

const fetchAPI = async <T>(endpoint: string): Promise<APIResponse<T>> => {
  const response = await fetch(endpoint);
  return response.json();
};

// Usage
const usersResponse = await fetchAPI<User[]>('/api/users');
```

### Accessibility-First Component Design
```jsx
// ❌ FORBIDDEN
// eslint-disable-next-line jsx-a11y/alt-text
// eslint-disable-next-line jsx-a11y/anchor-is-valid
<div>
  <img src="icon.png" />
  <a onClick={handleClick}>Click me</a>
</div>

// ✅ CORRECT - Accessibility first

// Option 1: Semantic HTML with proper attributes
<div>
  <img src="icon.png" alt="User profile icon" />
  <button onClick={handleClick} type="button">
    Click me
  </button>
</div>

// Option 2: ARIA-compliant interactive elements
<div>
  <img src="decorative.png" alt="" aria-hidden="true" />
  <button
    onClick={handleClick}
    aria-label="Save changes"
    type="button"
  >
    Save
  </button>
</div>

// Option 3: Complex accessible components
<div role="button"
     tabIndex={0}
     onClick={handleClick}
     onKeyDown={(e) => e.key === 'Enter' && handleClick()}
     aria-label="Expand details"
>
  <img src="expand.png" alt="" aria-hidden="true" />
  Expand
</div>
```

## Project-Specific Patterns

### This Codebase's Common Fixes

#### React Hooks Pattern
```jsx
// Pattern: Stabilize functions with proper dependencies
const processData = useCallback((data: DataType) => {
  // Process data logic
}, [stableDependency]);

useEffect(() => {
  processData(currentData);
}, [processData, currentData]);
```

#### TypeScript Pattern
```tsx
// Pattern: Define interfaces for external data
interface ExternalAPIResponse {
  results: ItemType[];
  pagination: {
    page: number;
    total: number;
  };
}

const data: ExternalAPIResponse = await fetchData();
```

#### Accessibility Pattern
```jsx
// Pattern: Semantic HTML with ARIA support
<button
  onClick={handleAction}
  disabled={isLoading}
  aria-label={isLoading ? 'Loading...' : 'Save changes'}
  type="button"
>
  {isLoading ? 'Saving...' : 'Save'}
</button>
```

## Emergency Procedures

### When You Encounter a False Positive

1. **Document the Issue Thoroughly**
   ```jsx
   // Document with code example
   // Issue: ESLint rule flags valid pattern as error
   // Rule: specific-rule-name
   // Context: Explain why the pattern is actually correct
   // Proposed solution: Detailed explanation
   ```

2. **Research Alternative Solutions**
   - Search Stack Overflow
   - Check ESLint GitHub issues
   - Look for community patterns

3. **Consider Project-Wide Configuration Changes**
   ```json
   // .eslintrc.js
   module.exports = {
     rules: {
       'rule-name': 'off' // Only if truly inappropriate project-wide
     }
   };
   ```

4. **Team Consultation Required**
   - Discuss in code review
   - Bring to team meeting
   - Document decision

5. **NEVER Use Temporary Disable**
   ```jsx
   // ❌ NEVER DO THIS - even temporarily
   // eslint-disable-next-line rule-name
   temporaryBadCode();
   ```

## Enforcement Mechanisms

### Automated Enforcement
```json
// package.json scripts
{
  "scripts": {
    "lint": "eslint src --max-warnings 0",
    "lint:strict": "eslint src --max-warnings 0 --quiet",
    "pre-commit": "lint-staged"
  }
}
```

### Pre-commit Hooks
```json
// .husky/pre-commit
#!/bin/sh
npm run lint
npm run type-check

# Block commits if any eslint-disable found
if git diff --cached --name-only | xargs grep -l "eslint-disable"; then
  echo "❌ ESLint disable comments found. Fix issues instead of disabling rules."
  exit 1
fi
```

### CI/CD Pipeline
```yaml
# .github/workflows/ci.yml
- name: Check for ESLint disable comments
  run: |
    if grep -r "eslint-disable" src/; then
      echo "❌ ESLint disable comments detected"
      exit 1
    fi
```

## Validation Checklist
- [ ] NO eslint-disable comments anywhere in the codebase
- [ ] All ESLint errors are properly fixed with root cause solutions
- [ ] Code follows consistent patterns enforced by ESLint rules
- [ ] Accessibility issues are resolved, not disabled
- [ ] Type safety is maintained, not bypassed with `any`
- [ ] React hooks follow proper dependency patterns
- [ ] All fixes are tested and verified to work correctly
- [ ] Team education on proper ESLint usage is maintained

## Benefits of This Approach

1. **Prevents Real Bugs** - Rules catch actual issues before they reach production
2. **Maintains Code Quality** - Consistent patterns across the entire codebase
3. **Improves Performance** - Rules prevent inefficient React patterns
4. **Ensures Accessibility** - All users can use the application
5. **Reduces Technical Debt** - No shortcuts that accumulate over time
6. **Enables Better Tooling** - IDE features work reliably with consistent code
7. **Facilitates Team Collaboration** - Everyone follows the same standards

## Remember

**ESLint rules are guardrails that keep our code safe, performant, and maintainable.** Disabling them is like removing safety equipment - it might seem easier in the moment, but it creates dangerous conditions that will cause problems later.

**When in doubt, fix the code - never disable the rule.**

This zero-tolerance policy ensures our codebase remains robust, accessible, and maintainable for the long term.