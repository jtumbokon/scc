---
id: rule-030
type: rule
version: 1.0.0
description: Never use void to suppress unused variable warnings - fix root causes instead of masking code quality issues
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No Void Unused Variables Rule (rule-030)

## Purpose
Using `void` statements to suppress TypeScript unused variable warnings is a dangerous anti-pattern that masks real code quality issues. This hack bypasses proper code analysis and creates technical debt instead of addressing the root cause.

This approach hides real issues that should be addressed properly, creates technical debt by leaving unused code in place, bypasses TypeScript's helpful analysis, and makes code harder to maintain.

## Requirements

### MUST (Critical)
- **NEVER use `void` statements** to suppress unused variable warnings
- **NEVER use `void` with variables** to bypass linting rules
- **ALWAYS fix the root cause** instead of suppressing the warning
- **REMOVE unused variables** completely if they're not needed
- **REFACTOR code** to eliminate unused variables properly

### SHOULD (Important)
- **Use underscore prefix** for intentionally unused variables
- **DESTRUCTURE properly** to avoid unused assignments
- **EXTRACT only what's needed** from complex objects or arrays
- **ELIMINATE dead code** that serves no purpose

### MAY (Optional)
- **Document temporary unused variables** with clear future usage plans
- **Create utility functions** to handle complex destructuring patterns
- **Use TypeScript utility types** to extract specific object properties
- **Implement code review guidelines** for unused variable handling

## Forbidden Patterns

### ❌ ALL FORMS ARE FORBIDDEN
```typescript
// ❌ FORBIDDEN - Using void to suppress warnings

// Basic void suppression
const unusedVariable = getValue();
void unusedVariable; // Suppress lint warning

// With comments trying to justify it
const [isInputFocused, setIsInputFocused] = useState(false);
// Suppress lint warning - isInputFocused is used in ChatInput component
void isInputFocused;

// Complex suppression patterns
const result = useComplexHook();
void result.unusedProperty; // Suppressing unused part
void result.data; // Another part we don't need

// Multiple void suppressions
const unused1 = getVal1();
const unused2 = getVal2();
void unused1, unused2; // Multiple suppressions

// In function parameters
function handleClick(event: React.MouseEvent) {
  doSomething();
  void event; // Suppress unused parameter
}
```

## Proper Solutions

### Solution 1: Remove Unused Variables Completely
```typescript
// ❌ BAD - Void suppression
const [isInputFocused, setIsInputFocused] = useState(false);
void isInputFocused; // Suppress lint warning

// ✅ GOOD - Remove unused variable
const [, setIsInputFocused] = useState(false);

// ✅ EVEN BETTER - Remove entirely if setter is also unused
// const [isInputFocused, setIsInputFocused] = useState(false);
// If neither is used, remove the entire state declaration
```

### Solution 2: Use Underscore Prefix for Intentionally Unused
```typescript
// ❌ BAD - Void suppression
const unusedParam = getParam();
void unusedParam; // Suppress warning

// ✅ GOOD - Underscore prefix
const _unusedParam = getParam(); // Intentionally unused
const _param = getParam(); // Will be used later (clear intent)

// ✅ GOOD - Function parameters
function handleEvent(_event: Event, data: string): void {
  console.log(data);
}

function handleClick(_: React.MouseEvent): void {
  // Handle click without using event
}
```

### Solution 3: Actually Use the Variable Properly
```typescript
// ❌ BAD - Void suppression instead of proper usage
const [isInputFocused, setIsInputFocused] = useState(false);
void isInputFocused; // Not actually using it

// ✅ GOOD - Implement proper usage if needed
const [isInputFocused, setIsInputFocused] = useState(false);

// Pass to component that needs it
<ChatInput
  onFocus={() => setIsInputFocused(true)}
  onBlur={() => setIsInputFocused(false)}
  isFocused={isInputFocused}
/>

// Use in component logic
useEffect(() => {
  if (isInputFocused) {
    // Handle focus state
    console.log('Input is focused');
  }
}, [isInputFocused]);
```

