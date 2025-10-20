---
id: rule-036
type: rule
version: 1.0.0
description: Use package.json scripts for Drizzle operations with proper environment variable loading via dotenv-cli
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Use package.json Scripts for Drizzle Operations Rule (rule-036)

## Purpose
This project has specific package.json scripts configured for Drizzle ORM operations that include proper environment variable loading via `dotenv-cli`. Using `npx drizzle-kit` commands directly bypasses the configured environment setup and can cause database connection issues or use wrong environment variables.

The project uses a specific setup with `.env.local` file loading and environment-specific configurations that are only properly loaded through the npm scripts.

## Requirements

### MUST (Critical)
- **NEVER use direct `npx drizzle-kit` commands** in terminal operations
- **ALWAYS use corresponding package.json scripts** for Drizzle operations
- **ENSURE environment loading** - Scripts load `.env.local` properly via `dotenv-cli`
- **CONSISTENT commands** - All team members use same commands

### SHOULD (Important)
- **Check package.json scripts section** for available commands
- **Use configured scripts** to respect project-specific drizzle config
- **PREVENT database connection issues** by using proper environment loading
- **MAINTAIN consistency** across development environments

### MAY (Optional)
- **Create custom scripts** for project-specific database operations
- **Add environment validation** to scripts for better error handling
- **Document script usage** in project README
- **Implement script aliases** for commonly used operations

## Command Mappings

| ❌ Bad (Direct Commands) | ✅ Good (Package.json Scripts) |
|---|---|
| `npx drizzle-kit generate` | `npm run db:generate` |
| `npx drizzle-kit generate --custom` | `npm run db:generate:custom` |
| `npx drizzle-kit studio` | `npm run db:studio` |
| Direct migration scripts | `npm run db:migrate` |
| Direct rollback scripts | `npm run db:rollback` |

## Available Scripts

### Core Database Operations
- **`npm run db:generate`** - Generate migrations from schema changes
- **`npm run db:generate:custom`** - Generate custom migrations
- **`npm run db:migrate`** - Run pending migrations
- **`npm run db:rollback`** - Rollback last migration
- **`npm run db:status`** - Check migration status
- **`npm run db:studio`** - Open Drizzle Studio
- **`npm run db:seed`** - Run database seeding

### Example package.json Configuration
```json
{
  "scripts": {
    "db:generate": "dotenv-cli -e .env.local -- drizzle-kit generate",
    "db:generate:custom": "dotenv-cli -e .env.local -- drizzle-kit generate --custom",
    "db:migrate": "dotenv-cli -e .env.local -- drizzle-kit migrate",
    "db:rollback": "dotenv-cli -e .env.local -- drizzle-kit rollback",
    "db:status": "dotenv-cli -e .env.local -- drizzle-kit status",
    "db:studio": "dotenv-cli -e .env.local -- drizzle-kit studio",
    "db:seed": "dotenv-cli -e .env.local -- tsx scripts/seed.ts"
  }
}
```

## Why This Matters

### Environment Variables
Scripts ensure `.env.local` is properly loaded via `dotenv-cli`:
```bash
# ✅ GOOD - Loads .env.local automatically
npm run db:generate

# ❌ BAD - May miss environment variables
npx drizzle-kit generate
```

### Consistency
All team members use same commands with same environment setup.

### Error Prevention
Avoids database connection issues from missing or wrong environment variables.

### Configuration Respect
Ensures project-specific drizzle configuration is properly used.

## Implementation Patterns

### Pattern 1: Standard Database Operations
```bash
# ✅ GOOD - Use package.json scripts
npm run db:generate     # Generate migrations
npm run db:migrate      # Run migrations
npm run db:studio       # Open Drizzle Studio

# ❌ BAD - Direct commands bypass environment setup
npx drizzle-kit generate
npx drizzle-kit migrate
npx drizzle-kit studio
```

### Pattern 2: Development Workflow
```bash
# 1. Make schema changes
# 2. Generate migration
npm run db:generate

# 3. Review generated migration
# 4. Run migration
npm run db:migrate

# 5. Verify with studio
npm run db:studio
```

### Pattern 3: Custom Operations
```bash
# Generate custom migration with specific name
npm run db:generate:custom -- --name add_user_table

# Rollback last migration
npm run db:rollback

# Check migration status
npm run db:status
```

## Forbidden Patterns

### ❌ NEVER Use Direct drizzle-kit Commands
```bash
# ❌ FORBIDDEN - Direct command usage
npx drizzle-kit generate
npx drizzle-kit migrate
npx drizzle-kit studio
npx drizzle-kit push
npx drizzle-kit pull

# ❌ FORBIDDEN - Even with flags
npx drizzle-kit generate --custom
npx drizzle-kit migrate --force
```

