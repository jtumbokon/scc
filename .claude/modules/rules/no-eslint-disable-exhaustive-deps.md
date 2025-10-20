---
id: rule-028
type: rule
version: 1.0.0
description: NEVER disable react-hooks/exhaustive-deps - ZERO TOLERANCE policy for preventing stale closures and dependency bugs
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No ESLint Disable Exhaustive Deps Rule (rule-028)

## Purpose
The ESLint rule `react-hooks/exhaustive-deps` ensures React hooks like `useEffect`, `useCallback`, and `useMemo` have all their dependencies properly declared. This prevents subtle bugs where effects don't re-run when they should, or where stale closures capture outdated values. Disabling this rule hides real dependency issues that can lead to bugs, stale state, infinite loops, and unpredictable behavior.

**This is a ZERO TOLERANCE rule** - there are NO acceptable exceptions for disabling `react-hooks/exhaustive-deps`.

## Requirements

### MUST (Critical)
- **NEVER disable** `react-hooks/exhaustive-deps` ESLint rule
- **NEVER use** `// eslint-disable-next-line react-hooks/exhaustive-deps`
- **NEVER use** `/* eslint-disable react-hooks/exhaustive-deps */`
- **ALWAYS fix the root cause** when dependencies are missing
- **INCLUDE all required dependencies** in dependency arrays
- **STABILIZE dependencies** with useCallback/useMemo when needed

### SHOULD (Important)
- **Use useCallback** to stabilize function dependencies
- **Use useMemo** to stabilize object/array dependencies
- **Restructure code** to eliminate circular dependencies
- **Separate complex effects** into multiple focused hooks
- **Use trigger states** to break dependency cycles

### MAY (Optional)
- **Extract stable values** outside components when appropriate
- **Use custom hooks** to encapsulate complex dependency logic
- **Create utility functions** for common dependency patterns
- **Document complex dependency decisions** with clear reasoning

## Forbidden Disable Patterns

### ❌ ALL FORMS ARE ABSOLUTELY FORBIDDEN
```tsx
// ❌ FORBIDDEN - All variations of disabling the rule

// Next-line disable
// eslint-disable-next-line react-hooks/exhaustive-deps

// Block disable
/* eslint-disable react-hooks/exhaustive-deps */

// File-level disable
/* eslint-disable react-hooks/exhaustive-deps */

// Combined disable
/* eslint-disable react-hooks/exhaustive-deps, other-rule */

// Inline disable
/* eslint-disable-line react-hooks/exhaustive-deps */
```

## Core Fix Strategies

### Strategy 1: Add Missing Dependencies
```tsx
// ❌ BAD - Missing dependency
useEffect(() => {
  fetchData(userId);
  updateUI(userData);
// eslint-disable-next-line react-hooks/exhaustive-deps
}, []);

// ✅ GOOD - Add all required dependencies
useEffect(() => {
  fetchData(userId);
  updateUI(userData);
}, [userId, userData]);
```

### Strategy 2: Stabilize Function Dependencies
```tsx
// ❌ BAD - Unstable function dependency
useEffect(() => {
  const handler = (event: Event) => {
    processData(event.data);
  };

  document.addEventListener('custom-event', handler);
  return () => document.removeEventListener('custom-event', handler);
// eslint-disable-next-line react-hooks/exhaustive-deps
}, []);

// ✅ GOOD - Stabilize with useCallback
const handler = useCallback((event: Event) => {
  processData(event.data);
}, [processData]);

useEffect(() => {
  document.addEventListener('custom-event', handler);
  return () => document.removeEventListener('custom-event', handler);
}, [handler]);
```

### Strategy 3: Move Logic Inside Hook
```tsx
// ❌ BAD - External dependencies causing issues
const processItems = () => {
  items.forEach(item => {
    if (item.isActive) {
      setActiveItems(prev => [...prev, item.id]);
    }
  });
};

useEffect(() => {
  processItems();
// eslint-disable-next-line react-hooks/exhaustive-deps
}, [items]);

// ✅ GOOD - Move logic inside effect
useEffect(() => {
  const processItems = () => {
    items.forEach(item => {
      if (item.isActive) {
        setActiveItems(prev => [...prev, item.id]);
      }
    });
  };

  processItems();
}, [items]);
```

