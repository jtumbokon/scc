---
id: rule-004
type: rule
version: 1.0.0
description: Establishes comprehensive security standards and vulnerability prevention measures
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Security Rules (rule-004)

## Purpose
Implement comprehensive security standards to protect against common vulnerabilities, ensure data protection, and maintain secure development practices across all systems.

## Core Security Principles

### 1. Zero Trust Architecture
- Never trust user input automatically
- Validate all data at system boundaries
- Implement least privilege access controls
- Assume network is always compromised

### 2. Defense in Depth
- Multiple layers of security controls
- No single point of failure
- Redundant security measures
- Fail-safe defaults

### 3. Security by Design
- Security considerations from project start
- Built-in rather than bolted-on security
- Regular security reviews and updates
- Security testing as part of development

## Input Validation and Sanitization

### Comprehensive Input Validation
**Validate all inputs at entry points:**

```javascript
// ✅ GOOD - Comprehensive input validation
class UserInputValidator {
  static validateEmail(email) {
    if (!email || typeof email !== 'string') {
      throw new ValidationError('Email is required and must be a string');
    }

    // Length validation
    if (email.length > 254) {
      throw new ValidationError('Email address too long');
    }

    // Format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new ValidationError('Invalid email format');
    }

    // Whitelist allowed characters
    if (!/^[a-zA-Z0-9.@_-]+$/.test(email)) {
      throw new ValidationError('Email contains invalid characters');
    }

    return email.toLowerCase().trim();
  }

  static validatePassword(password) {
    if (!password || typeof password !== 'string') {
      throw new ValidationError('Password is required');
    }

    if (password.length < 12) {
      throw new ValidationError('Password must be at least 12 characters');
    }

    if (password.length > 128) {
      throw new ValidationError('Password too long');
    }

    // Complexity requirements
    if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/.test(password)) {
      throw new ValidationError('Password must contain uppercase, lowercase, number, and special character');
    }

    return password;
  }

  static sanitizeHtml(input) {
    if (!input) return '';

    // Use a proper HTML sanitizer
    const DOMPurify = require('dompurify');
    const { JSDOM } = require('jsdom');
    const window = new JSDOM('').window;
    const dompurify = DOMPurify(window);

    return dompurify.sanitize(input, {
      ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li'],
      ALLOWED_ATTR: []
    });
  }
}

// ❌ BAD - Insufficient validation
function validateEmail(email) {
  if (!email.includes('@')) {
    throw new Error('Invalid email');
  }
  return email;
}
```

### SQL Injection Prevention
**Use parameterized queries exclusively:**

```javascript
// ✅ GOOD - Parameterized queries
class UserRepository {
  async findUserByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = ?';
    const [rows] = await this.database.execute(query, [email]);
    return rows[0] || null;
  }

  async createUser(userData) {
    const query = `
      INSERT INTO users (email, password_hash, name, created_at)
      VALUES (?, ?, ?, ?)
    `;
    const [result] = await this.database.execute(query, [
      userData.email,
      userData.passwordHash,
      userData.name,
      new Date()
    ]);
    return result.insertId;
  }

  async searchUsers(searchTerm, limit = 10, offset = 0) {
    const query = `
      SELECT id, email, name, created_at
      FROM users
      WHERE email LIKE ? OR name LIKE ?
      LIMIT ? OFFSET ?
    `;
    const [rows] = await this.database.execute(query, [
      `%${searchTerm}%`,
      `%${searchTerm}%`,
      limit,
      offset
    ]);
    return rows;
  }
}

// ❌ BAD - SQL injection vulnerability
class UserRepository {
  async findUserByEmail(email) {
    const query = `SELECT * FROM users WHERE email = '${email}'`;
    const [rows] = await this.database.execute(query);
    return rows[0] || null;
  }
}
```

