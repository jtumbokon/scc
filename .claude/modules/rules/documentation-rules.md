---
id: rule-006
type: rule
version: 1.0.0
description: Establishes comprehensive documentation standards for code, APIs, and project documentation
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Documentation Rules (rule-006)

## Purpose
Establish comprehensive documentation standards to ensure code is well-documented, APIs are clearly understood, and project knowledge is properly captured and maintained.

## Documentation Philosophy

### 1. Documentation as Code
- Documentation should live alongside code
- Keep documentation in sync with code changes
- Use version control for documentation
- Automated documentation generation where possible

### 2. Audience Awareness
- Write for the intended audience
- Provide appropriate level of detail
- Include examples and use cases
- Consider different skill levels

### 3. Living Documentation
- Documentation should evolve with the codebase
- Regular reviews and updates
- Remove outdated information
- Add new features promptly

## README Standards

### Project README Structure
```markdown
# Project Name

Brief, compelling description of what this project does and why it exists.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Configuration](#configuration)
- [Examples](#examples)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✅ Feature 1 with brief description
- ✅ Feature 2 with brief description
- ✅ Feature 3 with brief description

## Installation

### Prerequisites
- Node.js 16+
- PostgreSQL 13+
- Redis 6+

### Quick Start
\`\`\`bash
# Clone the repository
git clone https://github.com/username/project-name.git
cd project-name

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
npm run db:migrate

# Start the application
npm start
\`\`\`

### Docker Installation
\`\`\`bash
# Build and run with Docker Compose
docker-compose up -d
\`\`\`

## Usage

### Basic Usage
\`\`\`javascript
import { ProjectService } from 'project-name';

const service = new ProjectService({
  apiKey: 'your-api-key',
  baseUrl: 'https://api.example.com'
});

const result = await service.processData(input);
console.log(result);
\`\`\`

### Advanced Configuration
\`\`\`javascript
const service = new ProjectService({
  apiKey: 'your-api-key',
  baseUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
  cache: {
    enabled: true,
    ttl: 300
  }
});
\`\`\`

## API Reference

### Methods

#### `processData(input, options?)`
Processes the provided input data.

**Parameters:**
- `input` (Object): The input data to process
- `options` (Object, optional): Configuration options
  - `format` (string): Output format ('json', 'xml', 'csv')
  - `validate` (boolean): Enable input validation (default: true)

**Returns:**
- `Promise<Object>`: Processed data result

**Example:**
\`\`\`javascript
const result = await service.processData(
  { name: 'John', age: 30 },
  { format: 'json', validate: true }
);
\`\`\`

## Configuration

### Environment Variables
\`\`\`bash
# Required
API_KEY=your-secret-api-key
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Optional
LOG_LEVEL=info
CACHE_TTL=300
MAX_RETRIES=3
\`\`\`

### Configuration File
\`\`\`javascript
// config/default.js
module.exports = {
  server: {
    port: process.env.PORT || 3000,
    host: process.env.HOST || 'localhost'
  },
  database: {
    url: process.env.DATABASE_URL,
    pool: {
      min: 2,
      max: 10
    }
  }
};
\`\`\`

## Examples

### Complete Example
\`\`\`javascript
const { ProjectService } = require('project-name');

async function completeExample() {
  // Initialize service
  const service = new ProjectService({
    apiKey: process.env.API_KEY,
    environment: 'production'
  });

  try {
    // Process data
    const data = { name: 'Example', value: 42 };
    const result = await service.processData(data);

    console.log('Success:', result);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

completeExample();
\`\`\`

## Testing

### Running Tests
\`\`\`bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- --grep "UserService"
\`\`\`

### Test Structure
\`\`\`
tests/
├── unit/
│   ├── services/
│   │   ├── UserService.test.js
│   │   └── ValidationService.test.js
│   └── utils/
│       └── helpers.test.js
├── integration/
│   ├── api/
│   │   └── users.test.js
│   └── database/
│       └── migrations.test.js
└── e2e/
    ├── user-registration.test.js
    └── data-processing.test.js
\`\`\`

## Contributing

### Development Setup
\`\`\`bash
# Fork the repository
git clone https://github.com/your-username/project-name.git
cd project-name

# Install dependencies
npm install

# Set up development database
npm run db:setup:dev

# Run tests
npm test
\`\`\`

### Code Style
This project uses ESLint and Prettier for code formatting. Before submitting a pull request:

\`\`\`bash
# Check code style
npm run lint

# Auto-fix formatting issues
npm run format

# Run type checking
npm run type-check
\`\`\`

### Pull Request Process
1. Create a feature branch from `main`
2. Implement your changes with tests
3. Ensure all tests pass and code is properly formatted
4. Update documentation if needed
5. Submit a pull request with a clear description

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

## Code Documentation Standards

### JSDoc Standards
```javascript
/**
 * Creates a new user account with comprehensive validation and security measures.
 *
 * This method performs email validation, password strength checking,
 * and user data normalization before creating the account.
 *
 * @example
 * // Basic user creation
 * const user = await userService.createUser({
 *   email: 'john@example.com',
 *   password: 'SecurePass123!',
 *   name: 'John Doe'
 * });
 *
 * // User creation with optional fields
 * const user = await userService.createUser({
 *   email: 'jane@example.com',
 *   password: 'SecurePass456!',
 *   name: 'Jane Smith',
 *   phone: '+1-555-0123',
 *   dateOfBirth: '1990-01-15'
 * });
 *
 * @param {CreateUserData} userData - The user data for account creation
 * @param {string} userData.email - User's email address (must be valid format)
 * @param {string} userData.password - User's password (min 12 chars, uppercase, lowercase, number, special char)
 * @param {string} userData.name - User's full name (2-100 characters)
 * @param {string} [userData.phone] - Optional phone number in international format
 * @param {string} [userData.dateOfBirth] - Optional date of birth (YYYY-MM-DD format)
 * @param {Object} [userData.preferences] - Optional user preferences
 * @param {string} [userData.preferences.language] - Preferred language (ISO 639-1 code)
 * @param {string} [userData.preferences.timezone] - User's timezone (IANA timezone database)
 *
 * @returns {Promise<User>} The created user object with generated fields
 * @returns {number} returns.id - Unique user identifier
 * @returns {string} returns.email - User's email (normalized to lowercase)
 * @returns {string} returns.name - User's display name
 * @returns {Date} returns.createdAt - Account creation timestamp
 * @returns {Date} returns.updatedAt - Last update timestamp
 *
 * @throws {ValidationError} When input validation fails
 * @throws {ValidationError} throws.code='INVALID_EMAIL' - When email format is invalid
 * @throws {ValidationError} throws.code='WEAK_PASSWORD' - When password doesn't meet requirements
 * @throws {ValidationError} throws.code='INVALID_NAME' - When name is too short or too long
 * @throws {DuplicateEmailError} When email address already exists in system
 * @throws {DatabaseError} When database operation fails
 *
 * @since 1.0.0
 * @version 2.1.0
 * @author John Doe <john@example.com>
 * @see {@link https://example.com/docs/authentication} Authentication documentation
 * @see {@link UserService#updateUser} Related user update method
 *
 * @deprecated Use createUserWithProfile instead for better user experience
 * @deprecated This method will be removed in version 3.0.0
 */
