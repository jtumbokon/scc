---
id: rule-010
type: rule
version: 1.0.0
description: Next.js 15 requires async params and searchParams - they must be awaited before accessing properties
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Next.js 15 Requires Async `params` and `searchParams` Rule (rule-010)

## Purpose
In Next.js 15, both `params` and `searchParams` are now Promises that must be awaited before accessing their properties. Direct access will cause runtime errors.

## Requirements

### MUST (Critical)
- **ALWAYS define params and searchParams as Promise types** in Next.js 15
- **ALWAYS await params and searchParams** before accessing properties
- **NEVER directly access properties** without awaiting the promise
- **ALWAYS include type parameter** when using revalidatePath with dynamic routes

### SHOULD (Important)
- **Use React's use() hook** for Client Components that cannot be async
- **Update Route Handlers** to await params
- **Update generateMetadata functions** to await params

### MAY (Optional)
- **Use optional chaining** with awaited params when properties might be undefined

## Examples

### ❌ Bad - Next.js 14 Style (Direct Access)
```typescript
// ❌ Bad - Direct property access
interface PageProps {
  params: { id: string };
  searchParams: { query: string };
}

export default async function Page({ params, searchParams }: PageProps) {
  const { id } = params; // Error: params should be awaited
  const { query } = searchParams; // Error: searchParams should be awaited
}

// ❌ Bad - Client Component with direct access
'use client';
export default function Page({ params }: { params: { id: string } }) {
  const { id } = params; // Error in Next.js 15
}

// ❌ Bad - Route Handler
export async function GET(request: Request, { params }: { params: { id: string } }) {
  const { id } = params; // Error: params should be awaited
}

// ❌ Bad - generateMetadata
export function generateMetadata({ params }: { params: { slug: string } }) {
  const { slug } = params; // Error: params should be awaited
}

// ❌ Bad - revalidatePath without type
revalidatePath('/path/[...param]'); // Missing type parameter
```

### ✅ Good - Next.js 15 Style (Async Access)
```typescript
// ✅ Good - Proper async types and awaiting
interface PageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ query: string }>;
}

export default async function Page({ params, searchParams }: PageProps) {
  const { id } = await params; // Must await
  const { query } = await searchParams; // Must await
}

// ✅ Good - Client Component with use() hook
'use client';
import { use } from 'react';

export default function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params); // Use React's use() hook
}

// ✅ Good - Route Handler with awaiting
export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params; // Must await
}

// ✅ Good - generateMetadata with awaiting
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params; // Must await
}

// ✅ Good - revalidatePath with type parameter
revalidatePath('/path/[...param]', 'page'); // Include type parameter
```

## Detailed Implementation

### Server Components
```typescript
// ✅ Good - Server Component pattern
interface PageProps {
  params: Promise<{
    id: string;
    category?: string;
  }>;
  searchParams: Promise<{
    query?: string;
    page?: string;
    filter?: string;
  }>;
}

export default async function Page({ params, searchParams }: PageProps) {
  // Await the promises before accessing properties
  const { id, category } = await params;
  const { query, page, filter } = await searchParams;

  // Now you can safely use the values
  const data = await fetchData({
    id,
    category,
    query,
    page: page ? parseInt(page) : 1,
    filter
  });

  return <div>{/* JSX */}</div>;
}
```

### Client Components
```typescript
// ✅ Good - Client Component with use() hook
'use client';
import { use } from 'react';

interface ClientPageProps {
  params: Promise<{ id: string }>;
}

export default function ClientPage({ params }: ClientPageProps) {
  // Use React's use() hook to unwrap the promise
  const { id } = use(params);

  const [data, setData] = useState(null);

  useEffect(() => {
    fetchData(id).then(setData);
  }, [id]);

  return <div>{/* JSX */}</div>;
}

// ✅ Good - Combined with other hooks
'use client';
import { use, useState, useEffect } from 'react';

interface ComponentProps {
  params: Promise<{ id: string; tab?: string }>;
  searchParams: Promise<{ view?: string }>;
}

export default function Component({ params, searchParams }: ComponentProps) {
  const { id, tab } = use(params);
  const { view } = use(searchParams);

  const [activeTab, setActiveTab] = useState(tab || 'overview');

  // Rest of component logic
}
```

