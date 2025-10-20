---
id: rule-024
type: rule
version: 1.0.0
description: Never run build commands during development - use lint and type-check for faster validation
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No Build Commands Rule (rule-024)

## Purpose
Build commands (`npm run build`, `next build`, etc.) are expensive operations that consume significant system resources and take substantial time to complete. During development, lighter-weight validation commands provide faster feedback and catch the same issues that would cause build failures.

## Requirements

### MUST (Critical)
- **Never suggest build commands** for development validation
- **Never run build commands** during code development sessions
- **Use lint commands** for code quality and import validation
- **Use type-check commands** for TypeScript validation
- **Reserve build commands** for actual deployment scenarios

### SHOULD (Important)
- **Prefer incremental validation** over comprehensive builds
- **Use appropriate validation commands** for different types of changes
- **Test code changes** with faster feedback loops
- **Save build commands** for CI/CD pipelines and production deployment

### MAY (Optional)
- **Use build commands** for final integration testing before deployment
- **Run builds** when specifically testing deployment configuration
- **Use build analysis** for bundle size optimization (separate from validation)

## Validation Command Mapping

### For Different Change Types

| Change Type | Preferred Validation | Alternative | Build Command (Deployment Only) |
|-------------|---------------------|-------------|---------------------------------|
| Import path changes | `npm run lint` | `npm run lint --fix` | `npm run build` |
| Type definition changes | `npm run type-check` | `npx tsc --noEmit` | `npm run build` |
| Component logic changes | `npm run lint` + `npm test` | `npm run type-check` | `npm run build` |
| Configuration changes | `npm run lint` + manual testing | `npm run type-check` | `npm run build` |
| New dependencies | `npm run lint` + `npm run type-check` | `npm install` | `npm run build` |
| UI changes | `npm run lint` + visual testing | Storybook checks | `npm run build` |

### Language-Specific Commands

| Language/Framework | Validation Commands | Build Commands (Deployment Only) |
|-------------------|-------------------|---------------------------------|
| Next.js | `npm run lint`, `npm run type-check` | `next build` |
| React | `npm run lint`, `npm run type-check` | `npm run build` |
| TypeScript | `npm run type-check`, `npm run lint` | `tsc --build` |
| Vite | `npm run lint`, `npm run type-check` | `vite build` |
| Webpack | `npm run lint`, `npm run type-check` | `webpack --mode production` |

## Examples

### ❌ Bad - Using Build Commands for Development
```bash
# ❌ Bad - Using build for validation
npm run build
npm run build 2>&1 | head -20
next build --dry-run
vite build --mode development

# ❌ Bad - Suggesting build for code changes
"After updating imports, run `npm run build` to verify"
"Let's check if the types work by running `next build`"
"Test the component by building the project"
```

### ✅ Good - Using Validation Commands
```bash
# ✅ Good - Using lint for code quality
npm run lint
npm run lint --fix
npm run lint --max-warnings 0

# ✅ Good - Using type-check for TypeScript
npm run type-check
npx tsc --noEmit
npx tsc --noEmit --project tsconfig.json

# ✅ Good - Combined validation
npm run lint && npm run type-check
npm run lint --fix && npm run type-check

# ✅ Good - Test-driven validation
npm run test
npm run test --watch
npm run test --coverage
```

## Development Workflow Patterns

### Pattern 1: Code Change Validation
```bash
# After making code changes
npm run lint --fix          # Fix auto-fixable issues
npm run type-check          # Verify types
npm test                    # Run tests if available

# Only before deployment
npm run build               # Production build
```

### Pattern 2: Import Path Updates
```bash
# After changing import paths
npm run lint                # Check for broken imports
npm run type-check          # Verify type resolution

# Never use build for this validation
# npm run build           # ❌ Wrong approach
```

### Pattern 3: New Component Development
```bash
# During component development
npm run lint                # Code quality checks
npm run type-check          # TypeScript validation
npm test                    # Unit tests
npm run storybook           # Visual testing (if available)

# Only before deployment
npm run build               # Full production build
```

