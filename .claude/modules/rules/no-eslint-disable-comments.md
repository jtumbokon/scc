---
id: rule-012
type: rule
version: 1.0.0
description: Never use ESLint disable comments - always fix the root cause instead of bypassing important code quality checks
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No ESLint Disable Comments Rule (rule-012)

## Purpose
ESLint rules exist to catch real issues, enforce consistent code patterns, and prevent bugs. Using `eslint-disable` comments (in any form) bypasses these important checks instead of addressing the underlying problems. This creates technical debt, hides real issues, and makes the codebase less maintainable.

Disabling linting rules is a dangerous anti-pattern that:
- **Hides real bugs** that ESLint is designed to catch
- **Creates inconsistent code** that doesn't follow established patterns
- **Accumulates technical debt** that becomes harder to fix over time
- **Bypasses important safeguards** like accessibility, security, and performance checks
- **Makes refactoring dangerous** because disabled rules won't catch breaking changes

## Requirements

### MUST (Critical)
- **NEVER use ANY form of ESLint disable comments**:
  - `/* eslint-disable */`
  - `/* eslint-disable-next-line */`
  - `// eslint-disable-next-line`
  - `/* eslint-disable rule-name */`
  - `// eslint-disable-next-line rule-name`
- **ALWAYS fix the root cause** instead of disabling the rule
- **NEVER bypass accessibility, security, or performance checks**

### SHOULD (Important)
- **Understand WHY each ESLint rule exists** before attempting to fix it
- **Use proper alternatives** that satisfy the rule's requirements
- **Refactor code** to follow the patterns the rule enforces
- **Separate concerns** if the rule indicates architectural issues

### MAY (Optional)
- **Document edge cases** where a rule might seem inappropriate
- **Suggest rule configuration changes** at the project level if a rule is consistently problematic

## Common ESLint Rules and How to Fix Them (Never Disable)

### `jsx-a11y/alt-text`
| ❌ Bad (disable rule) | ✅ Good (fix root cause) |
|---|---|
| ```tsx
{/* eslint-disable-next-line jsx-a11y/alt-text */}
<Image className="w-6 h-6 text-blue-500" />
``` | ```tsx
// For Lucide React icons (SVG components), the rule is a false positive
// The real solution is that this is an icon, not an image
// Use proper semantic markup
<div className="w-6 h-6 text-blue-500" aria-hidden="true">
  <Image className="w-full h-full" />
</div>
// OR use a different approach that's semantically correct
``` |

### `react-hooks/exhaustive-deps`
| ❌ Bad (disable rule) | ✅ Good (fix root cause) |
|---|---|
| ```tsx
useEffect(() => {
  fetchData(userId);
// eslint-disable-next-line react-hooks/exhaustive-deps
}, []);
``` | ```tsx
useEffect(() => {
  fetchData(userId);
}, [userId]); // Add missing dependency
``` |

### `react/no-unescaped-entities`
| ❌ Bad (disable rule) | ✅ Good (fix root cause) |
|---|---|
| ```tsx
{/* eslint-disable-next-line react/no-unescaped-entities */}
<p>Sarah's workflow</p>
``` | ```tsx
<p>Sarah&rsquo;s workflow</p>
// OR
<p>{"Sarah's workflow"}</p>
``` |

### `@typescript-eslint/no-explicit-any`
| ❌ Bad (disable rule) | ✅ Good (fix root cause) |
|---|---|
| ```tsx
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const data: any = await apiCall();
``` | ```tsx
interface ApiResponse {
  id: string;
  name: string;
}
const data: ApiResponse = await apiCall();
``` |

### `@typescript-eslint/no-unused-vars`
| ❌ Bad (disable rule) | ✅ Good (fix root cause) |
|---|---|
| ```tsx
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const unusedVariable = getValue();
``` | ```tsx
// Remove the unused variable entirely
// OR use underscore prefix if it's intentionally unused
const _unusedVariable = getValue();
// OR actually use the variable
const neededVariable = getValue();
doSomethingWith(neededVariable);
``` |

## Root Cause Analysis Process

When ESLint flags an issue:

1. **Read the error message carefully** - it usually explains what's wrong
2. **Understand WHY the rule exists** - what problem is it preventing?
3. **Identify the real issue** - what needs to be changed in the code?
4. **Apply the proper fix** - refactor, add missing dependencies, fix types, etc.
5. **Verify the fix** - ensure the code still works and is more robust

## Specific Examples from Real Codebases

### Icon Accessibility Issue
The `jsx-a11y/alt-text` rule flagged a Lucide React `Image` component because it thought it was an HTML `<img>` tag. The real solutions are:

