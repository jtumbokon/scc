---
id: rule-035
type: rule
version: 1.0.0
description: "use client" directive guidelines - Server vs Client component boundaries in Next.js 13+ App Router
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# "use client" Directive Guidelines Rule (rule-035)

## Purpose
In Next.js 13+ App Router, Server Components are the default and provide better performance through server-side rendering. The `"use client"` directive should only be added when you need client-side functionality that cannot run on the server.

Many developers add `"use client"` unnecessarily, which increases bundle size, hurts performance, reduces benefits of server-side rendering, and can cause hydration issues.

## Requirements

### MUST (Critical)
- **Default to Server Components** - Never add `"use client"` unless you need client-side functionality
- **Push `"use client"` down the tree** - Add it to the smallest component that needs client functionality
- **NEVER make async functions client components** - Server Components handle async data fetching
- **IDENTIFY client-only features** - Use `"use client"` only for browser APIs, React hooks, and interactivity

### SHOULD (Important)
- **Start with Server Components** - Only add `"use client"` when errors occur
- **Separate static content from interactive elements**
- **Use Server Actions** instead of client-side form handling
- **Move interactivity to leaf components** - Keep client boundary as small as possible

### MAY (Optional)
- **Create wrapper patterns** for mixed server/client functionality
- **Use composition patterns** to minimize client component scope
- **Implement component boundaries** strategically for performance
- **Document client component decisions** with clear reasoning

## When TO Use "use client"

### ✅ React Hooks and State
```tsx
"use client";
import { useState, useEffect } from "react";

function Counter() {
  const [count, setCount] = useState(0); // ✅ Requires client

  useEffect(() => {
    document.title = `Count: ${count}`; // ✅ Browser API
  }, [count]);

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  );
}
```

### ✅ Event Handlers and Interactivity
```tsx
"use client";

function InteractiveButton() {
  const handleClick = () => {
    alert("Button clicked!"); // ✅ Browser API
  };

  return <button onClick={handleClick}>Click me</button>; // ✅ Event handler
}
```

### ✅ Browser APIs
```tsx
"use client";

function LocalStorageComponent() {
  const [data, setData] = useState("");

  useEffect(() => {
    const saved = localStorage.getItem("data"); // ✅ Browser API
    if (saved) setData(saved);
  }, []);

  return <div>{data}</div>;
}
```

### ✅ Client-Side Navigation and Search Params
```tsx
"use client";
import { useRouter, useSearchParams } from "next/navigation";

function SearchComponent() {
  const router = useRouter(); // ✅ Client-side routing
  const searchParams = useSearchParams(); // ✅ Client-side params

  const handleSearch = (query: string) => {
    router.push(`/search?q=${query}`);
  };

  return <SearchForm onSearch={handleSearch} />;
}
```

### ✅ Third-Party Client Libraries
```tsx
"use client";
import { GoogleMap } from "@googlemaps/react"; // ✅ Client-only library

function MapComponent() {
  return <GoogleMap center={{ lat: 0, lng: 0 }} />;
}
```

## When NOT to Use "use client"

### ❌ Data Fetching (Use Server Components)
| ❌ Bad (Client Component) | ✅ Good (Server Component) |
|---|---|
| ```tsx
"use client";
import { useEffect, useState } from "react";

function UserList() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch("/api/users")
      .then(res => res.json())
      .then(setUsers);
  }, []);

  return (
    <div>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}
``` | ```tsx
// No "use client" - Server Component
async function UserList() {
  const users = await getUsers(); // ✅ Server-side fetch

  return (
    <div>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}
``` |

### ❌ Static Content and Layout
| ❌ Bad (Unnecessary Client) | ✅ Good (Server Component) |
|---|---|
| ```tsx
"use client";

function Header() {
  return (
    <header>
      <h1>My App</h1>
      <nav>
        <Link href="/">Home</Link>
        <Link href="/about">About</Link>
      </nav>
    </header>
  );
}
``` | ```tsx
// No "use client" - Server Component
function Header() {
  return (
    <header>
      <h1>My App</h1>
      <nav>
        <Link href="/">Home</Link>
        <Link href="/about">About</Link>
      </nav>
    </header>
  );
}
``` |

### ❌ Server Actions and Forms
| ❌ Bad (Client Component) | ✅ Good (Server Component) |
|---|---|
| ```tsx
"use client";

function ContactForm() {
  const handleSubmit = async (formData: FormData) => {
    const response = await fetch("/api/contact", {
      method: "POST",
      body: formData,
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" />
      <button type="submit">Submit</button>
    </form>
  );
}
``` | ```tsx
import { submitContact } from "@/app/actions/contact";

// No "use client" - Server Component
function ContactForm() {
  return (
    <form action={submitContact}>
      <input name="email" />
      <button type="submit">Submit</button>
    </form>
  );
}
``` |

## Component Architecture Patterns

### Pattern 1: Wrapper Pattern (Recommended)
```tsx
// Server Component wrapper for data + layout
async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id); // ✅ Server-side data fetching

  return (
    <div>
      <ProductDetails product={product} />
      <AddToCartButton productId={product.id} /> {/* ✅ Client component only where needed */}
    </div>
  );
}

// Small client component only for interactivity
"use client";
function AddToCartButton({ productId }: { productId: string }) {
  const [isLoading, setIsLoading] = useState(false);

  const handleAddToCart = async () => {
    setIsLoading(true);
    await addToCart(productId);
    setIsLoading(false);
  };

  return (
    <button onClick={handleAddToCart} disabled={isLoading}>
      {isLoading ? "Adding..." : "Add to Cart"}
    </button>
  );
}

// Server component for static content
function ProductDetails({ product }: { product: Product }) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span>${product.price}</span>
    </div>
  );
}
```

