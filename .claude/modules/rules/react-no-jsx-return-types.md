---
id: rule-021
type: rule
version: 1.0.0
description: React components don't need explicit JSX return types - let TypeScript infer JSX return types automatically
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# React No JSX Return Types Rule (rule-021)

## Purpose
In modern React with TypeScript, explicit return type annotations like `JSX.Element`, `React.ReactElement`, or `React.FC` are **unnecessary and discouraged** for functional components. TypeScript automatically infers the correct JSX return type, and adding these annotations is redundant boilerplate that doesn't provide any additional type safety.

This rule clarifies an exception to the general "explicit return types" rule - React functional components are the one case where TypeScript's inference is preferred over explicit annotations.

## Requirements

### MUST (Critical)
- **NEVER add explicit JSX return types** to React functional components
- **Let TypeScript infer JSX return types** automatically
- **Remove existing JSX return type annotations** when encountered
- **Focus explicit typing on props interfaces** instead of return types
- **This rule overrides** the general explicit return types rule for React components specifically

### SHOULD (Important)
- **Use TypeScript inference** for all component return types
- **Define clear props interfaces** for component APIs
- **Focus typing efforts** on state, props, and event handlers
- **Let TypeScript handle conditional rendering** type inference automatically

### MAY (Optional)
- **Add return types** for non-React functions in the same file
- **Use return types** for utility functions or complex business logic
- **Document component behavior** through JSDoc comments

## Examples

### ✅ Correct - No Return Type Annotation
```typescript
// ✅ Good - TypeScript infers the JSX return type
function HeroSection() {
  return (
    <div>
      <h1>Welcome</h1>
    </div>
  );
}

// ✅ Good - With props, still no return type needed
interface Props {
  title: string;
  subtitle?: string;
}

function HeroSection({ title, subtitle }: Props) {
  return (
    <div>
      <h1>{title}</h1>
      {subtitle && <p>{subtitle}</p>}
    </div>
  );
}

// ✅ Good - Arrow function, no return type
const HeroSection = ({ title }: { title: string }) => {
  return <div><h1>{title}</h1></div>;
};

// ✅ Good - Async component (Server Component)
async function ServerComponent() {
  const data = await fetchData();
  return <div>{data.title}</div>;
}
```

### ❌ Incorrect - Unnecessary Return Type Annotations
```typescript
// ❌ Bad - Unnecessary JSX.Element annotation
function HeroSection(): JSX.Element {
  return <div><h1>Welcome</h1></div>;
}

// ❌ Bad - Unnecessary React.ReactElement annotation
function HeroSection(): React.ReactElement {
  return <div><h1>Welcome</h1></div>;
}

// ❌ Bad - React.FC is also unnecessary
const HeroSection: React.FC = () => {
  return <div><h1>Welcome</h1></div>;
};

// ❌ Bad - With props, still unnecessary
function HeroSection({ title }: { title: string }): JSX.Element {
  return <div><h1>{title}</h1></div>;
}

// ❌ Bad - Arrow function with unnecessary return type
const HeroSection = (): JSX.Element => {
  return <div><h1>Welcome</h1></div>;
};
```

## Why This Rule Exists

### TypeScript's JSX Inference is Excellent
Modern TypeScript (4.1+) has excellent JSX type inference that:
- **Automatically determines** the correct return type based on JSX elements
- **Handles conditional rendering** and complex JSX expressions correctly
- **Provides full type safety** without manual annotations
- **Catches JSX errors** at compile time

### Explicit JSX Return Types Are Redundant
Adding explicit JSX return types:
- **Provides no additional type safety** - TypeScript already knows it's JSX
- **Creates unnecessary boilerplate** that clutters component definitions
- **Can become outdated** if component logic changes
- **Doesn't follow modern React best practices** (React team doesn't recommend them)

### Focus on What Matters
Instead of return types, focus TypeScript efforts on:
- **Props interfaces** - Define clear component APIs
- **State types** - Type useState and other hooks properly
- **Event handler types** - Ensure event handling is type-safe
- **Custom hooks** - Type hook parameters and return values

## Specific Cases

### Server Components (Async)
```typescript
// ✅ Good - No return type needed even for async
async function ServerComponent() {
  const data = await getData();
  return <div>{data.title}</div>;
}

// ❌ Bad - Unnecessary Promise<JSX.Element>
async function ServerComponent(): Promise<JSX.Element> {
  const data = await getData();
  return <div>{data.title}</div>;
}
```

### Components with Conditional Returns
```typescript
// ✅ Good - TypeScript handles conditional returns automatically
function ConditionalComponent({ show }: { show: boolean }) {
  if (!show) {
    return null; // TypeScript knows this returns JSX.Element | null
  }

  return <div>Content</div>;
}

// ❌ Bad - Explicit union type is unnecessary
function ConditionalComponent({ show }: { show: boolean }): JSX.Element | null {
  if (!show) return null;
  return <div>Content</div>;
}
```

