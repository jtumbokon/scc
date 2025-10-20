---
id: rule-003
type: rule
version: 1.0.0
description: Defines comprehensive testing standards, coverage requirements, and testing practices
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Testing Standards Rule (rule-003)

## Purpose
Establishes comprehensive testing standards to ensure code quality, reliability, and maintainability across all projects and languages.

## Testing Pyramid

### Test Type Hierarchy
1. **Unit Tests (70%)** - Fast, isolated tests of individual functions/components
2. **Integration Tests (20%)** - Tests of multiple components working together
3. **End-to-End Tests (10%)** - Tests of complete user workflows

### Coverage Requirements
- **Unit Tests**: 90%+ line coverage, 80%+ branch coverage
- **Integration Tests**: Critical path coverage only
- **E2E Tests**: Core user journey coverage

## Unit Testing Standards

### Test Structure
**Follow AAA Pattern (Arrange, Act, Assert):**

```javascript
// ✅ GOOD - Clear AAA structure
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User'
      };
      const expectedUser = { id: 1, ...userData };

      // Act
      const result = await userService.createUser(userData);

      // Assert
      expect(result).toEqual(expectedUser);
      expect(result.email).toBe(userData.email);
    });
  });
});

// ❌ BAD - Mixed arrange/act/assert
describe('UserService', () => {
  it('should create user', async () => {
    const userData = { email: 'test@example.com', password: 'password123' };
    const user = await userService.createUser(userData);
    expect(user.email).toBe(userData.email);
    // Missing proper assertion structure
  });
});
```

### Test Naming Conventions
**Use descriptive, behavior-driven names:**

```javascript
// ✅ GOOD - Descriptive test names
describe('PaymentProcessor', () => {
  it('should process payment successfully when card is valid');
  it('should decline payment when card is expired');
  it('should refund payment when requested within 30 days');
  it('should throw error when payment amount is negative');
});

// ❌ BAD - Vague test names
describe('PaymentProcessor', () => {
  it('test payment processing');
  it('test card validation');
  it('test refund functionality');
});
```

### Test Isolation
**Each test should be independent:**

```javascript
// ✅ GOOD - Independent tests with proper setup/teardown
describe('OrderService', () => {
  beforeEach(() => {
    // Reset state before each test
    orderService.clearCache();
    jest.clearAllMocks();
  });

  it('should create order with valid data', async () => {
    const orderData = { items: [{ id: 1, quantity: 2 }] };
    const order = await orderService.createOrder(orderData);
    expect(order.status).toBe('pending');
  });

  it('should fail when order data is invalid', async () => {
    const orderData = { items: [] }; // Invalid empty items
    await expect(orderService.createOrder(orderData))
      .rejects
      .toThrow('Order must contain at least one item');
  });
});

// ❌ BAD - Tests sharing state
describe('OrderService', () => {
  let sharedOrder = null;

  it('should create order', async () => {
    sharedOrder = await orderService.createOrder({ items: [{ id: 1 }] });
    expect(sharedOrder).toBeDefined();
  });

  it('should update order', async () => {
    // Depends on previous test execution
    sharedOrder.status = 'updated';
    const result = await orderService.updateOrder(sharedOrder);
    expect(result.status).toBe('updated');
  });
});
```

## Mock and Stub Guidelines

### When to Use Mocks
- External dependencies (databases, APIs, file systems)
- Complex objects that are difficult to create
- Time-dependent operations
- Network calls

### Mock Best Practices
```javascript
// ✅ GOOD - Proper mocking with clear behavior
describe('EmailService', () => {
  let emailService;
  let mockEmailProvider;

  beforeEach(() => {
    mockEmailProvider = {
      send: jest.fn().mockResolvedValue({ messageId: 'msg-123' })
    };
    emailService = new EmailService(mockEmailProvider);
  });

  it('should send welcome email to new user', async () => {
    const user = { email: 'user@example.com', name: 'John' };

    await emailService.sendWelcomeEmail(user);

    expect(mockEmailProvider.send).toHaveBeenCalledWith({
      to: user.email,
      subject: 'Welcome!',
      template: 'welcome',
      data: { name: user.name }
    });
  });
});

// ❌ BAD - Over-mocking or unclear behavior
describe('EmailService', () => {
  it('should send email', async () => {
    const mockEmailProvider = {
      send: jest.fn().mockResolvedValue({}),
      validateEmail: jest.fn().mockReturnValue(true),
      trackDelivery: jest.fn().mockResolvedValue({ delivered: true })
    };
    // Too many mocks, test becomes complex
  });
});
```

