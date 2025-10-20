---
id: rule-038
type: rule
version: 1.0.0
description: Wrap Client Components using useSearchParams() in Suspense boundaries to prevent build failures
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# UseSearchParams Requires Suspense Rule (rule-038)

## Purpose
In the Next.js App Router, the hook `useSearchParams()` triggers a **client-side rendering bailout** unless the component that calls it is rendered inside a React `<Suspense>` boundary. Omitting the boundary leads to build-time failures such as:

```
useSearchParams() should be wrapped in a suspense boundary
```

This rule ensures proper usage of `useSearchParams()` with Suspense boundaries to prevent build failures.

## Requirements

### MUST (Critical)
- **ALWAYS wrap Client Components** using `useSearchParams()` in `<Suspense>` boundary
- **NEVER use `useSearchParams()`** in Client Components without Suspense boundary
- **PROVIDE appropriate fallback** prop to avoid layout shifts
- **ENSURE boundary directly wraps** the component that uses the hook

### SHOULD (Important)
- **PLACE Suspense boundary** in parent Server Component when possible
- **USE meaningful fallback content** that matches expected component structure
- **MINIMIZE layout shifts** with appropriately sized fallbacks
- **SEPARATE concerns** by isolating `useSearchParams()` usage in dedicated components

### MAY (Optional)
- **CREATE reusable wrapper components** for common search params patterns
- **IMPLEMENT loading skeletons** for better user experience
- **USE error boundaries** in combination with Suspense for robustness
- **CACHE search params** in parent components to minimize re-renders

## Correct Implementation Patterns

### Pattern 1: Server Component Wrapper (Recommended)
```tsx
// app/search/page.tsx (Server Component)
import { Suspense } from 'react';
import SearchResults from './SearchResults';

export default function SearchPage() {
  return (
    <div>
      <h1>Search Results</h1>
      <Suspense fallback={<SearchResultsSkeleton />}>
        <SearchResults />
      </Suspense>
    </div>
  );
}

// components/SearchResults.tsx (Client Component)
'use client';
import { useSearchParams } from 'next/navigation';

export default function SearchResults() {
  const searchParams = useSearchParams();
  const query = searchParams.get('q');

  // Component logic using searchParams
  return (
    <div>
      {query ? <div>Results for: {query}</div> : <div>No search query</div>}
    </div>
  );
}

// components/SearchResultsSkeleton.tsx
export default function SearchResultsSkeleton() {
  return (
    <div className="animate-pulse">
      <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
      <div className="h-4 bg-gray-200 rounded w-1/2"></div>
    </div>
  );
}
```

### Pattern 2: Client Component with Internal Suspense
```tsx
// components/FilterableList.tsx (Client Component)
'use client';
import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import FilterControls from './FilterControls';
import FilteredList from './FilteredList';

export default function FilterableList() {
  return (
    <div>
      <FilterControls />
      <Suspense fallback={<ListSkeleton />}>
        <FilteredListWrapper />
      </Suspense>
    </div>
  );
}

// components/FilteredListWrapper.tsx (Client Component)
'use client';
import { useSearchParams } from 'next/navigation';

export default function FilteredListWrapper() {
  const searchParams = useSearchParams();
  const category = searchParams.get('category');
  const sort = searchParams.get('sort');

  return <FilteredList category={category} sort={sort} />;
}
```

### Pattern 3: Reusable Search Params Hook Wrapper
```tsx
// hooks/useSafeSearchParams.ts
'use client';
import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';

interface SafeSearchParamsProps {
  children: (params: URLSearchParams) => React.ReactNode;
  fallback?: React.ReactNode;
}

export default function SafeSearchParams({
  children,
  fallback = <div>Loading...</div>
}: SafeSearchParamsProps) {
  return (
    <Suspense fallback={fallback}>
      <SafeSearchParamsWrapper>{children}</SafeSearchParamsWrapper>
    </Suspense>
  );
}

function SafeSearchParamsWrapper({
  children
}: { children: (params: URLSearchParams) => React.ReactNode }) {
  const searchParams = useSearchParams();
  return <>{children(searchParams)}</>;
}

// Usage in components
// components/SearchComponent.tsx
'use client';
import SafeSearchParams from './hooks/useSafeSearchParams';

export default function SearchComponent() {
  return (
    <SafeSearchParams fallback={<SearchSkeleton />}>
      {(searchParams) => {
        const query = searchParams.get('q');
        return <SearchResults query={query} />;
      }}
    </SafeSearchParams>
  );
}
```

## Examples

### ❌ Bad (No Suspense Boundary)
```tsx
// app/search/page.tsx
'use client';
import { useSearchParams } from 'next/navigation';

export default function SearchPage() {
  const searchParams = useSearchParams(); // ❌ Build error!
  const query = searchParams.get('q');

  return (
    <div>
      <h1>Search Results for: {query}</h1>
    </div>
  );
}
```

### ✅ Good (With Suspense Boundary)
```tsx
// app/search/SearchPage.tsx (Client Component)
'use client';
import { useSearchParams } from 'next/navigation';

export default function SearchPage() {
  const searchParams = useSearchParams(); // ✅ Wrapped in Suspense
  const query = searchParams.get('q');

  return (
    <div>
      <h1>Search Results for: {query}</h1>
    </div>
  );
}

// app/search/page.tsx (Server Component)
import { Suspense } from 'react';
import SearchPage from './SearchPage';

export default function Page() {
  return (
    <Suspense fallback={<div>Loading search...</div>}>
      <SearchPage />
    </Suspense>
  );
}
```

