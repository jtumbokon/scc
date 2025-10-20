---
id: rule-034
type: rule
version: 1.0.0
description: Detect project types automatically and use appropriate linting commands for Python vs Node.js projects
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Detect Project Type for Linting Commands

## Purpose
In multi-app repositories, different directories may contain different types of projects (Python, Node.js, etc.). Using the wrong linting commands can cause confusion and errors.

## Requirements

### MUST (Critical)
- **ALWAYS check project type** before running any linting or validation commands
- **NEVER assume project type** - always verify based on files present
- **ALWAYS use correct commands** for detected project type

### SHOULD (Important)
- **Check current directory** for project indicators first
- **Look for parent directories** if not found in current dir
- **When in doubt, explicitly check** what files exist in the directory

## Project Type Detection

### Python Projects - Look for:
- `pyproject.toml` file
- `requirements.txt` file
- `.py` files
- Common directories: `src/`, `tests/`, `rag_processor/`, etc.

### Node.js/TypeScript Projects - Look for:
- `package.json` file
- `tsconfig.json` file
- `.js`, `.ts`, `.tsx` files
- Common directories: `app/`, `components/`, `lib/`, etc.

## Correct Commands by Project Type

| Project Type | Linting Commands | Type Checking | Formatting |
|--------------|------------------|---------------|------------|
| **Python** | `uv run ruff check` | `uv run mypy` | `uv run black --check` |
| **Node.js/TypeScript** | `npm run lint` | `npm run type-check` | `npm run format` |

## Examples

### ❌ Bad (Wrong commands for project type)
```bash
# In a Python project (has pyproject.toml)
npm run lint  # WRONG - this is for Node.js projects

# In a Node.js project (has package.json)
uv run ruff check  # WRONG - this is for Python projects
```

### ✅ Good (Correct commands for project type)
```bash
# In a Python project (rag-processor with pyproject.toml)
uv run ruff check
uv run mypy
uv run black --check

# In a Node.js project (web app with package.json)
npm run lint
npm run type-check
```

## Implementation Strategy

1. **Check current directory** for project indicators
2. **Look for parent directories** if not found in current dir
3. **Use the appropriate commands** based on project type detected
4. **Never assume** - always verify project type before running commands

## Detection Logic

### Primary Indicators
```bash
# Check for Python project
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    echo "Python project detected"
    # Use Python commands
fi

# Check for Node.js project
if [ -f "package.json" ] || [ -f "tsconfig.json" ]; then
    echo "Node.js/TypeScript project detected"
    # Use Node.js commands
fi
```

### Fallback Detection
```bash
# Check file extensions
python_files=$(find . -name "*.py" -type f | head -5)
js_files=$(find . -name "*.js" -o -name "*.ts" -o -name "*.tsx" | head -5)

if [ -n "$python_files" ] && [ -z "$js_files" ]; then
    echo "Likely Python project (based on file types)"
elif [ -n "$js_files" ] && [ -z "$python_files" ]; then
    echo "Likely Node.js/TypeScript project (based on file types)"
fi
```

## Validation Checklist
- [ ] Check for `pyproject.toml` vs `package.json` in current/target directory
- [ ] Use Python commands (`uv run`) for Python projects
- [ ] Use Node.js commands (`npm run`) for JavaScript/TypeScript projects
- [ ] When in doubt, explicitly check what files exist in the directory
- [ ] Verify commands match project configuration files

## Error Prevention

### Common Mistakes to Avoid
1. **Running `npm run lint` in Python projects** - Will fail with "package.json not found"
2. **Running `uv run ruff check` in Node.js projects** - Will fail with "no Python files found"
3. **Assuming project type based on directory name** - Always check for configuration files
4. **Using wrong package manager** - Check for `package.json` (npm/yarn) vs `pyproject.toml` (uv/pip)

### Recovery Procedures
If wrong commands are run:
1. **Stop execution** immediately
2. **Identify actual project type** using detection logic
3. **Use correct commands** for the detected project type
4. **Document the correction** to prevent future issues

## Enforcement
This rule is enforced through:
- Pre-execution validation in build scripts
- Automated project type detection in CI/CD pipelines
- Manual verification during development workflow

This prevents confusion and ensures the correct tooling is used for each project type.