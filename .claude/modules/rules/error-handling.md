---
id: rule-002
type: rule
version: 1.0.0
description: Establishes comprehensive error handling patterns and exception management
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Error Handling Rule (rule-002)

## Purpose
Ensures robust, consistent error handling across all code to prevent crashes, provide meaningful feedback, and maintain system stability.

## Core Principles

### 1. Fail Fast, Fail Clearly
- Detect errors early in the execution flow
- Provide clear, actionable error messages
- Never ignore or suppress errors silently

### 2. Graceful Degradation
- Systems should continue operating at reduced capacity
- Provide fallback behaviors when possible
- Never leave users in undefined states

### 3. Consistent Error Patterns
- Use standardized error handling across all modules
- Maintain predictable error response formats
- Follow language-specific best practices

## Error Handling Patterns

### Try-Catch-Finally Structure
**Always use complete error handling blocks:**

```javascript
// ✅ GOOD
async function getUserData(userId) {
  try {
    const user = await database.findUser(userId);
    if (!user) {
      throw new NotFoundError(`User not found: ${userId}`);
    }
    return user;
  } catch (error) {
    logger.error('Failed to get user data', { userId, error: error.message });
    throw new DatabaseError('Unable to retrieve user data', { cause: error });
  } finally {
    // Cleanup operations
    await database.closeConnection();
  }
}

// ❌ BAD
async function getUserData(userId) {
  const user = await database.findUser(userId);  // No error handling
  return user;
}
```

```python
# ✅ GOOD
async def get_user_data(user_id: int) -> dict:
    try:
        user = await database.find_user(user_id)
        if not user:
            raise NotFoundError(f"User not found: {user_id}")
        return user
    except DatabaseError as error:
        logger.error("Failed to get user data", extra={"user_id": user_id, "error": str(error)})
        raise DatabaseError("Unable to retrieve user data") from error
    finally:
        await database.close_connection()

# ❌ BAD
async def get_user_data(user_id: int) -> dict:
    user = await database.find_user(user_id)  # No error handling
    return user
```

### Exception Chaining
**Preserve original error context:**

```javascript
// ✅ GOOD - Proper exception chaining
function processPayment(paymentData) {
  try {
    const result = paymentGateway.charge(paymentData);
    return result;
  } catch (gatewayError) {
    // Chain the original error
    throw new PaymentProcessingError(
      'Payment processing failed',
      { paymentId: paymentData.id, amount: paymentData.amount },
      { cause: gatewayError }
    );
  }
}

// ❌ BAD - Losing original error context
function processPayment(paymentData) {
  try {
    const result = paymentGateway.charge(paymentData);
    return result;
  } catch (error) {
    throw new Error('Payment failed');  // Original error lost
  }
}
```

```python
# ✅ GOOD - Proper exception chaining
def process_payment(payment_data: dict) -> dict:
    try:
        result = payment_gateway.charge(payment_data)
        return result
    except PaymentGatewayError as error:
        raise PaymentProcessingError(
            "Payment processing failed",
            payment_id=payment_data["id"],
            amount=payment_data["amount"]
        ) from error

# ❌ BAD - Losing original error context
def process_payment(payment_data: dict) -> dict:
    try:
        result = payment_gateway.charge(payment_data)
        return result
    except error:
        raise PaymentProcessingError("Payment failed")  # Original error lost
```

## Error Classification

### Hierarchy of Error Types
```javascript
// ✅ GOOD - Structured error hierarchy
class BaseError extends Error {
  constructor(message, code, details = {}) {
    super(message);
    this.name = this.constructor.name;
    this.code = code;
    this.details = details;
    this.timestamp = new Date().toISOString();
  }
}

class ValidationError extends BaseError {
  constructor(message, field, value) {
    super(message, 'VALIDATION_ERROR', { field, value });
  }
}

class DatabaseError extends BaseError {
  constructor(message, query, params) {
    super(message, 'DATABASE_ERROR', { query, params });
  }
}

class NetworkError extends BaseError {
  constructor(message, url, statusCode) {
    super(message, 'NETWORK_ERROR', { url, statusCode });
  }
}
```