### Stub Usage
**Use stubs for simple data replacement:**

```javascript
// ✅ GOOD - Simple stub for test data
describe('UserService', () => {
  it('should format user name correctly', () => {
    const user = {
      firstName: 'John',
      lastName: 'Doe',
      title: 'Dr.'
    };

    const formattedName = userService.formatUserName(user);

    expect(formattedName).toBe('Dr. John Doe');
  });
});
```

## Integration Testing

### Database Integration Tests
```javascript
// ✅ GOOD - Database integration with cleanup
describe('UserRepository Integration', () => {
  let database;
  let userRepository;

  beforeAll(async () => {
    database = await createTestDatabase();
    userRepository = new UserRepository(database);
  });

  afterAll(async () => {
    await database.close();
  });

  beforeEach(async () => {
    await database.clear('users');
  });

  it('should save and retrieve user', async () => {
    const userData = {
      email: 'test@example.com',
      name: 'Test User'
    };

    const savedUser = await userRepository.save(userData);
    const retrievedUser = await userRepository.findById(savedUser.id);

    expect(retrievedUser.email).toBe(userData.email);
    expect(retrievedUser.name).toBe(userData.name);
  });
});
```

### API Integration Tests
```javascript
// ✅ GOOD - API integration with test server
describe('User API Integration', () => {
  let app;
  let server;

  beforeAll(async () => {
    app = createTestApp();
    server = app.listen(0); // Random port
  });

  afterAll(async () => {
    await server.close();
  });

  it('should create user via API', async () => {
    const userData = {
      email: 'test@example.com',
      name: 'Test User'
    };

    const response = await request(server)
      .post('/api/users')
      .send(userData)
      .expect(201);

    expect(response.body.email).toBe(userData.email);
    expect(response.body.id).toBeDefined();
  });
});
```

## End-to-End Testing

### User Journey Testing
```javascript
// ✅ GOOD - Complete user journey test
describe('User Registration E2E', () => {
  let page;

  beforeAll(async () => {
    page = await browser.newPage();
  });

  afterAll(async () => {
    await page.close();
  });

  it('should register new user successfully', async () => {
    // Navigate to registration page
    await page.goto('/register');

    // Fill registration form
    await page.fill('#email', 'test@example.com');
    await page.fill('#password', 'password123');
    await page.fill('#name', 'Test User');

    // Submit form
    await page.click('#register-button');

    // Verify success
    await expect(page.locator('.success-message')).toBeVisible();
    await expect(page).toHaveURL('/dashboard');
  });
});
```

### E2E Test Organization
```javascript
// ✅ GOOD - Organized E2E tests with setup
describe('Shopping Cart Flow', () => {
  let testUser;
  let testProducts;

  beforeAll(async () => {
    // Setup test data
    testUser = await createTestUser();
    testProducts = await createTestProducts();
  });

  afterAll(async () => {
    // Cleanup test data
    await cleanupTestData([testUser, ...testProducts]);
  });

  beforeEach(async () => {
    // Login before each test
    await loginAsUser(testUser);
  });

  it('should add product to cart', async () => {
    await page.goto(`/products/${testProducts[0].id}`);
    await page.click('#add-to-cart');

    await expect(page.locator('.cart-count')).toContainText('1');
  });

  it('should complete checkout process', async () => {
    // Add products to cart
    await page.goto(`/products/${testProducts[0].id}`);
    await page.click('#add-to-cart');
    await page.goto('/cart');

    // Complete checkout
    await page.click('#checkout-button');
    await page.fill('#shipping-address', '123 Test St');
    await page.fill('#payment-info', '4111111111111111');
    await page.click('#place-order');

    // Verify order confirmation
    await expect(page.locator('.order-confirmation')).toBeVisible();
  });
});
```

## Test Data Management