### Strategy 4: Use Trigger States for Circular Dependencies
```tsx
// ❌ BAD - Circular dependency
const fetchData = useCallback(() => {
  // Depends on filters
  apiCall(filters);
}, []);

useEffect(() => {
  if (shouldRefresh) {
    fetchData();
  }
// eslint-disable-next-line react-hooks/exhaustive-deps
}, [shouldRefresh]);

// ✅ GOOD - Break cycle with trigger state
const [refreshTrigger, setRefreshTrigger] = useState(0);

const fetchData = useCallback(() => {
  apiCall(filters);
}, [filters]);

// Effect that responds to trigger
useEffect(() => {
  if (refreshTrigger > 0) {
    fetchData();
  }
}, [refreshTrigger, fetchData]);

// Effect that sets the trigger
useEffect(() => {
  if (shouldRefresh) {
    setRefreshTrigger(prev => prev + 1);
  }
}, [shouldRefresh]);
```

## Advanced Patterns

### Pattern 1: Complex State Dependencies
```tsx
// ✅ GOOD - Complex state with proper dependencies
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(false);

  // Fetch user data - depends only on userId
  useEffect(() => {
    let cancelled = false;

    const fetchUser = async () => {
      setLoading(true);
      try {
        const userData = await api.getUser(userId);
        if (!cancelled) {
          setUser(userData);
        }
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    fetchUser();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  // Fetch posts when user changes
  useEffect(() => {
    if (!user) return;

    let cancelled = false;

    const fetchPosts = async () => {
      try {
        const userPosts = await api.getUserPosts(user.id);
        if (!cancelled) {
          setPosts(userPosts);
        }
      } catch (error) {
        console.error('Failed to fetch posts:', error);
      }
    };

    fetchPosts();

    return () => {
      cancelled = true;
    };
  }, [user]);

  return (
    <div>
      {loading ? 'Loading...' : (
        <>
          <h1>{user?.name}</h1>
          <PostList posts={posts} />
        </>
      )}
    </div>
  );
}
```

### Pattern 2: Event Listener Management
```tsx
// ✅ GOOD - Proper event listener dependency management
function KeyboardHandler({ onShortcut }: { onShortcut: (key: string) => void }) {
  const handleKeyDown = useCallback((event: KeyboardEvent) => {
    if (event.ctrlKey || event.metaKey) {
      switch (event.key) {
        case 's':
          event.preventDefault();
          onShortcut('save');
          break;
        case 'z':
          if (event.shiftKey) {
            event.preventDefault();
            onShortcut('redo');
          } else {
            event.preventDefault();
            onShortcut('undo');
          }
          break;
      }
    }
  }, [onShortcut]);

  useEffect(() => {
    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [handleKeyDown]);

  return null;
}
```

### Pattern 3: WebSocket Connection Management
```tsx
// ✅ GOOD - WebSocket with proper dependencies
function useWebSocket(url: string, onMessage: (data: any) => void) {
  const [socket, setSocket] = useState<WebSocket | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  // Stabilize the message handler
  const stableOnMessage = useCallback((event: MessageEvent) => {
    try {
      const data = JSON.parse(event.data);
      onMessage(data);
    } catch (error) {
      console.error('Failed to parse WebSocket message:', error);
    }
  }, [onMessage]);

  // Connect/disconnect based on URL
  useEffect(() => {
    if (!url) return;

    const ws = new WebSocket(url);

    ws.onopen = () => {
      setIsConnected(true);
      setSocket(ws);
    };

    ws.onclose = () => {
      setIsConnected(false);
      setSocket(null);
    };

    ws.onmessage = stableOnMessage;

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    return () => {
      ws.close();
    };
  }, [url, stableOnMessage]);

  // Send message function
  const sendMessage = useCallback((message: any) => {
    if (socket?.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify(message));
    }
  }, [socket]);

  return { socket, isConnected, sendMessage };
}

// Usage
function ChatComponent() {
  const [messages, setMessages] = useState<Message[]>([]);

  const handleMessage = useCallback((data: Message) => {
    setMessages(prev => [...prev, data]);
  }, []);

  const { socket, isConnected, sendMessage } = useWebSocket(
    'wss://api.example.com/chat',
    handleMessage
  );

  return (
    <div>
      <div>Connected: {isConnected ? 'Yes' : 'No'}</div>
      <MessageList messages={messages} />
      <MessageInput onSend={sendMessage} disabled={!isConnected} />
    </div>
  );
}
```

