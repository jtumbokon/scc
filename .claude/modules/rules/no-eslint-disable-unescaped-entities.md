---
id: rule-027
type: rule
version: 1.0.0
description: Never disable react/no-unescaped-entities ESLint rule - fix unescaped characters instead of masking the issue
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No ESLint Disable Unescaped Entities Rule (rule-027)

## Purpose
The ESLint rule `react/no-unescaped-entities` prevents rendering raw apostrophes (`'`) and quotation marks (`"`) in JSX/HTML text nodes. These characters can break HTML structure, cause rendering issues, and lead to XSS vulnerabilities. Disabling this rule masks real security and accessibility problems instead of addressing them properly.

## Requirements

### MUST (Critical)
- **NEVER disable** `react/no-unescaped-entities` ESLint rule
- **NEVER use** `/* eslint-disable react/no-unescaped-entities */`
- **NEVER use** `// eslint-disable-next-line react/no-unescaped-entities`
- **ALWAYS fix unescaped characters** using proper HTML entities or JavaScript expressions
- **MAINTAIN accessibility** by ensuring proper text rendering

### SHOULD (Important)
- **Use HTML entities** for typographically correct rendering
- **Prefer semantic entities** like `&rsquo;` over simple escapes
- **Use JavaScript expressions** for dynamic content with problematic characters
- **Test rendering** to ensure text displays correctly across browsers

### MAY (Optional)
- **Restructure sentences** to avoid problematic characters when appropriate
- **Create utility functions** for common escaping patterns
- **Use smart quotes** for better typography in formal content
- **Validate HTML output** for proper entity rendering

## Forbidden Disable Patterns

### ❌ ALL FORMS ARE FORBIDDEN
```jsx
// ❌ FORBIDDEN - All variations of disabling the rule

// File-level disable
/* eslint-disable react/no-unescaped-entities */

// Next-line disable
// eslint-disable-next-line react/no-unescaped-entities

// Block disable with specific rule
/* eslint-disable react/no-unescaped-entities */

// Combined with other rules
/* eslint-disable react/no-unescaped-entities, other-rule */
```

## Proper Fix Strategies

### Strategy 1: HTML Entity Escaping (Preferred)
```jsx
// ✅ GOOD - Use proper HTML entities

// Simple apostrophes
<p>Sarah&rsquo;s workflow</p>
<h1>User&rsquo;s Dashboard</h1>
<span>Don&apos;t forget to save</span>

// Quotation marks
<blockquote>&ldquo;Time-saving&rdquo; tools.</blockquote>
<h3>&ldquo;Best practice&rdquo; guide</h3>
<p>&quot;Important&rdquo; notification</p>

// Mixed characters
<p>The user&rsquo;s &ldquo;new&rdquo; feature</p>
<h2>AI Power Users&rsquo; Biggest Frustration&mdash;</h2>
```

### Strategy 2: JavaScript Expression Wrapping
```jsx
// ✅ GOOD - Wrap in JavaScript expressions

// Direct string expressions
<h2>{"AI Power Users' Biggest Frustration—"}</h2>
<p>{`The user's "new" feature`}</p>
<span>{`${userName}'s Profile`}</span>

// Template literals with variables
<p>{`Today's agenda: ${agendaItems.join(', ')}`}</p>
<h3>{`${title}'s Impact Analysis`}</h3>

// Complex expressions
<div>
  {status === 'success'
    ? 'Operation completed successfully'
    : `Error: "Can't process request"`
  }
</div>
```

### Strategy 3: Sentence Restructuring (When Appropriate)
```jsx
// ✅ GOOD - Restructure to avoid problematic characters

// Instead of: <p>Don't forget to save</p>
<p>Remember to save your work</p>

// Instead of: <h2>Users' Guide to AI</h2>
<h2>Guide to AI for Users</h2>

// Instead of: <p>What's New in Version 2.0</p>
<p>Version 2.0: New Features</p>

// Only when meaning is preserved and context remains clear
```

## React-Specific Patterns

### Dynamic Content with User Input
```jsx
// ❌ BAD - Unescaped user input
function UserProfile({ name, bio }) {
  return (
    <div>
      <h1>{name}'s Profile</h1>
      <p>{bio}</p>
    </div>
  );
}

// ✅ GOOD - Proper escaping for user-generated content
function UserProfile({ name, bio }) {
  return (
    <div>
      <h1>{`${name}'s Profile`}</h1>
      <p>{bio}</p>
    </div>
  );
}

