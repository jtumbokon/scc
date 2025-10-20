---
id: rule-013
type: rule
version: 1.0.0
description: Prefer shadcn/ui components over custom or third-party alternatives for consistency, accessibility, and theming
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Prefer shadcn Components Rule (rule-013)

## Purpose
shadcn/ui provides a comprehensive collection of beautifully designed, accessible, and fully-featured React components. These components are built on top of Radix UI primitives and styled with Tailwind CSS, ensuring consistency, accessibility, and proper theming integration.

Building custom components or importing third-party libraries when shadcn/ui equivalents exist leads to:
- **Inconsistent design** that doesn't follow the established design system
- **Missing accessibility features** that shadcn components provide by default
- **Theming conflicts** that don't integrate with the project's dark/light mode
- **Duplicate functionality** that increases bundle size and maintenance overhead
- **Lost integration benefits** like proper CSS variable usage and responsive design

## Requirements

### MUST (Critical)
- **Always check shadcn/ui first** before implementing custom UI components or importing third-party UI libraries
- **Use shadcn components** for all common UI patterns: buttons, cards, dialogs, forms, navigation, layouts, feedback, data display
- **Install missing shadcn components** using `npx shadcn@latest add <component>` rather than building custom alternatives
- **Never build custom components** when shadcn/ui provides equivalent functionality

### SHOULD (Important)
- **When a third-party library is needed** (e.g., for specialized functionality), check if shadcn provides an integrated wrapper first
- **Prefer shadcn wrappers** like sonner over direct third-party library usage
- **Extend shadcn components** through composition rather than inheritance
- **Follow shadcn patterns** when creating custom variants or extensions

### MAY (Optional)
- **Build custom components** only when shadcn/ui genuinely lacks the required functionality and no suitable alternative exists
- **Create specialized components** that compose multiple shadcn components for specific use cases

## Available shadcn/ui Components

### Feedback & Communication
- `alert` - Alert messages and notifications
- `toast` - Toast notifications (wraps sonner with theming)
- `sonner` - Advanced toast notifications with full theming
- `alert-dialog` - Confirmation and alert dialogs
- `dialog` - Modal dialogs and overlays

### Forms & Input
- `button` - All button variants and states
- `input` - Text inputs with proper styling
- `textarea` - Multi-line text input
- `select` - Dropdown selection
- `checkbox` - Checkbox inputs
- `label` - Form labels

### Layout & Navigation
- `card` - Content containers
- `sheet` - Slide-out panels and drawers
- `sidebar` - Navigation sidebars
- `breadcrumb` - Navigation breadcrumbs
- `separator` - Visual dividers

### Data Display
- `badge` - Status indicators and labels
- `progress` - Progress bars
- `skeleton` - Loading placeholders
- `table` - Data tables

## Examples

### Toast Notifications
| ❌ Bad (custom/third-party) | ✅ Good (shadcn/ui) |
|---|---|
| ```tsx
// Custom toast implementation
import toast from 'react-hot-toast';
toast.success('Success!');
``` | ```tsx
// Use shadcn's sonner integration
import { toast } from "sonner";
toast.success('Success!');
// + Add <Toaster /> from @/components/ui/sonner to layout
``` |

### Modal Dialogs
| ❌ Bad (custom/third-party) | ✅ Good (shadcn/ui) |
|---|---|
| ```tsx
// Third-party modal library
import Modal from 'react-modal';
<Modal isOpen={open}>Content</Modal>
``` | ```tsx
// Use shadcn dialog
import { Dialog, DialogContent } from "@/components/ui/dialog";
<Dialog open={open}>
  <DialogContent>Content</DialogContent>
</Dialog>
``` |

### Buttons
| ❌ Bad (custom component) | ✅ Good (shadcn/ui) |
|---|---|
| ```tsx
// Custom button component
const CustomButton = ({ children, variant, ...props }) => (
  <button className={`btn ${variant}`} {...props}>
    {children}
  </button>
);
``` | ```tsx
// Use shadcn button
import { Button } from "@/components/ui/button";
<Button variant="outline">Click me</Button>
``` |

