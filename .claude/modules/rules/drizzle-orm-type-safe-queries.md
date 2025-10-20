---
id: rule-020
type: rule
version: 1.0.0
description: Use type-safe Drizzle ORM query operators instead of raw SQL to prevent injection vulnerabilities and maintain type safety
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Drizzle ORM Type-Safe Queries Rule (rule-020)

## Purpose
Drizzle ORM provides a comprehensive set of type-safe query operators (`eq`, `inArray`, `and`, `or`, etc.) that should be preferred over manually constructed SQL using the `sql` template. Manually building SQL queries can lead to SQL injection vulnerabilities, type safety issues, and reduced code maintainability.

The `sql` template should only be used for complex database-specific functionality that doesn't have a corresponding Drizzle operator, not for basic query operations that have dedicated type-safe alternatives.

## Requirements

### MUST (Critical)
- **Always use Drizzle operators** for basic query operations instead of manually constructing SQL
- **Never use `sql` template** for operations that have dedicated Drizzle operators
- **Import required operators** from `drizzle-orm` instead of building equivalent SQL
- **Only use raw SQL** when no Drizzle operator exists for the specific functionality needed
- **Use `sql<T>`** for type hints when raw SQL is necessary

### SHOULD (Important)
- **Prefer type-safe operators** for all common query patterns
- **Use `and()` and `or()`** for combining conditions instead of string concatenation
- **Add type hints** to raw SQL when necessary for better type safety
- **Use dynamic query building** with arrays for conditional filters

### MAY (Optional)
- **Use raw SQL** for database-specific functions not covered by Drizzle
- **Create custom query builders** for complex patterns
- **Use raw SQL** for performance-critical operations where Drizzle overhead is a concern

## Common Operator Mappings

| ❌ Bad (Raw SQL) | ✅ Good (Drizzle Operators) |
|---|---|
| ```ts sql`${column} = ANY(${array})` ``` | ```ts import { inArray } from "drizzle-orm"; inArray(column, array) ``` |
| ```ts sql`${column} = ${value}` ``` | ```ts import { eq } from "drizzle-orm"; eq(column, value) ``` |
| ```ts sql`${col1} > ${val} AND ${col2} < ${val2}` ``` | ```ts import { and, gt, lt } from "drizzle-orm"; and(gt(col1, val), lt(col2, val2)) ``` |
| ```ts sql`${column} IN (${values.join(',')})` ``` | ```ts import { inArray } from "drizzle-orm"; inArray(column, values) ``` |
| ```ts sql`${column} IS NULL` ``` | ```ts import { isNull } from "drizzle-orm"; isNull(column) ``` |
| ```ts sql`${column} LIKE ${pattern}` ``` | ```ts import { like } from "drizzle-orm"; like(column, pattern) ``` |

## Available Drizzle Operators

### Comparison Operators
- `eq` - Equal to
- `ne` - Not equal to
- `gt` - Greater than
- `gte` - Greater than or equal to
- `lt` - Less than
- `lte` - Less than or equal to

### Array Operations
- `inArray` - Value is in array
- `notInArray` - Value is not in array

### Null Checks
- `isNull` - Value is null
- `isNotNull` - Value is not null

### Pattern Matching
- `like` - SQL LIKE pattern matching
- `ilike` - Case-insensitive LIKE
- `notIlike` - Case-insensitive NOT LIKE

### Range Operations
- `between` - Value is between range (inclusive)
- `notBetween` - Value is not between range

### Logical Operations
- `and` - Logical AND (combine conditions)
- `or` - Logical OR (combine conditions)
- `not` - Logical NOT

### Existence
- `exists` - Subquery returns rows
- `notExists` - Subquery returns no rows

### Array Functions
- `arrayContains` - Array contains another array
- `arrayContained` - Array is contained in another array
- `arrayOverlaps` - Arrays have overlapping elements

## Examples

