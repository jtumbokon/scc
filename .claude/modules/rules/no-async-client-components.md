---
id: rule-014
type: rule
version: 1.0.0
description: No async client components - separate server and client concerns properly in Next.js App Router
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No Async Client Components Rule (rule-014)

## Purpose
In Next.js 13+ App Router, only **Server Components** can be async. Client Components (marked with `'use client'`) cannot be async functions. This commonly occurs when developers try to mix server-side data fetching with client-side interactivity in the same component.

The error typically appears as:
```
<ComponentName> is an async Client Component. Only Server Components can be async at the moment. This error is often caused by accidentally adding `'use client'` to a module that was originally written for the server.
```

This happens when a file has `'use client'` at the top but contains async functions that fetch data or perform server-side operations.

## Requirements

### MUST (Critical)
- **Never make Client Components async** - Components marked with `'use client'` cannot use `async/await`
- **Separate data fetching from interactivity** - Move async data fetching to Server Components and interactive logic to Client Components
- **Use proper component architecture** - Create separate files for server and client concerns when needed
- **Pass data down** - Server Components should fetch data and pass it to Client Components as props

### SHOULD (Important)
- **Extract server logic** - Move data fetching to separate Server Components
- **Extract client logic** - Move interactive state to separate Client Components
- **Use Suspense boundaries** - Wrap async Server Components in Suspense for loading states
- **Maintain clear separation** - Keep server and client concerns in different files

### MAY (Optional)
- **Create wrapper components** - Use Server Components as data wrappers for Client Components
- **Use composition patterns** - Combine multiple smaller components rather than large mixed components

## Component Architecture Patterns

### Pattern 1: Separate Files
| ❌ Bad (Mixed Concerns) | ✅ Good (Separated Concerns) |
|---|---|
| ```tsx
// page.tsx
"use client";
import { useState } from "react";
import { getData } from "@/actions";

// ❌ This will cause an error
async function MyComponent() {
  const [state, setState] = useState(false);
  const data = await getData(); // ❌ async in client component

  return (
    <div>
      <button onClick={() => setState(!state)}>
        Toggle
      </button>
      {data.map(item => <div key={item.id}>{item.name}</div>)}
    </div>
  );
}
``` | ```tsx
// MyComponentClient.tsx (Client Component)
"use client";
import { useState } from "react";

interface Props {
  data: DataType[];
}

export function MyComponentClient({ data }: Props) {
  const [state, setState] = useState(false);

  return (
    <div>
      <button onClick={() => setState(!state)}>
        Toggle
      </button>
      {data.map(item => <div key={item.id}>{item.name}</div>)}
    </div>
  );
}

// page.tsx (Server Component)
import { getData } from "@/actions";
import { MyComponentClient } from "./MyComponentClient";

export default async function Page() {
  const data = await getData(); // ✅ async in server component

  return <MyComponentClient data={data} />;
}
``` |

### Pattern 2: Wrapper Components
```tsx
// Server Component wrapper for data fetching
async function DataWrapper() {
  const data = await fetchData();

  if (!data.success) {
    return <ErrorDisplay message="Failed to load data" />;
  }

  return <InteractiveClient data={data.items} />;
}

// Client Component for interactivity
"use client";
function InteractiveClient({ data }: { data: Item[] }) {
  const [selected, setSelected] = useState<string | null>(null);

  return (
    <div>
      {data.map(item => (
        <button
          key={item.id}
          onClick={() => setSelected(item.id)}
          className={selected === item.id ? "selected" : ""}
        >
          {item.name}
        </button>
      ))}
    </div>
  );
}

// Main page combines them
export default function Page() {
  return (
    <div>
      <h1>My Page</h1>
      <Suspense fallback={<Loading />}>
        <DataWrapper />
      </Suspense>
    </div>
  );
}
```

## Real Example: Admin Models Page Fix

### ❌ Before: Mixed concerns in one file
```tsx
"use client";

async function ModelsTableWrapper() { // ❌ async Client Component
  const result = await getAllModelsForAdmin();
  return <ModelsTable models={result.models} />;
}

export default function AdminModelsPage() {
  const [showDialog, setShowDialog] = useState(false); // Client state

  return (
    <div>
      <Button onClick={() => setShowDialog(true)}>Add Model</Button>
      <ModelsTableWrapper /> {/* ❌ This causes the error */}
    </div>
  );
}
```

### ✅ After: Separated into proper architecture
```tsx
// ModelsComponents.tsx (Client Component)
"use client";
export function AdminModelsPageClient() {
  const [showDialog, setShowDialog] = useState(false);

  return (
    <>
      <Button onClick={() => setShowDialog(true)}>Add Model</Button>
      <AddModelDialog open={showDialog} onOpenChange={setShowDialog} />
    </>
  );
}

export function ModelsTableClient({ models }: { models: AiModel[] }) {
  return <ModelsTable models={models} />;
}

// page.tsx (Server Component)
import { getAllModelsForAdmin } from "@/app/actions/models";
import { AdminModelsPageClient, ModelsTableClient } from "./ModelsComponents";

async function ModelsTableWrapper() { // ✅ async Server Component
  const result = await getAllModelsForAdmin();
  if (!result.success) return <ErrorDisplay />;
  return <ModelsTableClient models={result.models} />;
}

export default function AdminModelsPage() {
  return (
    <div>
      <AdminModelsPageClient />
      <Suspense fallback={<LoadingSkeleton />}>
        <ModelsTableWrapper />
      </Suspense>
    </div>
  );
}
```