### Cards
| ❌ Bad (custom layout) | ✅ Good (shadcn/ui) |
|---|---|
| ```tsx
// Building custom card layout
<div className="border rounded-lg p-4 shadow">
  <h3 className="font-bold">Title</h3>
  <p>Content</p>
</div>
``` | ```tsx
// Use shadcn card
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>Content</CardContent>
</Card>
``` |

### Form Elements
| ❌ Bad (custom form) | ✅ Good (shadcn/ui) |
|---|---|
| ```tsx
// Custom form styling
<form className="space-y-4">
  <div>
    <label className="block text-sm font-medium">Name</label>
    <input type="text" className="mt-1 block w-full border rounded" />
  </div>
</form>
``` | ```tsx
// Use shadcn form components
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
<form className="space-y-4">
  <div>
    <Label htmlFor="name">Name</Label>
    <Input id="name" type="text" />
  </div>
</form>
``` |

## Integration Benefits

Using shadcn/ui components provides automatic:

### Theme Integration
- Respects light/dark mode settings
- Uses CSS variables for consistent theming
- Follows project color scheme automatically

### Accessibility
- ARIA labels and attributes built-in
- Keyboard navigation support
- Screen reader compatibility
- Focus management

### Type Safety
- Full TypeScript definitions
- IntelliSense support
- Component prop validation
- Autocomplete in IDE

### Consistency
- Unified design language
- Consistent spacing and sizing
- Standardized interaction patterns
- Cohesive visual hierarchy

## Installation and Setup

### Adding Components
```bash
# Install individual components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog

# Install multiple components
npx shadcn@latest add button card dialog input label
```

### Required Setup
```tsx
// Add to layout.tsx for toast notifications
import { Toaster } from "@/components/ui/sonner";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Toaster />
      </body>
    </html>
  );
}
```

## Component Customization

### Extending Through Composition
```tsx
// ✅ Good - Compose shadcn components
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

function CustomCard({ title, actions, children }: CustomCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <div className="flex gap-2">
          {actions.map((action) => (
            <Button key={action.id} variant="outline" size="sm">
              {action.label}
            </Button>
          ))}
        </div>
      </CardHeader>
      <CardContent>{children}</CardContent>
    </Card>
  );
}
```

### Custom Variants
```tsx
// ✅ Good - Use Tailwind classes with shadcn components
import { Button } from "@/components/ui/button";

function CustomButton({ variant = "default", ...props }) {
  return (
    <Button
      variant={variant}
      className="bg-gradient-to-r from-blue-500 to-purple-600"
      {...props}
    />
  );
}
```

## Third-Party Integration Patterns

### When Third-Party Libraries Are Necessary
```tsx
// ✅ Good - Wrap third-party in shadcn styling
import { Chart as ChartJS } from 'chart.js/react';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

function ChartCard({ title, data }: ChartCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <ChartJS data={data} />
      </CardContent>
    </Card>
  );
}
```

### Specialized Functionality
```tsx
// ✅ Good - Use shadcn wrapper when available
import { toast } from "sonner"; // shadcn wrapper for react-hot-toast

// Instead of directly importing react-hot-toast
// import toast from 'react-hot-toast'; // ❌ Bad
```

## Validation Checklist
- [ ] Checked shadcn/ui for equivalent components before building custom
- [ ] Used `npx shadcn@latest add <component>` to install missing components
- [ ] Integrated components properly (e.g., Toaster in layout)
- [ ] Applied shadcn styling patterns and variants
- [ ] Maintained accessibility features provided by shadcn
- [ ] Used proper TypeScript types from shadcn components
- [ ] Followed shadcn composition patterns for custom components

## Enforcement
This rule is enforced through:
- Code review validation
- Component library audits
- Design system compliance checks
- Bundle size analysis for duplicate functionality

Using shadcn/ui components ensures a consistent, accessible, and maintainable user interface that integrates seamlessly with the project's design system.