---
id: rule-015
type: rule
version: 1.0.0
description: No inline styles - use cn() utility with conditional Tailwind classes for consistent styling
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No Inline Styles - Use cn() Utility Rule (rule-015)

## Purpose
Mixing `className` and `style` attributes creates inconsistent styling approaches and makes code harder to maintain. Inline styles bypass Tailwind's design system and can't benefit from its responsive breakpoints, dark mode variants, or other utilities.

When dynamic styling is needed (e.g., positioning based on component state), it's better to use conditional Tailwind classes with the `cn()` utility rather than inline styles.

## Requirements

### MUST (Critical)
- **Never use** inline `style` attributes alongside `className` in React components
- **Always use Tailwind classes** for styling instead of inline styles
- **Import cn utility** when conditional styling is needed
- **Maintain consistent styling approach** throughout the application

### SHOULD (Important)
- **Use Tailwind's arbitrary value syntax** for static calculated values
- **Use the `cn()` utility** with conditional Tailwind classes for dynamic/conditional values
- **Prefer semantic class names** over arbitrary values when possible
- **Leverage Tailwind's responsive variants** instead of inline media queries

### MAY (Optional)
- **Use CSS-in-JS libraries** only for truly complex animations that Tailwind cannot handle
- **Create custom Tailwind classes** in config for frequently used patterns

## Examples

### Basic Style Mixing
| ❌ Bad (mixed className + style) | ✅ Good (cn with conditional classes) |
|---|---|
| ```tsx
<div
  className="fixed bottom-0 right-0 z-50"
  style={{ left: leftPosition }}
>
``` | ```tsx
<div
  className={cn(
    "fixed bottom-0 right-0 z-50",
    isMobile ? "left-0" : state === "collapsed" ? "left-16" : "left-64"
  )}
>
``` |

### Calculated Values
| ❌ Bad (inline styles) | ✅ Good (Tailwind arbitrary values) |
|---|---|
| ```tsx
<div
  className="h-full w-full overflow-y-auto"
  style={{ paddingBottom: "calc(9rem + 2vh)" }}
>
``` | ```tsx
<div className="h-full w-full overflow-y-auto pb-[calc(9rem+2vh)]">
``` |

### Dynamic Positioning
| ❌ Bad (inline styles) | ✅ Good (conditional classes) |
|---|---|
| ```tsx
const leftPosition = isMobile ? "0" : state === "collapsed" ? "4rem" : "16rem";
<div style={{ left: leftPosition }} />
``` | ```tsx
<div
  className={cn(
    "base-classes",
    isMobile ? "left-0" : state === "collapsed" ? "left-16" : "left-64"
  )}
/>
``` |

## Common Patterns

### Conditional Visibility
```tsx
// ❌ Bad - using inline styles
<div
  className="base-component"
  style={{ display: isOpen ? "block" : "none" }}
>

// ✅ Good - using conditional classes
<div className={cn("base-component", isOpen ? "block" : "hidden")}>
```

### Dynamic Colors
```tsx
// ❌ Bad - using inline styles
<div
  className="p-4 rounded"
  style={{ backgroundColor: isError ? "#ef4444" : "#10b981" }}
>

// ✅ Good - using conditional classes
<div className={cn(
  "p-4 rounded",
  isError ? "bg-red-500" : "bg-green-500"
)}>
```

### Responsive Spacing
```tsx
// ❌ Bad - using inline styles
<div
  className="content"
  style={{ marginTop: isMobile ? "1rem" : "2rem" }}
>

// ✅ Good - using responsive classes
<div className={cn(
  "content",
  isMobile ? "mt-4" : "mt-8"
)}>
```

## Advanced Usage

### Complex State-Based Styling
```tsx
import { cn } from "@/lib/utils";

interface SidebarProps {
  isCollapsed: boolean;
  isMobile: boolean;
  isActive: boolean;
  theme: "light" | "dark";
}

export function Sidebar({ isCollapsed, isMobile, isActive, theme }: SidebarProps) {
  return (
    <aside className={cn(
      // Base styles
      "fixed left-0 top-0 h-screen bg-background border-r transition-all duration-300",

      // Position based on state
      isMobile ? (isActive ? "translate-x-0" : "-translate-x-full") : "translate-x-0",
      isCollapsed ? "w-16" : "w-64",

      // Theme variants
      theme === "dark" ? "border-gray-800" : "border-gray-200",

      // Interactive states
      isActive && "shadow-lg",
      !isCollapsed && "overflow-y-auto"
    )}>
      {/* Sidebar content */}
    </aside>
  );
}
```