### Basic Queries
```typescript
// ❌ Bad - Raw SQL construction
import { sql } from "drizzle-orm";

const users = await db.select()
  .from(usersTable)
  .where(sql`${usersTable.name} = ${userName}`)
  .where(sql`${usersTable.age} > ${minAge}`);

// ✅ Good - Type-safe operators
import { eq, gt } from "drizzle-orm";

const users = await db.select()
  .from(usersTable)
  .where(and(
    eq(usersTable.name, userName),
    gt(usersTable.age, minAge)
  ));
```

### Array Operations
```typescript
// ❌ Bad - Manual array construction
const ids = [1, 2, 3, 4, 5];
const posts = await db.select()
  .from(postsTable)
  .where(sql`${postsTable.id} IN (${ids.join(',')})`);

// ✅ Good - Type-safe array operations
import { inArray } from "drizzle-orm";

const ids = [1, 2, 3, 4, 5];
const posts = await db.select()
  .from(postsTable)
  .where(inArray(postsTable.id, ids));
```

### Pattern Matching
```typescript
// ❌ Bad - Manual LIKE construction
const searchPattern = `%${searchTerm}%`;
const users = await db.select()
  .from(usersTable)
  .where(sql`${usersTable.name} LIKE ${searchPattern}`);

// ✅ Good - Type-safe pattern matching
import { like } from "drizzle-orm";

const searchPattern = `%${searchTerm}%`;
const users = await db.select()
  .from(usersTable)
  .where(like(usersTable.name, searchPattern));
```

## When Raw SQL is Appropriate

Use `sql` template only for:
- Database-specific functions not covered by Drizzle operators
- Complex expressions without Drizzle equivalents
- Custom database extensions or functions

### ✅ Good Examples
```typescript
// Database-specific function
import { sql } from "drizzle-orm";

const searchResults = await db.select()
  .from(postsTable)
  .where(sql<string>`to_tsvector('simple', ${postsTable.content}) @@ to_tsquery('simple', ${searchQuery})`);

// Complex custom function
const nearbyLocations = await db.select()
  .from(locationsTable)
  .where(sql<number>`calculate_distance(${lat}, ${lng}, ${locationsTable.latitude}, ${locationsTable.longitude}) < ${maxDistance}`);

// Full-text search with ranking
const rankedResults = await db.select({
  title: postsTable.title,
  rank: sql<number>`ts_rank_cd(to_tsvector('simple', ${postsTable.content}), to_tsquery('simple', ${query}))`
})
  .from(postsTable)
  .where(sql<string>`to_tsvector('simple', ${postsTable.content}) @@ to_tsquery('simple', ${query})`);
```

## Dynamic Query Building

### Conditional Filters
```typescript
// ✅ Good - Dynamic conditions with arrays
const conditions = [];
if (userId) conditions.push(eq(usersTable.userId, userId));
if (status) conditions.push(eq(usersTable.status, status));
if (tags.length > 0) conditions.push(inArray(usersTable.tags, tags));
if (dateRange) {
  conditions.push(
    between(usersTable.createdAt, dateRange.start, dateRange.end)
  );
}

const result = await db
  .select()
  .from(usersTable)
  .where(and(...conditions));
```

### Optional Parameters
```typescript
function findUsers(filters: UserFilters) {
  const conditions = [];

  if (filters.name) {
    conditions.push(like(usersTable.name, `%${filters.name}%`));
  }

  if (filters.minAge) {
    conditions.push(gte(usersTable.age, filters.minAge));
  }

  if (filters.status) {
    if (Array.isArray(filters.status)) {
      conditions.push(inArray(usersTable.status, filters.status));
    } else {
      conditions.push(eq(usersTable.status, filters.status));
    }
  }

  return db
    .select()
    .from(usersTable)
    .where(conditions.length > 0 ? and(...conditions) : undefined);
}
```

## SQL Injection Prevention

