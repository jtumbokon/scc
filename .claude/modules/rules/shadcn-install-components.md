---
id: rule-039
type: rule
version: 1.0.0
description: Install shadcn components using npx shadcn@latest add for consistent, up-to-date installations
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# shadcn Install Components Rule (rule-039)

## Purpose
The Shadcn UI library provides a CLI that scaffolds fully typed, theme-aware React components into a project. Using the **latest** CLI version ensures you always get the most up-to-date markup, styling, and TypeScript definitions.

Historically, multiple command variants have appeared in blog posts (e.g. `npx shadcn-ui`, `pnpm dlx shadcn`). These are **deprecated or inconsistent** and cause confusion.

## Requirements

### MUST (Critical)
- **ALWAYS use exact command format**: `npx shadcn@latest add <component>`
- **NEVER use alternative installers** (`pnpm dlx`, `yarn dlx`, global installs, etc.)
- **REPLACE `<component>`** with actual component name in concrete examples
- **USE `@latest` tag** to ensure most recent version

### SHOULD (Important)
- **INSTALL one component at a time** for better error handling
- **CHECK component availability** before suggesting installation
- **VERIFY project setup** (components.json exists) before installation
- **USE proper component names** matching shadcn registry

### MAY (Optional)
- **INSTALL multiple components** with space-separated list after `add`
- **CUSTOMIZE installation options** when needed (e.g., `--overwrite`)
- **CHECK for conflicts** with existing components
- **DOCUMENT customizations** for team reference

## Correct Command Format

### Standard Installation
```bash
npx shadcn@latest add <component>
```

### Multiple Components
```bash
npx shadcn@latest add button card input
```

### With Options
```bash
npx shadcn@latest add button --overwrite
```

## Examples

### ✅ Correct Commands
| Component | Correct Command |
|-----------|----------------|
| Button | `npx shadcn@latest add button` |
| Card | `npx shadcn@latest add card` |
| Alert | `npx shadcn@latest add alert` |
| Form | `npx shadcn@latest add form` |
| Multiple | `npx shadcn@latest add button card input` |

### ❌ Incorrect Commands (Deprecated)
| Incorrect Command | Why It's Wrong |
|------------------|----------------|
| `npx shadcn-ui add button` | Uses old package name |
| `pnpm dlx shadcn add card` | Wrong package manager |
| `yarn dlx shadcn@latest add alert` | Wrong package manager |
| `npx shadcn add input` | Missing `@latest` tag |
| `shadcn add button` | Assumes global install |

## Component Installation Workflow

### Step 1: Verify Project Setup
```bash
# Check if components.json exists
cat components.json

# If not exists, initialize shadcn
npx shadcn@latest init
```

### Step 2: Install Component
```bash
# Install single component
npx shadcn@latest add button

# Install multiple components
npx shadcn@latest add button card input
```

### Step 3: Verify Installation
```bash
# Check component files
ls -la components/ui/button.tsx
ls -la components/ui/card.tsx

# Check components.json updates
cat components.json
```

## Common Components

### Form Components
```bash
npx shadcn@latest add input
npx shadcn@latest add label
npx shadcn@latest add textarea
npx shadcn@latest add select
npx shadcn@latest add checkbox
npx shadcn@latest add radio-group
npx shadcn@latest add switch
```

### Layout Components
```bash
npx shadcn@latest add card
npx shadcn@latest add dialog
npx shadcn@latest add sheet
npx shadcn@latest add tabs
npx shadcn@latest add accordion
npx shadcn@latest add collapsible
```

### Feedback Components
```bash
npx shadcn@latest add alert
npx shadcn@latest add toast
npx shadcn@latest add badge
npx shadcn@latest add progress
npx shadcn@latest add skeleton
```

### Navigation Components
```bash
npx shadcn@latest add button
npx shadcn@latest add dropdown-menu
npx shadcn@latest add navigation-menu
npx shadcn@latest add breadcrumb
npx shadcn@latest add pagination
```

## Advanced Usage

