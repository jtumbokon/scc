---
id: rule-008
type: rule
version: 1.0.0
description: Write meaningful, strategic comments that explain "why" not "what", avoiding migration history and obvious statements
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Commenting Best Practices Rule (rule-008)

## Purpose
Ensure comments enhance code readability and provide valuable context that isn't obvious from the code itself.

## Requirements

### MUST (Critical)
- **NEVER write migration history comments** - they become outdated clutter
- **NEVER add "MOVED TO" comments or similar history tracking**
- **ALWAYS keep comments current** - outdated comments are worse than no comments
- **Focus on the "why" and "how"**, not the "what"

### SHOULD (Important)
- **Write comments that add value** - explain business logic, decisions, and non-obvious behavior
- **Avoid obvious comments** - if the code is self-explanatory, don't comment it
- **Use self-documenting code patterns** first, comments second
- **Include JSDoc/docstrings for public APIs and exported functions**

### MAY (Optional)
- **Add actionable TODO comments** with context and timeline
- **Explain complex regex and patterns** when not self-evident

## Examples

### ❌ Migration/History Comments (PROHIBITED)
```typescript
// ❌ Bad - Migration history clutter
// =============================================================================
// IMAGE UTILITIES - MOVED TO chat-utils-client.ts
// =============================================================================
export { validateImageFiles } from "./chat-utils-client";
```

```python
# ❌ Bad - Migration history clutter
# =============================================================================
// DATABASE UTILITIES - MOVED FROM old_db_utils.py
# =============================================================================
from .new_db_utils import get_user_data
```

### ✅ Correct Approach
```typescript
// ✅ Good - Clean and self-explanatory
export { validateImageFiles } from "./chat-utils-client";
```

```python
# ✅ Good - Clean and self-explanatory
from .new_db_utils import get_user_data
```

### ❌ Obvious/Redundant Comments (AVOID)
```typescript
// ❌ Bad - States the obvious
user.name = name;  // Set the user's name
counter++;         // Increment counter by 1
return result;     // Return the result
```

```python
# ❌ Bad - States the obvious
user.name = name    # Set the user's name
counter += 1        # Increment counter by 1
return result       # Return the result
```

### ✅ Business Logic and Requirements (GOOD)
```typescript
function calculateDiscount(orderTotal: number, customerTier: string): number {
  // Premium customers get 15% discount on orders over $100
  // to encourage larger purchases and reward loyalty
  if (customerTier === 'premium' && orderTotal > 100) {
    return orderTotal * 0.15;
  }
  return 0;
}
```

```python
def calculate_discount(order_total: float, customer_tier: str) -> float:
    # Premium customers get 15% discount on orders over $100
    # to encourage larger purchases and reward loyalty
    if customer_tier == 'premium' and order_total > 100:
        return order_total * 0.15
    return 0.0
```

### ✅ Non-Obvious Technical Decisions (GOOD)
```typescript
async function uploadFile(file: File): Promise<UploadResult> {
  // Use chunked upload for files over 10MB to prevent timeout
  // and improve user experience with progress indication
  if (file.size > 10 * 1024 * 1024) {
    return uploadFileChunked(file);
  }
  return uploadFileDirect(file);
}
```

```python
async def upload_file(file: File) -> UploadResult:
    # Use chunked upload for files over 10MB to prevent timeout
    # and improve user experience with progress indication
    if file.size > 10 * 1024 * 1024:
        return await upload_file_chunked(file)
    return await upload_file_direct(file)
```

### ✅ Complex Algorithms or Math (GOOD)
```typescript
function calculateShippingCost(weight: number, distance: number): number {
  // Shipping cost formula: base rate + (weight factor × distance factor)
  // Base rate covers handling, weight accounts for capacity, distance for fuel
  const baseRate = 5.99;
  const weightFactor = weight * 0.1;
  const distanceFactor = distance * 0.05;
  return baseRate + (weightFactor * distanceFactor);
}
```

```python
def calculate_shipping_cost(weight: float, distance: float) -> float:
    # Shipping cost formula: base rate + (weight factor × distance factor)
    # Base rate covers handling, weight accounts for capacity, distance for fuel
    base_rate = 5.99
    weight_factor = weight * 0.1
    distance_factor = distance * 0.05
    return base_rate + (weight_factor * distance_factor)
```

