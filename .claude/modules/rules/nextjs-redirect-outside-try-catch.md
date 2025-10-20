---
id: rule-017
type: rule
version: 1.0.0
description: Next.js 15 redirect() must be called outside try/catch blocks - never catch redirect errors
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Next.js Redirect Outside Try-Catch Rule (rule-017)

## Purpose
In Next.js 15 App Router, the `redirect()` function throws a `NEXT_REDIRECT` error to terminate rendering. This error should never be caught in try/catch blocks as it's designed to bubble up to the framework for proper handling. Catching redirect errors can cause infinite loops, broken navigation, and unexpected behavior.

The `redirect()` function has a `never` return type and is meant to be used as a control flow mechanism, not as a fallible operation that needs error handling.

## Requirements

### MUST (Critical)
- **Never use `redirect()` inside try/catch blocks** - redirect errors should bubble up naturally
- **Always call `redirect()` outside try/catch** - separate business logic from control flow
- **Let redirect errors bubble up** - the Next.js framework handles `NEXT_REDIRECT` errors properly
- **Use `redirect()` as control flow** - not as a fallible operation

### SHOULD (Important)
- **Separate business logic from redirect logic** - put fallible operations in try/catch, redirects outside
- **Handle business errors appropriately** - return error UI components when business logic fails
- **Use proper error handling patterns** - distinguish between business errors and framework control flow
- **Prevent infinite redirect loops** - handle authentication and authorization logic correctly

### MAY (Optional)
- **Create wrapper functions** for common redirect patterns
- **Use conditional rendering** instead of redirects when appropriate
- **Implement proper loading states** for async operations that might trigger redirects

## Examples

### ❌ Bad - redirect() inside try/catch blocks
```typescript
// WRONG - Don't do this
try {
  const session = await createSession();
  redirect(`/chat/${session.id}`); // ❌ redirect inside try/catch
} catch (error) {
  // This will catch the NEXT_REDIRECT error and break navigation
  console.error('Session creation failed:', error);
  return <ErrorComponent />;
}

// ❌ Also wrong - catching redirect errors
try {
  const user = await getUser();
  if (!user) {
    redirect('/login'); // ❌ Will be caught by the catch block
  }
  return <Dashboard user={user} />;
} catch (error) {
  // Catches both business errors AND redirect errors
  return <ErrorComponent error={error} />;
}
```

### ✅ Good - redirect() outside try/catch blocks
```typescript
// CORRECT - Separate concerns
let session;
try {
  session = await createSession();
} catch (error) {
  // Handle session creation error
  console.error('Session creation failed:', error);
  return <ErrorComponent message="Failed to create session" />;
}

// Redirect outside try/catch (Next.js 15 best practice)
redirect(`/chat/${session.id}`);

// ✅ Also correct - Conditional redirect outside try/catch
let user;
try {
  user = await getUser();
} catch (error) {
  console.error('Failed to get user:', error);
  return <ErrorComponent message="Authentication failed" />;
}

if (!user) {
  redirect('/login'); // ✅ redirect outside try/catch
}

return <Dashboard user={user} />;
```

## Common Patterns

### Authentication and Authorization
```typescript
// ❌ Bad - mixing auth logic with redirect in try/catch
export default async function ProtectedPage() {
  try {
    const user = await getCurrentUser();
    if (!user.isAdmin) {
      redirect('/unauthorized'); // ❌ Inside try/catch
    }
    return <AdminPanel user={user} />;
  } catch (error) {
    return <ErrorComponent />;
  }
}

// ✅ Good - separate auth logic from redirect
export default async function ProtectedPage() {
  let user;
  try {
    user = await getCurrentUser();
  } catch (error) {
    console.error('Authentication failed:', error);
    return <ErrorComponent message="Authentication failed" />;
  }

  if (!user) {
    redirect('/login'); // ✅ Outside try/catch
  }

  if (!user.isAdmin) {
    redirect('/unauthorized'); // ✅ Outside try/catch
  }

  return <AdminPanel user={user} />;
}
```

### Form Submission with Redirect
```typescript
// ❌ Bad - redirect in try/catch
export default function CreatePostForm() {
  async function createPost(formData: FormData) {
    'use server';

    try {
      const post = await savePost(formData);
      redirect(`/posts/${post.id}`); // ❌ Inside try/catch
    } catch (error) {
      console.error('Failed to create post:', error);
      return { error: 'Failed to create post' };
    }
  }

  return (
    <form action={createPost}>
      {/* Form fields */}
    </form>
  );
}

// ✅ Good - redirect outside try/catch in Server Action
export default function CreatePostForm() {
  async function createPost(formData: FormData) {
    'use server';

    let post;
    try {
      post = await savePost(formData);
    } catch (error) {
      console.error('Failed to create post:', error);
      // Return error state, don't redirect
      return { error: 'Failed to create post' };
    }

    // Redirect outside try/catch
    redirect(`/posts/${post.id}`); // ✅ Outside try/catch
  }

  return (
    <form action={createPost}>
      {/* Form fields */}
    </form>
  );
}
```