### ❌ NEVER Bypass Environment Loading
```bash
# ❌ FORBIDDEN - Manual environment loading
DATABASE_URL="postgres://..." npx drizzle-kit generate

# ❌ FORBIDDEN - Cross-environment operations
DATABASE_URL="prod-url" npx drizzle-kit migrate
```

## Correct Implementation

### ✅ ALWAYS Use Package.json Scripts
```bash
# ✅ GOOD - Proper script usage
npm run db:generate
npm run db:migrate
npm run db:studio
npm run db:rollback

# ✅ GOOD - With additional parameters
npm run db:generate -- --name create_users_table
npm run db:migrate -- --force
```

### ✅ Custom Script Creation
```json
// package.json
{
  "scripts": {
    "db:reset": "npm run db:rollback && npm run db:migrate && npm run db:seed",
    "db:deploy": "npm run db:generate && npm run db:migrate",
    "db:dev": "npm run db:generate && npm run db:migrate && npm run db:studio"
  }
}
```

## Environment Configuration

### Expected .env.local Structure
```env
# Database configuration
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="myapp"
DB_USER="postgres"
DB_PASSWORD="password"

# Drizzle configuration
DRIZZLE_STUDIO_PORT="4911"
DRIZZLE_MIGRATION_FOLDER="./drizzle"

# Environment
NODE_ENV="development"
```

### Drizzle Configuration
```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit';
import 'dotenv/config';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  verbose: true,
  strict: true,
});
```

## Error Handling and Troubleshooting

### Common Issues and Solutions

#### Issue 1: Database connection failed
```bash
# ❌ PROBLEM - Wrong environment loaded
npx drizzle-kit generate
# Error: Database connection failed

# ✅ SOLUTION - Use script with proper environment
npm run db:generate
# Success: Connected to database using .env.local
```

#### Issue 2: Migration not found
```bash
# ❌ PROBLEM - Wrong migration path
npx drizzle-kit migrate
# Error: No migrations found

# ✅ SOLUTION - Use configured script
npm run db:migrate
# Success: Found migrations in ./drizzle folder
```

#### Issue 3: Studio not connecting
```bash
# ❌ PROBLEM - Missing database URL
npx drizzle-kit studio
# Error: Database URL not found

# ✅ SOLUTION - Use script with environment loading
npm run db:studio
# Success: Studio connected using DATABASE_URL from .env.local
```

### Debugging Environment Issues
```bash
# Check environment variables in script
"db:check": "dotenv-cli -e .env.local -- printenv | grep DATABASE"

# Test database connection
"db:test": "dotenv-cli -e .env.local -- drizzle-kit introspect"
```

## Advanced Usage

### Multi-Environment Support
```json
{
  "scripts": {
    "db:generate": "dotenv-cli -e .env.local -- drizzle-kit generate",
    "db:generate:prod": "dotenv-cli -e .env.production -- drizzle-kit generate",
    "db:migrate": "dotenv-cli -e .env.local -- drizzle-kit migrate",
    "db:migrate:prod": "dotenv-cli -e .env.production -- drizzle-kit migrate"
  }
}
```

### Custom Migration Scripts
```bash
# Generate with custom name and timestamp
npm run db:generate -- --name $(date +%Y%m%d_%H%M%S)_add_feature

# Generate with specific table focus
npm run db:generate -- --name users_table_update
```

### Development Automation
```json
{
  "scripts": {
    "dev:setup": "npm run db:generate && npm run db:migrate && npm run db:seed",
    "dev:reset": "npm run db:rollback -- --all && npm run dev:setup",
    "dev:studio": "npm run db:studio",
    "dev:db": "npm run db:generate && npm run db:migrate"
  }
}
```

## Validation Checklist
- [ ] Never suggest direct `npx drizzle-kit` commands
- [ ] Always use `npm run db:*` scripts for database operations
- [ ] When generating migrations, use `npm run db:generate`
- [ ] When running migrations, use `npm run db:migrate`
- [ ] Check `package.json` scripts section for available commands
- [ ] Verify `.env.local` exists and contains required variables
- [ ] Ensure scripts use `dotenv-cli` for environment loading
- [ ] Test database operations work correctly with configured scripts

## Benefits

1. **Environment Safety** - Proper environment variable loading prevents connection issues
2. **Team Consistency** - All developers use same commands with same setup
3. **Error Prevention** - Avoids common database connection and configuration issues
4. **Configuration Respect** - Ensures project-specific drizzle configuration is used
5. **Maintainability** - Centralized script management in package.json

This ensures proper environment loading and consistent database operations across the project.