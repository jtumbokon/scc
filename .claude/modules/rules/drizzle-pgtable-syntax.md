---
id: rule-022
type: rule
version: 1.0.0
description: Enforce correct Drizzle pgTable syntax - constraints configuration function must return an array, not an object
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Drizzle pgTable Syntax Rule (rule-022)

## Purpose
The Drizzle ORM `pgTable` function has deprecated the syntax for defining table-level constraints (like indexes or composite unique keys) where the configuration function returns an object. This old syntax triggers deprecation warnings and will be removed in future versions.

The correct, modern syntax requires the configuration function to return an **array** of constraints.

## Requirements

### MUST (Critical)
- **Always use array syntax** for pgTable constraints configuration function
- **Return array `[...]`** from the third argument (constraints configuration function)
- **Each constraint must be an array element** - indexes, unique keys, foreign keys, etc.
- **Never use object literal `{...}`** for constraints configuration function

### SHOULD (Important)
- **Use consistent constraint naming** across all table definitions
- **Group related constraints** logically in the array
- **Add proper constraint descriptions** for complex multi-column constraints
- **Test constraint behavior** after schema changes

### MAY (Optional)
- **Add inline comments** explaining complex constraint logic
- **Use descriptive constraint names** that indicate their purpose
- **Group constraints by type** (indexes together, unique constraints together)

## Examples

### ❌ Bad - Object Return Syntax (Deprecated)
```typescript
// ❌ Bad - Returns object (deprecated syntax)
export const users = pgTable("users", {
  id: integer("id").primaryKey(),
  name: text("name").notNull(),
  email: text("email").notNull(),
}, (t) => ({
  name_idx: index('name_idx').on(t.name),
  email_idx: index('email_idx').on(t.email),
}));

// ❌ Bad - Composite unique constraint as object
export const posts = pgTable("posts", {
  id: integer("id").primaryKey(),
  author_id: integer("author_id").notNull(),
  city_id: integer("city_id").notNull(),
  title: text("title").notNull(),
}, (t) => ({
  author_city_unq: unique().on(t.author_id, t.city_id),
  title_idx: index('title_idx').on(t.title),
}));

// ❌ Bad - Foreign key constraint as object
export const comments = pgTable("comments", {
  id: integer("id").primaryKey(),
  post_id: integer("post_id").notNull(),
  user_id: integer("user_id").notNull(),
  content: text("content").notNull(),
}, (t) => ({
  post_fk: foreignKey({
    columns: [t.post_id],
    foreignColumns: [posts.id],
    name: "comments_post_fkey"
  }),
  post_user_idx: index('post_user_idx').on(t.post_id, t.user_id),
}));
```

### ✅ Good - Array Return Syntax (Current)
```typescript
// ✅ Good - Returns array (current syntax)
export const users = pgTable("users", {
  id: integer("id").primaryKey(),
  name: text("name").notNull(),
  email: text("email").notNull(),
}, (t) => [
  index('name_idx').on(t.name),
  index('email_idx').on(t.email),
]);

// ✅ Good - Composite unique constraint in array
export const posts = pgTable("posts", {
  id: integer("id").primaryKey(),
  author_id: integer("author_id").notNull(),
  city_id: integer("city_id").notNull(),
  title: text("title").notNull(),
}, (t) => [
  unique('author_city_unq').on(t.author_id, t.city_id),
  index('title_idx').on(t.title),
]);

// ✅ Good - Foreign key constraint in array
export const comments = pgTable("comments", {
  id: integer("id").primaryKey(),
  post_id: integer("post_id").notNull(),
  user_id: integer("user_id").notNull(),
  content: text("content").notNull(),
}, (t) => [
  foreignKey({
    columns: [t.post_id],
    foreignColumns: [posts.id],
    name: "comments_post_fkey"
  }),
  index('post_user_idx').on(t.post_id, t.user_id),
]);
```

## Advanced Constraint Patterns

### Multiple Constraint Types
```typescript
// ✅ Good - Complex table with multiple constraint types
export const orders = pgTable("orders", {
  id: integer("id").primaryKey(),
  user_id: integer("user_id").notNull(),
  order_date: timestamp("order_date").defaultNow().notNull(),
  total_amount: decimal("total_amount", { precision: 10, scale: 2 }).notNull(),
  status: text("status").notNull(),
}, (t) => [
  // Foreign key constraints
  foreignKey({
    columns: [t.user_id],
    foreignColumns: [users.id],
    name: "orders_user_fkey"
  }),

  // Unique constraints
  unique('user_order_date_unq').on(t.user_id, t.order_date),

  // Indexes for performance
  index('user_status_idx').on(t.user_id, t.status),
  index('order_date_idx').on(t.order_date),
  index('status_total_idx').on(t.status, t.total_amount),

  // Partial index for active orders
  index('active_orders_idx').on(t.user_id, t.order_date)
    .where(sql`${t.status} = 'active'`),
]);
```

### Named Constraints
```typescript
// ✅ Good - Explicit constraint naming
export const user_roles = pgTable("user_roles", {
  id: integer("id").primaryKey(),
  user_id: integer("user_id").notNull(),
  role_id: integer("role_id").notNull(),
  assigned_at: timestamp("assigned_at").defaultNow().notNull(),
}, (t) => [
  // Explicitly named foreign key
  foreignKey({
    columns: [t.user_id],
    foreignColumns: [users.id],
    name: "user_roles_user_fkey"
  }),

  foreignKey({
    columns: [t.role_id],
    foreignColumns: [roles.id],
    name: "user_roles_role_fkey"
  }),

  // Named unique constraint
  unique('user_role_unq').on(t.user_id, t.role_id),

  // Performance index
  index('user_role_assigned_idx').on(t.user_id, t.role_id, t.assigned_at),
]);
```

