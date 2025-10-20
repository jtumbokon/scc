---
id: rule-029
type: rule
version: 1.0.0
description: No toast notifications in server actions - server actions must return structured responses for client-side UI feedback
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No Toast in Server Actions Rule (rule-029)

## Purpose
Server actions run on the server side and do not have access to the DOM or browser APIs. Using toast notifications (like `toast.error()`, `toast.success()`, etc.) from libraries such as `sonner` in server actions is architecturally incorrect and can cause runtime errors or silent failures.

Toast notifications require client-side execution to manipulate the DOM and show UI feedback to users. When called from server actions, these operations either fail silently or throw errors because browser APIs are not available on the server.

## Requirements

### MUST (Critical)
- **NEVER import toast libraries** (`sonner`, `react-hot-toast`, etc.) in files with `"use server"` directive
- **NEVER call** `toast.*()` methods in server actions or server-side functions
- **ALWAYS return** structured response objects from server actions with success/error states
- **PRESERVE error messages** in server action return values for client-side display
- **SEPARATE concerns** between server-side logic and client-side UI feedback

### SHOULD (Important)
- **Use TypeScript types** for server action responses to ensure type safety
- **Include field-level errors** for form validation feedback
- **Handle all error scenarios** in client components with appropriate toast notifications
- **Use structured response patterns** consistently across all server actions
- **Test error paths** to ensure proper client-side feedback

### MAY (Optional)
- **Include additional metadata** in server responses (timestamps, IDs, etc.)
- **Use different response types** for different operation categories
- **Create utility functions** for common server response patterns
- **Add logging** in server actions while preserving user-facing error messages

## Forbidden Patterns

### ❌ ALL FORMS ARE FORBIDDEN
```typescript
// ❌ FORBIDDEN - Toast imports in server actions
"use server";
import { toast } from "sonner";                    // ❌ FORBIDDEN
import { toast } from "react-hot-toast";            // ❌ FORBIDDEN

// ❌ FORBIDDEN - Toast calls in server actions
export async function createAction() {
  toast.success("Action completed!");               // ❌ FORBIDDEN
  toast.error("Something went wrong!");            // ❌ FORBIDDEN
  toast.info("Processing...");                      // ❌ FORBIDDEN
}

// ❌ FORBIDDEN - Conditional toast calls
export async function processData(data) {
  try {
    const result = await process(data);
    toast.success("Processed successfully!");        // ❌ FORBIDDEN
    return result;
  } catch (error) {
    toast.error(`Processing failed: ${error.message}`); // ❌ FORBIDDEN
    throw error;
  }
}
```

## Correct Architecture Pattern

### Server Action: Structured Responses
```typescript
// ✅ GOOD - Server action with structured response
"use server";

interface ServerResponse<T = void> {
  success: boolean;
  data?: T;
  error?: string;
  field?: string; // For form validation errors
  timestamp?: string;
}

export async function uploadFile(file: File): Promise<ServerResponse<{ url: string }>> {
  try {
    if (!file) {
      return {
        success: false,
        error: "No file provided",
        field: "file"
      };
    }

    // Validate file size
    if (file.size > 10 * 1024 * 1024) { // 10MB
      return {
        success: false,
        error: "File size must be less than 10MB",
        field: "file"
      };
    }

    // Process upload
    const result = await storage.upload(file);

    return {
      success: true,
      data: { url: result.url },
      timestamp: new Date().toISOString()
    };

  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Upload failed"
    };
  }
}

export async function updateUserProfile(
  userId: string,
  data: { name: string; email: string }
): Promise<ServerResponse<User>> {
  try {
    // Validate input
    if (!data.name.trim()) {
      return {
        success: false,
        error: "Name is required",
        field: "name"
      };
    }

    if (!data.email.includes('@')) {
      return {
        success: false,
        error: "Invalid email address",
        field: "email"
      };
    }

    // Update user
    const updatedUser = await db.user.update({
      where: { id: userId },
      data: {
        name: data.name,
        email: data.email
      }
    });

    return {
      success: true,
      data: updatedUser
    };

  } catch (error) {
    // Check for unique constraint violation
    if (error.code === 'P2002') {
      return {
        success: false,
        error: "Email address is already in use",
        field: "email"
      };
    }

    return {
      success: false,
      error: "Failed to update profile"
    };
  }
}
```