### Solution 4: Extract Only What's Needed
```typescript
// ❌ BAD - Destructure everything then suppress unused parts
const result = useComplexHook();
void result.unusedProperty; // Suppressing unused part
void result.data; // Another part we don't need
return result.neededProperty;

// ✅ GOOD - Destructure only what's needed
const { neededProperty } = useComplexHook();
return neededProperty;

// ✅ GOOD - Use underscore for specific unused properties
const { neededProperty, _unusedProp, __anotherUnused } = useComplexHook();
return neededProperty;
```

## Advanced Destructuring Patterns

### Pattern 1: Complex Hook Returns
```typescript
// ✅ GOOD - Proper destructuring of complex hooks
function UserProfile() {
  // Instead of suppressing unused parts
  // const { user, error, loading, refetch } = useUserProfile();
  // void error;
  // void refetch;

  // Extract only what's needed
  const { user, loading } = useUserProfile();

  // Or use underscore for intentionally unused
  const { user, loading: isLoading, _error, _refetch } = useUserProfile();

  return (
    <div>
      {isLoading ? 'Loading...' : <UserCard user={user} />}
    </div>
  );
}
```

### Pattern 2: API Response Handling
```typescript
// ✅ GOOD - Proper API response destructuring
function DataProcessor({ apiResponse }: { apiResponse: ApiResponse }) {
  // ❌ BAD - Extract everything then suppress
  // const { data, error, warnings, timestamp, id } = apiResponse;
  // void warnings;
  // void timestamp;
  // void id;

  // ✅ GOOD - Extract only needed parts
  const { data, error } = apiResponse;

  // ✅ GOOD - Use underscore for intentionally unused
  const { data, error, _warnings, _timestamp, _id } = apiResponse;

  if (error) {
    return <ErrorDisplay error={error} />;
  }

  return <DataDisplay data={data} />;
}
```

### Pattern 3: Array Destructuring
```typescript
// ✅ GOOD - Proper array destructuring
function ProcessArrayItems() {
  const items = ['first', 'second', 'third', 'fourth'];

  // ❌ BAD - Extract all then suppress
  // const [first, second, third, fourth] = items;
  // void third;
  // void fourth;

  // ✅ GOOD - Extract only what's needed
  const [first, second] = items;

  // ✅ GOOD - Skip unused elements with commas
  const [first, , third] = items;

  // ✅ GOOD - Use rest operator for remaining items
  const [first, ...rest] = items;

  return (
    <div>
      <div>First: {first}</div>
      <div>Third: {third}</div>
      <div>Rest: {rest.join(', ')}</div>
    </div>
  );
}
```

## Function Parameter Patterns

### Event Handlers
```typescript
// ✅ GOOD - Event handler patterns
function ButtonComponents() {
  // ❌ BAD - Suppress unused event
  // const handleClick = (event: React.MouseEvent) => {
  //   doSomething();
  //   void event;
  // };

  // ✅ GOOD - Use underscore for unused event
  const handleClick = (_event: React.MouseEvent) => {
    doSomething();
  };

  // ✅ GOOD - Omit parameter type if not used
  const handleAnotherClick = () => {
    doSomething();
  };

  // ✅ GOOD - Use parameter if needed
  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    doSomething();
  };

  return (
    <>
      <button onClick={handleClick}>Click Me</button>
      <button onClick={handleAnotherClick}>Another Click</button>
      <form onSubmit={handleSubmit}>
        <button type="submit">Submit</button>
      </form>
    </>
  );
}
```