### Animation Classes
```tsx
// ❌ Bad - inline animation styles
<div
  className="modal-backdrop"
  style={{
    opacity: isOpen ? 1 : 0,
    transform: isOpen ? "translateY(0)" : "translateY(-20px)",
    transition: "all 0.3s ease-in-out"
  }}
>

// ✅ Good - Tailwind animation classes
<div className={cn(
  "modal-backdrop transition-all duration-300 ease-in-out",
  isOpen ? "opacity-100 translate-y-0" : "opacity-0 -translate-y-5"
)}>
```

### Layout Grids
```tsx
// ❌ Bad - inline grid styles
<div
  className="grid-container"
  style={{
    display: "grid",
    gridTemplateColumns: `repeat(${columns}, 1fr)`,
    gap: "1rem"
  }}
>

// ✅ Good - Tailwind grid classes
<div className={cn(
  "grid gap-4",
  columns === 1 && "grid-cols-1",
  columns === 2 && "grid-cols-2",
  columns === 3 && "grid-cols-3",
  columns >= 4 && "grid-cols-4"
)}>
```

## Tailwind Arbitrary Value Syntax

### When to Use Arbitrary Values
- **Complex calculations**: `pb-[calc(9rem+2vh)]`
- **Custom values not in config**: `w-[137px]`
- **CSS functions**: `bg-gradient-to-r from-[#ff0000] to-[#00ff00]`
- **Custom properties**: `text-[var(--custom-color)]`

### Examples
```tsx
// Complex positioning
<div className="absolute top-[calc(100%-2rem)] left-1/2 -translate-x-1/2">

// Custom spacing
<div className="px-[13px] py-[7px]">

// Dynamic values (still using Tailwind)
<div className={`w-[${width}px] h-[${height}px]`}>

// Custom colors
<div className="bg-[#3b82f6] text-[#1e293b]">

// CSS custom properties
<div className="text-[var(--primary-color)] bg-[var(--bg-secondary)]">
```

## Component Libraries Integration

### shadcn/ui Components
```tsx
// ❌ Bad - overriding shadcn styles with inline styles
<Button
  className="btn-primary"
  style={{ backgroundColor: customColor, padding: "0.75rem" }}
>

// ✅ Good - using shadcn's className prop with cn
<Button
  className={cn(
    "btn-primary",
    customVariant && "btn-custom",
    size === "lg" && "px-6 py-3"
  )}
>
```

## CSS-in-JS Alternatives

### When CSS-in-JS Might Be Considered
- **Complex keyframe animations** not possible with Tailwind
- **Dynamic theming** based on user-generated colors
- **Mathematical calculations** that can't be expressed in CSS

### Even Then, Prefer:
```tsx
// ✅ Better - define custom animations in CSS
// animations.css
@keyframes slide-up {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}

// component.tsx
<div className="animate-[slide-up_0.3s_ease-in-out]">
```

## Migration Guide

### Converting Existing Inline Styles
```tsx
// ❌ Before
<div
  className="card"
  style={{
    backgroundColor: card.color,
    padding: "1rem",
    borderRadius: "0.5rem",
    boxShadow: "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
    transition: "all 0.2s ease"
  }}
>

// ✅ After
<div className={cn(
  "card p-4 rounded-lg shadow-md transition-all duration-200 ease-in-out",
  card.color === "primary" && "bg-blue-500",
  card.color === "secondary" && "bg-gray-500",
  card.color === "success" && "bg-green-500"
)}>
```

## Benefits of Using cn() with Tailwind

1. **Consistency** - All styling uses the same approach
2. **Responsiveness** - Built-in responsive variants
3. **Dark Mode** - Automatic dark mode support
4. **Performance** - PurgeCSS optimization
5. **Maintainability** - Clear, readable class names
6. **Team Collaboration** - Shared design language

## Validation Checklist
- [ ] No inline style attributes used with className
- [ ] All dynamic styling uses cn() utility
- [ ] Tailwind arbitrary values used for static calculations
- [ ] Conditional classes implemented for state-based styling
- [ ] shadcn/ui components extended through className prop only
- [ ] Consistent styling approach across components
- [ ] Responsive variants leveraged instead of inline media queries

## Enforcement
This rule is enforced through:
- Code review validation
- ESLint rules (`react-native/no-inline-styles`)
- Stylelint configuration
- Component library guidelines

Using cn() with conditional Tailwind classes ensures consistent styling, better maintainability, and full utilization of Tailwind CSS capabilities.