async function createUser(userData) {
  // Implementation...
}

/**
 * @typedef {Object} CreateUserData
 * @property {string} email - User's email address
 * @property {string} password - User's password
 * @property {string} name - User's full name
 * @property {string} [phone] - Optional phone number
 * @property {string} [dateOfBirth] - Optional date of birth
 * @property {UserPreferences} [preferences] - Optional user preferences
 */

/**
 * @typedef {Object} UserPreferences
 * @property {string} [language] - Preferred language code
 * @property {string} [timezone] - User's timezone
 * @property {boolean} [emailNotifications] - Enable email notifications
 */
```

### Python Docstring Standards
```python
class UserService:
    """
    Service for managing user accounts, authentication, and profile data.

    This service provides comprehensive user management functionality including
    account creation, authentication, profile updates, and password management.
    All operations include proper validation, error handling, and security measures.

    Attributes:
        database (Database): Database connection instance
        email_service (EmailService): Email notification service
        password_service (PasswordService): Password hashing and validation

    Examples:
        >>> service = UserService(database, email_service, password_service)
        >>> user = await service.create_user({
        ...     'email': 'user@example.com',
        ...     'password': 'SecurePass123!',
        ...     'name': 'John Doe'
        ... })
        >>> print(user.id)
        12345

    Note:
        This service automatically handles password hashing, email validation,
        and user data normalization. All database operations are wrapped in
        transactions to ensure data consistency.

    See also:
        - :class:`ProfileService`: For managing user profiles
        - :class:`AuthService`: For authentication operations

    .. versionadded:: 1.0.0
    .. versionchanged:: 2.1.0
        Added support for multi-factor authentication
    """

    def __init__(self, database: Database, email_service: EmailService,
                 password_service: PasswordService) -> None:
        """
        Initialize the UserService with required dependencies.

        Args:
            database: Database connection instance for user data persistence
            email_service: Email service for sending notifications
            password_service: Service for password hashing and validation

        Raises:
            ConfigurationError: If any required service is not properly configured
        """
        self._database = database
        self._email_service = email_service
        self._password_service = password_service

    async def create_user(self, user_data: Dict[str, Any]) -> User:
        """
        Create a new user account with comprehensive validation and security.

        This method validates input data, checks for duplicate emails,
        hashes passwords securely, and creates the user account in a database
        transaction. Email verification is sent automatically.

        Args:
            user_data: Dictionary containing user information
                - email (str): User's email address (required)
                - password (str): User's password (required)
                - name (str): User's full name (required)
                - phone (str, optional): Phone number in international format
                - date_of_birth (str, optional): Date of birth (YYYY-MM-DD)
                - preferences (dict, optional): User preference settings

        Returns:
            User: Created user object with generated fields

        Raises:
            ValidationError: When input validation fails:
                - INVALID_EMAIL: Email format is invalid
                - WEAK_PASSWORD: Password doesn't meet security requirements
                - INVALID_NAME: Name length or format is invalid
            DuplicateEmailError: When email address already exists
            DatabaseError: When database operation fails

        Examples:
            >>> service = UserService(database, email_service, password_service)
            >>> user = await service.create_user({
            ...     'email': 'john@example.com',
            ...     'password': 'SecurePass123!',
            ...     'name': 'John Doe'
            ... })
            >>> print(f"Created user {user.id} with email {user.email}")
            Created user 12345 with email john@example.com

        Note:
            The password is automatically hashed using bcrypt with 12 rounds.
            Email verification is sent asynchronously and doesn't block
            user creation.

        .. versionadded:: 1.0.0
        .. versionchanged:: 2.0.0
            Added support for custom user preferences
        """
        # Implementation...