### Client Component: Toast Handling
```typescript
// ✅ GOOD - Client component handles UI feedback
"use client";
import { toast } from "sonner";
import { uploadFile, updateUserProfile } from "@/app/actions";

export function FileUploader() {
  async function handleUpload(file: File) {
    // Show loading toast immediately
    const loadingToast = toast.loading("Uploading file...");

    try {
      const result = await uploadFile(file);

      // Dismiss loading toast
      toast.dismiss(loadingToast);

      if (result.success) {
        toast.success("File uploaded successfully!", {
          description: `File: ${file.name}`
        });

        // Handle success (update UI, redirect, etc.)
        console.log("Upload result:", result.data);
      } else {
        // Handle error with field-specific feedback
        toast.error(result.error || "Upload failed");

        if (result.field === "file") {
          // Focus on file input
          document.getElementById('file-input')?.focus();
        }
      }
    } catch (error) {
      toast.dismiss(loadingToast);
      toast.error("An unexpected error occurred");
      console.error("Upload error:", error);
    }
  }

  return (
    <div>
      <input
        id="file-input"
        type="file"
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) handleUpload(file);
        }}
      />
    </div>
  );
}

export function ProfileForm({ userId }: { userId: string }) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(formData: FormData) {
    setIsSubmitting(true);

    const data = {
      name: formData.get('name') as string,
      email: formData.get('email') as string
    };

    const result = await updateUserProfile(userId, data);

    if (result.success) {
      toast.success("Profile updated successfully!");
      // Update local state or redirect
    } else {
      toast.error(result.error || "Failed to update profile");

      // Focus on the problematic field
      if (result.field) {
        const fieldElement = document.getElementById(result.field) as HTMLInputElement;
        fieldElement?.focus();
        fieldElement?.select();
      }
    }

    setIsSubmitting(false);
  }

  return (
    <form action={handleSubmit}>
      <div>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          name="name"
          type="text"
          required
          disabled={isSubmitting}
        />
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          required
          disabled={isSubmitting}
        />
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Updating..." : "Update Profile"}
      </button>
    </form>
  );
}
```

## Advanced Response Patterns

### Pattern 1: Progress Updates
```typescript
// ✅ GOOD - Server action with progress tracking
"use server";

interface ProgressResponse {
  success: boolean;
  data?: {
    progress: number;
    total: number;
    current: string;
  };
  error?: string;
}

export async function processLargeDataset(datasetId: string): Promise<ProgressResponse> {
  try {
    const dataset = await db.dataset.findUnique({ where: { id: datasetId } });
    if (!dataset) {
      return { success: false, error: "Dataset not found" };
    }

    const totalItems = dataset.itemCount;
    let processedItems = 0;

    // Process in batches
    for (let i = 0; i < totalItems; i += 100) {
      const batch = await db.datasetItem.findMany({
        where: { datasetId },
        skip: i,
        take: 100
      });

      // Process batch
      await processBatch(batch);
      processedItems += batch.length;

      // Return progress update
      return {
        success: true,
        data: {
          progress: Math.round((processedItems / totalItems) * 100),
          total: totalItems,
          current: `Processed ${processedItems} of ${totalItems} items`
        }
      };
    }

    return {
      success: true,
      data: {
        progress: 100,
        total: totalItems,
        current: "Processing complete"
      }
    };

  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Processing failed"
    };
  }
}

// Client component with progress feedback
export function DatasetProcessor({ datasetId }: { datasetId: string }) {
  const [progress, setProgress] = useState(0);
  const [currentStatus, setCurrentStatus] = useState("");

  async function startProcessing() {
    const loadingToast = toast.loading("Starting dataset processing...");

    try {
      // Poll for progress updates
      const pollProgress = async () => {
        const result = await processLargeDataset(datasetId);

        if (result.success && result.data) {
          setProgress(result.data.progress);
          setCurrentStatus(result.data.current);

          if (result.data.progress < 100) {
            setTimeout(pollProgress, 1000); // Poll every second
          } else {
            toast.dismiss(loadingToast);
            toast.success("Dataset processing complete!");
          }
        } else {
          toast.dismiss(loadingToast);
          toast.error(result.error || "Processing failed");
        }
      };

      await pollProgress();

    } catch (error) {
      toast.dismiss(loadingToast);
      toast.error("An unexpected error occurred");
    }
  }

  return (
    <div>
      <button onClick={startProcessing}>Start Processing</button>
      {progress > 0 && (
        <div>
          <div>Progress: {progress}%</div>
          <div>{currentStatus}</div>
        </div>
      )}
    </div>
  );
}
```

