---
id: template-001
type: template
version: 1.0.0
description: Standard component structure template for React/Next.js components
parents: [CLAUDE.md]
children: []
auto_cascade: conditional
last_updated: 2025-10-19
---

# Component Template (template-001)

## Purpose
Provides a standardized structure for creating React/Next.js components with proper TypeScript typing, accessibility, and best practices.

## Template Structure

### Basic Component Template
```typescript
// src/components/[component-name]/[component-name].tsx
'use client';

import React from 'react';
import { cn } from '@/lib/utils';

interface [ComponentName]Props {
  className?: string;
  children?: React.ReactNode;
  // Add specific props here
}

export const [ComponentName]: React.FC<[ComponentName]Props> = ({
  className,
  children,
  // Add specific props here
}) => {
  return (
    <div className={cn('base-component-styles', className)}>
      {children}
    </div>
  );
};

export default [ComponentName];
```

### Component with State Template
```typescript
// src/components/[component-name]/[component-name].tsx
'use client';

import React, { useState, useEffect } from 'react';
import { cn } from '@/lib/utils';

interface [ComponentName]Props {
  className?: string;
  initialData?: any;
  onStateChange?: (state: any) => void;
}

export const [ComponentName]: React.FC<[ComponentName]Props> = ({
  className,
  initialData,
  onStateChange,
}) => {
  const [state, setState] = useState(initialData || {});

  useEffect(() => {
    onStateChange?.(state);
  }, [state, onStateChange]);

  return (
    <div className={cn('base-component-styles', className)}>
      {/* Component content */}
    </div>
  );
};

export default [ComponentName];
```

### Form Component Template
```typescript
// src/components/[component-name]/[component-name].tsx
'use client';

import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { cn } from '@/lib/utils';

// Define form schema
const formSchema = z.object({
  // Add form fields here
});

type FormData = z.infer<typeof formSchema>;

interface [ComponentName]Props {
  className?: string;
  onSubmit: (data: FormData) => void;
  initialData?: Partial<FormData>;
}

export const [ComponentName]: React.FC<[ComponentName]Props> = ({
  className,
  onSubmit,
  initialData,
}) => {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: initialData,
  });

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className={cn('form-component-styles', className)}
    >
      {/* Form fields */}
      <button
        type="submit"
        disabled={isSubmitting}
        className="submit-button"
      >
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
};

export default [ComponentName];
```

## Usage Instructions

### 1. Replace Placeholders
- `[ComponentName]` → Your component name (PascalCase)
- `[component-name]` → Your component name (kebab-case)

### 2. Add Props Interface
Define TypeScript interface for your component props with proper typing.

### 3. Add Styling
Use Tailwind CSS classes or CSS modules for styling.

### 4. Add Accessibility
Include proper ARIA labels, semantic HTML, and keyboard navigation.

### 5. Add Tests
Create test files using the test template.

## Integration Points

### Dependencies
- React 18+
- TypeScript
- Tailwind CSS (recommended)
- React Hook Form (for forms)
- Zod (for validation)

### Tool Integration
- ESLint for code quality
- Prettier for formatting
- Jest for testing
- Storybook for documentation

## Best Practices Included

1. **TypeScript Support**: Full typing with interfaces
2. **Accessibility**: Semantic HTML and ARIA support
3. **Performance**: Proper memoization when needed
4. **Styling**: Consistent styling approach
5. **Error Handling**: Proper error boundaries
6. **Testing**: Test-ready structure

---

**This template ensures consistent, high-quality component creation across the entire application.**