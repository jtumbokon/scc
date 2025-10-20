---
id: rule-016
type: rule
version: 1.0.0
description: Next.js API Route Data Handling - Use App Router with async params and proper Web Request/Response APIs
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Next.js API Route Data Handling Rule (rule-016)

## Purpose
This project uses **App Router exclusively** (Next.js 13+) with Route Handlers that use Web Request/Response APIs.

**We do NOT use Pages Router** - any suggestions for Pages Router patterns (`pages/api/` directory, `NextApiRequest`, `NextApiResponse`) should be rejected.

**Critical**: In Next.js 15, all `params` are now Promises and must be awaited. Failing to await params will cause runtime errors and data access issues.

Different types of data come through different channels in API routes, and each has specific patterns that must be followed for type safety and proper functionality.

## Requirements

### MUST (Critical)
- **Only use App Router Route Handlers** - never suggest Pages Router patterns
- **Always await `params`** - they are Promises in Next.js 15+
- **Use proper TypeScript interfaces** for route parameters with Promise types
- **Use correct data access patterns** for each type of request data
- **Handle all HTTP methods** explicitly with proper typing
- **Use Web APIs exclusively** - Request/Response, not Node.js req/res

### SHOULD (Important)
- **Use separate exported functions** for each HTTP method (GET, POST, PUT, DELETE)
- **Provide clear type definitions** for route parameters and response types
- **Handle different content types** appropriately (JSON, form data, text)
- **Use proper error handling** with appropriate HTTP status codes

### MAY (Optional)
- **Create utility functions** for common data extraction patterns
- **Use middleware** for cross-cutting concerns like authentication
- **Implement validation** for request bodies and parameters

## Data Access Patterns

### App Router Route Handlers (Required)
| Data Type | Access Pattern | Example |
|-----------|---------------|---------|
| **URL Params** | `await params` | `const { id } = await params` |
| **Query Parameters** | `request.nextUrl.searchParams` | `const query = request.nextUrl.searchParams.get('q')` |
| **Request Body (JSON)** | `await request.json()` | `const body = await request.json()` |
| **Request Body (Form)** | `await request.formData()` | `const formData = await request.formData()` |
| **Request Body (Text)** | `await request.text()` | `const text = await request.text()` |
| **Headers** | `request.headers` or `headers()` | `const auth = request.headers.get('authorization')` |
| **Cookies** | `request.cookies` or `cookies()` | `const token = request.cookies.get('token')` |

## Examples

### App Router Route Handlers (✅ Correct Pattern)
```typescript
// app/api/documents/[id]/route.ts
import { NextRequest, NextResponse } from "next/server";

interface RouteParams {
  params: Promise<{
    id: string;
  }>;
}

export async function GET(request: NextRequest, { params }: RouteParams) {
  // ✅ Await params (Next.js 15+)
  const { id } = await params;

  // ✅ Get query parameters
  const searchParams = request.nextUrl.searchParams;
  const filter = searchParams.get('filter');

  // ✅ Get headers
  const auth = request.headers.get('authorization');

  return NextResponse.json({ id, filter, auth });
}

export async function POST(request: NextRequest, { params }: RouteParams) {
  // ✅ Await params
  const { id } = await params;

  // ✅ Parse JSON body
  const body = await request.json();

  // ✅ Get cookies
  const token = request.cookies.get('session');

  return NextResponse.json({ id, body, token: token?.value });
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  // ✅ Await params
  const { id } = await params;

  return NextResponse.json({ deleted: id });
}
```

## Common Mistakes

| ❌ Bad | ✅ Good |
|-------|-------|
| ```typescript
// Not awaiting params
export async function GET(request: Request, { params }: { params: { id: string } }) {
  const { id } = params; // ❌ Runtime error in Next.js 15
  return Response.json({ id });
}
``` | ```typescript
// Awaiting params correctly
export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params; // ✅ Correct
  return Response.json({ id });
}
``` |
| ```typescript
// Wrong query parameter access
export async function GET(request: Request) {
  const { q } = request.query; // ❌ Doesn't exist on Request
  return Response.json({ q });
}
``` | ```typescript
// Correct query parameter access
export async function GET(request: NextRequest) {
  const q = request.nextUrl.searchParams.get('q'); // ✅ Correct
  return Response.json({ q });
}
``` |
| ```typescript
// Using Pages Router patterns (NEVER USE)
export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const body = req.body; // ❌ Pages Router - NOT ALLOWED
  res.status(200).json({ body });
}
``` | ```typescript
// App Router only - Web APIs
export async function POST(request: Request) {
  const body = await request.json(); // ✅ Web API
  return Response.json({ body });
}
``` |
| ```typescript
// Wrong request body access
export async function POST(request: Request) {
  const body = request.body; // ❌ Body is a ReadableStream
  return Response.json({ body });
}
``` | ```typescript
// Correct request body access
export async function POST(request: Request) {
  const body = await request.json(); // ✅ Parse JSON
  return Response.json({ body });
}
``` |

