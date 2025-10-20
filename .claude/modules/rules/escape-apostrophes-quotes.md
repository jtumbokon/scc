---
id: rule-023
type: rule
version: 1.0.0
description: Escape apostrophes and quotes in JSX/HTML text nodes to prevent linter warnings and ensure proper rendering
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# Escape Apostrophes and Quotes Rule (rule-023)

## Purpose
Un-escaped apostrophes (`'`) and quotation marks (`"`) inside JSX/HTML text nodes trigger linter warnings and can cause rendering issues. Proper escaping ensures clean HTML output and prevents linting violations.

## Requirements

### MUST (Critical)
- **Never use raw apostrophes** inside JSX/HTML text nodes
- **Never use raw quotation marks** inside JSX/HTML text nodes
- **Always escape or wrap problematic characters** using approved methods
- **Apply this rule to all JSX/HTML** including Markdown that will be rendered as HTML

### SHOULD (Important)
- **Use HTML entities** for typographically correct rendering
- **Prefer JavaScript expressions** when dealing with dynamic content
- **Use semantic HTML entities** (like `&rsquo;` vs `&apos;`) for better typography
- **Maintain consistent escaping patterns** throughout the application

### MAY (Optional)
- **Rewrite sentences** to avoid problematic characters when possible
- **Use smart quotes** (`&ldquo;`, `&rdquo;`) for better typography
- **Create utility functions** for common escaping patterns

## Escaping Strategies

### 1. HTML Entity Escaping (Preferred)
```jsx
// ✅ Good - Use HTML entities for proper typography
<p>Sarah&rsquo;s workflow</p>
<p>&ldquo;Time-saving&rdquo; tools.</p>
<p>The user&rsquo;s guide to AI &amp; automation</p>
<p>&quot;Best practice&quot; implementation</p>

// Acceptable alternatives
<p>Sarah&apos;s workflow</p>          // Simple apostrophe
<p>Sarah&#39;s workflow</p>          // Numeric entity
<p>&quot;Quote&quote;</p>            // Standard quotes
<p>&ldquo;Smart quotes&rdquo;</p>    // Typography
```

### 2. JavaScript Expression Wrapping
```jsx
// ✅ Good - Wrap in JavaScript expressions
<h2>{"AI Power Users' Biggest Frustration—"}</h2>
<p>{`The user's data has been processed`}</p>
<span>{"Don't forget to save your work"}</span>
<div>{`"Important" notification`}</div>

// With template literals
<p>{`Today's agenda: ${agendaItems.join(', ')}`}</p>
<h3>{`${user.name}'s Dashboard`}</h3>
```

### 3. Sentence Restructuring (When Appropriate)
```jsx
// ✅ Good - Restructure to avoid problematic characters
// Instead of: <p>Don't forget to save</p>
<p>Remember to save your work</p>

// Instead of: <h2>Users' Guide to AI</h2>
<h2>Guide to AI for Users</h2>

// Only when meaning is preserved
```

## Examples

### ❌ Bad - Unescaped Characters
```jsx
// ❌ Bad - Raw apostrophes in text nodes
<p>Sarah's workflow</p>
<h2>User's Dashboard</h2>
<span>Don't forget to save</span>

// ❌ Bad - Raw quotes in text nodes
<p>"Time-saving" tools</p>
<h3>"Best practice" guide</h3>
<div>The "quick" brown fox</div>

// ❌ Bad - Mixed unescaped characters
<p>The user's "new" feature</p>
<h2>AI Power Users' Biggest Frustration—</h2>
```

### ✅ Good - Properly Escaped
```jsx
// ✅ Good - HTML entities for typography
<p>Sarah&rsquo;s workflow</p>
<h2>User&rsquo;s Dashboard</h2>
<span>Don&apos;t forget to save</span>

// ✅ Good - Proper quote escaping
<p>&ldquo;Time-saving&rdquo; tools</p>
<h3>&ldquo;Best practice&rdquo; guide</h3>
<div>The &ldquo;quick&rdquo; brown fox</div>

// ✅ Good - JavaScript expressions
<h2>{"AI Power Users' Biggest Frustration—"}</h2>
<p>{`The user's "new" feature`}</p>
<span>{`${userName}'s Profile`}</span>

// ✅ Good - Smart quotes for better typography
<p>&ldquo;Hello,&rdquo; she said.</p>
<h3>&ldquo;State of the Art&rdquo; Technology</h3>
```

## Advanced Patterns

### Dynamic Content Handling
```jsx
// ✅ Good - Handle dynamic content with expressions
function UserGreeting({ name, title }) {
  return (
    <div>
      <h1>{`${title}'s Dashboard`}</h1>
      <p>Welcome, {name}!</p>
      <p>{`Today's tasks: ${taskCount} items`}</p>
    </div>
  );
}