```python
# ✅ GOOD - Parameterized queries with SQLAlchemy
class UserRepository:
    def find_user_by_email(self, email: str) -> Optional[User]:
        return self.session.query(User).filter(User.email == email).first()

    def create_user(self, user_data: dict) -> User:
        user = User(
            email=user_data["email"],
            password_hash=user_data["password_hash"],
            name=user_data["name"],
            created_at=datetime.utcnow()
        )
        self.session.add(user)
        self.session.commit()
        return user

    def search_users(self, search_term: str, limit: int = 10, offset: int = 0):
        return self.session.query(User).filter(
            or_(
                User.email.ilike(f"%{search_term}%"),
                User.name.ilike(f"%{search_term}%")
            )
        ).limit(limit).offset(offset).all()

# ❌ BAD - SQL injection vulnerability
class UserRepository:
    def find_user_by_email(self, email: str) -> Optional[User]:
        query = f"SELECT * FROM users WHERE email = '{email}'"
        return self.session.execute(query).fetchone()
```

## Authentication and Authorization

### Secure Password Handling
```javascript
// ✅ GOOD - Secure password handling
class PasswordService {
  constructor() {
    this.bcrypt = require('bcrypt');
    this.saltRounds = 12;
  }

  async hashPassword(password) {
    // Always use bcrypt with sufficient salt rounds
    return await this.bcrypt.hash(password, this.saltRounds);
  }

  async verifyPassword(password, hash) {
    return await this.bcrypt.compare(password, hash);
  }

  generateSecurePassword() {
    const crypto = require('crypto');
    return crypto.randomBytes(16).toString('hex');
  }
}

// ✅ GOOD - Authentication with proper error handling
class AuthService {
  async authenticateUser(email, password) {
    // Rate limiting check
    await this.checkRateLimit(email);

    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      // Use generic error message to prevent enumeration
      throw new AuthenticationError('Invalid email or password');
    }

    const isValidPassword = await this.passwordService.verifyPassword(
      password,
      user.passwordHash
    );

    if (!isValidPassword) {
      await this.recordFailedAttempt(email);
      throw new AuthenticationError('Invalid email or password');
    }

    // Clear failed attempts on successful login
    await this.clearFailedAttempts(email);

    return this.generateTokens(user);
  }

  generateTokens(user) {
    const jwt = require('jsonwebtoken');
    const crypto = require('crypto');

    const accessToken = jwt.sign(
      {
        sub: user.id,
        email: user.email,
        role: user.role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '15m',
        issuer: 'your-app',
        audience: 'your-users'
      }
    );

    const refreshToken = crypto.randomBytes(32).toString('hex');

    // Store refresh token securely
    await this.tokenRepository.storeRefreshToken(user.id, refreshToken);

    return { accessToken, refreshToken };
  }
}
```

### Authorization Patterns
```javascript
// ✅ GOOD - Role-based access control
class AuthorizationService {
  constructor() {
    this.permissions = {
      'user': ['read:own_profile', 'update:own_profile'],
      'moderator': ['read:own_profile', 'update:own_profile', 'read:all_profiles', 'moderate:content'],
      'admin': ['*']  // All permissions
    };
  }

  hasPermission(user, permission, resource = null) {
    if (!user || !user.role) {
      return false;
    }

    const userPermissions = this.permissions[user.role] || [];

    // Wildcard permission for admins
    if (userPermissions.includes('*')) {
      return true;
    }

    // Direct permission check
    if (userPermissions.includes(permission)) {
      return true;
    }

    // Resource-specific permissions
    if (resource && user.id === resource.userId) {
      const ownPermission = permission.replace('all', 'own');
      return userPermissions.includes(ownPermission);
    }

    return false;
  }

  requirePermission(permission) {
    return (req, res, next) => {
      if (!this.hasPermission(req.user, permission, req.resource)) {
        return res.status(403).json({
          error: 'Insufficient permissions',
          required: permission
        });
      }
      next();
    };
  }
}

// Usage in Express routes
app.get('/api/users/:id',
  authenticateToken,
  authorization.requirePermission('read:all_profiles'),
  userController.getUser
);

app.put('/api/users/:id',
  authenticateToken,
  authorization.requirePermission('update:own_profile'),
  userController.updateUser
);
```

