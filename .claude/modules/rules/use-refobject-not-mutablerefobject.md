---
id: rule-037
type: rule
version: 1.0.0
description: Use RefObject instead of deprecated MutableRefObject for proper null safety and modern React typing
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Use RefObject Instead of MutableRefObject Rule (rule-037)

## Purpose
React's `MutableRefObject<T>` type is deprecated in favor of `RefObject<T>`. While both types serve similar purposes for referencing DOM elements and storing mutable values, there are important differences in their type signatures that affect null safety and usage patterns.

The key difference is:
- `MutableRefObject<T>` has `current: T` (never null)
- `RefObject<T>` has `current: T | null` (can be null)

Using the deprecated `MutableRefObject<T>` will result in TypeScript warnings and should be replaced with `RefObject<T>` with proper null handling.

## Requirements

### MUST (Critical)
- **NEVER use `React.MutableRefObject<T>`** in type annotations - it's deprecated
- **ALWAYS use `React.RefObject<T>`** for ref types
- **HANDLE nullability properly** since `RefObject.current` can be `null`
- **ADD null checks** when accessing or modifying `ref.current`
- **USE nullish coalescing** (`||`) when providing fallback values

### SHOULD (Important)
- **Update function parameters** to use `RefObject` instead of `MutableRefObject`
- **ENSURE component props** use `RefObject` consistently
- **TEST null handling** works correctly after migration
- **REMOVE non-null assertions** unless absolutely necessary

### MAY (Optional)
- **Use type assertions** when you know ref is non-null (prefer over non-null assertion)
- **Add ESLint rules** to catch deprecated usage
- **CREATE migration scripts** for large codebases
- **DOCUMENT ref usage patterns** for team consistency

## Examples

### Basic Ref Usage
| ❌ Bad (deprecated) | ✅ Good (current) |
|---|---|
| ```typescript
const textRef: React.MutableRefObject<string> = useRef("");

function updateText(newText: string) {
  textRef.current = newText; // No null safety
}
``` | ```typescript
const textRef: React.RefObject<string> = useRef("");

function updateText(newText: string) {
  if (textRef.current !== null) {
    textRef.current = newText; // Null-safe
  }
}
``` |

### Function Parameters
| ❌ Bad (deprecated) | ✅ Good (current) |
|---|---|
| ```typescript
function processRef(
  ref: React.MutableRefObject<string>
): void {
  ref.current += " processed";
}
``` | ```typescript
function processRef(
  ref: React.RefObject<string>
): void {
  if (ref.current !== null) {
    ref.current += " processed";
  }
}
``` |

### Component Props
| ❌ Bad (deprecated) | ✅ Good (current) |
|---|---|
| ```typescript
interface Props {
  textRef: React.MutableRefObject<string>;
  countRef: React.MutableRefObject<number>;
}

function MyComponent({ textRef, countRef }: Props) {
  textRef.current = "updated";
  countRef.current = 42;
}
``` | ```typescript
interface Props {
  textRef: React.RefObject<string>;
  countRef: React.RefObject<number>;
}

function MyComponent({ textRef, countRef }: Props) {
  if (textRef.current !== null) {
    textRef.current = "updated";
  }
  if (countRef.current !== null) {
    countRef.current = 42;
  }
}
``` |

### Reading Values with Fallbacks
| ❌ Bad (deprecated) | ✅ Good (current) |
|---|---|
| ```typescript
function getValue(
  ref: React.MutableRefObject<string>
): string {
  return ref.current; // Always assumes non-null
}
``` | ```typescript
function getValue(
  ref: React.RefObject<string>
): string {
  return ref.current || ""; // Handles null case
}
``` |

## Common Patterns

### State Management with Refs
```typescript
// ✅ Good - Handle null properly
function useAccumulatedText(): {
  textRef: React.RefObject<string>;
  appendText: (text: string) => void;
  clearText: () => void;
} {
  const textRef = useRef<string>("");

  const appendText = useCallback((text: string) => {
    if (textRef.current !== null) {
      textRef.current += text;
    }
  }, []);

  const clearText = useCallback(() => {
    if (textRef.current !== null) {
      textRef.current = "";
    }
  }, []);

  return { textRef, appendText, clearText };
}
```

### Streaming/Connection Management
```typescript
// ✅ Good - Null-safe ref operations
function StreamingManager({
  accumulatedTextRef,
  currentAgentRef
}: {
  accumulatedTextRef: React.RefObject<string>;
  currentAgentRef: React.RefObject<string>;
}): void {
  // Reset refs safely
  if (accumulatedTextRef.current !== null) {
    accumulatedTextRef.current = "";
  }
  if (currentAgentRef.current !== null) {
    currentAgentRef.current = "";
  }

  // Update refs safely
  const updateRefs = (text: string, agent: string) => {
    if (accumulatedTextRef.current !== null) {
      accumulatedTextRef.current += text;
    }
    if (currentAgentRef.current !== null) {
      currentAgentRef.current = agent;
    }
  };
}
```

### DOM Element Refs
```typescript
// ✅ Good - Handle DOM element refs properly
function useElementRef(): {
  elementRef: React.RefObject<HTMLDivElement>;
  focusElement: () => void;
} {
  const elementRef = useRef<HTMLDivElement>(null);

  const focusElement = useCallback(() => {
    if (elementRef.current) { // DOM refs are naturally nullable
      elementRef.current.focus();
    }
  }, []);

  return { elementRef, focusElement };
}
```

## Migration Strategy

### Step 1: Update Type Annotations
```typescript
// Before
const ref: React.MutableRefObject<string> = useRef("");

// After
const ref: React.RefObject<string> = useRef("");
```