### Error Severity Levels
1. **Critical**: System cannot continue (database connection lost)
2. **Error**: Operation failed but system can continue (invalid user input)
3. **Warning**: Potential issue but operation succeeded (deprecated API usage)
4. **Info**: Normal flow information (user action completed)

## Specific Error Scenarios

### Input Validation
**Always validate inputs and provide specific error messages:**

```javascript
// ✅ GOOD
function createUser(userData) {
  // Validate required fields
  if (!userData.email) {
    throw new ValidationError('Email is required', 'email', userData.email);
  }

  if (!userData.email.includes('@')) {
    throw new ValidationError('Invalid email format', 'email', userData.email);
  }

  if (!userData.password || userData.password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters', 'password', '***');
  }

  // Continue with user creation
  return userRepository.create(userData);
}

// ❌ BAD
function createUser(userData) {
  if (!userData.email || !userData.password) {
    throw new Error('Invalid user data');  // Vague error message
  }
  return userRepository.create(userData);
}
```

```python
# ✅ GOOD
def create_user(user_data: dict) -> dict:
    if not user_data.get("email"):
        raise ValidationError("Email is required", field="email", value=user_data.get("email"))

    if "@" not in user_data["email"]:
        raise ValidationError("Invalid email format", field="email", value=user_data["email"])

    if not user_data.get("password") or len(user_data["password"]) < 8:
        raise ValidationError("Password must be at least 8 characters", field="password", value="***")

    return user_repository.create(user_data)

# ❌ BAD
def create_user(user_data: dict) -> dict:
    if not user_data.get("email") or not user_data.get("password"):
        raise ValueError("Invalid user data")  # Vague error message
    return user_repository.create(user_data)
```

### Resource Management
**Always handle resource cleanup:**

```javascript
// ✅ GOOD - Proper resource management
async function processLargeFile(filePath) {
  let fileHandle = null;
  try {
    fileHandle = await fs.open(filePath, 'r');
    const content = await fileHandle.readFile();
    return await processData(content);
  } catch (error) {
    logger.error('File processing failed', { filePath, error: error.message });
    throw new FileProcessingError('Unable to process file', { filePath }, { cause: error });
  } finally {
    if (fileHandle) {
      await fileHandle.close();
    }
  }
}

// ❌ BAD - Resource leak potential
async function processLargeFile(filePath) {
  const fileHandle = await fs.open(filePath, 'r');
  const content = await fileHandle.readFile();
  return await processData(content);  // File handle never closed
}
```

### API Error Handling
**Standardized API error responses:**

```javascript
// ✅ GOOD - Consistent API error format
function apiErrorHandler(error, req, res, next) {
  // Log the error
  logger.error('API Error', {
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    userId: req.user?.id
  });

  // Determine appropriate status code
  let statusCode = 500;
  if (error instanceof ValidationError) {
    statusCode = 400;
  } else if (error instanceof NotFoundError) {
    statusCode = 404;
  } else if (error instanceof UnauthorizedError) {
    statusCode = 401;
  }

  // Send consistent error response
  res.status(statusCode).json({
    success: false,
    error: {
      code: error.code || 'INTERNAL_ERROR',
      message: error.message,
      details: error.details || {},
      timestamp: new Date().toISOString()
    }
  });
}
```

## Error Logging Standards

### Structured Logging
**Use structured logging for better analysis:**

```javascript
// ✅ GOOD - Structured error logging
logger.error('User registration failed', {
  userId: userData.id,
  email: userData.email,
  error: error.message,
  stack: error.stack,
  timestamp: new Date().toISOString(),
  requestId: req.id,
  userAgent: req.headers['user-agent']
});

// ❌ BAD - Unstructured logging
console.log('Error registering user: ' + error.message);
```

### Log Levels
- **ERROR**: System errors that require attention
- **WARN**: Warning conditions that should be investigated
- **INFO**: Important but normal flow information
- **DEBUG**: Detailed debugging information

