---
id: rule-018
type: rule
version: 1.0.0
description: No @ts-expect-error or TypeScript error suppression directives - fix type issues properly instead of masking them
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No TypeScript Error Suppression Rule (rule-018)

## Purpose
Never use `@ts-expect-error`, `@ts-ignore`, or similar TypeScript error suppression directives. These directives mask type safety issues and can hide real problems in the codebase.

TypeScript errors should be resolved properly by fixing the underlying type issues, not suppressed. Error suppression undermines the purpose of using TypeScript and can introduce runtime bugs.

## Requirements

### MUST (Critical)
- **Never use** `@ts-expect-error` directives
- **Never use** `@ts-ignore` directives
- **Never use** `// @ts-nocheck` directives
- **Fix the root cause** instead of suppressing errors
- **Maintain type safety** throughout the codebase

### SHOULD (Important)
- **Understand the root cause** of type mismatches before attempting fixes
- **Create proper type definitions** when working with third-party libraries
- **Use type assertions sparingly** and only with defined interfaces
- **Refactor code** when needed to work with the type system

### MAY (Optional)
- **Create wrapper components** when working around third-party library limitations
- **Use utility type functions** for complex type operations
- **Document complex type decisions** with clear reasoning

## Common Violations and Solutions

### ❌ BAD: Using @ts-expect-error
```typescript
// @ts-expect-error - DialogContent has type definition issues
<DialogContent className="max-w-lg">
  <div>Content</div>
</DialogContent>
```

### ✅ GOOD: Fix the type issue properly
```typescript
// Option 1: Use proper component composition
<DialogContent>
  <div className="max-w-lg">
    <div>Content</div>
  </div>
</DialogContent>

// Option 2: Create a wrapper component with proper types
const StyledDialogContent = ({ children, ...props }) => (
  <DialogContent {...props}>
    {children}
  </DialogContent>
);

// Option 3: Use a type assertion with proper interface
<DialogContent {...({className: "max-w-lg"} as ComponentProps<typeof DialogContent>)}>
  <div>Content</div>
</DialogContent>
```

### ❌ BAD: Ignoring type errors
```typescript
// @ts-ignore
const result = someFunction(invalidArgument);
```

### ✅ GOOD: Fix the types
```typescript
// Fix the argument type
const result = someFunction(validArgument);

// Or create proper interface
interface ValidInput {
  // define proper structure
}
const validInput: ValidInput = { /* proper data */ };
const result = someFunction(validInput);
```

## When You Think You Need TypeScript Suppression

### Use proper type assertions
```typescript
// ❌ BAD
// @ts-expect-error
const data = response.data;

// ✅ GOOD
const data = response.data as ExpectedType;
```

### Define missing interfaces
```typescript
// ❌ BAD
// @ts-ignore - third party library types missing
library.someMethod(data);

// ✅ GOOD
interface LibraryMethod {
  someMethod: (data: DataType) => ReturnType;
}
(library as LibraryMethod).someMethod(data);
```

### Use unknown for truly unknown data
```typescript
// ❌ BAD
// @ts-expect-error
function processData(data: any) {
  return data.someProperty;
}

// ✅ GOOD
function processData(data: unknown) {
  if (typeof data === 'object' && data !== null && 'someProperty' in data) {
    return (data as { someProperty: unknown }).someProperty;
  }
  throw new Error('Invalid data format');
}
```

## Specific Project Patterns

### For shadcn/ui components with type issues
```typescript
// ❌ BAD
// @ts-expect-error - DialogContent has type issues
<DialogContent className="custom-class">

// ✅ GOOD - Use component composition
<DialogContent>
  <div className="custom-class">
    {/* content */}
  </div>
</DialogContent>

// ✅ GOOD - Create a typed wrapper
const TypedDialogContent = DialogContent as React.ComponentType<{
  className?: string;
  children?: React.ReactNode;
}>;
```

### For form components
```typescript
// ❌ BAD
// @ts-expect-error
<Label htmlFor="email">Email</Label>

// ✅ GOOD
<Label {...({htmlFor: "email"} as LabelHTMLAttributes<HTMLLabelElement>)}>
  Email
</Label>
```

## Alternative Solutions

### 1. Component Wrappers
Create properly typed wrapper components when shadcn components have type issues:

```typescript
interface StyledDialogProps {
  className?: string;
  children: React.ReactNode;
}

const StyledDialog: React.FC<StyledDialogProps> = ({ className, children }) => (
  <DialogContent>
    <div className={className}>
      {children}
    </div>
  </DialogContent>
);
```

