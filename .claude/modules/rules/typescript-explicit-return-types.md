---
id: rule-011
type: rule
version: 1.0.0
description: Require explicit return types for TypeScript functions to improve type safety and code clarity
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# TypeScript Explicit Return Types Rule (rule-011)

## Purpose
TypeScript functions without explicit return types can lead to unpredictable behavior and runtime errors. When functions lack return type annotations, TypeScript infers the return type, which can sometimes be `undefined` or more permissive than intended. This creates situations where consumers of the function don't know what to expect, leading to errors like `Cannot read properties of undefined`.

Explicit return types provide:
- **Clear contracts** between functions and their consumers
- **Early error detection** when function implementations change
- **Better IDE support** with accurate autocomplete and error checking
- **Prevention of accidental undefined returns** that cause runtime errors
- **Improved refactoring safety** with compile-time guarantees

## Requirements

### MUST (Critical)
- **ALWAYS declare explicit return types** for all function declarations
- **ALWAYS declare explicit return types** for arrow functions
- **ALWAYS declare explicit return types** for method declarations
- **NEVER rely on TypeScript's return type inference** for exported functions
- **ALWAYS include Promise wrapper** for async functions

### SHOULD (Important)
- **Declare return types for private functions** when logic is complex
- **Use specific return types** rather than generic ones when possible
- **Consider using void** explicitly for functions that don't return values
- **Use discriminated unions** for functions that can return different result types

### MAY (Optional)
- **Omit return types** for simple callback functions in very local scope
- **Use type inference** for immediately invoked function expressions (IIFE)

## Examples

### ❌ Bad - Implicit Return Types
```typescript
// ❌ Bad - No explicit return type
function getUser(id: string) {
  return db.users.find(id);
}

// ❌ Bad - Arrow function without return type
const createUser = (userData: User) => {
  return db.users.create(userData);
};

// ❌ Bad - Method without return type
class UserService {
  getActiveUsers() {
    return this.users.filter(user => user.isActive);
  }
}

// ❌ Bad - Complex logic with implicit return
function processOrder(order: Order) {
  if (!order.items.length) {
    throw new Error('Empty order');
  }

  const total = calculateTotal(order.items);
  const tax = total * 0.08;

  return {
    total,
    tax,
    grandTotal: total + tax
  };
}
```

### ✅ Good - Explicit Return Types
```typescript
// ✅ Good - Function with explicit return type
function getUser(id: string): User | null {
  return db.users.find(id);
}

// ✅ Good - Arrow function with explicit return type
const createUser = (userData: CreateUserRequest): User => {
  return db.users.create(userData);
};

// ✅ Good - Method with explicit return type
class UserService {
  getActiveUsers(): User[] {
    return this.users.filter(user => user.isActive);
  }
}

// ✅ Good - Complex logic with explicit return type
function processOrder(order: Order): ProcessedOrder {
  if (!order.items.length) {
    throw new Error('Empty order');
  }

  const total = calculateTotal(order.items);
  const tax = total * 0.08;

  return {
    total,
    tax,
    grandTotal: total + tax
  };
}
```

## Function Types That Need Return Types

### Server Actions
```typescript
// ❌ Bad - no return type
export async function getCurrentUserUsage() {
  try {
    const result = await getUsageStats();
    return { success: true, data: result };
  } catch (error) {
    return { success: false, error: "Failed to fetch" };
  }
}

// ✅ Good - explicit return type with discriminated union
export type GetCurrentUserUsageResult =
  | { success: true; data: UsageStats }
  | { success: false; error: string };

export async function getCurrentUserUsage(): Promise<GetCurrentUserUsageResult> {
  try {
    const result = await getUsageStats();
    return { success: true, data: result };
  } catch (error) {
    return { success: false, error: "Failed to fetch" };
  }
}
```

### API Route Handlers
```typescript
// ❌ Bad - no return type
export async function GET(request: NextRequest) {
  const data = await fetchData();
  return NextResponse.json(data);
}

// ✅ Good - explicit return type
export async function GET(request: NextRequest): Promise<NextResponse> {
  try {
    const data = await fetchData();
    return NextResponse.json({ success: true, data });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Failed to fetch" }, { status: 500 });
  }
}
```

