---
id: rule-033
type: rule
version: 1.0.0
description: Separate server-side and client-safe utilities - never mix server imports with client-safe constants in same file
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Separate Server Client Utilities Rule (rule-033)

## Purpose
In Next.js applications, utility files that mix server-side imports (like `next/headers`, `@/lib/supabase/server`) with client-safe constants or functions can cause build errors when client components try to import the client-safe parts. This happens because Next.js attempts to bundle server-only modules into the client bundle when any part of the file is imported by a client component.

## Requirements

### MUST (Critical)
- **NEVER mix** server-side imports with client-safe utilities in the same file
- **SEPARATE concerns** by creating dedicated files for different purposes
- **CREATE `*-constants.ts`** files for client-safe constants, types, and pure utility functions
- **KEEP server-side imports** in dedicated `*.ts` files with optional re-exports
- **MAINTAIN clear boundaries** between server-only and client-safe code

### SHOULD (Important)
- **USE descriptive naming conventions** to distinguish file purposes
- **IMPLEMENT re-exports** in server files for backward compatibility
- **ORGANIZE files logically** by functionality and scope
- **VALIDATE imports** work correctly after separation
- **DOCUMENT file purposes** clearly in comments or JSDoc

### MAY (Optional)
- **CREATE `-client.ts` files** for client-side specific utilities
- **USE `-server.ts` files** for explicitly server-only functions
- **IMPLEMENT type-only files** for shared type definitions
- **CREATE utility index files** for cleaner import paths

## Forbidden Patterns

### ❌ MIXED CONCERNS ARE FORBIDDEN
```typescript
// ❌ FORBIDDEN - Server and client utilities in same file
// lib/storage.ts
import { createClient } from "@/lib/supabase/server"; // Server import

export const IMAGE_CONSTRAINTS = {
  MAX_SIZE: 10 * 1024 * 1024,
  ALLOWED_TYPES: ["image/jpeg", "image/png"]
};

export function generatePath(id: string) {
  return `images/${id}`;
}

export async function getPublicUrl(path: string) {
  const supabase = await createClient();
  return supabase.storage.from("bucket").getPublicUrl(path);
}

// ❌ FORBIDDEN - Mixed authentication utilities
// lib/auth.ts
import { cookies } from "next/headers"; // Server import
import jwt from "jsonwebtoken";      // Server import

export const JWT_SECRET = process.env.JWT_SECRET;
export const COOKIE_NAME = "auth-token";

export function validateToken(token: string) {
  // Client-safe validation logic
}

export function createServerCookie(token: string) {
  cookies().set(COOKIE_NAME, token, {
    httpOnly: true,
    secure: true,
    sameSite: "lax"
  });
}

// ❌ FORBIDDEN - Mixed database utilities
// lib/database.ts
import { createClient } from "@/lib/supabase/server"; // Server import

export const USER_ROLES = ["admin", "user", "guest"]; // Client constant

export interface User {
  id: string;
  email: string;
  role: typeof USER_ROLES[number];
}

export async function getUser(id: string) {
  const supabase = createClient();
  return supabase.from("users").select("*").eq("id", id).single();
}
```

## Correct Implementation Patterns