```

## API Documentation Standards

### REST API Documentation
```markdown
# User Management API

## Overview
The User Management API provides endpoints for creating, reading, updating, and deleting user accounts with comprehensive validation and security features.

## Base URL
```
https://api.example.com/v1
```

## Authentication
All API requests require authentication using Bearer tokens:

```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### Create User
Create a new user account with email verification.

**Endpoint:** `POST /users`

**Authentication:** Required (Admin role)

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe",
  "phone": "+1-555-0123",
  "dateOfBirth": "1990-01-15",
  "preferences": {
    "language": "en",
    "timezone": "America/New_York",
    "emailNotifications": true
  }
}
```

**Request Parameters:**
| Parameter | Type | Required | Description | Constraints |
|-----------|------|----------|-------------|-------------|
| email | string | Yes | User's email address | Valid email format, max 254 chars |
| password | string | Yes | User's password | Min 12 chars, uppercase, lowercase, number, special char |
| name | string | Yes | User's full name | 2-100 characters |
| phone | string | No | Phone number | International format (+X-XXX-XXX-XXXX) |
| dateOfBirth | string | No | Date of birth | YYYY-MM-DD format |
| preferences | object | No | User preferences | See preferences schema |

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 12345,
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1-555-0123",
    "dateOfBirth": "1990-01-15",
    "preferences": {
      "language": "en",
      "timezone": "America/New_York",
      "emailNotifications": true
    },
    "emailVerified": false,
    "createdAt": "2023-10-19T10:30:00Z",
    "updatedAt": "2023-10-19T10:30:00Z"
  },
  "meta": {
    "requestId": "req_123456789",
    "timestamp": "2023-10-19T10:30:00Z"
  }
}
```

**Status Codes:**
- `201 Created` - User created successfully
- `400 Bad Request` - Invalid input data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `409 Conflict` - Email already exists
- `422 Unprocessable Entity` - Validation errors

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Input validation failed",
    "details": {
      "email": "Email format is invalid",
      "password": "Password must contain at least one uppercase letter"
    },
    "requestId": "req_123456789",
    "timestamp": "2023-10-19T10:30:00Z"
  }
}
```

### Get User
Retrieve user information by ID.

**Endpoint:** `GET /users/{id}`

**Authentication:** Required

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Unique user identifier |

**Response:** Same as Create User response

**Status Codes:**
- `200 OK` - User retrieved successfully
- `401 Unauthorized` - Authentication required
- `404 Not Found` - User not found

### Update User
Update user information.

**Endpoint:** `PUT /users/{id}`

**Authentication:** Required

**Request Body:** Same as Create User (all fields optional)

**Response:** Updated user object

**Status Codes:**
- `200 OK` - User updated successfully
- `400 Bad Request` - Invalid input data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Can only update own profile or require admin role
- `404 Not Found` - User not found

### Delete User
Delete a user account.

**Endpoint:** `DELETE /users/{id}`

