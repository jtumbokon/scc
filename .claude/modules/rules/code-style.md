---
id: rule-005
type: rule
version: 1.0.0
description: Defines consistent code formatting, organization, and style standards across all languages
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Code Style Rule (rule-005)

## Purpose
Establish consistent code formatting, organization, and style standards to improve readability, maintainability, and team collaboration across all programming languages and projects.

## General Principles

### 1. Readability First
- Code should be self-documenting
- Clear, descriptive names over clever abbreviations
- Consistent formatting throughout codebase
- Logical organization of code elements

### 2. Consistency
- Follow established patterns within the codebase
- Use the same style across all files
- Maintain consistent indentation and spacing
- Uniform naming conventions

### 3. Simplicity
- Write straightforward code that's easy to understand
- Avoid unnecessary complexity
- Use language features appropriately
- Keep functions and classes focused

## Formatting Standards

### Line Length and Wrapping
- **Maximum line length**: 90 characters
- **Indentation**: 2 spaces for JavaScript/TypeScript, 4 spaces for Python
- **Tab characters**: Never use tabs, only spaces

```javascript
// ✅ GOOD - Proper line length and wrapping
function processUserOrder(userId, orderItems, shippingAddress, paymentMethod) {
  const order = {
    userId,
    items: orderItems.map(item => ({
      productId: item.id,
      quantity: item.quantity,
      price: calculateDiscountedPrice(item.price, item.discount)
    })),
    shipping: {
      address: formatShippingAddress(shippingAddress),
      method: determineShippingMethod(shippingAddress)
    },
    payment: {
      method: paymentMethod.type,
      amount: calculateTotalAmount(orderItems),
      currency: 'USD'
    },
    createdAt: new Date().toISOString()
  };

  return orderRepository.create(order);
}

// ❌ BAD - Lines too long, inconsistent wrapping
function processUserOrder(userId, orderItems, shippingAddress, paymentMethod) {
  const order = { userId, items: orderItems.map(item => ({ productId: item.id, quantity: item.quantity, price: calculateDiscountedPrice(item.price, item.discount) })), shipping: { address: formatShippingAddress(shippingAddress), method: determineShippingMethod(shippingAddress) }, payment: { method: paymentMethod.type, amount: calculateTotalAmount(orderItems), currency: 'USD' }, createdAt: new Date().toISOString() };
  return orderRepository.create(order);
}
```

### Spacing and Blank Lines
- **Single blank line** between logical sections
- **Two blank lines** between top-level definitions
- **No trailing whitespace** at end of lines
- **Single space** after commas in lists

```javascript
// ✅ GOOD - Proper spacing
import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

import { userService } from '../services/userService';
import { validationService } from '../services/validationService';

const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const router = useRouter();

  useEffect(() => {
    loadUser(userId);
  }, [userId]);

  const loadUser = async (id) => {
    try {
      setLoading(true);
      const userData = await userService.getUserById(id);
      setUser(userData);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
};

export default UserProfile;

// ❌ BAD - Inconsistent spacing, no logical separation
import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { userService } from '../services/userService';
import { validationService } from '../services/validationService';
const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const router = useRouter();
  useEffect(() => {
    loadUser(userId);
  }, [userId]);
  const loadUser = async (id) => {
    try { setLoading(true); const userData = await userService.getUserById(id); setUser(userData); } catch (err) { setError(err.message); } finally { setLoading(false); } };
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  return <div className="user-profile"><h1>{user.name}</h1><p>{user.email}</p></div>;
};
export default UserProfile;
```

## Code Organization

### File Structure
```
src/
├── components/
│   ├── common/
│   │   ├── Button/
│   │   │   ├── Button.jsx
│   │   │   ├── Button.test.jsx
│   │   │   ├── Button.stories.jsx
│   │   │   └── index.js
│   │   └── Input/
│   │       ├── Input.jsx
│   │       ├── Input.test.jsx
│   │       └── index.js
│   └── features/
│       ├── UserProfile/
│       │   ├── UserProfile.jsx
│       │   ├── UserProfile.test.jsx
│       │   └── index.js
│       └── ShoppingCart/
│           ├── ShoppingCart.jsx
│           ├── ShoppingCart.test.jsx
│           └── index.js
├── services/
│   ├── api/
│   │   ├── userService.js
│   │   ├── productService.js
│   │   └── orderService.js
│   └── utils/
│       ├── validation.js
│       ├── formatting.js
│       └── constants.js
├── hooks/
│   ├── useAuth.js
│   ├── useLocalStorage.js
│   └── useDebounce.js
├── styles/
│   ├── globals.css
│   ├── components.css
│   └── utilities.css
└── utils/
    ├── helpers.js
    ├── formatters.js
    └── validators.js
```