### ❌ Bad - SQL Injection Risk
```typescript
const userInput = "'; DROP TABLE users; --";
const query = sql`SELECT * FROM users WHERE name = '${userInput}'`; // Dangerous!
```

### ✅ Good - Parameterized Queries
```typescript
// Using Drizzle operator (preferred)
import { eq } from "drizzle-orm";
const query = eq(usersTable.name, userInput); // Safe!

// Using raw SQL with parameterization (when necessary)
import { sql } from "drizzle-orm";
const query = sql`SELECT * FROM users WHERE name = ${userInput}`; // Safe with Drizzle
```

## Type Safety

### Type Hints for Raw SQL
```typescript
// ❌ Bad - No type information
const result = sql`lower(${usersTable.name})`;

// ✅ Good - With type hint
const result = sql<string>`lower(${usersTable.name})`;

// ✅ Best - Use Drizzle operator when available
// (Note: lowercase example - use appropriate operator)
```

### Custom Type Aliases
```typescript
// Type-safe raw SQL expressions
type SearchVector = ReturnType<typeof sql<string>>;

const searchQuery: SearchVector = sql<string>`
  to_tsvector('english', ${content})
  @@ to_tsquery('english', ${keywords})
`;
```

## Real-World Examples

### Fixing Common Issues
```typescript
// ❌ Before - What caused a recent bug
import { sql } from "drizzle-orm";

const battleResults = await db
  .select()
  .from(battlesTable)
  .where(sql`${aiModelsTable.id} = ANY(${battleRequest.model_ids})`);

// ✅ After - Type-safe operator
import { inArray } from "drizzle-orm";

const battleResults = await db
  .select()
  .from(battlesTable)
  .where(inArray(aiModelsTable.id, battleRequest.model_ids));
```

### Complex Joins
```typescript
// ✅ Good - Type-safe joins with operators
import { eq, and } from "drizzle-orm";

const userOrders = await db
  .select({
    userId: usersTable.id,
    userName: usersTable.name,
    orderId: ordersTable.id,
    orderTotal: ordersTable.total,
    status: ordersTable.status,
  })
  .from(usersTable)
  .innerJoin(ordersTable, eq(usersTable.id, ordersTable.userId))
  .where(and(
    eq(usersTable.active, true),
    inArray(ordersTable.status, ['pending', 'processing'])
  ));
```

### Subqueries
```typescript
// ✅ Good - Type-safe subqueries
import { exists, gt } from "drizzle-orm";

const activeUsersWithRecentOrders = await db
  .select()
  .from(usersTable)
  .where(and(
    eq(usersTable.active, true),
    exists(
      db.select()
        .from(ordersTable)
        .where(and(
          eq(ordersTable.userId, usersTable.id),
          gt(ordersTable.createdAt, thirtyDaysAgo)
        ))
    )
  ));
```

## Required Imports

Always import the operators you need:
```typescript
import {
  eq, ne, gt, gte, lt, lte,
  inArray, notInArray,
  and, or, not,
  isNull, isNotNull,
  like, ilike,
  between, exists
} from "drizzle-orm";
```

## Validation Checklist
- [ ] Check if the query operation has a corresponding Drizzle operator before using `sql` template
- [ ] Import required operators from `drizzle-orm`
- [ ] Use `inArray()` instead of manually constructing `IN` or `ANY()` clauses
- [ ] Use `and()`, `or()` for combining conditions instead of string concatenation
- [ ] Only suggest `sql` template for database-specific functions without Drizzle equivalents
- [ ] Add `sql<T>` type hints when raw SQL is necessary
- [ ] Ensure all user inputs are properly parameterized, never string-interpolated into SQL

## Enforcement
This rule is enforced through:
- ESLint rules for Drizzle ORM usage
- Code review validation
- Static analysis for SQL injection patterns
- TypeScript compilation checks
- Automated testing for query patterns

Using type-safe Drizzle operators prevents SQL injection vulnerabilities, maintains type safety, and ensures consistent code patterns across the application.