### Pattern 2: Batch Operations
```typescript
// ✅ GOOD - Batch operation with detailed results
"use server";

interface BatchResult<T> {
  success: boolean;
  results: Array<{
    id: string;
    success: boolean;
    data?: T;
    error?: string;
  }>;
  summary: {
    total: number;
    successful: number;
    failed: number;
  };
}

export async function batchUpdateUsers(
  updates: Array<{ id: string; data: any }>
): Promise<BatchResult<User>> {
  const results = [];
  let successful = 0;
  let failed = 0;

  for (const update of updates) {
    try {
      const result = await db.user.update({
        where: { id: update.id },
        data: update.data
      });

      results.push({
        id: update.id,
        success: true,
        data: result
      });
      successful++;

    } catch (error) {
      results.push({
        id: update.id,
        success: false,
        error: error instanceof Error ? error.message : "Update failed"
      });
      failed++;
    }
  }

  return {
    success: failed === 0,
    results,
    summary: {
      total: updates.length,
      successful,
      failed
    }
  };
}

// Client component handles batch results
export function BatchUserUpdater() {
  async function handleBatchUpdate(updates: Array<{ id: string; data: any }>) {
    const loadingToast = toast.loading("Updating users...");

    try {
      const result = await batchUpdateUsers(updates);
      toast.dismiss(loadingToast);

      if (result.success) {
        toast.success(`Successfully updated ${result.summary.successful} users`);
      } else {
        // Show detailed results
        const failedUpdates = result.results.filter(r => !r.success);

        toast.error(`Failed to update ${failedUpdates.length} users`, {
          description: failedUpdates.map(f => f.error).join("; "),
          duration: 10000
        });

        // Log detailed results for debugging
        console.error("Batch update failures:", failedUpdates);
      }

    } catch (error) {
      toast.dismiss(loadingToast);
      toast.error("Batch update failed");
    }
  }

  return (
    <div>
      {/* Batch update interface */}
    </div>
  );
}
```

