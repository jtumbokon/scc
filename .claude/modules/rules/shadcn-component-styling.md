---
id: rule-019
type: rule
version: 1.0.0
description: Style shadcn components at the source using CVA variants, not at call-site with arbitrary Tailwind classes
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# shadcn Component Styling Rule (rule-019)

## Purpose
Shadcn UI components under `@/components/ui` (import alias `@/ui`) expose **variants** and **sizes** via `class-variance-authority` (CVA). These centralize Tailwind classes so every instance stays visually consistent and updates propagate everywhere.

Ad-hoc Tailwind classes added directly at the usage site (e.g., via `className` on `<Button>` or `<Sheet>`) quickly become un-tracked one-offs, defeating the design system and bloating markup.

## Requirements

### MUST (Critical)
- **Do not** tack on arbitrary Tailwind classes via `className` when using any component from `@/ui`
- **Use documented variants, sizes, or other props** when the desired look already exists
- **Extend component CVA declarations** in source files when new styling is needed
- **Keep call-sites clean** by using proper prop values instead of inline classes

### SHOULD (Important)
- **Define new variants** in the component's CVA declaration (e.g., `buttonVariants`) when adding new styles
- **Adjust default styles** inside the source file when component-wide changes are needed
- **Use semantic naming** for new variants that clearly describes their purpose
- **Maintain consistency** with existing variant patterns

### MAY (Optional)
- **Create size variants** for components that need different scales
- **Add state variants** (hover, focus, disabled) when needed
- **Use composition** for complex styling requirements

## Examples

### ❌ Bad: Inline styling at call-site
```tsx
<Button
  variant="outline"
  className="hidden sm:inline-flex bg-white/90 dark:bg-gray-800/80 text-gray-900 dark:text-gray-100 border-gray-300 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700"
>
  Save
</Button>
```

### ✅ Good: Centralized styling with variants
```tsx
// In components/ui/button.tsx - add new variant:
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variant: {
      default: "bg-primary text-primary-foreground hover:bg-primary/90",
      destructive:
        "bg-destructive text-destructive-foreground hover:bg-destructive/90",
      outline:
        "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
      secondary:
        "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground",
      link: "text-primary underline-offset-4 hover:underline",
      // New variant added here
      outlineMuted: "hidden sm:inline-flex bg-white/90 dark:bg-gray-800/80 text-gray-900 dark:text-gray-100 border-gray-300 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700",
    },
    size: {
      default: "h-10 px-4 py-2",
      sm: "h-9 rounded-md px-3",
      lg: "h-11 rounded-md px-8",
      icon: "h-10 w-10",
    },
  }
);

// Then consume it uniformly:
<Button variant="outlineMuted">Save</Button>
```

## Component Extension Patterns

### Adding New Variants
```typescript
// components/ui/card.tsx
import { cva, type VariantProps } from "class-variance-authority";

const cardVariants = cva(
  "rounded-lg border bg-card text-card-foreground shadow-sm",
  {
    variant: {
      default: "border-border",
      elevated: "border-border shadow-lg",
      flat: "border-transparent shadow-none bg-background/50",
      // New variant for specific use case
      interactive: "cursor-pointer hover:shadow-md hover:border-primary/50 transition-all duration-200",
    },
  }
);

export interface CardProps extends React.HTMLAttributes<HTMLDivElement>,
  VariantProps<typeof cardVariants> {}

const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(cardVariants({ variant, className }))}
      {...props}
    />
  )
);

Card.displayName = "Card";

// Usage:
// <Card variant="interactive">...</Card>
```

### Adding Size Variants
```typescript
// components/ui/badge.tsx
const badgeVariants = cva(
  "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
  {
    variant: {
      default:
        "border-transparent bg-primary text-primary-foreground hover:bg-primary/80",
      secondary:
        "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
      destructive:
        "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
      outline: "text-foreground",
    },
    size: {
      default: "px-2.5 py-0.5 text-xs",
      // New size variants
      sm: "px-2 py-0.5 text-[10px]",
      lg: "px-4 py-1 text-sm",
    },
  }
);

// Usage:
// <Badge variant="secondary" size="lg">Large Badge</Badge>
```