### Installation with Custom Options
```bash
# Overwrite existing component
npx shadcn@latest add button --overwrite

# Install with specific path (custom setup)
npx shadcn@latest add button --cwd ./apps/web

# Install from specific registry
npx shadcn@latest add button --registry https://ui.shadcn.com
```

### Batch Installation Script
```bash
#!/bin/bash
# install-shadcn-components.sh

components=(
  "button"
  "card"
  "input"
  "label"
  "textarea"
  "select"
  "checkbox"
  "dialog"
  "toast"
  "alert"
)

for component in "${components[@]}"; do
  echo "Installing $component..."
  npx shadcn@latest add "$component"
done

echo "All components installed!"
```

### Project-Specific Component List
```bash
# Create a components list file
echo "button card input label textarea select checkbox dialog toast" > shadcn-components.txt

# Install from list
xargs -n1 npx shadcn@latest add < shadcn-components.txt
```

## Project Configuration

### Example components.json
```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "src/app/globals.css",
    "baseColor": "slate",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
```

### Custom Component Paths
```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "aliases": {
    "components": "./src/components",
    "utils": "./src/lib/utils",
    "ui": "./src/components/ui"
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Command not found
```bash
# ❌ PROBLEM
shadcn@latest add button
# Error: command not found

# ✅ SOLUTION
npx shadcn@latest add button
```

#### Issue 2: Old package name
```bash
# ❌ PROBLEM
npx shadcn-ui add button
# Error: Package 'shadcn-ui' not found

# ✅ SOLUTION
npx shadcn@latest add button
```

#### Issue 3: Missing components.json
```bash
# ❌ PROBLEM
npx shadcn@latest add button
# Error: components.json not found

# ✅ SOLUTION
npx shadcn@latest init
npx shadcn@latest add button
```

#### Issue 4: Permission errors
```bash
# ❌ PROBLEM
npx shadcn@latest add button
# Error: Permission denied

# ✅ SOLUTION
sudo npx shadcn@latest add button
# OR check file permissions in project directory
```

## Verification After Installation

### Check Component Files
```bash
# Verify component exists
ls -la components/ui/button.tsx

# Check component content
cat components/ui/button.tsx
```

### Check Configuration Updates
```bash
# Check components.json includes new component
cat components.json | grep '"button"'
```

### Check Dependencies
```bash
# Check package.json includes required dependencies
cat package.json | grep -E "(class-variance-authority|clsx|tailwind-merge)"
```

## Best Practices

### 1. Initialize Project First
```bash
# Always ensure project is initialized
npx shadcn@latest init
```

### 2. Install Components Individually
```bash
# Better for error handling
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
```

### 3. Use Latest Version
```bash
# Always use @latest tag
npx shadcn@latest add component
```

### 4. Verify Installation
```bash
# Check component was installed correctly
ls components/ui/
```

### 5. Test Components
```typescript
// Test imported component
import { Button } from "@/components/ui/button";

export default function TestPage() {
  return <Button>Test Button</Button>;
}
```

## Integration with Development Workflow

### Pre-commit Hook Check
```bash
# .husky/pre-commit
#!/bin/sh

# Check if components.json exists
if [ ! -f "components.json" ]; then
  echo "❌ components.json not found. Run 'npx shadcn@latest init' first."
  exit 1
fi

echo "✅ shadcn project configuration verified"
```

### CI/CD Validation
```yaml
# .github/workflows/validate-shadcn.yml
name: Validate shadcn Setup

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm install

      - name: Verify shadcn setup
        run: |
          if [ ! -f "components.json" ]; then
            echo "❌ components.json not found"
            exit 1
          fi
          echo "✅ shadcn configuration verified"
```

## Validation Checklist
- [ ] Always start with `npx shadcn@latest add`
- [ ] Never use alternate package managers or older command names
- [ ] Ensure the placeholder `<component>` is replaced with actual component name
- [ ] Verify components.json exists before installation
- [ ] Check component files are created correctly after installation
- [ ] Test imported components work as expected
- [ ] Use `@latest` tag for most recent version
- [ ] Handle installation errors gracefully with proper troubleshooting

This ensures consistent, up-to-date shadcn component installations across all projects and team members.