### Pattern 3: File Upload with Multiple Steps
```typescript
// ✅ GOOD - Multi-step process with structured feedback
"use server";

interface MultiStepResponse {
  success: boolean;
  step?: 'validation' | 'upload' | 'processing' | 'complete';
  data?: {
    fileId?: string;
    processingResults?: any;
  };
  error?: string;
  warnings?: string[];
}

export async function processUploadedFile(file: File): Promise<MultiStepResponse> {
  const warnings: string[] = [];

  try {
    // Step 1: Validation
    if (!file.name.endsWith('.csv')) {
      return {
        success: false,
        error: "Only CSV files are supported",
        step: 'validation'
      };
    }

    if (file.size > 50 * 1024 * 1024) { // 50MB
      return {
        success: false,
        error: "File size must be less than 50MB",
        step: 'validation'
      };
    }

    // Step 2: Upload
    const uploadResult = await storage.upload(file);

    // Step 3: Processing
    const processingResults = await processCSVFile(uploadResult.url);

    if (processingResults.warnings) {
      warnings.push(...processingResults.warnings);
    }

    return {
      success: true,
      step: 'complete',
      data: {
        fileId: uploadResult.id,
        processingResults: processingResults.data
      },
      warnings: warnings.length > 0 ? warnings : undefined
    };

  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Processing failed"
    };
  }
}

// Client component with step-by-step feedback
export function FileProcessor() {
  async function handleFileUpload(file: File) {
    try {
      const result = await processUploadedFile(file);

      if (result.success) {
        if (result.warnings && result.warnings.length > 0) {
          toast.success("File processed successfully", {
            description: `Warnings: ${result.warnings.join(", ")}`,
            duration: 8000
          });
        } else {
          toast.success("File processed successfully!");
        }

        // Handle successful processing
        console.log("Processing results:", result.data);
      } else {
        // Provide step-specific error messages
        const stepMessages = {
          validation: "File validation failed",
          upload: "File upload failed",
          processing: "File processing failed"
        };

        toast.error(stepMessages[result.step!] || result.error!, {
          description: result.error
        });
      }

    } catch (error) {
      toast.error("File processing failed");
      console.error("Processing error:", error);
    }
  }

  return (
    <div>
      <input
        type="file"
        accept=".csv"
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) handleFileUpload(file);
        }}
      />
    </div>
  );
}
```

## TypeScript Response Types

### Standard Response Types
```typescript
// ✅ GOOD - Reusable response type definitions

// Basic success/error response
export type ActionResult<T = void> =
  | { success: true; data?: T }
  | { success: false; error: string };

// Response with field-level validation
export type ValidationActionResponse<T = void> =
  | { success: true; data?: T }
  | { success: false; error: string; field?: string };

// Response with multiple error messages
export type MultiErrorActionResponse<T = void> =
  | { success: true; data?: T }
  | { success: false; errors: string[] };

// Response with metadata
export type DetailedActionResponse<T = void> =
  | { success: true; data?: T; metadata?: Record<string, any> }
  | { success: false; error: string; metadata?: Record<string, any> };

// Generic server action wrapper
export function createServerAction<T>(
  action: (...args: any[]) => Promise<ActionResult<T>>
) {
  return action;
}

// Usage examples
export const createUser = createServerAction(async (userData: CreateUserInput) => {
  // Implementation
});

export const validateForm = createServerAction(async (formData: FormData) => {
  // Implementation
});
```

## Error Handling Best Practices

### Server-Side Error Handling
```typescript
// ✅ GOOD - Comprehensive server-side error handling
"use server";

async function safeDatabaseOperation<T>(
  operation: () => Promise<T>,
  errorMessage: string = "Operation failed"
): Promise<ActionResult<T>> {
  try {
    const result = await operation();
    return { success: true, data: result };
  } catch (error) {
    // Handle specific database errors
    if (error.code === 'P2002') {
      return {
        success: false,
        error: "A record with this value already exists"
      };
    }

    if (error.code === 'P2025') {
      return {
        success: false,
        error: "Record not found"
      };
    }

    // Log detailed error for debugging
    console.error("Database operation failed:", error);

    // Return user-friendly error
    return {
      success: false,
      error: errorMessage
    };
  }
}

export async function updateUserRole(
  userId: string,
  newRole: string
): Promise<ActionResult<User>> {
  return safeDatabaseOperation(
    () => db.user.update({
      where: { id: userId },
      data: { role: newRole }
    }),
    "Failed to update user role"
  );
}
```