### 2. Type Assertions with Interfaces
Use specific type assertions instead of error suppression:

```typescript
// Define the expected interface
interface DialogProps {
  className?: string;
  children?: React.ReactNode;
}

// Use proper type assertion
<DialogContent {...({className: "max-w-lg"} as DialogProps)}>
```

### 3. Utility Type Functions
Create utility functions for complex type operations:

```typescript
function withClassName<T>(
  component: T,
  className: string
): T & { className: string } {
  return { ...component, className };
}
```

### 4. Generic Wrapper Functions
```typescript
// Generic wrapper for extending component props
function extendComponentProps<T extends Record<string, any>>(
  Component: React.ComponentType<T>,
  additionalProps: Partial<T>
): React.ComponentType<T> {
  const ExtendedComponent = (props: T) => (
    <Component {...additionalProps} {...props} />
  );
  return ExtendedComponent;
}

// Usage
const ExtendedButton = extendComponentProps(Button, {
  variant: "outline" as const
});
```

### 5. Type Guards for Runtime Validation
```typescript
// Type guard function
function isValidUserData(data: unknown): data is UserData {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data &&
    typeof (data as any).id === 'string' &&
    typeof (data as any).name === 'string'
  );
}

// Usage
function processUserData(data: unknown): UserData {
  if (!isValidUserData(data)) {
    throw new Error('Invalid user data format');
  }
  return data; // TypeScript knows this is UserData now
}
```

## Advanced Examples

### Third-Party Library Integration
```typescript
// ❌ BAD
// @ts-expect-error - library has no types
import thirdPartyLib from 'third-party-lib';
thirdPartyLib.doSomething(data);

// ✅ GOOD - Create type definitions
interface ThirdPartyLib {
  doSomething: (data: { id: string; name: string }) => void;
}

const typedLib = thirdPartyLib as ThirdPartyLib;
typedLib.doSomething({ id: "123", name: "test" });
```

### Complex Event Handling
```typescript
// ❌ BAD
// @ts-expect-error - event type mismatch
function handleClick(event: Event) {
  const target = event.target; // Type errors
  console.log(target.value);
}

// ✅ GOOD - Proper event typing
function handleClick(event: React.ChangeEvent<HTMLInputElement>) {
  const target = event.target;
  console.log(target.value);
}

// Or with type guards
function handleClick(event: Event) {
  if (event.target instanceof HTMLInputElement) {
    console.log(event.target.value);
  }
}
```

### API Response Handling
```typescript
// ❌ BAD
// @ts-expect-error - unknown API response structure
async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data.name; // Property doesn't exist on unknown
}

// ✅ GOOD - Define response types
interface UserResponse {
  id: string;
  name: string;
  email: string;
}

async function fetchUser(id: string): Promise<UserResponse> {
  const response = await fetch(`/api/users/${id}`);

  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.statusText}`);
  }

  return response.json() as Promise<UserResponse>;
}
```

## ESLint Configuration

Add this to your ESLint config to prevent TypeScript error suppression:

```json
{
  "rules": {
    "@typescript-eslint/ban-ts-comment": "error",
    "@typescript-eslint/prefer-ts-expect-error": "off"
  }
}
```

## TypeScript Configuration

Enable strict type checking in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noImplicitReturns": true,
    "noImplicitThis": true
  }
}
```

## Migration Guide

### Step 1: Identify TypeScript Suppression
```bash
# Find all instances of error suppression
grep -r "@ts-expect-error" src/
grep -r "@ts-ignore" src/
grep -r "@ts-nocheck" src/
```

### Step 2: Analyze Each Case
For each instance, understand:
- What type error is being suppressed?
- Why does the type error exist?
- What is the correct type solution?

### Step 3: Apply Proper Fixes
Replace suppression with proper type solutions:
- Define missing interfaces
- Fix incorrect types
- Use proper type assertions
- Create wrapper components

## Validation Checklist
- [ ] No `@ts-expect-error` directives in the codebase
- [ ] No `@ts-ignore` directives in the codebase
- [ ] No `// @ts-nocheck` directives in the codebase
- [ ] All type errors resolved with proper solutions
- [ ] Proper type definitions for external libraries
- [ ] Component props properly typed
- [ ] Function return types explicitly defined
- [ ] Event handlers correctly typed

## Enforcement
This rule is enforced through:
- TypeScript compiler strict mode
- ESLint rules for TypeScript comments
- Code review validation
- Automated type checking in CI/CD
- Pre-commit hooks

Remember: TypeScript errors exist to prevent runtime issues. Suppressing them defeats the purpose of using TypeScript and can introduce bugs.