## Migration Guide

### Converting from Object to Array Syntax

**Step 1: Identify Object Syntax**
```bash
# Find tables using deprecated object syntax
grep -r "pgTable.*=> {" lib/drizzle/schema --include="*.ts"
```

**Step 2: Convert to Array Syntax**
```typescript
// Before (Object - Deprecated)
export const table = pgTable("table", {
  // columns
}, (t) => ({
  constraint1: index('idx1').on(t.col1),
  constraint2: unique().on(t.col1, t.col2),
}));

// After (Array - Current)
export const table = pgTable("table", {
  // columns
}, (t) => [
  index('idx1').on(t.col1),
  unique('unq1').on(t.col1, t.col2),
]);
```

**Step 3: Update Constraint Names**
```typescript
// Object syntax automatically uses property names
(t) => ({
  my_constraint: index('idx').on(t.col), // Creates constraint named "my_constraint"
})

// Array syntax requires explicit naming if custom names needed
(t) => [
  index('my_constraint').on(t.col), // Creates constraint named "my_constraint"
  // or use default naming
  index().on(t.col), // Creates auto-generated constraint name
]
```

## Common Migration Issues

### Issue 1: Constraint Naming Changes
```typescript
// Object syntax
(t) => ({
  user_email_idx: index().on(t.email),
})

// Array syntax - explicit naming required
(t) => [
  index('user_email_idx').on(t.email), // Preserve original name
]
```

### Issue 2: Multiple Similar Constraints
```typescript
// Object syntax - clear separation
(t) => ({
  primary_idx: index().on(t.primary),
  secondary_idx: index().on(t.secondary),
})

// Array syntax - need explicit names to distinguish
(t) => [
  index('primary_idx').on(t.primary),
  index('secondary_idx').on(t.secondary),
]
```

## Best Practices

### 1. Consistent Naming Convention
```typescript
// Use descriptive, consistent constraint names
export const products = pgTable("products", {
  id: integer("id").primaryKey(),
  category_id: integer("category_id").notNull(),
  sku: text("sku").notNull(),
  name: text("name").notNull(),
}, (t) => [
  // Foreign keys: table_column_fkey
  foreignKey({
    columns: [t.category_id],
    foreignColumns: [categories.id],
    name: "products_category_fkey"
  }),

  // Unique constraints: table_columns_unq
  unique('products_sku_unq').on(t.sku),

  // Indexes: table_columns_idx
  index('products_category_idx').on(t.category_id),
  index('products_name_idx').on(t.name),
  index('products_category_name_idx').on(t.category_id, t.name),
]);
```

### 2. Logical Constraint Grouping
```typescript
// Group constraints by type and purpose
export const audit_logs = pgTable("audit_logs", {
  id: integer("id").primaryKey(),
  user_id: integer("user_id").notNull(),
  action: text("action").notNull(),
  created_at: timestamp("created_at").defaultNow().notNull(),
  metadata: json("metadata"),
}, (t) => [
  // Foreign keys first
  foreignKey({
    columns: [t.user_id],
    foreignColumns: [users.id],
    name: "audit_logs_user_fkey"
  }),

  // Performance indexes
  index('audit_logs_user_created_idx').on(t.user_id, t.created_at),
  index('audit_logs_action_idx').on(t.action),
  index('audit_logs_created_idx').on(t.created_at),

  // JSON indexes for metadata queries
  index('audit_logs_metadata_idx').using('gin', t.metadata),
]);
```

### 3. Documentation Comments
```typescript
export const subscriptions = pgTable("subscriptions", {
  id: integer("id").primaryKey(),
  user_id: integer("user_id").notNull(),
  plan_id: integer("plan_id").notNull(),
  current_period_end: timestamp("current_period_end").notNull(),
  status: text("status").notNull(),
}, (t) => [
  // Foreign key relationship
  foreignKey({
    columns: [t.user_id],
    foreignColumns: [users.id],
    name: "subscriptions_user_fkey"
  }),

  // Business logic constraints
  unique('subscriptions_user_plan_unq').on(t.user_id, t.plan_id),

  // Performance indexes for common queries
  index('subscriptions_user_status_idx').on(t.user_id, t.status),
  index('subscriptions_period_end_idx').on(t.current_period_end),

  // Index for subscription expiry queries
  index('subscriptions_expiry_idx').on(t.current_period_end)
    .where(sql`${t.status} = 'active'`),
]);
```

## Validation Checklist
- [ ] All pgTable constraints use array syntax `[...]` not object `{...}`
- [ ] Constraint names are explicit and descriptive
- [ ] Foreign key constraints have proper naming conventions
- [ ] Unique constraints are clearly named to indicate their purpose
- [ ] Indexes have logical names that reflect their usage patterns
- [ ] No deprecation warnings related to pgTable syntax
- [ ] Schema can be generated without syntax errors
- [ ] All constraints are properly tested for expected behavior

## Enforcement
This rule is enforced through:
- ESLint rules for Drizzle ORM syntax
- TypeScript compilation checks
- Database migration validation
- Code review validation
- Automated schema generation testing

Using the correct array syntax for pgTable constraints ensures compatibility with current and future versions of Drizzle ORM while maintaining clear, maintainable database schema definitions.