### Pattern 1: Storage Utilities Separation
```typescript
// ✅ GOOD - Client-safe constants and utilities
// lib/storage-constants.ts

export const IMAGE_CONSTRAINTS = {
  MAX_SIZE: 10 * 1024 * 1024, // 10MB
  ALLOWED_TYPES: ["image/jpeg", "image/png", "image/webp"] as const,
  QUALITY_SETTINGS: {
    thumbnail: 60,
    medium: 80,
    high: 90
  }
} as const;

export function generateImagePath(id: string, filename: string): string {
  return `images/${id}/${filename}`;
}

export function generateImagePathWithTimestamp(id: string, filename: string): string {
  const timestamp = Date.now();
  return `images/${id}/${timestamp}-${filename}`;
}

export function validateImageFile(file: File): { isValid: boolean; error?: string } {
  if (!file) {
    return { isValid: false, error: "No file provided" };
  }

  if (file.size > IMAGE_CONSTRAINTS.MAX_SIZE) {
    return { isValid: false, error: `File size exceeds ${IMAGE_CONSTRAINTS.MAX_SIZE / 1024 / 1024}MB` };
  }

  if (!IMAGE_CONSTRAINTS.ALLOWED_TYPES.includes(file.type as any)) {
    return { isValid: false, error: `File type ${file.type} not allowed` };
  }

  return { isValid: true };
}

// ✅ GOOD - Server-side storage functions
// lib/storage.ts
import { createClient } from "@/lib/supabase/server";

// Re-export client-safe utilities for backward compatibility
export {
  IMAGE_CONSTRAINTS,
  generateImagePath,
  generateImagePathWithTimestamp,
  validateImageFile
} from "./storage-constants";

export async function uploadImage(
  file: File,
  path: string
): Promise<{ success: boolean; url?: string; error?: string }> {
  const validation = validateImageFile(file);
  if (!validation.isValid) {
    return { success: false, error: validation.error };
  }

  try {
    const supabase = createClient();
    const { data, error } = await supabase.storage
      .from("images")
      .upload(path, file);

    if (error) {
      return { success: false, error: error.message };
    }

    const { data: { publicUrl } } = supabase.storage
      .from("images")
      .getPublicUrl(path);

    return { success: true, url: publicUrl };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Upload failed"
    };
  }
}

export async function deleteImage(path: string): Promise<boolean> {
  try {
    const supabase = createClient();
    const { error } = await supabase.storage
      .from("images")
      .remove([path]);

    return !error;
  } catch {
    return false;
  }
}
```

### Pattern 2: Authentication Separation
```typescript
// ✅ GOOD - Client-safe auth constants and types
// lib/auth-constants.ts

export const AUTH_COOKIE_NAME = "auth-token";
export const AUTH_COOKIE_MAX_AGE = 7 * 24 * 60 * 60; // 7 days in seconds

export interface User {
  id: string;
  email: string;
  name: string;
  role: "admin" | "user" | "guest";
  emailVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AuthResponse {
  success: boolean;
  user?: User;
  error?: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  name: string;
  email: string;
  password: string;
}

// JWT payload interface
export interface JWTPayload {
  sub: string; // user id
  email: string;
  name: string;
  role: string;
  exp: number;
  iat: number;
}

export function generateAuthRedirectUrl(path: string): string {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
  return `${baseUrl}${path}`;
}

export function isTokenExpired(token: string): boolean {
  try {
    const payload = JSON.parse(atob(token.split('.')[1])) as JWTPayload;
    return Date.now() >= payload.exp * 1000;
  } catch {
    return true;
  }
}

// ✅ GOOD - Server-side auth functions
// lib/auth.ts
import { cookies } from "next/headers";
import jwt from "jsonwebtoken";
import { createClient } from "@/lib/supabase/server";

// Re-export client-safe utilities
export {
  AUTH_COOKIE_NAME,
  AUTH_COOKIE_MAX_AGE,
  User,
  AuthResponse,
  LoginCredentials,
  RegisterData,
  JWTPayload,
  generateAuthRedirectUrl,
  isTokenExpired
} from "./auth-constants";

const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  throw new Error("JWT_SECRET environment variable is not set");
}

export function generateToken(user: User): string {
  const payload: JWTPayload = {
    sub: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
    exp: Math.floor(Date.now() / 1000) + AUTH_COOKIE_MAX_AGE,
    iat: Math.floor(Date.now() / 1000)
  };

  return jwt.sign(payload, JWT_SECRET);
}

export function verifyToken(token: string): JWTPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
  } catch {
    return null;
  }
}

export function setAuthCookie(token: string): void {
  cookies().set(AUTH_COOKIE_NAME, token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: AUTH_COOKIE_MAX_AGE,
    path: "/"
  });
}

export function clearAuthCookie(): void {
  cookies().set(AUTH_COOKIE_NAME, "", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 0,
    path: "/"
  });
}

export async function getUserFromToken(token: string): Promise<User | null> {
  const payload = verifyToken(token);
  if (!payload) {
    return null;
  }

  try {
    const supabase = createClient();
    const { data } = await supabase
      .from("users")
      .select("*")
      .eq("id", payload.sub)
      .single();

    return data;
  } catch {
    return null;
  }
}
```

