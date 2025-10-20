---
id: rule-001
type: rule
version: 1.0.0
description: Enforces consistent naming conventions across all code and files
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Naming Conventions Rule (rule-001)

## Purpose
Establishes consistent, readable naming conventions across all programming languages and file types to improve code maintainability and team collaboration.

## Variable Naming

### CamelCase (lowerFirst)
**Use for:** Variables, properties, functions, methods

**Format:** `variableName`, `functionName`, `propertyName`

**Examples:**
```javascript
// ✅ GOOD
let userName = "john_doe";
const isActive = true;
function getUserData() { }

// ❌ BAD
let user_name = "john_doe";
const isactive = true;
function get_user_data() { }
```

```python
# ✅ GOOD
user_name = "john_doe"
is_active = True
def get_user_data(): pass

# ❌ BAD
userName = "john_doe"  # Python uses snake_case
isActive = True
def getUserData(): pass
```

### UPPER_SNAKE_CASE
**Use for:** Constants, environment variables, enum members

**Format:** `CONSTANT_NAME`, `ENVIRONMENT_VARIABLE`

**Examples:**
```javascript
// ✅ GOOD
const MAX_CONNECTIONS = 100;
const API_BASE_URL = process.env.API_BASE_URL;

// ❌ BAD
const maxConnections = 100;
const apiBaseUrl = process.env.apiBaseUrl;
```

```python
# ✅ GOOD
MAX_CONNECTIONS = 100
API_BASE_URL = os.getenv('API_BASE_URL')

# ❌ BAD
maxConnections = 100
apiBaseUrl = os.getenv('apiBaseUrl')
```

## Function and Method Naming

### Verb-Noun Pattern
**Format:** `verbNoun` or `verbAdjectiveNoun`

**Examples:**
```javascript
// ✅ GOOD
function getUser(id) { }
function validateEmail(email) { }
function calculateTotalPrice(items) { }
function isActive() { }
function hasPermission(user, resource) { }

// ❌ BAD
function user(id) { }
function email(email) { }
function total(items) { }
function active() { }
function permission(user, resource) { }
```

### Boolean Functions
**Prefix with:** `is`, `has`, `can`, `should`, `will`, `does`

**Examples:**
```javascript
// ✅ GOOD
function isValid() { }
function hasItems() { }
function canEdit() { }
function shouldRetry() { }
function willProcess() { }
function doesExist() { }

// ❌ BAD
function valid() { }
function items() { }
function edit() { }
function retry() { }
function process() { }
function exist() { }
```

## Class and Interface Naming

### PascalCase (UpperFirst)
**Format:** `ClassName`, `InterfaceName`

**Examples:**
```javascript
// ✅ GOOD
class UserService { }
class DatabaseConnection { }
class HttpErrorHandler { }

// ❌ BAD
class userService { }
class database_connection { }
class http_error_handler { }
```

```typescript
// ✅ GOOD
interface UserData { }
type ApiResponse = { };
class UserRepository { }

// ❌ BAD
interface userData { }
type apiResponse = { };
class userRepository { }
```

### Class Naming Patterns
**Use descriptive, purposeful names:**

```javascript
// ✅ GOOD
class UserRepository { }
class EmailValidator { }
class PaymentProcessor { }
class ApiClient { }

// ❌ BAD
class User { }  // Too generic
class Validator { }  // Too generic
class Process { }  // Too generic
class Client { }  // Too generic
```

## File and Directory Naming

### Kebab-Case (lower-with-dashes)
**Use for:** File names, directory names

**Format:** `file-name.ext`, `directory-name`

**Examples:**
```
// ✅ GOOD
user-service.js
email-validator.ts
api-client/
payment-processor/
database-connection.js

// ❌ BAD
userService.js  // camelCase
email_validator.ts  // snake_case
apiClient/  // camelCase
paymentProcessor/  // camelCase
```

### Component Files
**Pattern:** `[component-name].[type].ext`

```
// ✅ GOOD
user-card.component.jsx
email-input.field.tsx
nav-bar.menu.js

// ❌ BAD
UserCard.jsx
emailInput.tsx
navbar.js
```

### Test Files
**Pattern:** `[file-name].test.ext` or `[file-name].spec.ext`

```
// ✅ GOOD
user-service.test.js
email-validator.spec.ts
api-client.integration.test.js

// ❌ BAD
userServiceTest.js
test-email-validator.ts
api_client_tests.js
```

## Database Naming

### Table Names
**Format:** `snake_case` plural

```sql
-- ✅ GOOD
CREATE TABLE users ( );
CREATE TABLE user_profiles ( );
CREATE TABLE email_templates ( );

-- ❌ BAD
CREATE TABLE User ( );
CREATE TABLE userProfile ( );
CREATE TABLE emailTemplate ( );
```

### Column Names
**Format:** `snake_case`