### Pattern 4: Animation and RAF Dependencies
```tsx
// ✅ GOOD - Animation with proper dependency management
function useAnimation(
  callback: (timestamp: number) => void,
  dependencies: React.DependencyList
) {
  const animationRef = useRef<number>();

  // Stabilize the callback with its dependencies
  const stableCallback = useCallback(callback, dependencies);

  useEffect(() => {
    const animate = (timestamp: number) => {
      stableCallback(timestamp);
      animationRef.current = requestAnimationFrame(animate);
    };

    animationRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [stableCallback]);
}

// Usage
function BouncingBall() {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [velocity, setVelocity] = useState({ x: 2, y: 0 });

  const animate = useCallback((timestamp: number) => {
    setPosition(prev => {
      let newX = prev.x + velocity.x;
      let newY = prev.y + velocity.y;
      let newVelX = velocity.x;
      let newVelY = velocity.y + 0.5; // gravity

      // Bounce off walls
      if (newX > 380 || newX < 0) {
        newVelX = -newVelX * 0.8;
        newX = newX > 380 ? 380 : 0;
      }

      if (newY > 280) {
        newVelY = -newVelY * 0.8;
        newY = 280;
      }

      setVelocity({ x: newVelX, y: newVelY });

      return { x: newX, y: newY };
    });
  }, [velocity.x, velocity.y]);

  useAnimation(animate, [animate]);

  return (
    <div style={{ width: 400, height: 300, border: '1px solid black' }}>
      <div
        style={{
          position: 'absolute',
          left: position.x,
          top: position.y,
          width: 20,
          height: 20,
          backgroundColor: 'red',
          borderRadius: '50%'
        }}
      />
    </div>
  );
}
```

## Common Dependency Issues and Solutions

### Issue 1: "Function changes on every render"
```tsx
// ❌ PROBLEM
function MyComponent({ items, onSelect }) {
  useEffect(() => {
    // onSelect changes on every render, causing infinite re-renders
    const filtered = items.filter(item => item.active);
    onSelect(filtered);
  }, [items, onSelect]);
}

// ✅ SOLUTION - Parent stabilizes the callback
function ParentComponent() {
  const [selectedItems, setSelectedItems] = useState([]);

  const handleSelect = useCallback((filteredItems) => {
    setSelectedItems(filteredItems);
  }, []);

  return <MyComponent items={items} onSelect={handleSelect} />;
}
```

### Issue 2: "Object/array changes on every render"
```tsx
// ❌ PROBLEM
function MyComponent({ userId }) {
  useEffect(() => {
    const config = { userId, timestamp: Date.now() };
    api.configure(config);
  }, [userId]); // Missing config dependency

// ✅ SOLUTION 1 - Include the object
useEffect(() => {
  const config = { userId, timestamp: Date.now() };
  api.configure(config);
}, [userId]); // Actually needs to run when userId changes

// ✅ SOLUTION 2 - Use useMemo for complex objects
const config = useMemo(() => ({
  userId,
  timestamp: Date.now()
}), [userId]);

useEffect(() => {
  api.configure(config);
}, [config]);
```

### Issue 3: "Circular dependency with state"
```tsx
// ❌ PROBLEM
function MyComponent() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const result = await api.getData();
      setData(result);
    } finally {
      setLoading(false);
    }
  }, []); // Missing setLoading dependency

  useEffect(() => {
    fetchData();
  }, [fetchData]);
}

// ✅ SOLUTION - Include state setter (it's stable)
const fetchData = useCallback(async () => {
  setLoading(true);
  try {
    const result = await api.getData();
    setData(result);
  } finally {
    setLoading(false);
  }
}, [setLoading]); // State setters are stable but include for clarity
```

## Debugging Dependency Issues

### Step 1: Identify the Warning
```bash
# Look for this pattern in console:
# Warning: React Hook useEffect has a missing dependency: 'variableName'
# Either include it or remove the dependency array
```