### Pattern 3: Database Utilities Separation
```typescript
// ✅ GOOD - Database types and constants
// lib/database-constants.ts

export const DATABASE_TABLES = {
  USERS: "users",
  POSTS: "posts",
  COMMENTS: "comments",
  CATEGORIES: "categories",
  TAGS: "tags"
} as const;

export const POST_STATUSES = {
  DRAFT: "draft",
  PUBLISHED: "published",
  ARCHIVED: "archived"
} as const;

export interface User {
  id: string;
  email: string;
  name: string;
  bio?: string;
  avatar?: string;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Post {
  id: string;
  title: string;
  content: string;
  excerpt?: string;
  status: keyof typeof POST_STATUSES;
  authorId: string;
  categoryId?: string;
  publishedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface Comment {
  id: string;
  content: string;
  authorId: string;
  postId: string;
  parentId?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface DatabaseQueryOptions {
  limit?: number;
  offset?: number;
  orderBy?: string;
  orderDirection?: "asc" | "desc";
  filters?: Record<string, any>;
}

// ✅ GOOD - Database operations
// lib/database.ts
import { createClient } from "@/lib/supabase/server";

// Re-export constants and types
export {
  DATABASE_TABLES,
  POST_STATUSES,
  User,
  Post,
  Comment,
  DatabaseQueryOptions
} from "./database-constants";

export async function getUserById(id: string): Promise<User | null> {
  try {
    const supabase = createClient();
    const { data } = await supabase
      .from(DATABASE_TABLES.USERS)
      .select("*")
      .eq("id", id)
      .single();

    return data;
  } catch (error) {
    console.error("Database error:", error);
    return null;
  }
}

export async function getPosts(options: DatabaseQueryOptions = {}): Promise<Post[]> {
  try {
    const supabase = createClient();
    let query = supabase
      .from(DATABASE_TABLES.POSTS)
      .select(`
        *,
        ${DATABASE_TABLES.USERS}(name),
        ${DATABASE_TABLES.CATEGORIES}(name)
      `)
      .eq("status", POST_STATUSES.PUBLISHED);

    if (options.limit) {
      query = query.limit(options.limit);
    }

    if (options.offset) {
      query = query.range(options.offset, options.offset + (options.limit || 10) - 1);
    }

    if (options.orderBy) {
      query = query.order(options.orderBy, {
        ascending: options.orderDirection === "asc"
      });
    }

    const { data } = await query;
    return data || [];
  } catch (error) {
    console.error("Database error:", error);
    return [];
  }
}

export async function createPost(post: Omit<Post, "id" | "createdAt" | "updatedAt">): Promise<Post | null> {
  try {
    const supabase = createClient();
    const { data } = await supabase
      .from(DATABASE_TABLES.POSTS)
      .insert({
        ...post,
        status: POST_STATUSES.PUBLISHED,
        publishedAt: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      })
      .select()
      .single();

    return data;
  } catch (error) {
    console.error("Database error:", error);
    return null;
  }
}
```

### Pattern 4: API Integration Separation
```typescript
// ✅ GOOD - API types and constants
// lib/api-constants.ts

export const API_ENDPOINTS = {
  USERS: "/api/users",
  POSTS: "/api/posts",
  COMMENTS: "/api/comments",
  SEARCH: "/api/search"
} as const;

export const HTTP_METHODS = {
  GET: "GET",
  POST: "POST",
  PUT: "PUT",
  DELETE: "DELETE",
  PATCH: "PATCH"
} as const;

export const HTTP_STATUS_CODES = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  INTERNAL_SERVER_ERROR: 500
} as const;

export interface ApiError {
  message: string;
  status: number;
  code?: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta?: {
    pagination?: {
      page: number;
      limit: number;
      total: number;
    };
  };
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  offset?: number;
}

export function createApiUrl(endpoint: string, params?: Record<string, string>): string {
  const baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";
  const url = new URL(endpoint, baseUrl);

  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      url.searchParams.set(key, value);
    });
  }

  return url.toString();
}

// ✅ GOOD - API client functions
// lib/api-client.ts
import { createApiUrl } from "./api-constants";

// Re-export constants for client use
export {
  API_ENDPOINTS,
  HTTP_METHODS,
  HTTP_STATUS_CODES,
  ApiError,
  ApiResponse,
  PaginationParams,
  createApiUrl
} from "./api-constants";

export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  try {
    const url = createApiUrl(endpoint);
    const response = await fetch(url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
    });

    const data = await response.json();

    if (!response.ok) {
      return {
        success: false,
        error: {
          message: data.message || "Request failed",
          status: response.status,
          code: data.code
        }
      };
    }

    return {
      success: true,
      data
    };
  } catch (error) {
    return {
      success: false,
      error: {
        message: error instanceof Error ? error.message : "Network error",
        status: HTTP_STATUS_CODES.INTERNAL_SERVER_ERROR
      }
    };
  }
}

export async function get<T = any>(
  endpoint: string,
  params?: Record<string, string>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, {
    method: HTTP_METHODS.GET,
    headers: {
      // Add any specific GET headers here
    },
    // GET doesn't have body, params go in URL
  });
}

export async function post<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, string>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, {
    method: HTTP_METHODS.POST,
    body: data ? JSON.stringify(data) : undefined,
    headers: {
      // Add any specific POST headers here
    },
  });
}
```