### Pattern 4: Configuration Changes
```bash
# After config changes
npm run lint                # Validate config syntax
npm run type-check          # Check type imports
# Manual testing            # Test configuration behavior

# Build only for deployment validation
npm run build               # ✅ Only for deployment prep
```

## Performance Comparison

### Command Execution Times
| Command | Typical Time | Resource Usage | Purpose |
|---------|--------------|----------------|---------|
| `npm run lint` | 1-5 seconds | Low | Code quality |
| `npm run type-check` | 5-15 seconds | Medium | Type validation |
| `npm test` | 10-30 seconds | Medium | Test validation |
| `npm run build` | 30-120 seconds | High | Production bundle |

### Development Efficiency
```bash
# Fast iteration cycle (recommended)
npm run lint && npm run type-check  # ~10-20 seconds
# Make changes
npm run lint && npm run type-check  # ~10-20 seconds
# Repeat as needed

# Slow iteration cycle (avoid)
npm run build                      # 30-120 seconds
# Make changes
npm run build                      # 30-120 seconds
# Poor developer experience
```

## CI/CD Integration

### Development vs. Production Validation
```yaml
# Development (local)
- npm run lint
- npm run type-check
- npm test

# Production (CI/CD)
- npm run lint
- npm run type-check
- npm test
- npm run build        # Only in CI/CD
- npm run deploy
```

### GitHub Actions Example
```yaml
name: CI
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test

  build:
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run build    # Only for production deployment
```

## Editor Integration

### VS Code Settings
```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.preferences.preferTypeOnlyAutoImports": true,
  "eslint.workingDirectories": ["."],
  "typescript.suggest.autoImports": true
}
```

### Pre-commit Hooks
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "git add"
    ],
    "*.{ts,tsx}": [
      "tsc --noEmit"
    ]
  }
}
```

## Package.json Scripts

### Recommended Script Configuration
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch",
    "validate": "npm run lint && npm run type-check",
    "validate:fix": "npm run lint:fix && npm run type-check",
    "deploy": "npm run build && npm run start"
  }
}
```

## Advanced Validation Strategies

### Incremental Type Checking
```bash
# Faster type checking for specific files
npx tsc --noEmit path/to/file.ts
npx tsc --noEmit --skipLibCheck
npx tsc --noEmit --project tsconfig.build.json
```

### Selective Linting
```bash
# Lint specific files or directories
npm run lint -- src/components/
npm run lint -- path/to/changed/files.ts
npm run lint -- --ext .ts,.tsx src/
```

### Watch Mode Development
```bash
# Continuous validation during development
npm run lint -- --watch
npm run type-check -- --watch
npm run test -- --watch
```

## Exception Handling

### When Build Commands ARE Appropriate
```bash
# ✅ Acceptable use cases for build commands:

# 1. Production deployment
npm run build && npm run deploy

# 2. Bundle size analysis
npm run build -- --analyze
npm run build && npx bundle-analyzer .next

# 3. Production configuration testing
npm run build && npm run start:prod

# 4. Final integration testing before release
npm run build && npm run e2e:tests
```

### Migration from Build-Heavy Workflows
```bash
# Before (build-heavy workflow)
# 1. Make changes
# 2. npm run build (30+ seconds)
# 3. Check results
# 4. Repeat

# After (validation-focused workflow)
# 1. Make changes
# 2. npm run lint && npm run type-check (10-20 seconds)
# 3. npm test (if needed)
# 4. Repeat
# 5. npm run build (only before deployment)
```

## Validation Checklist
- [ ] Never suggest `npm run build` for development validation
- [ ] Use `npm run lint` for code quality and import validation
- [ ] Use `npm run type-check` for TypeScript validation
- [ ] Use `npm test` for logic validation when tests are available
- [ ] Reserve build commands for deployment scenarios only
- [ ] Prefer fast, incremental validation tools
- [ ] Educate team about efficient validation workflows
- [ ] Configure CI/CD to separate validation from build steps

## Enforcement
This rule is enforced through:
- Code review validation
- Team education and documentation
- Package.json script configuration
- Development workflow guidelines
- Performance monitoring for long-running commands

Using lightweight validation commands instead of build commands ensures faster development cycles, better resource utilization, and earlier detection of issues during the development process.