```sql
-- ✅ GOOD
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email_address VARCHAR(100),
    created_at TIMESTAMP
);

-- ❌ BAD
CREATE TABLE users (
    userId INT PRIMARY KEY,
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    emailAddress VARCHAR(100),
    createdAt TIMESTAMP
);
```

## API Endpoint Naming

### REST Endpoints
**Format:** `kebab-case` resource names

```javascript
// ✅ GOOD
GET /api/users
GET /api/users/{id}
POST /api/users
PUT /api/users/{id}
DELETE /api/users/{id}

GET /api/user-profiles
GET /api/user-profiles/{userId}

// ❌ BAD
GET /api/getUsers
GET /api/getUserById
POST /api/createUser
PUT /api/updateUser/{id}
DELETE /api/deleteUser/{id}
```

### Query Parameters
**Format:** `camelCase` or `snake_case` (be consistent)

```javascript
// ✅ GOOD - camelCase
GET /api/users?firstName=John&lastName=Doe&pageNumber=1

// ✅ GOOD - snake_case
GET /api/users?first_name=John&last_name=Doe&page_number=1

// ❌ BAD - inconsistent
GET /api/users?firstName=John&last_name=Doe&pageNumber=1
```

## Environment Variable Naming

### UPPER_SNAKE_CASE
**Format:** `SERVICE_SETTING_NAME`

```
# ✅ GOOD
DATABASE_HOST=localhost
DATABASE_PORT=5432
REDIS_URL=redis://localhost:6379
API_BASE_URL=https://api.example.com
JWT_SECRET_KEY=your-secret-key

# ❌ BAD
databaseHost=localhost
database_port=5432
redisUrl=redis://localhost:6379
apiBaseUrl=https://api.example.com
jwtSecretKey=your-secret-key
```

### Service-Specific Prefixes
**Format:** `SERVICE_` or `APP_` prefix

```
# ✅ GOOD
MYAPP_DATABASE_HOST=
MYAPP_REDIS_URL=
MYAPP_API_PORT=
AUTH_SERVICE_JWT_SECRET=
PAYMENT_SERVICE_API_KEY=

# ❌ BAD
DATABASE_HOST=  # No service prefix
REDIS_URL=  # Could conflict with other services
API_PORT=  # Generic, could conflict
```

## Special Cases and Exceptions

### Acronyms and Initialisms
**Treat as regular words (usually):**

```javascript
// ✅ GOOD - treat as regular words
const userId = 123;  // not userID
const htmlContent = "<div>";  // not HTMLContent
const apiUrl = "https://api.example.com";  // not APIURL

// ✅ GOOD - when acronym is commonly used as-is
const httpStatusCode = 200;  // not HttpStatusCode
const pdfDocument = loadPdf();  // not PDFDocument

// ❌ BAD
const userID = 123;
const HTMLContent = "<div>";
const APIURL = "https://api.example.com";
```

### Private/Internal Members
**Use underscore prefix for private members:**

```javascript
// ✅ GOOD
class UserService {
  constructor() {
    this._cache = new Map();
    this._logger = console;
  }

  _validateUser(user) {
    // Private method
  }
}

// ❌ BAD
class UserService {
  constructor() {
    this.cache = new Map();  // Should be private
    this.__logger = console;  // Double underscore
  }

  validateUser(user) {  // Private method should be prefixed
    // Private method
  }
}
```

## Validation Rules

### Automatic Detection
This rule automatically detects naming violations:
- Inconsistent case usage within the same scope
- Mixed naming conventions in the same file
- Incorrect file naming patterns
- Inconsistent API endpoint naming

### Enforcement
- **Warnings**: Non-critical naming inconsistencies
- **Errors**: Critical naming convention violations
- **Suggestions**: Improved naming alternatives

## Integration Points

### Language-Specific Rules
- **JavaScript/TypeScript**: camelCase for variables, PascalCase for classes
- **Python**: snake_case for variables and functions, PascalCase for classes
- **SQL**: snake_case for tables and columns
- **JSON**: camelCase for keys (JavaScript context) or snake_case (Python context)

### Tool Integration
- **ESLint**: `camelcase`, `snakecase`, `kebab-case` rules
- **Pylint**: `naming-convention` rules
- **Database Tools**: Naming convention validators
- **API Tools**: Endpoint naming pattern checkers

## Benefits of Consistent Naming

1. **Readability**: Code is easier to read and understand
2. **Maintainability**: Easier to find and modify code
3. **Collaboration**: Team members can understand each other's code
4. **Automation**: Tools can reliably parse and analyze code
5. **Documentation**: Self-documenting code through clear naming

## Migration Strategy

When applying this rule to existing codebases:

1. **Start New Files**: Apply naming conventions to all new files
2. **Gradual Refactor**: Update existing files during maintenance
3. **Tool-Assisted**: Use automated refactoring tools where possible
4. **Team Agreement**: Ensure team consensus on conventions
5. **Documentation**: Update documentation to reflect new naming standards

---

**This rule ensures that all code follows consistent naming conventions, making it more readable, maintainable, and collaborative.**