## File Naming Conventions

### Recommended File Structure
```
lib/
├── auth/
│   ├── auth-constants.ts      # Client-safe auth types and constants
│   └── auth.ts                # Server-side auth functions
├── database/
│   ├── database-constants.ts   # Database types and constants
│   └── database.ts            # Database operations
├── storage/
│   ├── storage-constants.ts    # Storage constraints and utilities
│   └── storage.ts             # Server-side storage functions
├── api/
│   ├── api-constants.ts       # API types and constants
│   ├── api-client.ts           # Client-side API functions
│   └── api-server.ts           # Server-side API handlers
├── utils/
│   ├── validation-constants.ts  # Validation schemas and rules
│   ├── validation.ts          # Validation functions
│   ├── formatting-constants.ts # Formatting utilities
│   └── formatting.ts          # Formatting functions
└── types/
    ├── common-types.ts         # Shared type definitions
    ├── server-types.ts          # Server-only types
    └── client-types.ts          # Client-only types
```

### Naming Patterns
| Pattern | Purpose | Example |
|---------|---------|---------|
| `*-constants.ts` | Client-safe constants, types, pure utilities | `auth-constants.ts`, `storage-constants.ts` |
| `*.ts` | Primary implementation with server imports | `storage.ts`, `database.ts` |
| `*-client.ts` | Explicitly client-side utilities | `api-client.ts`, `storage-client.ts` |
| `*-server.ts` | Explicitly server-only functions | `auth-server.ts`, `api-server.ts` |
| `types/*.ts` | Type definitions | `types/common-types.ts` |

## Import Guidelines

### Client Component Imports
```tsx
// ✅ GOOD - Client components import from constants files
import { IMAGE_CONSTRAINTS, generateImagePath } from "@/lib/storage-constants";
import { User, AuthResponse } from "@/lib/auth-constants";
import { POST_STATUSES } from "@/lib/database-constants";

function ImageUpload() {
  const handleUpload = async (file: File) => {
    const validation = validateImageFile(file);
    if (!validation.isValid) {
      console.error(validation.error);
      return;
    }

    // Upload logic using server action
    const result = await uploadImage(file);
    // Handle result...
  };

  return (
    <div>
      <p>Max size: {IMAGE_CONSTRAINTS.MAX_SIZE / 1024 / 1024}MB</p>
      <input
        type="file"
        accept={IMAGE_CONSTRAINTS.ALLOWED_TYPES.join(",")}
        onChange={(e) => e.target.files?.[0] && handleUpload(e.target.files[0])}
      />
    </div>
  );
}
```

### Server Component/Action Imports
```tsx
// ✅ GOOD - Server components can import from either file
import { uploadImage, deleteImage } from "@/lib/storage";
import { generateToken, setAuthCookie } from "@/lib/auth";
import { createPost, getPosts } from "@/lib/database";

// Server action example
"use server";
import { uploadImage } from "@/lib/storage";

export async function uploadServerAction(file: File) {
  return await uploadImage(file, generateImagePath(file.id, file.name));
}

// Server component example
async function ServerComponent() {
  const posts = await getPosts({ limit: 10 });
  return <PostList posts={posts} />;
}
```

## Migration Strategy