## Data Protection

### Encryption Standards
```javascript
// ✅ GOOD - Proper encryption for sensitive data
class EncryptionService {
  constructor() {
    this.crypto = require('crypto');
    this.algorithm = 'aes-256-gcm';
    this.keyLength = 32;
    this.ivLength = 16;
    this.tagLength = 16;
  }

  getEncryptionKey() {
    const key = process.env.ENCRYPTION_KEY;
    if (!key || key.length !== this.keyLength * 2) {
      throw new Error('Invalid encryption key');
    }
    return Buffer.from(key, 'hex');
  }

  encrypt(text) {
    const key = this.getEncryptionKey();
    const iv = this.crypto.randomBytes(this.ivLength);

    const cipher = this.crypto.createCipher(this.algorithm, key, iv);

    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    const tag = cipher.getAuthTag();

    return {
      encrypted,
      iv: iv.toString('hex'),
      tag: tag.toString('hex')
    };
  }

  decrypt(encryptedData) {
    const key = this.getEncryptionKey();
    const iv = Buffer.from(encryptedData.iv, 'hex');
    const tag = Buffer.from(encryptedData.tag, 'hex');

    const decipher = this.crypto.createDecipher(this.algorithm, key, iv);
    decipher.setAuthTag(tag);

    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  }

  encryptSensitiveFields(data, sensitiveFields) {
    const encrypted = { ...data };

    sensitiveFields.forEach(field => {
      if (data[field]) {
        encrypted[field] = this.encrypt(data[field]);
      }
    });

    return encrypted;
  }
}
```

### Secure Data Storage
```javascript
// ✅ GOOD - Secure data storage with proper field handling
class SecureUserService {
  constructor(encryptionService) {
    this.encryptionService = encryptionService;
    this.sensitiveFields = ['ssn', 'creditCard', 'bankAccount'];
  }

  async createUser(userData) {
    // Hash password
    const passwordHash = await this.bcrypt.hash(userData.password, 12);

    // Encrypt sensitive fields
    const encryptedData = this.encryptionService.encryptSensitiveFields(
      userData,
      this.sensitiveFields
    );

    const user = {
      ...encryptedData,
      passwordHash,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    return await this.userRepository.create(user);
  }

  async getUserById(userId, requestingUser) {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    // Authorization check
    if (!this.canAccessUserData(requestingUser, user)) {
      throw new AuthorizationError('Cannot access user data');
    }

    // Decrypt sensitive fields only if authorized
    const userData = { ...user };

    if (this.canViewSensitiveData(requestingUser, user)) {
      this.sensitiveFields.forEach(field => {
        if (userData[field]) {
          userData[field] = this.encryptionService.decrypt(userData[field]);
        }
      });
    } else {
      // Remove sensitive fields for unauthorized access
      this.sensitiveFields.forEach(field => {
        delete userData[field];
      });
    }

    return userData;
  }
}
```

## API Security

### Secure API Design
```javascript
// ✅ GOOD - Secure API middleware
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cors = require('cors');

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // limit each IP to 5 auth requests per windowMs
  skipSuccessfulRequests: true
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
```