### Route Handlers with Conditional Redirects
```typescript
// ❌ Bad - redirect inside try/catch in Route Handler
export async function GET(request: NextRequest) {
  try {
    const user = await authenticateRequest(request);
    if (!user) {
      redirect('/login'); // ❌ Inside try/catch
    }
    return NextResponse.json({ user });
  } catch (error) {
    return NextResponse.json({ error: 'Authentication failed' }, { status: 500 });
  }
}

// ✅ Good - separate authentication from redirect
export async function GET(request: NextRequest) {
  let user;
  try {
    user = await authenticateRequest(request);
  } catch (error) {
    console.error('Authentication error:', error);
    return NextResponse.json({ error: 'Authentication failed' }, { status: 500 });
  }

  if (!user) {
    redirect('/login'); // ✅ Outside try/catch
  }

  return NextResponse.json({ user });
}
```

## Advanced Patterns

### Complex Conditional Logic
```typescript
export default async function ComplexPage({ params }: PageProps) {
  const { id } = await params;

  let user, permissions, data;

  // Step 1: Authenticate user
  try {
    user = await getCurrentUser();
  } catch (error) {
    return <AuthError />;
  }

  if (!user) {
    redirect('/login'); // ✅ Outside try/catch
  }

  // Step 2: Check permissions
  try {
    permissions = await getUserPermissions(user.id);
  } catch (error) {
    return <PermissionError />;
  }

  if (!permissions.canAccessResource(id)) {
    redirect('/unauthorized'); // ✅ Outside try/catch
  }

  // Step 3: Load data
  try {
    data = await getResourceData(id);
  } catch (error) {
    return <DataError />;
  }

  if (!data) {
    notFound(); // ✅ Outside try/catch
  }

  return <ResourcePage data={data} user={user} />;
}
```

### Loading States with Conditional Redirects
```typescript
export default async function LoadingPage() {
  let session, preferences;

  // Check session
  try {
    session = await getOrCreateSession();
  } catch (error) {
    return <SessionError />;
  }

  if (!session) {
    redirect('/login'); // ✅ Outside try/catch
  }

  // Load preferences
  try {
    preferences = await getUserPreferences(session.id);
  } catch (error) {
    // Use defaults if preferences fail to load
    preferences = getDefaultPreferences();
  }

  // Conditional redirect based on preferences
  if (preferences.defaultDashboard) {
    redirect(`/dashboard/${preferences.defaultDashboard}`); // ✅ Outside try/catch
  }

  return <WelcomePage session={session} />;
}
```

### Error Boundary Integration
```typescript
// Error boundary that properly handles redirect errors
class RedirectAwareErrorBoundary extends Component {
  constructor(props: any) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error) {
    // Don't catch redirect errors - let them bubble up
    if (error.message.includes('NEXT_REDIRECT')) {
      throw error; // Re-throw redirect errors
    }

    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }

    return this.props.children;
  }
}

// Usage in component
export default function PageWithRedirects() {
  let data;

  try {
    data = await fetchData();
  } catch (error) {
    return <ErrorComponent />;
  }

  if (!data.needsRedirect) {
    return <NormalComponent data={data} />;
  }

  redirect('/new-location'); // ✅ Outside try/catch, properly handled by framework
}
```

## Why This Matters

1. **`redirect()` throws an error** - It throws a `NEXT_REDIRECT` error to terminate rendering
2. **Should be called OUTSIDE try/catch** - Next.js 15 docs explicitly state this for Server Actions and Route Handlers
3. **Has `never` return type** - Designed to stop execution completely
4. **Prevents infinite loops** - Proper error handling prevents redirect loops in layouts and components
5. **Framework handles it properly** - Next.js knows how to handle `NEXT_REDIRECT` errors when they bubble up

## Migration Guide

### Converting Existing Code
```typescript
// ❌ Before - redirect inside try/catch
export default async function OldPage() {
  try {
    const user = await getCurrentUser();
    if (!user) {
      redirect('/login');
    }
    return <Dashboard user={user} />;
  } catch (error) {
    return <ErrorComponent />;
  }
}

// ✅ After - redirect outside try/catch
export default async function NewPage() {
  let user;
  try {
    user = await getCurrentUser();
  } catch (error) {
    return <ErrorComponent />;
  }

  if (!user) {
    redirect('/login'); // ✅ Outside try/catch
  }

  return <Dashboard user={user} />;
}
```

## Validation Checklist
- [ ] Never use `redirect()` inside try/catch blocks
- [ ] Always call `redirect()` outside try/catch as control flow
- [ ] Separate business logic (try/catch) from redirect logic
- [ ] Let redirect errors bubble up naturally
- [ ] Handle business errors with proper error components
- [ ] Prevent infinite redirect loops with proper conditional logic
- [ ] Use `redirect()` as control flow, not as a fallible operation

## Enforcement
This rule is enforced through:
- Next.js compilation warnings
- Runtime error detection
- Code review validation
- Error boundary testing
- Integration testing for navigation flows

Proper separation of redirects from try/catch blocks ensures reliable navigation and prevents framework interference with control flow.