### Higher-Order Components
```typescript
// ✅ Good - Generic inference works well
function withLoading<T extends object>(Component: React.ComponentType<T>) {
  return function LoadingWrapper(props: T & { isLoading?: boolean }) {
    if (props.isLoading) {
      return <div>Loading...</div>;
    }
    return <Component {...props} />;
  };
}

// ❌ Bad - Return type annotation interferes with generics
function withLoading<T extends object>(
  Component: React.ComponentType<T>
): React.ComponentType<T & { isLoading?: boolean }> {
  // More complex and less flexible
}
```

## Advanced Patterns

### Generic Components
```typescript
// ✅ Good - Generic props without return type
interface GenericListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
}

function GenericList<T>({ items, renderItem }: GenericListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={index}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage:
<GenericList
  items={users}
  renderItem={(user) => <span>{user.name}</span>}
/>
```

### Component with Hooks
```typescript
// ✅ Good - No return type, hooks properly typed
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

### Custom Hooks with Components
```typescript
// ✅ Good - Custom hook properly typed, component without return type
function useUserData(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading };
}

function UserProfile({ userId }: { userId: string }) {
  const { user, loading } = useUserData(userId);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return <div>{user.name}</div>;
}
```

## Integration with Existing Rules

This rule provides a **specific exception** to the general `typescript-explicit-return-types` rule:

- **General functions**: Still require explicit return types
- **API handlers**: Still require explicit return types
- **Utility functions**: Still require explicit return types
- **React components**: Do NOT require return type annotations (this rule)

## Migration Strategy

### Step 1: Identify JSX Return Types
```bash
# Find components with JSX return types
grep -r "): JSX\.Element\|React\.ReactElement\|React\.FC" src/components --include="*.tsx"
```

### Step 2: Remove Return Type Annotations
```typescript
// Before
function Component(): JSX.Element {
  return <div>Content</div>;
}

// After
function Component() {
  return <div>Content</div>;
}
```

### Step 3: Verify Compilation
```bash
# TypeScript should still compile successfully
npx tsc --noEmit
```

### Step 4: Update Documentation
```typescript
// Remove return type from JSDoc
/**
 * Renders a hero section
 * @param props - Component props
 * @returns JSX element
 */
function HeroSection({ title }: { title: string }) {
  return <h1>{title}</h1>;
}

// Better - Focus on props
/**
 * Renders a hero section with title and optional subtitle
 * @param title - Main title to display
 * @param subtitle - Optional subtitle to display
 */
function HeroSection({ title, subtitle }: Props) {
  return (
    <div>
      <h1>{title}</h1>
      {subtitle && <p>{subtitle}</p>}
    </div>
  );
}
```

## Benefits of This Approach

1. **Cleaner Code** - Less visual noise in component definitions
2. **Better Developer Experience** - Less boilerplate to write and maintain
3. **Modern Best Practices** - Aligns with current React/TypeScript recommendations
4. **Automatic Updates** - TypeScript adjusts types as JSX changes
5. **Focus on Value** - Spend typing effort on props and logic, not return types

## Comparison Table

| Aspect | With JSX Return Types | Without JSX Return Types |
|--------|-------------------|------------------------|
| **Boilerplate** | High - Every function needs type annotation | Low - TypeScript infers automatically |
| **Maintainability** | Low - Must update types when JSX changes | High - TypeScript tracks changes automatically |
| **Learning Curve** | Higher - New developers need to learn JSX types | Lower - Focus on component logic |
| **Modern Practice** | Poor - React team discourages them | Good - Follows current best practices |
| **Type Safety** | Same - TypeScript provides full safety | Same - TypeScript provides full safety |

## Common Misconceptions

### "But I need explicit types for clarity!"
```typescript
// ❌ Unnecessary - JSX is self-documenting
function Button(): JSX.Element {
  return <button>Click me</button>;
}

// ✅ Better - Props provide the clarity you need
interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
}

function Button({ children, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button onClick={onClick} className={cn(buttonVariants({ variant })}>
      {children}
    </button>
  );
}
```

### "What about null returns?"
```typescript
// ✅ TypeScript handles this automatically
function ConditionalComponent({ show }: { show: boolean }) {
  if (!show) {
    return null; // TypeScript knows this is JSX.Element | null
  }
  return <div>Content</div>;
}
```

## Validation Checklist
- [ ] Never suggest JSX.Element, React.ReactElement, or React.FC return types
- [ ] Remove explicit JSX return types when editing React components
- [ ] Focus TypeScript suggestions on props interfaces instead
- [ ] Let TypeScript automatically infer JSX return types
- [ ] This rule overrides general return type requirements for React components
- [ ] Still apply explicit return types to non-React functions in the same file

## Enforcement
This rule is enforced through:
- ESLint rules for React component patterns
- TypeScript compiler configuration
- Code review validation
- Automated refactoring tools
- React team best practice guidelines

Letting TypeScript infer JSX return types results in cleaner, more maintainable components that follow modern React best practices while maintaining full type safety.