### React Component Functions
```typescript
// ❌ Bad - no return type
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState(null);
  return <div>{user?.name}</div>;
}

// ✅ Good - explicit return type
function UserProfile({ userId }: { userId: string }): JSX.Element {
  const [user, setUser] = useState<User | null>(null);
  return <div>{user?.name}</div>;
}
```

## Return Type Patterns

### Result Pattern for Operations That Can Fail
```typescript
export type Result<T, E = string> =
  | { success: true; data: T }
  | { success: false; error: E };

export async function saveDocument(doc: Document): Promise<Result<string>> {
  try {
    const id = await db.documents.insert(doc);
    return { success: true, data: id };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

### Optional Data Pattern
```typescript
export async function findUser(email: string): Promise<User | null> {
  const user = await db.users.findByEmail(email);
  return user || null;
}
```

### Validation Result Pattern
```typescript
export type ValidationResult<T> = {
  valid: T[];
  invalid: { item: T; reason: string }[];
};

export function validateFiles(files: File[]): ValidationResult<File> {
  const valid: File[] = [];
  const invalid: { item: File; reason: string }[] = [];

  files.forEach(file => {
    if (file.size > MAX_SIZE) {
      invalid.push({ item: file, reason: "File too large" });
    } else {
      valid.push(file);
    }
  });

  return { valid, invalid };
}
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Using `any` as return type
```typescript
// ❌ Bad
function processData(input: unknown): any {
  return JSON.parse(input as string);
}

// ✅ Good
interface ProcessedData {
  id: string;
  name: string;
}

function processData(input: unknown): ProcessedData {
  const parsed = JSON.parse(input as string);
  return {
    id: parsed.id,
    name: parsed.name,
  };
}
```

### ❌ Mistake 2: Forgetting Promise wrapper for async functions
```typescript
// ❌ Bad
async function fetchUser(id: string): User {
  return await db.users.findById(id);
}

// ✅ Good
async function fetchUser(id: string): Promise<User | null> {
  return await db.users.findById(id);
}
```

### ❌ Mistake 3: Not handling error cases in return type
```typescript
// ❌ Bad - doesn't account for errors
async function uploadFile(file: File): Promise<string> {
  return await storage.upload(file); // What if this throws?
}

// ✅ Good - explicit error handling
async function uploadFile(file: File): Promise<{ success: true; url: string } | { success: false; error: string }> {
  try {
    const url = await storage.upload(file);
    return { success: true, url };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

## Benefits of Explicit Return Types

1. **Prevents undefined access errors** - Consumers know exactly what to expect
2. **Better error handling** - Forces consideration of failure cases
3. **Improved refactoring** - Changes to function implementation are caught at compile time
4. **Enhanced IDE experience** - Better autocomplete and error detection
5. **Self-documenting code** - Return types serve as inline documentation
6. **Easier testing** - Clear contracts make it easier to write comprehensive tests

## Migration Strategy

For existing codebases:
1. **Start with public APIs** - Add return types to exported functions first
2. **Focus on critical paths** - Prioritize functions that handle user data or business logic
3. **Use gradual typing** - Add return types incrementally during code reviews
4. **Update tests** - Ensure tests validate the new return type contracts

## Validation Checklist
- [ ] All exported functions have explicit return types
- [ ] All arrow functions have explicit return types
- [ ] All class methods have explicit return types
- [ ] Async functions return Promise<T>
- [ ] Void functions explicitly return void
- [ ] Generic functions have proper type parameters
- [ ] Complex return types use appropriate unions/intersections

## Enforcement
This rule is enforced through:
- TypeScript compiler configuration (`noImplicitReturns: true`)
- ESLint rules (`@typescript-eslint/explicit-function-return-type`)
- Code review validation
- Automated type checking

Explicit return types make code more predictable, self-documenting, and maintainable while catching potential type errors early in development.