### Step 2: Analyze the Dependency
```tsx
// Ask these questions:
// 1. Does the effect actually use this variable?
// 2. Should the effect re-run when this variable changes?
// 3. Is this dependency stable (doesn't change unnecessarily)?
// 4. Can I move this logic inside the effect?
```

### Step 3: Apply the Correct Strategy
```tsx
// Strategy Decision Tree:

if (dependencyIsActuallyUsed) {
  if (dependencyIsStable) {
    // Just add it to dependency array
    useEffect(() => {
      // effect logic
    }, [dependency]);
  } else {
    // Stabilize it first
    const stableDependency = useCallback(() => {
      // dependency logic
    }, [actualDependencies]);

    useEffect(() => {
      // effect logic using stableDependency
    }, [stableDependency]);
  }
} else {
  // Move logic inside effect or remove dependency
  useEffect(() => {
    const localDependency = createDependency();
    // effect logic using localDependency
  }, []);
}
```

## Performance Optimization with Proper Dependencies

### Memoizing Expensive Computations
```tsx
// ✅ GOOD - Proper memoization with dependencies
function ExpensiveComponent({ data, filters, sortBy }) {
  const filteredAndSortedData = useMemo(() => {
    return data
      .filter(item => matchesFilters(item, filters))
      .sort((a, b) => compareItems(a, b, sortBy));
  }, [data, filters, sortBy]);

  const processedData = useMemo(() => {
    return filteredAndSortedData.map(item => ({
      ...item,
      computed: expensiveCalculation(item)
    }));
  }, [filteredAndSortedData]);

  return <DataList items={processedData} />;
}
```

### Optimizing Re-renders
```tsx
// ✅ GOOD - Stable callbacks prevent unnecessary re-renders
function TodoList({ todos, onToggle, onDelete }) {
  const handleToggle = useCallback((id: string) => {
    onToggle(id);
  }, [onToggle]);

  const handleDelete = useCallback((id: string) => {
    onDelete(id);
  }, [onDelete]);

  return (
    <ul>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}
          onDelete={handleDelete}
        />
      ))}
    </ul>
  );
}
```

## Testing Strategies

### Testing Hook Dependencies
```tsx
// ✅ GOOD - Test hook behavior with dependency changes
import { renderHook, act } from '@testing-library/react';
import { useUserData } from './useUserData';

describe('useUserData', () => {
  it('should refetch data when userId changes', async () => {
    const { result, rerender } = renderHook(
      ({ userId }) => useUserData(userId),
      { initialProps: { userId: 'user1' } }
    );

    expect(result.current.loading).toBe(true);
    await act(async () => {
      await new Promise(resolve => setTimeout(resolve, 100));
    });

    expect(result.current.user).toEqual(mockUser1);

    // Change userId - should trigger refetch
    rerender({ userId: 'user2' });
    expect(result.current.loading).toBe(true);

    await act(async () => {
      await new Promise(resolve => setTimeout(resolve, 100));
    });

    expect(result.current.user).toEqual(mockUser2);
  });
});
```

## Validation Checklist
- [ ] NO `eslint-disable-next-line react-hooks/exhaustive-deps` anywhere
- [ ] All useEffect hooks have complete dependency arrays
- [ ] All useCallback hooks have complete dependency arrays
- [ ] All useMemo hooks have complete dependency arrays
- [ ] Functions are stabilized with useCallback when used as dependencies
- [ ] Objects/arrays are stabilized with useMemo when used as dependencies
- [ ] Circular dependencies are resolved with proper patterns
- [ ] Effects behave correctly when dependencies change
- [ ] No infinite loops caused by dependency issues
- [ ] Component performance is optimized with stable dependencies

## Enforcement
This rule is enforced through:
- ESLint `react-hooks/exhaustive-deps` rule configuration
- Pre-commit hooks that block eslint-disable for this rule
- Code review validation
- Automated testing for hook behavior
- React DevTools Profiler for effect re-run analysis
- Performance monitoring for unnecessary re-renders

By maintaining proper hook dependencies, we prevent stale closures, ensure effects run when needed, and create predictable, bug-free React components.