### Test Factories
```javascript
// ✅ GOOD - Test factory for consistent test data
class UserFactory {
  static create(overrides = {}) {
    return {
      id: faker.datatype.number(),
      email: faker.internet.email(),
      name: faker.name.findName(),
      createdAt: new Date(),
      ...overrides
    };
  }

  static createMany(count, overrides = {}) {
    return Array.from({ length: count }, () => this.create(overrides));
  }
}

// Usage in tests
describe('UserService', () => {
  it('should handle multiple users', () => {
    const users = UserFactory.createMany(5, {
      createdAt: new Date('2023-01-01')
    });

    const result = userService.getActiveUsers(users);
    expect(result).toHaveLength(5);
  });
});
```

### Test Fixtures
```javascript
// ✅ GOOD - Test fixtures for complex scenarios
const fixtures = {
  validUser: {
    email: 'test@example.com',
    password: 'password123',
    name: 'Test User'
  },

  invalidUser: {
    email: 'invalid-email',
    password: '123',  // Too short
    name: ''
  },

  adminUser: {
    email: 'admin@example.com',
    password: 'admin123',
    name: 'Admin User',
    role: 'admin'
  }
};

describe('UserValidation', () => {
  Object.entries(fixtures).forEach(([fixtureName, userData]) => {
    describe(`with ${fixtureName}`, () => {
      it('should validate correctly', () => {
        const result = userValidator.validate(userData);
        expect(result.isValid).toBe(fixtureName === 'validUser' || fixtureName === 'adminUser');
      });
    });
  });
});
```

## Performance Testing

### Load Testing Patterns
```javascript
// ✅ GOOD - Performance test with metrics
describe('API Performance', () => {
  it('should handle concurrent requests', async () => {
    const concurrentRequests = 100;
    const startTime = Date.now();

    const promises = Array.from({ length: concurrentRequests }, () =>
      request(app).get('/api/users')
    );

    const responses = await Promise.all(promises);
    const endTime = Date.now();
    const duration = endTime - startTime;

    // All requests should succeed
    responses.forEach(response => {
      expect(response.status).toBe(200);
    });

    // Performance assertions
    expect(duration).toBeLessThan(5000); // 5 seconds max
    expect(duration / concurrentRequests).toBeLessThan(100); // 100ms per request avg
  });
});
```

## Test Organization

### File Structure
```
src/
├── components/
│   └── Button/
│       ├── Button.jsx
│       ├── Button.test.jsx
│       └── Button.stories.jsx
├── services/
│   └── UserService/
│       ├── UserService.js
│       ├── UserService.test.js
│       └── UserService.integration.test.js
└── tests/
    ├── e2e/
    │   ├── user-registration.test.js
    │   └── shopping-cart.test.js
    ├── fixtures/
    │   ├── users.js
    │   └── products.js
    └── utils/
        ├── test-helpers.js
        └── factories.js
```

### Test Configuration
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 90,
      lines: 90,
      statements: 90
    }
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.{js,jsx,ts,tsx}',
    '<rootDir>/src/**/*.{test,spec}.{js,jsx,ts,tsx}'
  ]
};
```

## Continuous Integration Testing

### CI Pipeline Testing
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run test:unit
      - run: npm run test:integration
      - run: npm run test:e2e
      - run: npm run test:coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

## Test Metrics and Reporting

### Coverage Reports
- **Line Coverage**: Percentage of executed lines
- **Branch Coverage**: Percentage of executed branches
- **Function Coverage**: Percentage of called functions
- **Statement Coverage**: Percentage of executed statements

### Quality Metrics
- **Test Success Rate**: Percentage of passing tests
- **Test Execution Time**: Performance of test suite
- **Flaky Test Detection**: Tests with inconsistent results
- **Code Quality Index**: Combined quality metrics

## Best Practices Summary

### Do's
- Write tests before or alongside code (TDD)
- Test behavior, not implementation
- Keep tests simple and focused
- Use descriptive test names
- Mock external dependencies
- Maintain high coverage thresholds
- Run tests automatically in CI/CD

### Don'ts
- Test private methods directly
- Use production databases in tests
- Write tests that depend on each other
- Ignore failing tests
- Over-mock complex scenarios
- Test framework internals
- Skip error path testing

---

**This rule ensures comprehensive testing practices that deliver reliable, maintainable code with appropriate coverage and quality assurance.**