### Import Organization
1. **Node.js built-in modules** (fs, path, etc.)
2. **Third-party libraries** (react, lodash, etc.)
3. **Internal modules** (services, components, etc.)
4. **Relative imports** (./, ../)
5. **Type imports** (type only imports last)

```javascript
// ✅ GOOD - Organized imports
// Node.js built-in
import fs from 'fs';
import path from 'path';

// Third-party libraries
import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import clsx from 'clsx';

// Internal modules
import { userService } from '../services/userService';
import { validationService } from '../services/validationService';
import { Button } from '../components/common/Button';
import { Input } from '../components/common/Input';

// Relative imports
import { formatUserName } from './formatters';
import { validateEmail } from './validators';

// Type imports
import type { User } from '../types/user';
import type { FormField } from '../types/form';

// ❌ BAD - Disorganized imports
import { Button } from '../components/common/Button';
import React, { useState, useEffect } from 'react';
import { userService } from '../services/userService';
import { useRouter } from 'next/router';
import path from 'path';
import { formatUserName } from './formatters';
import type { User } from '../types/user';
import { validateEmail } from './validators';
import fs from 'fs';
import clsx from 'clsx';
```

### Function and Class Organization
- **Constants** at the top of the file
- **Helper functions** before main functions
- **Public API** functions after private helpers
- **Class methods**: constructor first, then public, then private

```javascript
// ✅ GOOD - Well-organized class
class OrderService {
  constructor(database, emailService, paymentService) {
    this.database = database;
    this.emailService = emailService;
    this.paymentService = paymentService;
  }

  // Public methods
  async createOrder(orderData) {
    const validatedOrder = this.validateOrderData(orderData);
    const order = await this.saveOrder(validatedOrder);
    await this.sendOrderConfirmation(order);
    return order;
  }

  async updateOrderStatus(orderId, newStatus) {
    const order = await this.getOrderById(orderId);
    if (!order) {
      throw new NotFoundError(`Order not found: ${orderId}`);
    }

    const updatedOrder = await this.database.orders.update(orderId, {
      status: newStatus,
      updatedAt: new Date()
    });

    await this.notifyStatusChange(updatedOrder);
    return updatedOrder;
  }

  async getOrderById(orderId) {
    return await this.database.orders.findById(orderId);
  }

  // Private helper methods
  validateOrderData(orderData) {
    if (!orderData.items || orderData.items.length === 0) {
      throw new ValidationError('Order must contain at least one item');
    }

    return {
      ...orderData,
      total: this.calculateOrderTotal(orderData.items),
      status: 'pending',
      createdAt: new Date()
    };
  }

  calculateOrderTotal(items) {
    return items.reduce((total, item) => {
      return total + (item.price * item.quantity);
    }, 0);
  }

  async saveOrder(orderData) {
    return await this.database.orders.create(orderData);
  }

  async sendOrderConfirmation(order) {
    await this.emailService.sendOrderConfirmation(order.customerEmail, order);
  }

  async notifyStatusChange(order) {
    await this.emailService.sendStatusUpdate(order.customerEmail, order);
  }
}
```

## Commenting Standards

### Comment Philosophy
- **Explain WHY, not WHAT** - Code should explain what it does
- **Document complex business logic** - Help others understand the reasoning
- **Mark TODO/FIXME items** - Track work that needs to be done
- **Avoid obvious comments** - Don't comment self-evident code

```javascript
// ✅ GOOD - Meaningful comments
class PaymentProcessor {
  constructor(paymentGateway) {
    this.gateway = paymentGateway;
  }

  async processPayment(order) {
    // Validate payment amount matches order total to prevent overcharging
    if (order.payment.amount !== order.total) {
      throw new ValidationError('Payment amount does not match order total');
    }

    // Use retry logic for network failures, but not for validation errors
    const maxRetries = 3;
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const result = await this.gateway.charge(order.payment);

        // Log successful payment for audit trail
        await this.logPaymentSuccess(order.id, result.transactionId);

        return result;
      } catch (error) {
        // Don't retry authentication failures - they won't succeed
        if (error.code === 'AUTHENTICATION_FAILED') {
          throw error;
        }

        // Log retry attempt for monitoring
        if (attempt < maxRetries) {
          await this.logRetryAttempt(order.id, attempt, error);
        }

        if (attempt === maxRetries) {
          throw new PaymentError('Payment processing failed after retries', error);
        }
      }
    }
  }

  // TODO: Implement refund logic with proper idempotency
  // FIXME: Handle currency conversion for international orders
}

// ❌ BAD - Obvious or redundant comments
class PaymentProcessor {
  constructor(paymentGateway) {
    this.gateway = paymentGateway; // Initialize payment gateway
  }

  async processPayment(order) {
    // Check if payment amount equals order total
    if (order.payment.amount !== order.total) {
      throw new ValidationError('Payment amount does not match order total');
    }

    // Try to charge the payment
    const result = await this.gateway.charge(order.payment);

    // Return the result
    return result;
  }
}
```