### Route Handlers
```typescript
// ✅ Good - API Route Handler
export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;

  const { searchParams } = new URL(request.url);
  const query = searchParams.get('query');

  const data = await fetchData(id, query);

  return Response.json(data);
}

// ✅ Good - POST Route Handler
export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();

  const result = await updateData(id, body);

  return Response.json(result);
}
```

### generateMetadata
```typescript
// ✅ Good - Metadata generation
import { Metadata } from 'next';

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;

  const post = await getPostBySlug(slug);

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: post.coverImage ? [post.coverImage] : []
    }
  };
}

// ✅ Good - Dynamic metadata with searchParams
interface SearchPageProps {
  params: Promise<{}>;
  searchParams: Promise<{ q?: string; page?: string }>;
}

export async function generateMetadata({
  searchParams
}: SearchPageProps): Promise<Metadata> {
  const { q, page } = await searchParams;

  const pageTitle = q
    ? `Search results for "${q}" - Page ${page || '1'}`
    : 'Search';

  return {
    title: pageTitle,
    description: q
      ? `Find content matching "${q}"`
      : 'Search our content database'
  };
}
```

## Dynamic Routes

### Catch-all Routes
```typescript
// ✅ Good - Catch-all route [...slug]
interface CatchAllProps {
  params: Promise<{ slug: string[] }>;
}

export default async function CatchAllPage({ params }: CatchAllProps) {
  const { slug } = await params;

  // slug is now an array of path segments
  const path = slug.join('/');
  const data = await fetchDataByPath(path);

  return <div>{/* JSX */}</div>;
}

// ✅ Good - Optional catch-all route [[...slug]]
interface OptionalCatchAllProps {
  params: Promise<{ slug?: string[] }>;
}

export default async function OptionalCatchAllPage({ params }: OptionalCatchAllProps) {
  const { slug = [] } = await params;

  // Handle root case when slug is undefined
  const path = slug.length > 0 ? slug.join('/') : 'home';
  const data = await fetchDataByPath(path);

  return <div>{/* JSX */}</div>;
}
```

### Layout Parameters
```typescript
// ✅ Good - Layout with params
interface LayoutProps {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}

export default async function Layout({ children, params }: LayoutProps) {
  const { locale } = await params;

  return (
    <html lang={locale}>
      <body>
        {children}
      </body>
    </html>
  );
}
```

## Error Handling

### Graceful Fallbacks
```typescript
// ✅ Good - Safe parameter access
interface PageProps {
  params: Promise<{ id?: string; category?: string }>;
}

export default async function Page({ params }: PageProps) {
  const { id, category } = await params;

  // Handle undefined parameters gracefully
  if (!id) {
    notFound(); // Next.js 404 page
  }

  const data = await fetchData({ id, category });
  return <div>{/* JSX */}</div>;
}

// ✅ Good - Type-safe optional chaining
interface SearchPageProps {
  params: Promise<{}>;
  searchParams: Promise<{ query?: string; sort?: 'asc' | 'desc' }>;
}

export default async function SearchPage({ searchParams }: SearchPageProps) {
  const { query, sort = 'desc' } = await searchParams;

  if (!query) {
    return <div>Please enter a search query</div>;
  }

  const results = await search(query, sort);
  return <div>{/* Results JSX */}</div>;
}
```

## Validation Checklist
- [ ] params and searchParams defined as Promise types
- [ ] All property accesses are preceded with await
- [ ] Client components use React's use() hook
- [ ] Route handlers await params before use
- [ ] generateMetadata functions await params
- [ ] revalidatePath includes type parameter for dynamic routes
- [ ] Optional parameters handled with fallbacks
- [ ] Error handling for missing required parameters

## Migration Guide

### Step 1: Update Type Definitions
```typescript
// Before
interface PageProps {
  params: { id: string };
  searchParams: { query: string };
}

// After
interface PageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ query: string }>;
}
```

### Step 2: Add Await Before Property Access
```typescript
// Before
const { id } = params;
const { query } = searchParams;

// After
const { id } = await params;
const { query } = await searchParams;
```

### Step 3: Update Client Components
```typescript
// Before
'use client';
export default function Page({ params }: { params: { id: string } }) {
  const { id } = params;
}

// After
'use client';
import { use } from 'react';
export default function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
}
```

## Enforcement
This rule is enforced through:
- TypeScript compilation errors
- Next.js development server warnings
- Runtime error detection
- Code review validation

Following this rule ensures compatibility with Next.js 15 and prevents runtime errors from improper parameter access.