// ✅ EVEN BETTER - Safe content wrapper
function SafeText({ children, className }) {
  if (typeof children !== 'string') {
    return <span className={className}>{children}</span>;
  }

  const safeText = children
    .replace(/'/g, '&rsquo;')
    .replace(/"/g, '&ldquo;$&rdquo;');

  return <span className={className}>{safeText}</span>;
}

// Usage
<SafeText className="title">{`${user.name}'s Dashboard`}</SafeText>
```

### Internationalization Support
```jsx
// ✅ GOOD - i18n-safe patterns
function LocalizedContent({ t, user }) {
  return (
    <div>
      <h1>{t('welcome.title', { name: user.name })}</h1>
      <p>{t('user.stats', {
        count: user.postCount,
        possession: `${user.name}'s`.replace(/'/g, '&rsquo;')
      })}</p>
    </div>
  );
}

// ✅ GOOD - Translation key handling
const translations = {
  'user.profile.title': "{name}'s Profile",
  'error.message': "Can't save the file",
  'quote.message': "\"Best practice\" implementation",
};

function MessageDisplay({ id, params }) {
  const message = translations[id].replace(
    /'([^']+)'/g,
    '&rsquo;$1&rsquo;'
  ).replace(
    /"([^"]+)"/g,
    '&ldquo;$1&rdquo;'
  );

  return <p>{message}</p>;
}
```

### Component Props with Problematic Characters
```jsx
// ❌ BAD - Unescaped characters in props
interface CardProps {
  title: string;
  description: string;
}

function Card({ title, description }: CardProps) {
  return (
    <div>
      <h3>{title}</h3> {/* May contain unescaped quotes */}
      <p>{description}</p> {/* May contain unescaped apostrophes */}
    </div>
  );
}

// ✅ GOOD - Safe component props
interface CardProps {
  title: string;
  description: string;
}

function Card({ title, description }: CardProps) {
  return (
    <div>
      <h3>{title}</h3> {/* Parent component must ensure safe content */}
      <p>{description}</p>
    </div>
  );
}