### Step 2: Add Null Checks
```typescript
// Before
ref.current = "new value";

// After
if (ref.current !== null) {
  ref.current = "new value";
}
```

### Step 3: Handle Fallback Values
```typescript
// Before
const value = ref.current;

// After
const value = ref.current || "";
```

### Step 4: Update Function Signatures
```typescript
// Before
function processRef(ref: React.MutableRefObject<string>): void {
  // ...
}

// After
function processRef(ref: React.RefObject<string>): void {
  // ...
}
```

## When RefObject.current is Always Non-Null

In some cases, you know the ref will always have a value (e.g., initialized with a default). You have several options:

### Option 1: Defensive Programming (Recommended)
```typescript
const textRef = useRef<string>("initial");
if (textRef.current !== null) {
  textRef.current += " more text";
}
```

### Option 2: Type Assertion (Prefer over non-null assertion)
```typescript
const textRef = useRef<string>("initial");
(textRef.current as string) += " more text";
```

### Option 3: Non-null Assertion (Use sparingly)
```typescript
const textRef = useRef<string>("initial");
textRef.current! += " more text";
```

## ESLint Configuration

Add this to your ESLint config to catch deprecated usage:

```json
{
  "rules": {
    "@typescript-eslint/ban-types": [
      "error",
      {
        "types": {
          "React.MutableRefObject": {
            "message": "Use React.RefObject instead - MutableRefObject is deprecated",
            "fixWith": "React.RefObject"
          }
        }
      }
    ]
  }
}
```

## Common Mistakes

### ❌ Mistake 1: Forgetting null checks
```typescript
// Bad - assumes current is never null
function updateRef(ref: React.RefObject<string>) {
  ref.current = "new value"; // TypeScript error!
}

// Good - check for null
function updateRef(ref: React.RefObject<string>) {
  if (ref.current !== null) {
    ref.current = "new value";
  }
}
```

### ❌ Mistake 2: Not handling fallbacks
```typescript
// Bad - could return null
function getRefValue(ref: React.RefObject<string>): string {
  return ref.current; // TypeScript error!
}

// Good - provide fallback
function getRefValue(ref: React.RefObject<string>): string {
  return ref.current || "";
}
```

### ❌ Mistake 3: Mixed usage patterns
```typescript
// Bad - inconsistent types
interface Props {
  oldRef: React.MutableRefObject<string>; // Deprecated
  newRef: React.RefObject<string>; // Current
}

// Good - consistent modern types
interface Props {
  textRef: React.RefObject<string>;
  countRef: React.RefObject<number>;
}
```

### ❌ Mistake 4: Unsafe non-null assertions
```typescript
// Bad - overusing non-null assertions
function processRef(ref: React.RefObject<string>) {
  ref.current! += " processed"; // Unsafe
}

// Good - proper null checking
function processRef(ref: React.RefObject<string>) {
  if (ref.current !== null) {
    ref.current += " processed";
  }
}
```

## Advanced Patterns

### Generic Ref Helper
```typescript
// ✅ Good - Generic helper for null-safe ref operations
function useSafeRef<T>(initialValue: T): {
  ref: React.RefObject<T>;
  getValue: () => T;
  setValue: (value: T) => void;
} {
  const ref = useRef<T>(initialValue);

  const getValue = useCallback((): T => {
    return ref.current ?? initialValue;
  }, [initialValue]);

  const setValue = useCallback((value: T) => {
    if (ref.current !== null) {
      ref.current = value;
    }
  }, []);

  return { ref, getValue, setValue };
}
```

### Ref Collections
```typescript
// ✅ Good - Managing multiple refs safely
function useRefCollection<T>(): {
  refs: React.RefObject<T>[];
  addRef: () => React.RefObject<T>;
  updateRef: (index: number, value: T) => void;
  clearAllRefs: () => void;
} {
  const [refs, setRefs] = useState<React.RefObject<T>[]>([]);

  const addRef = useCallback(() => {
    const newRef = useRef<T>(null as any);
    setRefs(prev => [...prev, newRef]);
    return newRef;
  }, []);

  const updateRef = useCallback((index: number, value: T) => {
    const ref = refs[index];
    if (ref && ref.current !== null) {
      ref.current = value;
    }
  }, [refs]);

  const clearAllRefs = useCallback(() => {
    refs.forEach(ref => {
      if (ref && ref.current !== null) {
        ref.current = null as any;
      }
    });
  }, [refs]);

  return { refs, addRef, updateRef, clearAllRefs };
}
```

## Benefits of Using RefObject

1. **Future-proof** - Aligns with React's current type definitions
2. **Better null safety** - Forces consideration of null cases
3. **Consistency** - Matches DOM element ref patterns
4. **No deprecation warnings** - Keeps codebase warning-free
5. **Type system alignment** - Works better with strict TypeScript
6. **Defensive programming** - Encourages safer code practices

## Validation Checklist
- [ ] Never suggest `React.MutableRefObject<T>` in type annotations
- [ ] Always use `React.RefObject<T>` for ref types
- [ ] Add null checks when modifying `ref.current`
- [ ] Use nullish coalescing (`||`) for fallback values when reading `ref.current`
- [ ] Update function parameters to use `RefObject` instead of `MutableRefObject`
- [ ] Ensure component props use `RefObject` consistently
- [ ] Test that null handling works correctly after migration
- [ ] Remove any non-null assertions unless absolutely necessary
- [ ] Add ESLint rules to catch deprecated usage patterns

This ensures modern React typing practices and eliminates deprecation warnings while maintaining type safety.