### Documentation Comments
- Use JSDoc format for JavaScript/TypeScript
- Include parameter types and return types
- Document examples for complex functions
- Mark deprecated methods clearly

```javascript
// ✅ GOOD - Comprehensive JSDoc
/**
 * Creates a new user account with the provided user data.
 *
 * @example
 * const user = await userService.createUser({
 *   email: 'user@example.com',
 *   password: 'securePassword123',
 *   name: 'John Doe'
 * });
 *
 * @param {CreateUserData} userData - The user data for account creation
 * @param {string} userData.email - User's email address (must be valid format)
 * @param {string} userData.password - User's password (min 12 characters)
 * @param {string} userData.name - User's full name
 * @param {string} [userData.phone] - Optional phone number
 * @returns {Promise<User>} The created user object
 * @throws {ValidationError} When input data is invalid
 * @throws {DuplicateEmailError} When email already exists
 * @deprecated Use createUserWithProfile instead for better user experience
 */
async function createUser(userData) {
  // Implementation...
}
```

## Naming Conventions

### Variable and Function Names
```javascript
// ✅ GOOD - Descriptive, clear names
const isActiveUser = true;
const userProfileData = await getUserProfile(userId);
const shouldShowNotification = hasUnreadMessages;

function calculateDiscountedPrice(originalPrice, discountPercentage) {
  return originalPrice * (1 - discountPercentage / 100);
}

function isEmailValid(email) {
  return email.includes('@') && email.includes('.');
}

// ❌ BAD - Vague or abbreviated names
const flag = true;
const upd = await getUserProfile(userId);
const shw = hasUnreadMessages;

function calcPrice(p, d) {
  return p * (1 - d / 100);
}

function chkEmail(e) {
  return e.includes('@') && e.includes('.');
}
```

### Class and Component Names
```javascript
// ✅ GOOD - Descriptive class names
class UserService { }
class PaymentProcessor { }
class EmailNotificationSender { }
class UserAuthenticationService { }

class UserProfile extends React.Component { }
class ShoppingCart extends React.Component { }
class OrderHistoryTable extends React.Component { }

// ❌ BAD - Vague class names
class User { }  // Too generic
class Process { }  // Too generic
class Service { }  // Too generic
class Manager { }  // Too generic
```

## Language-Specific Guidelines

### JavaScript/TypeScript
```typescript
// ✅ GOOD - TypeScript best practices
interface UserData {
  id: number;
  email: string;
  name: string;
  createdAt: Date;
  updatedAt?: Date;
}

class UserService {
  private readonly database: Database;

  constructor(database: Database) {
    this.database = database;
  }

  public async createUser(userData: Omit<UserData, 'id' | 'createdAt'>): Promise<UserData> {
    const newUser: UserData = {
      ...userData,
      id: this.generateId(),
      createdAt: new Date()
    };

    return await this.database.users.create(newUser);
  }

  private generateId(): number {
    return Math.floor(Math.random() * 1000000);
  }
}

// ✅ GOOD - Modern JavaScript features
const processUsers = async (users: UserData[]): Promise<UserData[]> => {
  const processedUsers = await Promise.all(
    users.map(async (user) => {
      const enrichedUser = await enrichUserData(user);
      return validateUserData(enrichedUser);
    })
  );

  return processedUsers.filter(Boolean);
};
```

### Python
```python
# ✅ GOOD - Python best practices
from typing import List, Dict, Optional
from dataclasses import dataclass
from datetime import datetime

@dataclass
class UserData:
    id: int
    email: str
    name: str
    created_at: datetime
    updated_at: Optional[datetime] = None

class UserService:
    def __init__(self, database: Database) -> None:
        self._database = database

    async def create_user(self, user_data: Dict[str, str]) -> UserData:
        """Create a new user with the provided data."""
        validated_data = self._validate_user_data(user_data)

        new_user = UserData(
            id=self._generate_id(),
            email=validated_data["email"],
            name=validated_data["name"],
            created_at=datetime.utcnow()
        )

        return await self._database.users.create(new_user)

    def _validate_user_data(self, user_data: Dict[str, str]) -> Dict[str, str]:
        """Validate user input data."""
        if not user_data.get("email"):
            raise ValueError("Email is required")

        if "@" not in user_data["email"]:
            raise ValueError("Invalid email format")

        return user_data

    def _generate_id(self) -> int:
        """Generate a unique user ID."""
        return random.randint(1, 1000000)

# ✅ GOOD - Type hints and proper docstrings
def process_user_data(users: List[UserData]) -> List[UserData]:
    """
    Process a list of user data by applying business rules.

    Args:
        users: List of user data to process

    Returns:
        List of processed user data

    Raises:
        ValueError: If user data is invalid
    """
    processed_users = []

    for user in users:
        try:
            enriched_user = enrich_user_data(user)
            validated_user = validate_user_data(enriched_user)
            processed_users.append(validated_user)
        except ValueError as error:
            logger.warning(f"Skipping invalid user {user.id}: {error}")

    return processed_users
```