// ✅ EVEN BETTER - Component with built-in safety
function SafeCard({ title, description }: CardProps) {
  const safeText = (text: string) =>
    text
      .replace(/'/g, '&rsquo;')
      .replace(/"/g, '&ldquo;$&rdquo;');

  return (
    <div>
      <h3>{safeText(title)}</h3>
      <p>{safeText(description)}</p>
    </div>
  );
}
```

## HTML Entity Reference for React

### Essential Entities for JSX
| Character | Entity | Code | Usage | React Support |
|-----------|--------|------|-------|---------------|
| Right Single Quote | `&rsquo;` | Right single quote | Possessives | ✅ Best |
| Apostrophe | `&apos;` | Apostrophe | Simple apostrophes | ✅ Good |
| Single Quote | `&#39;` | Single quote | Fallback | ✅ Acceptable |
| Left Double Quote | `&ldquo;` | Left double quote | Opening quotes | ✅ Best |
| Right Double Quote | `&rdquo;` | Right double quote | Closing quotes | ✅ Best |
| Double Quote | `&quot;` | Double quote | Standard quotes | ✅ Good |
| Double Quote (Numeric) | `&#34;` | Double quote | Fallback | ✅ Acceptable |
| Em Dash | `&mdash;` | Em dash | Parenthetical | ✅ Good |
| En Dash | `&ndash;` | En dash | Ranges | ✅ Good |
| Ampersand | `&amp;` | Ampersand | Required in JSX | ✅ Required |

### Common Patterns
```jsx
// ✅ GOOD - Common usage patterns
<p>&ldquo;Hello World&rdquo;</p>           // "Hello World"
<p>&lsquo;Single quotes&rsquo;</p>        // 'Single quotes'
<p>&ldquo;Nested &rsquo;quotes&rsquo;&rdquo;</p> // "Nested 'quotes'"
<p>&mdash; Important Notice &mdash;</p>    // — Important Notice —
<p>&copy; 2024 Company Name</p>           // © 2024 Company Name
```

## React Component Patterns

### Safe Text Component
```jsx
// ✅ GOOD - Reusable safe text component
interface SafeTextProps {
  children: React.ReactNode;
  className?: string;
  as?: keyof JSX.IntrinsicElements;
}

function SafeText({
  children,
  className,
  as: Component = 'span'
}: SafeTextProps) {
  if (typeof children !== 'string') {
    return <Component className={className}>{children}</Component>;
  }

  const safeText = children
    .replace(/'/g, '&rsquo;')
    .replace(/"/g, '&ldquo;$&rdquo;')
    .replace(/--/g, '&mdash;')
    .replace(/&/g, '&amp;');

  return <Component className={className}>{safeText}</Component>;
}

// Usage examples
<SafeText as="h1" className="title">
  User's Dashboard
</SafeText>

<SafeText as="blockquote">
  "Important message from the team"
</SafeText>
```

### Typography Component
```jsx
// ✅ GOOD - Typography component with built-in safety
interface TypographyProps {
  variant: 'h1' | 'h2' | 'h3' | 'body' | 'quote';
  children: React.ReactNode;
  className?: string;
}

function Typography({ variant, children, className }: TypographyProps) {
  const safeText = (text: string) =>
    text
      .replace(/'/g, '&rsquo;')
      .replace(/"/g, '&ldquo;$&rdquo;')
      .replace(/--/g, '&mdash;');

  const Component = {
    h1: 'h1',
    h2: 'h2',
    h3: 'h3',
    body: 'p',
    quote: 'blockquote'
  }[variant];

  const content = typeof children === 'string'
    ? safeText(children)
    : children;

  return <Component className={className}>{content}</Component>;
}

// Usage
<Typography variant="h1">
  User's Complete Guide to AI
</Typography>

<Typography variant="quote">
  "The future belongs to those who prepare for it today"
</Typography>
```

## Testing Strategies

### Component Testing with Problematic Characters
```jsx
// ✅ GOOD - Test components with various character combinations
describe('SafeText Component', () => {
  it('handles apostrophes correctly', () => {
    const { getByText } = render(
      <SafeText>User's Dashboard</SafeText>
    );

    expect(getByText("User's Dashboard")).toBeInTheDocument();
  });

  it('handles quotation marks correctly', () => {
    const { getByText } = render(
      <SafeText>"Important message"</SafeText>
    );

    expect(getByText('"Important message"')).toBeInTheDocument();
  });

  it('handles mixed special characters', () => {
    const { getByText } = render(
      <SafeText>User's "new" feature—amazing!</SafeText>
    );

    expect(getByText('User\'s "new" feature—amazing!')).toBeInTheDocument();
  });
});
```

### Accessibility Testing
```jsx
// ✅ GOOD - Ensure screen readers read content correctly
describe('Accessibility', () => {
  it('announces text content properly to screen readers', () => {
    const { container } = render(
      <Typography variant="h1">
        Sarah's Complete Guide to AI
      </Typography>
    );

    expect(container).toHaveTextContent('Sarah\'s Complete Guide to AI');

    // Test that HTML entities are properly rendered
    const h1 = container.querySelector('h1');
    expect(h1?.innerHTML).toBe('Sarah&rsquo;s Complete Guide to AI');
  });
});
```

## Migration Guide

### Step 1: Identify Problematic Usage
```bash
# Find files with the forbidden disable directive
grep -r "eslint-disable.*no-unescaped-entities" src/ --include="*.tsx"

# Find JSX with unescaped characters
grep -r "'" src/components --include="*.tsx" | grep -v "&apos;"
grep -r '"' src/components --include="*.tsx" | grep -v "&quot;"
```

### Step 2: Remove Disable Directives
```jsx
// ❌ BEFORE
/* eslint-disable react/no-unescaped-entities */
function UserProfile({ name }) {
  return <h1>{name}'s Profile</h1>;
}

// ✅ AFTER - Remove disable directive
function UserProfile({ name }) {
  return <h1>{`${name}'s Profile`}</h1>;
}
```

### Step 3: Apply Proper Escaping
```jsx
// Apply one of the three strategies:

// Strategy 1: HTML entities
<h1>Sarah&rsquo;s Profile</h1>

// Strategy 2: JavaScript expressions
<h1>{`${name}'s Profile`}</h1>

// Strategy 3: Restructure
<h1>Profile for {name}</h1>
```

### Step 4: Validate Changes
```bash
# Run linter to ensure no violations
npm run lint

# Test components render correctly
npm test

# Verify HTML output
npm run build && check output
```

## Real-World Examples

### User Dashboard
```jsx
// ❌ BAD
/* eslint-disable react/no-unescaped-entities */
function UserDashboard({ user }) {
  return (
    <div>
      <h1>{user.name}'s Dashboard</h1>
      <p>Welcome to your "personal" workspace</p>
      <blockquote>"Today's goals: {user.goals.join(', ')}"</blockquote>
    </div>
  );
}

// ✅ GOOD
function UserDashboard({ user }) {
  return (
    <div>
      <h1>{`${user.name}'s Dashboard`}</h1>
      <p>Welcome to your &ldquo;personal&rdquo; workspace</p>
      <blockquote>&ldquo;Today's goals: {user.goals.join(', ')}&rdquo;</blockquote>
    </div>
  );
}
```

### Product Listing
```jsx
// ❌ BAD
function ProductCard({ product }) {
  return (
    <div>
      <h3>{product.name}</h3>
      <p>{product.description}</p>
      <span>{product.tagline}</span>
    </div>
  );
}

// ✅ GOOD - With built-in safety
function ProductCard({ product }) {
  const safeText = (text: string) =>
    text
      .replace(/'/g, '&rsquo;')
      .replace(/"/g, '&ldquo;$&rdquo;')
      .replace(/--/g, '&mdash;');

  return (
    <div>
      <h3>{safeText(product.name)}</h3>
      <p>{safeText(product.description)}</p>
      <span>{safeText(product.tagline)}</span>
    </div>
  );
}
```

## Validation Checklist
- [ ] No `eslint-disable react/no-unescaped-entities` directives anywhere
- [ ] All JSX text nodes are free of unescaped apostrophes and quotes
- [ ] HTML entities are used correctly for static content
- [ ] JavaScript expressions wrap dynamic content with problematic characters
- [ ] Components render correctly in all browsers
- [ ] Screen readers announce text content properly
- [ ] HTML output validates without entity errors
- [ ] Accessibility tests pass for text content

## Enforcement
This rule is enforced through:
- ESLint `react/no-unescaped-entities` rule configuration
- Pre-commit hooks that prevent disabling the rule
- Code review validation
- Automated testing for component rendering
- Accessibility testing in CI/CD pipeline

By properly escaping entities instead of disabling the rule, we maintain security, accessibility, and proper HTML rendering across all React components.