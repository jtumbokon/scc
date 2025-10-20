---
id: rule-009
type: rule
version: 1.0.0
description: Prohibit explicit 'any' types in TypeScript to maintain type safety
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No Explicit `any` Types Rule (rule-009)

## Purpose
Maintaining strict type safety is critical for catching errors at compile-time rather than runtime. Explicit `any` types defeat TypeScript's type system and should be avoided.

## Requirements

### MUST (Critical)
- **NEVER use explicit `any` types** in variable declarations
- **NEVER use explicit `any` types** in function parameters
- **NEVER use explicit `any` types** in return types
- **ALWAYS use specific types** or interfaces instead

### SHOULD (Important)
- **Prefer `unknown` over `any`** when type cannot be determined
- **Use generic types** for flexible but type-safe implementations
- **Create proper type definitions** for external data

### MAY (Optional)
- **Use `any` only as last resort** for legacy code integration
- **Document reasons** when `any` is absolutely necessary

## Examples

### ❌ Bad - Explicit `any` Types
```typescript
// ❌ Bad - Explicit any
let data: any = fetchData();
const user: any = { name: "John", age: 30 };

function processData(input: any): any {
  return input.map(item => item.value);
}

// ❌ Bad - Any in function parameters
function createUser(userData: any) {
  return userData;
}

// ❌ Bad - Any in arrays
const items: any[] = [1, "hello", true];
const result: Record<string, any> = {};
```

### ✅ Good - Specific Types
```typescript
// ✅ Good - Specific interfaces
interface User {
  name: string;
  age: number;
}

let user: User = { name: "John", age: 30 };

// ✅ Good - Generic functions
interface DataItem {
  id: string;
  value: string;
}

function processData<T extends { value: string }>(input: T[]): string[] {
  return input.map(item => item.value);
}

// ✅ Good - Typed parameters
function createUser(userData: {
  name: string;
  email: string;
  age?: number;
}): User {
  return {
    name: userData.name,
    age: userData.age || 0
  };
}

// ✅ Good - Typed arrays
const items: Array<string | number | boolean> = [1, "hello", true];
const result: Record<string, string | number> = {};
```

## Type-Safe Alternatives

### Use `unknown` for Uncertain Types
```typescript
// ❌ Bad
function handleApiResponse(data: any) {
  // No type safety
}

// ✅ Good
function handleApiResponse(data: unknown) {
  if (typeof data === 'string') {
    // Type narrowed to string
    console.log(data.toUpperCase());
  } else if (typeof data === 'object' && data !== null) {
    // Type narrowed to object
    console.log(Object.keys(data));
  }
}
```

### Use Generic Types
```typescript
// ❌ Bad
function getFirstElement(arr: any[]): any {
  return arr[0];
}

// ✅ Good
function getFirstElement<T>(arr: T[]): T | undefined {
  return arr[0];
}

// Usage with type inference
const numbers = [1, 2, 3];
const first = getFirstElement(numbers); // Type: number | undefined
```

### Create Proper Type Definitions
```typescript
// ❌ Bad
const apiResponse: any = await fetch('/api/data');

// ✅ Good - Define response type
interface ApiResponse<T> {
  data: T;
  status: 'success' | 'error';
  message?: string;
}

type UserData = {
  id: string;
  name: string;
  email: string;
};

const apiResponse: ApiResponse<UserData> = await fetch('/api/data');
```

## Common Scenarios

### API Responses
```typescript
// ❌ Bad
async function fetchUser(id: string): Promise<any> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// ✅ Good
interface User {
  id: string;
  name: string;
  email: string;
}

async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

### Event Handlers
```typescript
// ❌ Bad
function handleClick(event: any) {
  console.log(event.target.value);
}

// ✅ Good
function handleClick(event: React.MouseEvent<HTMLInputElement>) {
  console.log(event.currentTarget.value);
}
```

### Form Data
```typescript
// ❌ Bad
function handleSubmit(data: any) {
  // Process form data
}

// ✅ Good
interface FormData {
  name: string;
  email: string;
  message: string;
}

function handleSubmit(data: FormData) {
  // Process form data with type safety
}
```

### Third-Party Libraries
```typescript
// ❌ Bad
import ThirdPartyLib from 'third-party-lib';
const config: any = { /* config */ };

// ✅ Good - Create type definitions
interface ThirdPartyConfig {
  apiKey: string;
  endpoint: string;
  timeout?: number;
}

const config: ThirdPartyConfig = {
  apiKey: process.env.API_KEY!,
  endpoint: 'https://api.example.com'
};
```

## Migration Strategy

### Step 1: Identify `any` Usage
```bash
# Find all explicit any types
grep -r ": any" src/
grep -r "<any>" src/
grep -r "as any" src/
```

### Step 2: Replace with Specific Types
```typescript
// Before
const data: any = fetchData();

// After - analyze the actual structure
interface FetchedData {
  id: string;
  name: string;
  // ... other properties
}
const data: FetchedData = fetchData();
```

### Step 3: Gradual Improvement
```typescript
// Transitional - use unknown temporarily
function processLegacyData(data: unknown) {
  // Add type guards and validation
  if (isValidData(data)) {
    // Now we can safely use the data
    return processData(data as ValidatedData);
  }
}
```

## Validation Checklist
- [ ] No explicit `any` types in variable declarations
- [ ] No explicit `any` types in function parameters
- [ ] No explicit `any` types in return types
- [ ] Used `unknown` instead of `any` when type uncertain
- [ ] Created proper type definitions for external data
- [ ] Used generic types for flexible but type-safe implementations
- [ ] Added type guards for runtime type checking when needed

## Enforcement
This rule is enforced through:
- TypeScript compiler configuration (`noImplicitAny: true`)
- ESLint rules (`@typescript-eslint/no-explicit-any`)
- Code review validation
- Automated type checking in CI/CD

Maintaining strict type safety prevents runtime errors and improves code reliability and maintainability.