### State Variants
```typescript
// components/ui/button.tsx
const buttonVariants = cva(
  // ... base classes
  {
    variant: {
      // ... existing variants
      // New state variant
      loading: "opacity-75 cursor-not-allowed",
    },
    // State modifiers
    state: {
      loading: "opacity-50 cursor-not-allowed",
      disabled: "opacity-50 cursor-not-allowed pointer-events-none",
    },
  }
);

// Usage:
// <Button variant="outline" state="loading">Loading...</Button>
```

## Complex Styling Scenarios

### Component Composition
```typescript
// When you need complex styling, compose components instead of adding classes
const StyledCard = ({ children, className, ...props }) => (
  <Card className="p-6">
    <div className={cn("space-y-4", className)}>
      {children}
    </div>
  </Card>
);

// Usage:
// <StyledCard className="bg-blue-50">...</StyledCard>
```

### Conditional Variants
```typescript
// components/ui/alert.tsx
const alertVariants = cva(
  "relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground",
  {
    variant: {
      default: "bg-background text-foreground",
      destructive:
        "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive",
      warning:
        "border-warning/50 text-warning dark:border-warning [&>svg]:text-warning",
      success:
        "border-success/50 text-success dark:border-success [&>svg]:text-success",
    },
  }
);

// Usage with conditional logic:
function Alert({ variant, children, ...props }) {
  const alertVariant = isError ? "destructive" : isSuccess ? "success" : "default";
  return (
    <div className={cn(alertVariants({ variant: alertVariant }))} {...props}>
      {children}
    </div>
  );
}
```

## Integration with Design System

### Theme Integration
```typescript
// components/ui/dialog.tsx
const dialogVariants = cva(
  "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=open]:slide-in-from-left-1/2 sm:rounded-lg md:w-full",
  {
    size: {
      default: "max-w-lg",
      sm: "max-w-sm",
      md: "max-w-2xl",
      lg: "max-w-4xl",
      full: "max-w-[calc(100vw-2rem)] h-[calc(100vh-2rem)]",
    },
  }
);

// Usage:
// <Dialog size="lg">Large Dialog</Dialog>
```

### Responsive Variants
```typescript
// components/ui/navigation-menu.tsx
const navigationMenuTriggerStyle = cva(
  "group inline-flex h-10 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground focus:outline-none disabled:pointer-events-none disabled:opacity-50 data-[active]:bg-accent/50 data-[state=open]:bg-accent/50",
  {
    variant: {
      default: "",
      // Responsive variant that shows/hides based on screen size
      responsive: "hidden md:flex",
      mobile: "flex md:hidden",
    },
  }
);

// Usage:
// <NavigationMenuTrigger variant="responsive">Menu</NavigationMenuTrigger>
```

## Migration Guide

### Step 1: Identify Inline Styling
```bash
# Find components with inline classes
grep -r "className.*bg-\|text-\|border-" src/components --include="*.tsx"
```

### Step 2: Analyze Usage Patterns
For each instance, determine:
- Is this a one-off or repeated pattern?
- Does this deserve a new variant?
- Can this be achieved with existing variants?

### Step 3: Create New Variants
```typescript
// In the component file, add new variant
const componentVariants = cva(baseClasses, {
  variant: {
    // existing variants...
    // Add new variant based on inline usage
    customVariant: "inline-classes-here",
  },
});
```

### Step 4: Update Call Sites
```typescript
// Replace
<Component className="inline-classes-here" />

// With
<Component variant="customVariant" />
```

## Validation Checklist
- [ ] No arbitrary Tailwind classes added via `className` on shadcn components
- [ ] New styling needs are addressed by extending component CVA declarations
- [ ] Call-sites remain clean with semantic prop values
- [ ] Variants are properly named and documented
- [ ] Component source files are updated instead of adding wrapper complexity
- [ ] Consistent styling patterns maintained across the application

## Enforcement
This rule is enforced through:
- Code review validation
- Component library audits
- ESLint rules for className usage
- Design system compliance checks
- Automated testing for component variants

Centralized styling through CVA variants ensures design consistency, maintainability, and easy updates across the entire application.