### JWT Token Security
```javascript
// ✅ GOOD - Secure JWT handling
class TokenService {
  constructor() {
    this.jwt = require('jsonwebtoken');
    this.refreshTokenSecret = process.env.REFRESH_TOKEN_SECRET;
    this.accessTokenSecret = process.env.ACCESS_TOKEN_SECRET;
  }

  generateAccessToken(user) {
    return this.jwt.sign(
      {
        sub: user.id,
        email: user.email,
        role: user.role,
        type: 'access'
      },
      this.accessTokenSecret,
      {
        expiresIn: '15m',
        issuer: 'your-app',
        audience: 'your-users',
        algorithm: 'HS256'
      }
    );
  }

  generateRefreshToken(user) {
    return this.jwt.sign(
      {
        sub: user.id,
        type: 'refresh',
        tokenId: crypto.randomUUID() // Unique token ID for revocation
      },
      this.refreshTokenSecret,
      {
        expiresIn: '7d',
        issuer: 'your-app',
        audience: 'your-users',
        algorithm: 'HS256'
      }
    );
  }

  verifyAccessToken(token) {
    try {
      return this.jwt.verify(token, this.accessTokenSecret, {
        issuer: 'your-app',
        audience: 'your-users',
        algorithms: ['HS256']
      });
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new TokenExpiredError('Access token expired');
      } else if (error.name === 'JsonWebTokenError') {
        throw new InvalidTokenError('Invalid access token');
      }
      throw error;
    }
  }

  async revokeToken(tokenId) {
    await this.tokenRepository.revokeToken(tokenId);
  }
}

// Middleware for token validation
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = tokenService.verifyAccessToken(token);

    // Check if token is revoked
    const isRevoked = await tokenRepository.isTokenRevoked(decoded.tokenId);
    if (isRevoked) {
      return res.status(401).json({ error: 'Token has been revoked' });
    }

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: error.message });
  }
}
```

## Web Security

### XSS Prevention
```javascript
// ✅ GOOD - XSS prevention
class SecurityService {
  static escapeHtml(unsafe) {
    if (!unsafe) return '';

    return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  static sanitizeInput(input, type = 'text') {
    if (!input) return '';

    switch (type) {
      case 'html':
        // Use proper HTML sanitizer
        const DOMPurify = require('dompurify');
        return DOMPurify.sanitize(input);

      case 'url':
        // Validate and sanitize URLs
        try {
          const url = new URL(input);
          return ['http:', 'https:'].includes(url.protocol) ? url.toString() : '';
        } catch {
          return '';
        }

      case 'numeric':
        // Allow only numbers
        return input.replace(/[^0-9]/g, '');

      default:
        return this.escapeHtml(input);
    }
  }

  static generateCspNonce() {
    return require('crypto').randomBytes(16).toString('base64');
  }
}

// CSP middleware
function setContentSecurityPolicy(req, res, next) {
  const nonce = SecurityService.generateCspNonce();

  res.locals.cspNonce = nonce;

  res.setHeader(
    'Content-Security-Policy',
    `default-src 'self'; script-src 'self' 'nonce-${nonce}'; style-src 'self' 'nonce-${nonce}'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none';`
  );

  next();
}
```

### CSRF Protection
```javascript
// ✅ GOOD - CSRF protection
const csrf = require('csurf');

// CSRF protection configuration
const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  }
});

// CSRF token middleware
app.use(csrfProtection);