### Pattern 2: Composition Pattern
```tsx
// app/dashboard/page.tsx (Server Component)
async function DashboardPage() {
  const stats = await getDashboardStats(); // ✅ Server-side data

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <StatsDisplay stats={stats} /> {/* ✅ Server component */}
      <InteractiveCharts data={stats.chartData} /> {/* ✅ Client component */}
      <RecentActivity activities={stats.recent} /> {/* ✅ Server component */}
    </div>
  );
}

// StatsDisplay.tsx (Server Component - no interactivity)
function StatsDisplay({ stats }: { stats: DashboardStats }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      <div>Total Users: {stats.totalUsers}</div>
      <div>Revenue: ${stats.revenue}</div>
      <div>Growth: {stats.growth}%</div>
    </div>
  );
}

// InteractiveCharts.tsx (Client Component - needs interactivity)
"use client";
import { Chart } from "chart.js";

function InteractiveCharts({ data }: { data: ChartData[] }) {
  const [chartType, setChartType] = useState("bar");

  return (
    <div>
      <select onChange={(e) => setChartType(e.target.value)}>
        <option value="bar">Bar Chart</option>
        <option value="line">Line Chart</option>
      </select>
      <Chart data={data} type={chartType} />
    </div>
  );
}
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Adding "use client" to async components
```tsx
"use client"; // ❌ This will cause an error
async function MyComponent() {
  const data = await fetchData(); // ❌ Can't use async in client components
  return <div>{data}</div>;
}
```

### ❌ Mistake 2: Adding "use client" for no reason
```tsx
"use client"; // ❌ Unnecessary
function StaticHeader() {
  return <h1>Welcome to my site</h1>; // No client features needed
}
```

### ❌ Mistake 3: Adding "use client" too high in the tree
```tsx
"use client"; // ❌ Too broad - entire page becomes client-side
function ProductPage() {
  const [showDetails, setShowDetails] = useState(false);

  return (
    <div>
      <ProductInfo /> {/* Doesn't need client-side */}
      <ProductReviews /> {/* Doesn't need client-side */}
      <button onClick={() => setShowDetails(!showDetails)}>
        Toggle Details
      </button>
      {showDetails && <ProductDetails />}
    </div>
  );
}
```

### ✅ Better: Push "use client" down
```tsx
// Server Component (default)
function ProductPage() {
  return (
    <div>
      <ProductInfo />
      <ProductReviews />
      <ToggleDetailsButton /> {/* Only this needs "use client" */}
    </div>
  );
}

// Small client component
"use client";
function ToggleDetailsButton() {
  const [showDetails, setShowDetails] = useState(false);

  return (
    <>
      <button onClick={() => setShowDetails(!showDetails)}>
        Toggle Details
      </button>
      {showDetails && <ProductDetails />}
    </>
  );
}
```

## Decision Tree

```
Do you need client-side functionality?
├─ NO → Don't use "use client" (Server Component)
└─ YES → Ask: What specific functionality?
   ├─ React hooks (useState, useEffect, etc.) → Use "use client"
   ├─ Event handlers (onClick, onChange, etc.) → Use "use client"
   ├─ Browser APIs (localStorage, window, etc.) → Use "use client"
   ├─ Client routing (useRouter, useSearchParams) → Use "use client"
   ├─ Third-party client libraries → Use "use client"
   └─ Data fetching with async/await → DON'T use "use client" (Server Component)
```

## Migration Checklist

When reviewing existing code:
- [ ] Remove unnecessary `"use client"` from components that don't need client features
- [ ] Move `"use client"` down to the smallest component that needs it
- [ ] Convert client-side data fetching to Server Components where possible
- [ ] Use Server Actions instead of client-side form handling
- [ ] Separate static content from interactive elements

## Validation Questions

Before adding `"use client"`, ask:
1. **Does this component use React hooks?** (useState, useEffect, etc.)
2. **Does this component handle user interactions?** (onClick, onChange, etc.)
3. **Does this component use browser APIs?** (localStorage, window, etc.)
4. **Does this component use client-side routing?** (useRouter, useSearchParams)
5. **Does this component use client-only libraries?**

If all answers are NO → Don't use `"use client"`

## Forbidden Patterns

### ❌ NEVER Use These Patterns
```tsx
// ❌ Async client components (forbidden)
"use client";
async function BadComponent() {
  const data = await fetchSomething();
  return <div>{data}</div>;
}

// ❌ Unnecessary client directives
"use client";
function StaticContent() {
  return <div>No interactivity here</div>;
}

// ❌ Client components doing server work
"use client";
function DataFetcher() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('/api/data').then(setData); // Should be server component
  }, []);

  return <div>{data}</div>;
}
```

## Performance Optimization

### Bundle Size Impact
- **Server Components**: Zero client-side JavaScript
- **Client Components**: Full component code sent to browser
- **Hybrid Approach**: Minimize client-side bundle size

### Best Practices
1. **Start with Server Components** - Add client boundary only when needed
2. **Push client boundary down** - Keep client components small and focused
3. **Use Server Actions** - For form submissions and mutations
4. **Leverage Suspense** - For loading states in server components

## Validation Checklist
- [ ] Default to Server Components - never suggest `"use client"` unless absolutely necessary
- [ ] Identify the specific client-side functionality that requires `"use client"`
- [ ] Suggest pushing `"use client"` down to the smallest component that needs it
- [ ] Never use `"use client"` with async functions - use Server Components for data fetching
- [ ] Recommend Server Actions over client-side form handling
- [ ] When in doubt, start with Server Component and add `"use client"` only when errors occur

This ensures optimal performance and follows Next.js App Router best practices for server vs client component boundaries.