// ✅ Good - Conditional content with proper escaping
function StatusMessage({ status }) {
  return (
    <p>
      {status === 'success'
        ? 'Operation completed successfully'
        : `Error: ${status}`
      }
    </p>
  );
}
```

### Internationalization Support
```jsx
// ✅ Good - i18n-safe patterns
function LocalizedContent({ t, user }) {
  return (
    <div>
      <h1>{t('welcome.title', { name: user.name })}</h1>
      <p>{t('user.greeting', {
        possession: `${user.name}'s`.replace(/'/g, '&rsquo;')
      })}</p>
    </div>
  );
}

// ✅ Good - Translation keys with proper escaping
const messages = {
  'user.profile.title': "{name}'s Profile",
  'error.message': "Can't save the file",
};

function MessageDisplay({ id, params }) {
  const message = messages[id].replace(
    /'([^']+)'/g,
    '&rsquo;$1&rsquo;'
  );
  return <p>{message}</p>;
}
```

### Content from APIs
```jsx
// ✅ Good - Sanitize external content
function DisplayContent({ content }) {
  const sanitized = content
    .replace(/'/g, '&rsquo;')
    .replace(/"/g, '&quot;');

  return <p>{sanitized}</p>;
}

// ✅ Good - Use dangerousHTML with caution and proper escaping
import { dangerouslySetInnerHTML } from 'react';

function RichContent({ html }) {
  const escaped = html
    .replace(/'/g, '&rsquo;')
    .replace(/"/g, '&quot;');

  return (
    <div dangerouslySetInnerHTML={{ __html: escaped }} />
  );
}
```

## HTML Entity Reference

### Apostrophes
| Entity | Code | Usage | Recommendation |
|--------|------|-------|----------------|
| Right Single Quote | `&rsquo;` | Typography, possessives | **Best** - Modern typography |
| Apostrophe | `&apos;` | Standard apostrophe | Good - Simple alternative |
| Single Quote | `&#39;` | Numeric fallback | Acceptable - Universal support |

### Quotation Marks
| Entity | Code | Usage | Recommendation |
|--------|------|-------|----------------|
| Left Double Quote | `&ldquo;` | Opening quotes | **Best** - Typography |
| Right Double Quote | `&rdquo;` | Closing quotes | **Best** - Typography |
| Double Quote | `&quot;` | Standard quotes | Good - Simple alternative |
| Double Quote (Numeric) | `&#34;` | Numeric fallback | Acceptable - Universal support |

### Common Combinations
```jsx
// ✅ Good - Common patterns
<p>&ldquo;Hello World&rdquo;</p>           // "Hello World"
<p>&lsquo;Single quotes&rsquo;</p>        // 'Single quotes'
<p>&ldquo;Nested &rsquo;quotes&rsquo;&rdquo;</p> // "Nested 'quotes'"
```

## Component Patterns

### Typography Component
```jsx
// ✅ Good - Create reusable typography component
function Typography({
  children,
  variant = 'body',
  ...props
}) {
  const content = typeof children === 'string'
    ? children
        .replace(/'/g, '&rsquo;')
        .replace(/"/g, '&quot;')
    : children;

  const Component = {
    h1: 'h1',
    h2: 'h2',
    h3: 'h3',
    body: 'p',
    quote: 'blockquote'
  }[variant];

  return <Component {...props}>{content}</Component>;
}

// Usage
<Typography variant="h1">User's Dashboard</Typography>
<Typography variant="quote">"Best practice" approach</Typography>
```

### Smart Text Wrapper
```jsx
// ✅ Good - Utility function for safe text rendering
function SafeText({ children, ...props }) {
  if (typeof children !== 'string') {
    return <span {...props}>{children}</span>;
  }

  const safeText = children
    .replace(/'/g, '&rsquo;')
    .replace(/"/g, '&ldquo;$&rdquo;');

  return <span {...props}>{safeText}</span>;
}

// Usage
<SafeText className="title">User's Profile</SafeText>
<SafeText className="quote">"Important message"</SafeText>
```

## Migration Guide

### Step 1: Identify Problematic Text
```bash
# Find JSX files with unescaped quotes
grep -r "'" src/components --include="*.tsx" | grep -v "&apos;"
grep -r '"' src/components --include="*.tsx" | grep -v "&quot;"
```

### Step 2: Apply Escaping Strategy
```jsx
// Before
<p>Sarah's workflow</p>
<h2>"Important" notice</h2>

// After - Strategy 1: HTML Entities
<p>Sarah&rsquo;s workflow</p>
<h2>&ldquo;Important&rdquo; notice</h2>

// After - Strategy 2: JavaScript Expressions
<p>{"Sarah's workflow"}</p>
<h2>{"Important notice"}</h2>
```

### Step 3: Validate Rendering
```jsx
// Test component renders correctly
// Check HTML output for proper entities
// Verify linter passes without warnings
```

## Linter Configuration

### ESLint Rules
```json
{
  "rules": {
    "react/no-unescaped-entities": "error",
    "jsx-a11y/alt-text": "error"
  }
}
```

### Custom ESLint Rule (Optional)
```javascript
module.exports = {
  rules: {
    'no-raw-quotes': {
      meta: {
        type: 'error',
        docs: {
          description: 'Prevent raw quotes in JSX text nodes'
        }
      },
      create(context) {
        return {
          JSXText(node) {
            if (node.value.includes("'") || node.value.includes('"')) {
              context.report({
                node,
                message: 'Raw quotes in JSX text nodes should be escaped'
              });
            }
          }
        };
      }
    }
  }
};
```

## Validation Checklist
- [ ] All JSX/HTML text nodes are scanned for raw quotes and apostrophes
- [ ] Proper HTML entities are used for static content
- [ ] JavaScript expressions are used for dynamic content
- [ ] No linter warnings for unescaped entities
- [ ] HTML output validates correctly
- [ ] Typography is maintained across different browsers
- [ ] Internationalization support is preserved
- [ ] Accessibility standards are met

## Enforcement
This rule is enforced through:
- ESLint `react/no-unescaped-entities` rule
- Code review validation
- Automated testing for component rendering
- HTML validation in build process
- Accessibility testing

Proper escaping of apostrophes and quotes ensures clean HTML output, prevents linter warnings, and maintains consistent typography across all rendered content.