// Provide CSRF token to frontend
app.get('/api/csrf-token', (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// Validate CSRF token on state-changing requests
app.post('/api/users', csrfProtection, userController.createUser);
app.put('/api/users/:id', csrfProtection, userController.updateUser);
app.delete('/api/users/:id', csrfProtection, userController.deleteUser);
```

## Security Monitoring and Logging

### Security Event Logging
```javascript
// ✅ GOOD - Security logging
class SecurityLogger {
  static logAuthenticationAttempt(req, email, success, ip, userAgent) {
    const event = {
      timestamp: new Date().toISOString(),
      type: 'AUTHENTICATION_ATTEMPT',
      email: this.sanitizeEmail(email),
      success,
      ip: this.sanitizeIp(ip),
      userAgent: this.sanitizeUserAgent(userAgent),
      sessionId: req.sessionID,
      requestId: req.id
    };

    this.logSecurityEvent(event);
  }

  static logAuthorizationFailure(req, userId, resource, action, ip) {
    const event = {
      timestamp: new Date().toISOString(),
      type: 'AUTHORIZATION_FAILURE',
      userId,
      resource,
      action,
      ip: this.sanitizeIp(ip),
      sessionId: req.sessionID,
      requestId: req.id
    };

    this.logSecurityEvent(event);
  }

  static logSuspiciousActivity(req, description, severity = 'medium') {
    const event = {
      timestamp: new Date().toISOString(),
      type: 'SUSPICIOUS_ACTIVITY',
      description,
      severity,
      ip: this.sanitizeIp(req.ip),
      userAgent: this.sanitizeUserAgent(req.headers['user-agent']),
      sessionId: req.sessionID,
      requestId: req.id
    };

    this.logSecurityEvent(event);

    // Alert for high severity events
    if (severity === 'high') {
      this.sendSecurityAlert(event);
    }
  }

  static logSecurityEvent(event) {
    // Log to security monitoring system
    logger.warn('Security Event', event);

    // Store in security events database
    securityEventRepository.create(event);
  }

  static sanitizeEmail(email) {
    // Mask email for privacy
    const [username, domain] = email.split('@');
    const maskedUsername = username.charAt(0) + '*'.repeat(username.length - 2) + username.charAt(username.length - 1);
    return `${maskedUsername}@${domain}`;
  }

  static sanitizeIp(ip) {
    // Hash IP for privacy while maintaining uniqueness
    return require('crypto').createHash('sha256').update(ip).digest('hex').substring(0, 16);
  }

  static sanitizeUserAgent(userAgent) {
    // Remove potentially sensitive info from user agent
    return userAgent?.substring(0, 200) || '';
  }
}
```

### Intrusion Detection
```javascript
// ✅ GOOD - Basic intrusion detection
class IntrusionDetectionService {
  constructor() {
    this.suspiciousPatterns = [
      /\.\.\//,           // Path traversal
      /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,  // XSS
      /union\s+select/i,  // SQL injection
      /exec\s*\(/i,       // Code execution
      /eval\s*\(/i,       // Code execution
      /\$\(.*\)/,         // Command injection
    ];
  }

  detectSuspiciousActivity(req, res, next) {
    const suspiciousActivity = this.analyzeRequest(req);

    if (suspiciousActivity) {
      SecurityLogger.logSuspiciousActivity(
        req,
        `Suspicious pattern detected: ${suspiciousActivity}`,
        'high'
      );

      // Optionally block the request
      return res.status(403).json({ error: 'Request blocked' });
    }

    next();
  }

  analyzeRequest(req) {
    const checkPatterns = (data) => {
      if (typeof data === 'string') {
        for (const pattern of this.suspiciousPatterns) {
          if (pattern.test(data)) {
            return pattern.toString();
          }
        }
      } else if (typeof data === 'object' && data !== null) {
        for (const value of Object.values(data)) {
          const result = checkPatterns(value);
          if (result) return result;
        }
      }
      return null;
    };

    // Check URL, query parameters, and body
    return checkPatterns(req.url) ||
           checkPatterns(req.query) ||
           checkPatterns(req.body);
  }
}
```

## Security Checklist

### Development Security
- [ ] Input validation on all user inputs
- [ ] Output encoding for all user-generated content
- [ ] Parameterized queries for database operations
- [ ] Proper error handling (no information leakage)
- [ ] Secure password hashing (bcrypt, Argon2)
- [ ] HTTPS enforcement in production
- [ ] Security headers configured
- [ ] CSRF protection enabled
- [ ] Rate limiting implemented
- [ ] Security logging enabled

### Deployment Security
- [ ] Environment variables properly secured
- [ ] Secrets management configured
- [ ] Database access restricted
- [ ] Firewall rules configured
- [ ] Regular security updates applied
- [ ] Security monitoring enabled
- [ ] Backup encryption enabled
- [ ] Access logging configured
- [ ] Vulnerability scanning scheduled
- [ ] Incident response plan prepared

### Code Review Security
- [ ] No hardcoded credentials
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No insecure deserialization
- [ ] Proper authentication implemented
- [ ] Authorization checks present
- [ ] Sensitive data encrypted
- [ ] Secure cookie configuration
- [ ] Proper session management
- [ ] Input validation comprehensive

---

**This rule ensures comprehensive security measures that protect against common vulnerabilities and maintain secure development practices across all systems.**