**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "User deleted successfully",
  "meta": {
    "requestId": "req_123456789",
    "timestamp": "2023-10-19T10:30:00Z"
  }
}
```

**Status Codes:**
- `200 OK` - User deleted successfully
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Can only delete own account or require admin role
- `404 Not Found` - User not found

## Rate Limiting
- **Standard endpoints:** 100 requests per 15 minutes per IP
- **Authentication endpoints:** 5 requests per 15 minutes per IP
- **Admin endpoints:** 200 requests per 15 minutes per authenticated user

## Error Codes
| Code | Description |
|------|-------------|
| VALIDATION_ERROR | Input validation failed |
| INVALID_EMAIL | Email format is invalid |
| WEAK_PASSWORD | Password doesn't meet requirements |
| DUPLICATE_EMAIL | Email already exists |
| USER_NOT_FOUND | User does not exist |
| INSUFFICIENT_PERMISSIONS | User lacks required permissions |
| RATE_LIMIT_EXCEEDED | Too many requests |

## SDK Examples

### JavaScript/Node.js
```javascript
const { UserAPI } = require('@example/api-client');

const api = new UserAPI({
  baseURL: 'https://api.example.com/v1',
  apiKey: 'your-api-key'
});

// Create user
const user = await api.users.create({
  email: 'user@example.com',
  password: 'SecurePass123!',
  name: 'John Doe'
});

// Get user
const retrievedUser = await api.users.get(user.id);

// Update user
const updatedUser = await api.users.update(user.id, {
  name: 'John Smith'
});
```

### Python
```python
from example_api import UserAPI

api = UserAPI(
    base_url='https://api.example.com/v1',
    api_key='your-api-key'
)

# Create user
user = api.users.create(
    email='user@example.com',
    password='SecurePass123!',
    name='John Doe'
)

# Get user
retrieved_user = api.users.get(user.id)

# Update user
updated_user = api.users.update(user.id, name='John Smith')
```
```

## In-Code Documentation Standards

### Comment Types and Usage
```javascript
// Single-line comment for brief clarification
const timeout = 5000; // 5 seconds in milliseconds

/**
 * Multi-line comment for complex explanations
 * This function processes user registration data through multiple validation
 * steps including email verification, password strength checking, and
 * database uniqueness validation.
 */
async function processRegistration(userData) {
  // Implementation
}

// TODO: Implement email verification template system
// FIXME: Handle edge case where user provides invalid date format
// NOTE: This method should be moved to a separate service in v2.0
// HACK: Temporary workaround for API rate limiting
// WARNING: This method performs synchronous I/O and should be refactored
```

### Documentation Annotations
```javascript
/**
 * @public - Public API method
 * @private - Internal method, not for external use
 * @protected - Method for subclass use only
 * @internal - Internal implementation detail
 * @experimental - Experimental feature, may change
 * @deprecated - Deprecated feature, will be removed
 * @since 1.0.0 - Feature version information
 * @author John Doe - Author information
 */

class UserService {
  /**
   * @public
   * Create a new user account
   */
  async createUser(userData) { }

  /**
   * @private
   * Internal email validation logic
   */
  _validateEmail(email) { }

  /**
   * @protected
   * Template method for user data processing
   */
  _processUserData(userData) { }

  /**
   * @internal
   * Database connection management
   */
  _connectToDatabase() { }

  /**
   * @experimental
   * Feature: Multi-factor authentication
   */
  async enableMFA(userId) { }

  /**
   * @deprecated
   * Use createUser instead
   * @deprecated This method will be removed in v3.0.0
   */
  async registerUser(userData) { }
}
```

## Documentation Maintenance

### Documentation Review Process
1. **Code Changes**: Update relevant documentation
2. **Feature Addition**: Add comprehensive documentation
3. **API Changes**: Update API documentation and versioning
4. **Deprecation**: Mark deprecated features with migration paths
5. **Removal**: Remove documentation for removed features

### Documentation Quality Checklist
- [ ] README is up-to-date with current features
- [ ] All public APIs have comprehensive documentation
- [ ] Code comments explain complex logic
- [ ] Examples are tested and working
- [ ] Installation instructions are accurate
- [ ] Configuration options are documented
- [ ] Error conditions are documented
- [ ] Performance considerations are noted
- [ ] Security considerations are addressed
- [ ] Troubleshooting guide is available

### Automated Documentation
```javascript
// Generate API documentation from code comments
const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'User API',
      version: '1.0.0',
      description: 'User management API documentation'
    }
  },
  apis: ['./src/routes/*.js'] // Path to API docs
};

const specs = swaggerJsdoc(options);

// Generate documentation site
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
```

---

**This rule ensures comprehensive documentation practices that make code maintainable, APIs understandable, and project knowledge accessible to all team members.**