## Common Scenarios

### Data Tables
- **Server Component**: Fetch table data, handle pagination, sorting on server
- **Client Component**: Handle row selection, filtering UI, inline editing

### Forms with Dynamic Data
- **Server Component**: Load form options, validation rules, initial data
- **Client Component**: Handle form state, validation feedback, submission

### Admin Dashboards
- **Server Component**: Fetch statistics, analytics data, user permissions
- **Client Component**: Handle chart interactions, date range filters, real-time updates

### Modal/Dialog Triggers
- **Server Component**: Load modal content, permissions, related data
- **Client Component**: Manage modal state, animations, user interactions

## Migration Steps

When encountering this error:

1. **Identify the async operation** - Find what's causing the component to be async
2. **Extract server logic** - Move data fetching to a separate Server Component
3. **Extract client logic** - Move interactive state to a separate Client Component
4. **Connect with props** - Pass data from Server to Client Components
5. **Add Suspense boundaries** - Wrap async components in Suspense for loading states

## Detailed Example: Interactive Data Table

### ❌ Bad Approach
```tsx
"use client";
import { useState, useEffect } from "react";

// ❌ This will cause an error
export default async function DataTable() {
  const [selectedRows, setSelectedRows] = useState<string[]>([]);
  const [data, setData] = useState<Item[]>([]);

  // ❌ Cannot use await in client component
  const fetchedData = await fetchTableData();

  useEffect(() => {
    setData(fetchedData);
  }, [fetchedData]);

  return (
    <div>
      {/* Table with selection functionality */}
    </div>
  );
}
```

### ✅ Good Approach
```tsx
// DataTableClient.tsx
"use client";
import { useState } from "react";

interface Props {
  data: Item[];
}

export function DataTableClient({ data }: Props) {
  const [selectedRows, setSelectedRows] = useState<string[]>([]);

  const handleRowSelect = (id: string) => {
    setSelectedRows(prev =>
      prev.includes(id)
        ? prev.filter(rowId => rowId !== id)
        : [...prev, id]
    );
  };

  return (
    <div>
      {data.map(item => (
        <div
          key={item.id}
          onClick={() => handleRowSelect(item.id)}
          className={selectedRows.includes(item.id) ? "selected" : ""}
        >
          {item.name}
        </div>
      ))}
    </div>
  );
}

// page.tsx
import { fetchTableData } from "@/app/actions/data";
import { DataTableClient } from "./DataTableClient";

async function DataTableWrapper() {
  const data = await fetchTableData();

  return <DataTableClient data={data} />;
}

export default function DataPage() {
  return (
    <div>
      <h1>Data Table</h1>
      <Suspense fallback={<TableSkeleton />}>
        <DataTableWrapper />
      </Suspense>
    </div>
  );
}
```

## Advanced Patterns

### Server Components with Error Boundaries
```tsx
// Error boundary wrapper
async function SafeDataWrapper({ children }: { children: React.ReactNode }) {
  try {
    const data = await fetchData();
    return children({ data });
  } catch (error) {
    return <ErrorFallback error={error} />;
  }
}

// Usage
export default function Page() {
  return (
    <SafeDataWrapper>
      {({ data }) => <InteractiveComponent data={data} />}
    </SafeDataWrapper>
  );
}
```

### Dynamic Imports for Client Components
```tsx
// Server Component
import dynamic from 'next/dynamic';
import { LoadingSkeleton } from '@/components/ui/skeleton';

const HeavyClientComponent = dynamic(
  () => import('./HeavyClientComponent'),
  {
    loading: () => <LoadingSkeleton />,
    ssr: false
  }
);

export default async function Page() {
  const data = await fetchData();

  return (
    <div>
      <h1>Page Title</h1>
      <HeavyClientComponent data={data} />
    </div>
  );
}
```

## Validation Checklist
- [ ] No Client Components marked as async
- [ ] Data fetching moved to Server Components
- [ ] Interactive state managed in Client Components
- [ ] Props flow from Server to Client Components
- [ ] Suspense boundaries wrapping async Server Components
- [ ] Clear separation of concerns in file structure
- [ ] Proper error handling for async operations

## Enforcement
This rule is enforced through:
- Next.js compilation errors
- Code review validation
- ESLint rules for async/await usage
- Architecture pattern validation

Proper separation of server and client concerns ensures optimal performance, better user experience, and follows Next.js App Router best practices.