### ✅ Important Warnings and Performance Notes (GOOD)
```typescript
async function deleteUser(userId: string): Promise<void> {
  // CRITICAL: This permanently deletes user data and cannot be undone.
  // All related records will also be deleted due to cascade constraints.
  await db.users.delete({ where: { id: userId } });
}
```

```python
async def delete_user(user_id: str) -> None:
    # CRITICAL: This permanently deletes user data and cannot be undone.
    # All related records will also be deleted due to cascade constraints.
    await db.users.delete(user_id)
```

## Self-Documenting Code Patterns

### Use Descriptive Names Instead of Comments
```typescript
// ❌ Bad - Needs comments
const d = new Date();
const ms = d.getTime();
const s = ms / 1000; // Convert to seconds

// ✅ Good - Self-documenting
const currentDate = new Date();
const milliseconds = currentDate.getTime();
const seconds = milliseconds / 1000;
```

```python
# ❌ Bad - Needs comments
d = datetime.now()
ms = d.timestamp() * 1000
s = ms / 1000  # Convert to seconds

# ✅ Good - Self-documenting
current_date = datetime.now()
milliseconds = current_date.timestamp() * 1000
seconds = milliseconds / 1000
```

### Extract Methods with Clear Names
```typescript
// ❌ Bad - Complex logic needs explanation
function processOrder(order: Order): void {
  // Validate, calculate total, check shipping eligibility...
  if (!order.items || order.items.length === 0) {
    throw new Error("Order must have items");
  }
  // ... more complex logic
}

// ✅ Good - Extracted methods are self-documenting
function processOrder(order: Order): void {
  validateOrderItems(order);
  order.total = calculateTotalWithTax(order.items);
  order.freeShipping = qualifiesForFreeShipping(order);
}
```

```python
# ❌ Bad - Complex logic needs explanation
def process_order(order: Order) -> None:
    # Validate, calculate total, check shipping eligibility...
    if not order.items:
        raise ValueError("Order must have items")
    # ... more complex logic

# ✅ Good - Extracted methods are self-documenting
def process_order(order: Order) -> None:
    validate_order_items(order)
    order.total = calculate_total_with_tax(order.items)
    order.free_shipping = qualifies_for_free_shipping(order)
```

## Language-Specific Documentation

### TypeScript - JSDoc for Public APIs
```typescript
/**
 * Uploads a file with automatic retry and progress tracking
 *
 * @param file - The file to upload
 * @param options - Upload configuration options
 * @returns Promise resolving to upload result with file URL
 * @throws {UploadError} When file size exceeds limit or upload fails
 */
async function uploadFile(file: File, options: UploadOptions = {}): Promise<UploadResult> {
  // Implementation...
}
```

### Python - Docstrings for Public APIs
```python
async def upload_file(file: File, options: UploadOptions = None) -> UploadResult:
    """Upload a file with automatic retry and progress tracking.

    Args:
        file: The file to upload
        options: Upload configuration options

    Returns:
        UploadResult: Upload result with file URL

    Raises:
        UploadError: When file size exceeds limit or upload fails
    """
    # Implementation...
```

## Special Cases

### TODO Comments - Be Actionable
```typescript
// ✅ Good - Actionable TODO with context
// TODO: Add input validation once user requirements are finalized (Sprint 3)
function processUserInput(input: string): void { }

// ❌ Bad - Vague TODO
// TODO: Fix this
```

### Complex Regex and Patterns
```typescript
// ✅ Good - Explain complex regex
// Match email format: local@domain.tld with basic validation
const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
```

```python
# ✅ Good - Explain complex regex
# Match email format: local@domain.tld with basic validation
email_regex = r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
```

## Validation Checklist
- [ ] Comments explain "why" and business logic, not "what" the code does
- [ ] No migration history comments or "MOVED TO" comments
- [ ] No obvious comments that restate what the code clearly shows
- [ ] Self-documenting variable and function names used when possible
- [ ] Comments for complex algorithms, business rules, and non-obvious technical decisions
- [ ] JSDoc/docstrings for public APIs and exported functions
- [ ] Comments updated when refactoring code
- [ ] Focus on future developer understanding, not implementation history

## Enforcement
This rule is enforced through:
- Code review validation
- Automated comment analysis where possible
- Manual review during pull requests

Remember: Comments should focus on helping future developers understand the current implementation and business logic, not the code's history or migration path.