## Import and Export Standards

### Named Exports vs Default Exports
```javascript
// ✅ GOOD - Use named exports for utilities
// utils/validation.js
export const validateEmail = (email) => { /* ... */ };
export const validatePhone = (phone) => { /* ... */ };
export const validatePassword = (password) => { /* ... */ };

// Use default export for main component
// components/UserProfile.jsx
export default UserProfile;

// ✅ GOOD - Clear import statements
import { validateEmail, validatePhone } from '../utils/validation';
import UserProfile from '../components/UserProfile';

// ❌ BAD - Mixed export styles, unclear imports
export default validateEmail;
export const validatePhone = (phone) => { /* ... */ };

import validateEmail from '../utils/validation';
import { validatePhone } from '../utils/validation';
```

### Barrel Exports
```javascript
// ✅ GOOD - Organized barrel exports
// services/index.js
export { default as userService } from './userService';
export { default as productService } from './productService';
export { default as orderService } from './orderService';

// components/index.js
export { default as Button } from './common/Button';
export { default as Input } from './common/Input';
export { default as UserProfile } from './features/UserProfile';
export { default as ShoppingCart } from './features/ShoppingCart';

// Clean imports
import { userService, productService } from '../services';
import { Button, UserProfile } from '../components';
```

## Code Quality Standards

### Error Handling Style
```javascript
// ✅ GOOD - Consistent error handling
async function processOrder(orderData) {
  try {
    const validatedOrder = validateOrder(orderData);
    const savedOrder = await orderRepository.create(validatedOrder);
    await notificationService.sendOrderConfirmation(savedOrder);

    return savedOrder;
  } catch (error) {
    if (error instanceof ValidationError) {
      logger.error('Order validation failed', { orderData, error: error.message });
      throw new OrderProcessingError('Invalid order data', { cause: error });
    }

    logger.error('Unexpected error processing order', { orderData, error: error.message });
    throw new OrderProcessingError('Unable to process order', { cause: error });
  }
}
```

### Async/Await Patterns
```javascript
// ✅ GOOD - Clear async patterns
async function loadUserData(userId) {
  const user = await userService.getUserById(userId);
  const profile = await userService.getUserProfile(userId);
  const preferences = await userService.getUserPreferences(userId);

  return { user, profile, preferences };
}

// ✅ GOOD - Parallel async operations when possible
async function loadUserDataParallel(userId) {
  const [user, profile, preferences] = await Promise.all([
    userService.getUserById(userId),
    userService.getUserProfile(userId),
    userService.getUserPreferences(userId)
  ]);

  return { user, profile, preferences };
}
```

## Tool Configuration

### ESLint Configuration
```json
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "max-len": ["error", { "code": 90 }],
    "indent": ["error", 2],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "comma-dangle": ["error", "never"],
    "object-curly-spacing": ["error", "always"],
    "no-trailing-spaces": "error",
    "eol-last": "error"
  }
}
```

### Prettier Configuration
```json
{
  "semi": true,
  "trailingComma": "none",
  "singleQuote": true,
  "printWidth": 90,
  "tabWidth": 2,
  "useTabs": false
}
```

### Python Configuration (pyproject.toml)
```toml
[tool.black]
line-length = 90
target-version = ['py311']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
line_length = 90
multi_line_output = 3
include_trailing_comma = false
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
```

## Review Checklist

### Before Committing
- [ ] All lines are under 90 characters
- [ ] Consistent indentation (2 spaces for JS/TS, 4 for Python)
- [ ] Proper import organization
- [ ] Meaningful variable and function names
- [ ] Appropriate comments explaining complex logic
- [ ] No trailing whitespace
- [ ] Consistent error handling patterns
- [ ] Proper async/await usage
- [ ] Type annotations where applicable
- [ ] Code formatting tools applied

### Code Review Focus
- **Readability**: Is the code easy to understand?
- **Consistency**: Does it follow established patterns?
- **Maintainability**: Will it be easy to modify later?
- **Performance**: Are there obvious performance issues?
- **Security**: Are there security vulnerabilities?
- **Testing**: Is the code testable and tested?

---

**This rule ensures consistent, readable, and maintainable code across all projects and programming languages.**