### Custom Hook Parameters
```typescript
// ✅ GOOD - Custom hook with optional parameters
function useCustomHook(options: {
  required: string;
  optional?: string;
  callback?: (data: any) => void;
}) {
  // ✅ GOOD - Use destructuring with defaults
  const { required, optional: _optional, callback: _callback } = options;

  // Implementation uses only what's needed
  useEffect(() => {
    // Use required parameter
    console.log('Required:', required);
  }, [required]);

  return { data: required };
}

// Usage
function MyComponent() {
  const { data } = useCustomHook({
    required: 'test',
    optional: 'not used',
    callback: () => {} // not used in hook
  });

  return <div>{data}</div>;
}
```

## Object and Array Manipulation

### Object Property Selection
```typescript
// ✅ GOOD - Object property selection patterns
function ProcessUserObject(user: User) {
  // ❌ BAD - Extract all then suppress
  // const { id, name, email, age, address, phone } = user;
  // void age;
  // void address;
  // void phone;

  // ✅ GOOD - Extract only needed properties
  const { id, name, email } = user;

  // ✅ GOOD - Use underscore for unused
  const { id, name, email, _age, _address, _phone } = user;

  // ✅ GOOD - Use utility types for extraction
  type UserBasicInfo = Pick<User, 'id' | 'name' | 'email'>;
  const basicInfo: UserBasicInfo = {
    id: user.id,
    name: user.name,
    email: user.email
  };

  return <UserInfo info={basicInfo} />;
}
```