```tsx
// ✅ Option 1: Use proper ARIA attributes for decorative icons
<div className="w-12 h-12 bg-blue-500/10 rounded-xl flex items-center justify-center" aria-hidden="true">
  <Image className="w-6 h-6 text-blue-500" />
</div>

// ✅ Option 2: Use a different icon approach
<FileImageIcon className="w-6 h-6 text-blue-500" aria-hidden="true" />

// ✅ Option 3: If it's meaningful, provide proper labeling
<div className="w-12 h-12 bg-blue-500/10 rounded-xl flex items-center justify-center"
     role="img"
     aria-label="Product image icon">
  <Image className="w-6 h-6 text-blue-500" />
</div>
```

### Missing Dependencies in useEffect
```tsx
// ❌ Bad - disabling the rule
useEffect(() => {
  const controller = new AbortController();

  const fetchData = async () => {
    try {
      const result = await fetch(`/api/users/${userId}`, {
        signal: controller.signal
      });
      const data = await result.json();
      setUser(data);
    } catch (error) {
      if (error.name !== 'AbortError') {
        setError(error.message);
      }
    }
  };

  fetchData();

  return () => controller.abort();
// eslint-disable-next-line react-hooks/exhaustive-deps
}, [userId]);
```

```tsx
// ✅ Good - fixing the root cause with proper dependency management
useEffect(() => {
  const controller = new AbortController();

  const fetchData = async () => {
    try {
      const result = await fetch(`/api/users/${userId}`, {
        signal: controller.signal
      });
      const data = await result.json();
      setUser(data);
    } catch (error) {
      if (error.name !== 'AbortError') {
        setError(error.message);
      }
    }
  };

  fetchData();

  return () => controller.abort();
}, [userId]); // Include the actual dependency

// OR if the function causes issues, use useCallback
const fetchData = useCallback(async () => {
  // ... fetch logic
}, [userId]);

useEffect(() => {
  fetchData();
  return () => controller.abort();
}, [fetchData]);
```

## Benefits of Fixing Root Causes

1. **More robust code** that actually handles edge cases properly
2. **Better accessibility** by addressing real a11y issues
3. **Improved type safety** by using proper TypeScript types
4. **Consistent patterns** that follow project conventions
5. **Easier refactoring** because all code follows the same rules
6. **Better performance** by addressing inefficient patterns
7. **Fewer bugs** because ESLint rules catch real issues

## Project-Specific Patterns

In well-configured projects, establish patterns for common issues:
- **Accessibility**: Use proper ARIA attributes and semantic HTML
- **Type safety**: Define proper interfaces instead of using `any`
- **React hooks**: Include all dependencies in dependency arrays
- **Quotes in JSX**: Use HTML entities or string expressions
- **Async components**: Separate server and client concerns properly

## Emergency Exception Process

In the **extremely rare** case where an ESLint rule is genuinely incorrect:

1. **Document why** the rule is wrong in this specific case
2. **Create a GitHub issue** to track the problem
3. **Consider if the rule configuration** needs to be adjusted project-wide
4. **Get team review** before proceeding
5. **Only then** consider a disable comment with extensive documentation

This should happen less than once per year in a well-configured project.

## Examples of Proper Fixes

### TypeScript Type Issues
```typescript
// ❌ Bad - disabling the rule
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function processApiData(data: any): User {
  return transformData(data);
}

// ✅ Good - defining proper types
interface ApiData {
  id: string;
  name: string;
  email: string;
  createdAt: string;
}

function processApiData(data: ApiData): User {
  return transformData(data);
}
```

### Import/Export Issues
```typescript
// ❌ Bad - disabling unused import rule
// eslint-disable-next-line @typescript-eslint/no-unused-vars
import { useEffect, useState } from 'react';
import { SomeComponent } from './components';

function MyComponent() {
  const [state, setState] = useState(null);

  useEffect(() => {
    // useEffect logic
  }, []);

  return <div>Component</div>;
}

// ✅ Good - removing unused imports
import { useEffect, useState } from 'react';

function MyComponent() {
  const [state, setState] = useState(null);

  useEffect(() => {
    // useEffect logic
  }, []);

  return <div>Component</div>;
}
```

## Validation Checklist
- [ ] No ESLint disable comments in any form
- [ ] All ESLint errors addressed with proper fixes
- [ ] Root causes understood and resolved
- [ ] Code follows project patterns and conventions
- [ ] Accessibility issues properly addressed
- [ ] Type safety maintained throughout codebase
- [ ] Performance implications considered

## Enforcement
This rule is enforced through:
- Code review validation
- Automated linting checks that flag disable comments
- Pre-commit hooks that prevent disable comments
- Team education and code quality standards

Remember: ESLint rules are there to help us write better code. Disabling them defeats the purpose and creates long-term maintenance problems.