### Step-by-Step Migration
```typescript
// ❌ BEFORE - Mixed concerns in one file
// lib/mixed.ts
import { createClient } from "@/lib/supabase/server";
import { cookies } from "next/headers";

export const CONFIG = {
  MAX_FILE_SIZE: 10 * 1024 * 1024,
  COOKIE_NAME: "session"
};

export function generatePath(id: string) {
  return `files/${id}`;
}

export async function uploadFile(file: File) {
  // Server logic here
}

export function setSessionCookie(token: string) {
  cookies().set(CONFIG.COOKIE_NAME, token);
}

// ✅ AFTER - Separated concerns

// Step 1: Create constants file
// lib/mixed-constants.ts
export const CONFIG = {
  MAX_FILE_SIZE: 10 * 1024 * 1024,
  COOKIE_NAME: "session"
};

export function generatePath(id: string) {
  return `files/${id}`;
}

// Step 2: Update original file with server imports only
// lib/mixed.ts
import { createClient } from "@/lib/supabase/server";
import { cookies } from "next/headers";

// Re-export for backward compatibility
export { CONFIG, generatePath } from "./mixed-constants";

export async function uploadFile(file: File) {
  // Server logic here
}

export function setSessionCookie(token: string) {
  cookies().set(CONFIG.COOKIE_NAME, token);
}

// Step 3: Update client component imports
// Before: import { CONFIG, generatePath } from "@/lib/mixed";
// After: import { CONFIG, generatePath } from "@/lib/mixed-constants";
```

### Validation After Migration
```bash
# Check that all imports resolve correctly
npm run build

# Test both client and server components
npm run dev

# Check for any remaining mixed imports
grep -r "import.*from.*server" src/ --include="*.tsx" --include="*.ts"
```

## Advanced Patterns

### Pattern 1: Utility Index Files
```typescript
// ✅ GOOD - Clean import paths with index files
// lib/utils/index.ts
export { validateImageFile } from "./validation";
export { formatDate, formatFileSize } from "./formatting";
export { generateId } from "./helpers";

// lib/utils/validation.ts
export function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// lib/utils/formatting.ts
export function formatDate(date: Date): string {
  return date.toLocaleDateString();
}

// lib/utils/helpers.ts
export function generateId(): string {
  return Math.random().toString(36).substr(2, 9);
}
```

### Pattern 2: Type-Only Utilities
```typescript
// ✅ GOOD - Type-only files for shared definitions
// lib/types/common-types.ts

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    code?: string;
  };
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  meta?: {
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}

export interface FilterOptions {
  search?: string;
  category?: string;
  dateRange?: {
    from: string;
    to: string;
  };
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}
```

### Pattern 3: Error Handling Utilities
```typescript
// ✅ GOOD - Error handling separation
// lib/errors/constants.ts
export const ERROR_CODES = {
  VALIDATION_ERROR: "VALIDATION_ERROR",
  NOT_FOUND: "NOT_FOUND",
  UNAUTHORIZED: "UNAUTHORIZED",
  SERVER_ERROR: "SERVER_ERROR"
} as const;

export interface AppError {
  code: string;
  message: string;
  details?: any;
  statusCode: number;
}

export function createError(
  code: string,
  message: string,
  details?: any,
  statusCode: number = 500
): AppError {
  return {
    code,
    message,
    details,
    statusCode
  };
}

// lib/errors/handlers.ts
import { createError, ERROR_CODES } from "./constants";

export function handleDatabaseError(error: any): AppError {
  console.error("Database error:", error);

  if (error.code === "P2002") {
    return createError(
      ERROR_CODES.VALIDATION_ERROR,
      "Duplicate entry",
      { field: error.details },
      409
    );
  }

  return createError(
    ERROR_CODES.SERVER_ERROR,
    "Database operation failed",
    error,
    500
  );
}
```

## Validation Checklist
- [ ] Files with server-side imports do not export client-needed constants directly
- [ ] Constants and pure utilities are in separate `-constants.ts` files
- [ ] Client components only import from client-safe files
- [ ] Server-side files re-export from constants files for backward compatibility
- [ ] All imports resolve correctly after separation
- [] File naming follows established conventions
- [ ] Import paths are clear and consistent
- [ ] No circular dependencies exist between files
- [ ] Build process completes without server/client boundary errors

## Enforcement
This rule is enforced through:
- ESLint rules to detect mixed imports
- Build-time validation for Next.js server/client boundaries
- Code review validation
- TypeScript compilation checks
- Automated testing for import resolution
- Pre-commit hooks to prevent mixed utility files

By maintaining clear separation between server-side and client-safe utilities, we prevent build errors, improve maintainability, and ensure clean architecture boundaries in Next.js applications.