### Array Filtering and Mapping
```typescript
// ✅ GOOD - Array processing without unused variables
function ProcessItems() {
  const items = [
    { id: 1, name: 'Item 1', category: 'A' },
    { id: 2, name: 'Item 2', category: 'B' },
    { id: 3, name: 'Item 3', category: 'A' }
  ];

  // ❌ BAD - Extract all then suppress
  // const filtered = items.filter(item => item.category === 'A');
  // void filtered;

  // ✅ GOOD - Use directly or assign meaningful name
  const categoryAItems = items.filter(item => item.category === 'A');
  const itemNames = items.map(item => item.name);

  // ✅ GOOD - Chain operations without intermediate unused variables
  const categoryAItemNames = items
    .filter(item => item.category === 'A')
    .map(item => item.name);

  return (
    <div>
      <h3>Category A Items:</h3>
      <ul>
        {categoryAItems.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

## React Component Patterns

### State Management
```typescript
// ✅ GOOD - Proper state management without unused variables
function FormComponent() {
  // ❌ BAD - Multiple state variables with void suppression
  // const [name, setName] = useState('');
  // const [email, setEmail] = useState('');
  // const [age, setAge] = useState(0);
  // void age; // Not used in current implementation

  // ✅ GOOD - Only define state that's actually used
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  // ✅ GOOD - Use underscore for intentionally unused state
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [_age, setAge] = useState(0); // Will be used later

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Only use name and email
    console.log('Submitting:', { name, email });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Name"
      />
      <input
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
      />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Props Destructuring
```typescript
// ✅ GOOD - Props destructuring without unused variables
interface ComponentProps {
  id: string;
  title: string;
  description?: string;
  metadata?: {
    created: string;
    updated: string;
    author: string;
  };
  onClick?: (id: string) => void;
  className?: string;
}

function MyComponent({
  id,
  title,
  description,
  metadata: _metadata, // Unused but might be needed later
  onClick,
  className
}: ComponentProps) {
  // ✅ GOOD - Only destructure what's needed
  // const { id, title, description, onClick, className } = props;

  // ✅ GOOD - Use underscore for intentionally unused
  // const { id, title, description, metadata: _metadata, onClick, className } = props;

  const handleClick = () => {
    onClick?.(id);
  };

  return (
    <div className={className} onClick={handleClick}>
      <h3>{title}</h3>
      {description && <p>{description}</p>}
    </div>
  );
}
```

## TypeScript Utility Types

### Extracting Specific Properties
```typescript
// ✅ GOOD - Use TypeScript utility types to avoid unused variables
interface UserProfile {
  id: string;
  name: string;
  email: string;
  age: number;
  address: string;
  phone: string;
  preferences: {
    theme: string;
    language: string;
    notifications: boolean;
  };
}

// ✅ GOOD - Use Pick to extract only needed properties
type UserBasicInfo = Pick<UserProfile, 'id' | 'name' | 'email'>;
type UserContactInfo = Pick<UserProfile, 'email' | 'phone'>;

// ✅ GOOD - Use Omit to exclude unwanted properties
type UserWithoutSensitive = Omit<UserProfile, 'phone' | 'address'>;

function ProcessUser() {
  const userProfile: UserProfile = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    age: 30,
    address: '123 Main St',
    phone: '555-1234',
    preferences: {
      theme: 'dark',
      language: 'en',
      notifications: true
    }
  };

  // ✅ GOOD - Extract specific types without void suppression
  const basicInfo: UserBasicInfo = {
    id: userProfile.id,
    name: userProfile.name,
    email: userProfile.email
  };

  // ✅ GOOD - Destructure only what's needed
  const { id, name, email } = userProfile;

  return <UserCard user={basicInfo} />;
}
```

### Conditional Property Access
```typescript
// ✅ GOOD - Conditional property access without unused variables
function ConditionalComponent({ user, showDetails }: {
  user?: User;
  showDetails?: boolean;
}) {
  // ❌ BAD - Extract all then suppress
  // const { name, email, role } = user || {};
  // void role; // Not used

  // ✅ GOOD - Extract only what's needed
  const { name, email } = user || {};

  // ✅ GOOD - Use optional chaining and nullish coalescing
  const displayName = user?.name || 'Guest';
  const displayEmail = user?.email ?? 'No email';

  return (
    <div>
      <h3>{displayName}</h3>
      {showDetails && <p>{displayEmail}</p>}
    </div>
  );
}
```

## Migration Guide

### Converting Existing Code
```typescript
// ❌ BEFORE - Void suppression everywhere
function OldComponent() {
  const [state1, setState1] = useState('');
  const [state2, setState2] = useState(0);
  const [state3, setState3] = useState(false);

  // Suppress unused variables
  void state1;
  void state3;

  const data = useApiData();
  void data.unusedProp;

  const handleClick = (event: React.MouseEvent) => {
    setState2(1);
    void event;
  };

  return <div>Content</div>;
}

// ✅ AFTER - Clean code without void suppression
function NewComponent() {
  // Only keep state that's actually used
  const [, setState2] = useState(0);

  // Extract only needed data
  const { neededProp } = useApiData();

  // Use underscore for intentionally unused parameters
  const handleClick = (_event: React.MouseEvent) => {
    setState2(1);
  };

  return <div>Content</div>;
}
```

## ESLint Configuration

### Recommended ESLint Rules
```json
{
  "rules": {
    "@typescript-eslint/no-unused-vars": [
      "error",
      {
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_",
        "caughtErrorsIgnorePattern": "^_"
      }
    ],
    "no-void": [
      "error",
      {
        "allowAsStatement": false
      }
    ],
    "@typescript-eslint/no-unused-expressions": "error",
    "@typescript-eslint/prefer-const": "error"
  }
}
```

## Validation Checklist
- [ ] NO `void` statements used to suppress unused variable warnings
- [ ] All truly unused variables are removed from code
- [ ] Intentionally unused variables use underscore prefix
- [ ] Destructuring patterns avoid unused assignments
- [ ] Function parameters properly handle unused values
- [ ] Array and object manipulations don't create unused variables
- [ ] Component state and props are clean and minimal
- [ ] TypeScript utility types are used for complex property extraction
- [ ] Code is maintainable and follows clean code principles

## Enforcement
This rule is enforced through:
- ESLint `no-void` and `@typescript-eslint/no-unused-vars` rules
- Pre-commit hooks that detect void suppression patterns
- Code review validation
- TypeScript compilation checks
- Automated code quality analysis
- Team education on proper variable handling

By avoiding `void` suppression and properly handling unused variables, we maintain code quality, improve maintainability, and leverage TypeScript's analysis capabilities effectively.