### Client-Side Error Boundaries
```typescript
// ✅ GOOD - Client-side error handling with user feedback
"use client";
import { toast } from "sonner";

export function useServerAction<T>() {
  const [isPending, setIsPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const execute = useCallback(async (
    action: () => Promise<ActionResult<T>>,
    options: {
      successMessage?: string;
      errorMessage?: string;
      onSuccess?: (data: T) => void;
      onError?: (error: string) => void;
    } = {}
  ) => {
    setIsPending(true);
    setError(null);

    try {
      const result = await action();

      if (result.success) {
        if (options.successMessage) {
          toast.success(options.successMessage);
        }
        if (options.onSuccess && result.data) {
          options.onSuccess(result.data);
        }
      } else {
        setError(result.error);
        toast.error(options.errorMessage || result.error);
        if (options.onError) {
          options.onError(result.error);
        }
      }
    } catch (error) {
      const errorMessage = "An unexpected error occurred";
      setError(errorMessage);
      toast.error(errorMessage);
      console.error("Server action error:", error);
    } finally {
      setIsPending(false);
    }
  }, []);

  return { execute, isPending, error };
}

// Usage
export function UserProfile({ userId }: { userId: string }) {
  const { execute, isPending, error } = useServerAction();

  const handleRoleChange = async (newRole: string) => {
    await execute(
      () => updateUserRole(userId, newRole),
      {
        successMessage: "User role updated successfully",
        errorMessage: "Failed to update user role"
      }
    );
  };

  return (
    <div>
      <select
        onChange={(e) => handleRoleChange(e.target.value)}
        disabled={isPending}
      >
        <option value="user">User</option>
        <option value="admin">Admin</option>
      </select>
      {error && <div className="error">{error}</div>}
    </div>
  );
}
```

## Migration Guide

### Converting Existing Server Actions
```typescript
// ❌ BEFORE - Toast in server action
"use server";
import { toast } from "sonner";

export async function createPost(data: FormData) {
  try {
    const post = await db.post.create({
      data: {
        title: data.get('title'),
        content: data.get('content')
      }
    });

    toast.success("Post created successfully!");
    return { success: true, post };
  } catch (error) {
    toast.error("Failed to create post");
    return { success: false };
  }
}

// ✅ AFTER - Structured response
"use server";

export async function createPost(data: FormData): Promise<ActionResult<Post>> {
  try {
    const title = data.get('title') as string;
    const content = data.get('content') as string;

    if (!title.trim()) {
      return {
        success: false,
        error: "Title is required",
        field: "title"
      };
    }

    const post = await db.post.create({
      data: { title, content }
    });

    return { success: true, data: post };
  } catch (error) {
    console.error("Failed to create post:", error);
    return {
      success: false,
      error: "Failed to create post"
    };
  }
}

// Client component handles UI feedback
"use client";
import { toast } from "sonner";
import { createPost } from "@/app/actions";

export function PostForm() {
  async function handleSubmit(formData: FormData) {
    const result = await createPost(formData);

    if (result.success) {
      toast.success("Post created successfully!");
      // Handle success (redirect, update UI, etc.)
    } else {
      toast.error(result.error);
      // Handle error (focus field, show validation, etc.)
    }
  }

  return <form action={handleSubmit}>{/* form fields */}</form>;
}
```

## Validation Checklist
- [ ] No toast library imports in files with `"use server"` directive
- [ ] No `toast.*()` method calls in server actions
- [ ] All server actions return structured response objects
- [ ] Error messages are preserved in server responses
- [ ] Client components handle server action responses with toast notifications
- [ ] TypeScript types are used for server action responses
- [ ] Form validation errors include field information
- [ ] Loading states are handled appropriately in client components
- [ ] Error scenarios are tested with proper UI feedback
- [ ] Server-side logging doesn't expose sensitive information

## Enforcement
This rule is enforced through:
- ESLint rules to detect toast imports in server actions
- Build-time validation of server action files
- Code review validation
- TypeScript compilation checks
- Automated testing for server action response patterns
- Architecture validation tools

By maintaining proper separation between server-side logic and client-side UI feedback, we prevent runtime errors, maintain clean architecture, and ensure reliable user experience across all server operations.