## Type Definitions

### Route Handler Parameter Types
```typescript
// Single dynamic parameter
interface RouteParams {
  params: Promise<{ id: string }>;
}

// Multiple dynamic parameters
interface RouteParams {
  params: Promise<{ category: string; item: string }>;
}

// Catch-all parameters
interface RouteParams {
  params: Promise<{ slug: string[] }>;
}

// Optional catch-all parameters
interface RouteParams {
  params: Promise<{ slug?: string[] }>;
}
```

### Response Types
```typescript
// Custom response type
interface ApiResponse {
  success: boolean;
  data?: any;
  error?: string;
}

// Usage in route handler
export async function POST(request: NextRequest) {
  const response: ApiResponse = {
    success: true,
    data: { id: "123" }
  };
  return NextResponse.json(response);
}
```

## HTTP Method Handling

### App Router - Separate Functions (Required Pattern)
```typescript
export async function GET(request: NextRequest, { params }: RouteParams) {
  // Handle GET requests
}

export async function POST(request: NextRequest, { params }: RouteParams) {
  // Handle POST requests
}

export async function PUT(request: NextRequest, { params }: RouteParams) {
  // Handle PUT requests
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  // Handle DELETE requests
}
```

### Method Not Allowed Handling
```typescript
// Next.js automatically handles unsupported methods with 405
// No manual method checking needed like in Pages Router
// Each HTTP method gets its own exported function
```

## Advanced Patterns

### Complex Route with Multiple Parameters
```typescript
// app/api/users/[userId]/documents/[docId]/route.ts
interface ComplexRouteParams {
  params: Promise<{
    userId: string;
    docId: string;
  }>;
}

export async function GET(request: NextRequest, { params }: ComplexRouteParams) {
  const { userId, docId } = await params;

  // Fetch document for specific user
  const document = await getDocument(userId, docId);

  return NextResponse.json({ userId, docId, document });
}
```

### Request Body Validation
```typescript
interface CreateDocumentRequest {
  title: string;
  content: string;
  tags: string[];
}

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const body: CreateDocumentRequest = await request.json();

    // Validate required fields
    if (!body.title || !body.content) {
      return NextResponse.json(
        { error: "Title and content are required" },
        { status: 400 }
      );
    }

    const { id } = await params;
    const document = await createDocument(id, body);

    return NextResponse.json(document, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: "Invalid JSON format" },
      { status: 400 }
    );
  }
}
```

### File Upload Handling
```typescript
export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File;
    const metadata = formData.get('metadata') as string;

    if (!file) {
      return NextResponse.json(
        { error: "No file provided" },
        { status: 400 }
      );
    }

    const { id } = await params;
    const result = await uploadFile(id, file, JSON.parse(metadata));

    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json(
      { error: "Upload failed" },
      { status: 500 }
    );
  }
}
```

### Error Handling Patterns
```typescript
export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;

    // Validate ID format
    if (!isValidId(id)) {
      return NextResponse.json(
        { error: "Invalid ID format" },
        { status: 400 }
      );
    }

    const data = await fetchData(id);

    if (!data) {
      return NextResponse.json(
        { error: "Resource not found" },
        { status: 404 }
      );
    }

    return NextResponse.json(data);
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

## Validation Checklist
- [ ] Always await `params` in Route Handlers (Next.js 15+)
- [ ] Use `Promise<{ ... }>` type for params in TypeScript interfaces
- [ ] Use `request.nextUrl.searchParams.get()` for query parameters
- [ ] Use `await request.json()` for JSON request body parsing
- [ ] Use `await request.formData()` for form data parsing
- [ ] Use `await request.text()` for text body parsing
- [ ] Use `request.headers.get()` or `headers()` for header access
- [ ] Use `request.cookies.get()` or `cookies()` for cookie access
- [ ] Never suggest Pages Router patterns (`NextApiRequest`, `NextApiResponse`, `pages/api/`)
- [ ] Always use separate functions for each HTTP method (GET, POST, PUT, DELETE)
- [ ] Use proper TypeScript interfaces for route parameters
- [ ] Ensure all route handlers are in the `app/` directory structure

## Enforcement
This rule is enforced through:
- Next.js compilation errors
- TypeScript type checking
- Code review validation
- Runtime error prevention
- Project architecture compliance

Proper data handling ensures type safety, App Router compliance, and compatibility with Next.js 15's async params requirement.