```javascript
// ✅ GOOD - Appropriate log levels
logger.debug('Starting user creation process', { userData });
logger.info('User created successfully', { userId: user.id });
logger.warn('User creation with deprecated field', { field: 'oldField' });
logger.error('Database connection failed', { error: dbError.message });
```

## Recovery Strategies

### Retry Mechanisms
**Implement exponential backoff for transient failures:**

```javascript
// ✅ GOOD - Retry with exponential backoff
async function executeWithRetry(operation, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (attempt === maxRetries || !isTransientError(error)) {
        throw error;
      }

      const delay = Math.pow(2, attempt) * 1000; // Exponential backoff
      logger.warn(`Operation failed, retrying in ${delay}ms`, {
        attempt,
        error: error.message
      });
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

function isTransientError(error) {
  return error.code === 'ECONNRESET' ||
         error.code === 'ETIMEDOUT' ||
         error.code === 'ENOTFOUND';
}
```

### Circuit Breaker Pattern
**Prevent cascading failures:**

```javascript
// ✅ GOOD - Circuit breaker implementation
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failureThreshold = threshold;
    this.timeout = timeout;
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
  }

  async execute(operation) {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime > this.timeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new CircuitBreakerOpenError('Circuit breaker is open');
      }
    }

    try {
      const result = await operation();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
    }
  }
}
```

## Error Prevention

### Input Sanitization
**Prevent errors through input validation:**

```javascript
// ✅ GOOD - Comprehensive input validation
function sanitizeInput(input, type) {
  if (typeof input !== 'string') {
    throw new ValidationError('Input must be a string', 'input', input);
  }

  switch (type) {
    case 'email':
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(input)) {
        throw new ValidationError('Invalid email format', 'email', input);
      }
      return input.toLowerCase().trim();

    case 'phone':
      const phoneRegex = /^\+?[\d\s\-\(\)]+$/;
      if (!phoneRegex.test(input)) {
        throw new ValidationError('Invalid phone format', 'phone', input);
      }
      return input.replace(/\D/g, '');

    default:
      return input.trim();
  }
}
```

### Null Safety
**Prevent null/undefined errors:**

```javascript
// ✅ GOOD - Null safety patterns
function getUserName(user) {
  // Defensive programming
  if (!user || !user.profile) {
    return 'Unknown User';
  }

  return user.profile.name || 'No Name Provided';
}

// ✅ GOOD - Optional chaining (modern JavaScript)
function getUserName(user) {
  return user?.profile?.name ?? 'Unknown User';
}

// ❌ BAD - Potential null reference errors
function getUserName(user) {
  return user.profile.name;  // Throws if user or profile is null
}
```

## Testing Error Handling

### Error Testing Patterns
**Test both success and failure scenarios:**

```javascript
// ✅ GOOD - Comprehensive error testing
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      const userData = { email: 'test@example.com', password: 'password123' };
      const user = await userService.createUser(userData);
      expect(user.email).toBe(userData.email);
    });

    it('should throw ValidationError for invalid email', async () => {
      const userData = { email: 'invalid-email', password: 'password123' };
      await expect(userService.createUser(userData))
        .rejects
        .toThrow(ValidationError);
    });

    it('should throw ValidationError for short password', async () => {
      const userData = { email: 'test@example.com', password: '123' };
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Password must be at least 8 characters');
    });
  });
});
```

## Performance Considerations

### Error Overhead
- Use error handling only for exceptional cases
- Avoid using exceptions for flow control
- Consider error budgets for distributed systems

### Memory Management
- Clean up resources in finally blocks
- Avoid memory leaks in error paths
- Use weak references for error caching

## Monitoring and Alerting

### Error Metrics
Track error rates and patterns:
- Error frequency by type
- Error rate by endpoint/service
- Error correlation with system load
- User impact assessment

### Alerting Thresholds
- **Critical**: > 5% error rate for critical services
- **Warning**: > 1% error rate for non-critical services
- **Info**: New error types detected

---

**This rule ensures robust error handling that prevents crashes, provides meaningful feedback, and maintains system stability under all conditions.**