## Advanced Patterns

### Multiple Search Params Components
```tsx
// app/dashboard/page.tsx (Server Component)
import { Suspense } from 'react';
import UserFilters from './UserFilters';
import DateFilters from './DateFilters';
import DataDisplay from './DataDisplay';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<FiltersSkeleton />}>
        <UserFilters />
      </Suspense>
      <Suspense fallback={<FiltersSkeleton />}>
        <DateFilters />
      </Suspense>
      <Suspense fallback={<DataSkeleton />}>
        <DataDisplay />
      </Suspense>
    </div>
  );
}

// Each component using useSearchParams is separately wrapped
```

### Dynamic Route with Search Params
```tsx
// app/posts/[slug]/page.tsx (Server Component)
import { Suspense } from 'react';
import PostContent from './PostContent';
import PostComments from './PostComments';

export default function PostPage({ params }: { params: { slug: string } }) {
  return (
    <div>
      <PostContent slug={params.slug} />
      <Suspense fallback={<CommentsSkeleton />}>
        <PostComments />
      </Suspense>
    </div>
  );
}

// components/PostComments.tsx (Client Component)
'use client';
import { useSearchParams } from 'next/navigation';

export default function PostComments() {
  const searchParams = useSearchParams();
  const sort = searchParams.get('sort') || 'newest';
  const page = searchParams.get('page') || '1';

  // Component logic using searchParams
  return (
    <div>
      {/* Comments sorted and paginated by search params */}
    </div>
  );
}
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Forgetting Suspense Boundary
```tsx
// Bad - Direct usage without Suspense
'use client';
import { useSearchParams } from 'next/navigation';

function Component() {
  const params = useSearchParams(); // Build error!
  return <div>{params.get('tab')}</div>;
}
```

### ❌ Mistake 2: Suspense Boundary Too High
```tsx
// Bad - Suspense wraps entire page unnecessarily
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Suspense fallback={<div>Loading...</div>}>
          {children} {/* Too broad */}
        </Suspense>
      </body>
    </html>
  );
}
```

### ❌ Mistake 3: Poor Fallback Content
```tsx
// Bad - Fallback causes layout shift
<Suspense fallback={null}>
  <SearchResults />
</Suspense>

// Good - Fallback maintains layout
<Suspense fallback={<SearchResultsSkeleton />}>
  <SearchResults />
</Suspense>
```

## Skeleton Components

### Search Results Skeleton
```tsx
// components/SearchResultsSkeleton.tsx
export default function SearchResultsSkeleton() {
  return (
    <div className="space-y-4">
      <div className="animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
        <div className="h-3 bg-gray-200 rounded w-1/2"></div>
      </div>
      <div className="animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-2/3 mb-2"></div>
        <div className="h-3 bg-gray-200 rounded w-1/3"></div>
      </div>
      <div className="animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-4/5 mb-2"></div>
        <div className="h-3 bg-gray-200 rounded w-2/5"></div>
      </div>
    </div>
  );
}
```

### Filter Controls Skeleton
```tsx
// components/FilterControlsSkeleton.tsx
export default function FilterControlsSkeleton() {
  return (
    <div className="flex space-x-4 mb-6">
      <div className="animate-pulse">
        <div className="h-10 bg-gray-200 rounded w-32"></div>
      </div>
      <div className="animate-pulse">
        <div className="h-10 bg-gray-200 rounded w-24"></div>
      </div>
      <div className="animate-pulse">
        <div className="h-10 bg-gray-200 rounded w-28"></div>
      </div>
    </div>
  );
}
```

## Error Handling

### Combining Suspense with Error Boundaries
```tsx
// components/SafeSearchComponent.tsx
'use client';
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import SearchComponent from './SearchComponent';
import SearchErrorFallback from './SearchErrorFallback';

export default function SafeSearchComponent() {
  return (
    <ErrorBoundary FallbackComponent={SearchErrorFallback}>
      <Suspense fallback={<SearchSkeleton />}>
        <SearchComponent />
      </Suspense>
    </ErrorBoundary>
  );
}
```

## Performance Considerations

### Minimize Re-renders
```tsx
// Good - Extract search params once
function SearchResults() {
  const searchParams = useSearchParams();
  const category = searchParams.get('category');
  const sort = searchParams.get('sort');

  return (
    <div>
      <CategoryFilter category={category} />
      <SortControl sort={sort} />
      <DataList category={category} sort={sort} />
    </div>
  );
}

// Bad - Multiple useSearchParams calls
function BadSearchResults() {
  return (
    <div>
      <CategoryFilter category={useSearchParams().get('category')} />
      <SortControl sort={useSearchParams().get('sort')} />
    </div>
  );
}
```

## Validation Checklist
- [ ] When a component uses `useSearchParams()`, ensure it's wrapped in `<Suspense>` with fallback
- [ ] Never suggest using `useSearchParams()` in a Client Component without Suspense boundary
- [ ] Verify that pages/layouts continue to compile without the CSR-bailout error
- [ ] Use appropriate fallback content that matches component structure
- [ ] Place Suspense boundary as close as possible to the component using `useSearchParams()`
- [ ] Test loading states and fallback content
- [ ] Consider using reusable wrapper components for common patterns

This rule ensures proper usage of `useSearchParams()` with Suspense boundaries to prevent build failures and provide better user experience.