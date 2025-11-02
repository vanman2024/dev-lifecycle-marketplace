# Status Markers and Completion Evidence Examples

This document provides examples of completion markers that the sync-patterns scripts look for when determining if a feature is implemented.

## Overview

The sync scripts use heuristics to detect implementation evidence by searching for specific patterns in code. Understanding these patterns helps you write code and specs that are easily synchronized.

---

## 1. Test Files (Evidence Score: +2)

Tests are the strongest evidence that a feature is implemented and working.

### JavaScript/TypeScript Tests

**Jest/Vitest:**
```typescript
// tests/auth/login.test.ts

describe('User Login', () => {
  it('should authenticate user with valid credentials', async () => {
    const result = await login('user@example.com', 'password123');
    expect(result.success).toBe(true);
  });

  it('should reject invalid credentials', async () => {
    const result = await login('user@example.com', 'wrong');
    expect(result.success).toBe(false);
  });

  test('should generate JWT token on successful login', async () => {
    const result = await login('user@example.com', 'password123');
    expect(result.token).toBeDefined();
  });
});
```

**What the script detects:**
- `describe('User Login')` - Feature name match
- `it('should authenticate')` - Test assertion
- `test('should generate JWT')` - Test assertion
- File path contains `test` or `spec`

### Python Tests

**pytest:**
```python
# tests/test_authentication.py

def test_user_login_success():
    """Test successful user login"""
    result = authenticate_user('user@example.com', 'password123')
    assert result.success is True

def test_user_login_failure():
    """Test failed login with wrong password"""
    result = authenticate_user('user@example.com', 'wrong')
    assert result.success is False

class TestUserAuthentication:
    def test_password_hashing(self):
        """Test password is properly hashed"""
        hashed = hash_password('password123')
        assert verify_password('password123', hashed)
```

**What the script detects:**
- `def test_` prefix - Test function
- `class TestUser` - Test class
- `assert` statements - Assertions
- File name starts with `test_`

---

## 2. Implementation Files (Evidence Score: +1)

Actual code implementation of features.

### Function Definitions

**JavaScript/TypeScript:**
```typescript
// src/auth/login.ts

export async function authenticateUser(
  email: string,
  password: string
): Promise<AuthResult> {
  const user = await findUserByEmail(email);
  if (!user) {
    return { success: false, error: 'User not found' };
  }

  const isValid = await verifyPassword(password, user.passwordHash);
  if (!isValid) {
    return { success: false, error: 'Invalid password' };
  }

  const token = generateJWT(user.id);
  return { success: true, token, user };
}

export function generateJWT(userId: string): string {
  return jwt.sign({ userId }, process.env.JWT_SECRET!);
}
```

**What the script detects:**
- `function authenticateUser` - Function name
- `export function` - Exported function
- `async function` - Async implementation

**Python:**
```python
# src/authentication.py

def authenticate_user(email: str, password: str) -> AuthResult:
    """Authenticate user with email and password"""
    user = find_user_by_email(email)
    if not user:
        return AuthResult(success=False, error='User not found')

    is_valid = verify_password(password, user.password_hash)
    if not is_valid:
        return AuthResult(success=False, error='Invalid password')

    token = generate_jwt(user.id)
    return AuthResult(success=True, token=token, user=user)

class AuthenticationService:
    """Service for handling user authentication"""

    def login(self, email: str, password: str) -> LoginResponse:
        # Implementation
        pass
```

**What the script detects:**
- `def authenticate_user` - Function definition
- `class AuthenticationService` - Class definition
- Docstrings describing functionality

### Class Definitions

**TypeScript:**
```typescript
// src/auth/AuthService.ts

export class AuthenticationService {
  constructor(private userRepository: UserRepository) {}

  async login(email: string, password: string): Promise<LoginResult> {
    // Implementation
  }

  async logout(userId: string): Promise<void> {
    // Implementation
  }
}
```

**What the script detects:**
- `class AuthenticationService` - Class name
- `export class` - Exported class
- Method names: `login`, `logout`

---

## 3. Configuration Files (Evidence Score: +1)

Configuration that enables or configures a feature.

### Environment Variables

**.env:**
```bash
# Authentication Configuration
JWT_SECRET=your-secret-key-here
JWT_EXPIRATION=24h
SESSION_TIMEOUT=3600

# OAuth Configuration
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
OAUTH_CALLBACK_URL=http://localhost:3000/auth/callback
```

**What the script detects:**
- `JWT_SECRET` - Authentication config
- `OAUTH` keywords - OAuth integration
- Comments indicating feature configuration

### Config Files

**JSON:**
```json
// config/authentication.json
{
  "authentication": {
    "enabled": true,
    "providers": ["email", "google", "github"],
    "jwt": {
      "algorithm": "HS256",
      "expiresIn": "24h"
    },
    "session": {
      "timeout": 3600,
      "secure": true
    }
  }
}
```

**YAML:**
```yaml
# config/auth.yml
authentication:
  enabled: true
  providers:
    - email
    - google
    - github
  jwt:
    algorithm: HS256
    expiresIn: 24h
  passwordPolicy:
    minLength: 8
    requireUppercase: true
    requireNumbers: true
```

**What the script detects:**
- `authentication` key in config
- Feature-related settings
- File in `config/` directory

---

## 4. Documentation (Evidence Score: +1)

Documentation describing the feature.

### README Sections

**README.md:**
```markdown
## Authentication

This application uses JWT-based authentication with support for email/password and OAuth providers.

### Features

- User registration and login
- Password hashing with bcrypt
- JWT token generation and validation
- Session management
- OAuth integration (Google, GitHub)

### Usage

\`\`\`typescript
import { authenticateUser } from './auth';

const result = await authenticateUser('user@example.com', 'password');
if (result.success) {
  console.log('Logged in:', result.user);
}
\`\`\`

### Configuration

Set these environment variables:
- `JWT_SECRET` - Secret key for signing tokens
- `JWT_EXPIRATION` - Token expiration time
```

**What the script detects:**
- `## Authentication` heading
- Feature description
- Usage examples
- Configuration documentation

### Inline Comments

**TypeScript:**
```typescript
/**
 * Authenticates a user with email and password
 *
 * This function:
 * 1. Looks up user by email
 * 2. Verifies password hash
 * 3. Generates JWT token
 * 4. Returns authentication result
 *
 * @param email - User's email address
 * @param password - Plain text password
 * @returns Authentication result with token
 */
export async function authenticateUser(
  email: string,
  password: string
): Promise<AuthResult> {
  // Implementation
}
```

**What the script detects:**
- JSDoc comments describing feature
- Function/class documentation
- Implementation notes

### CHANGELOG

**CHANGELOG.md:**
```markdown
## [1.2.0] - 2025-11-01

### Added
- User authentication with email and password
- JWT token generation and validation
- Password reset flow
- OAuth integration with Google

### Changed
- Updated session timeout to 1 hour
- Improved password hashing algorithm

### Security
- Implemented rate limiting on login endpoint
- Added brute force protection
```

**What the script detects:**
- Feature mentions in CHANGELOG
- Implementation dates
- Security improvements

---

## 5. API Routes/Endpoints (Evidence Score: +1)

Exposed API endpoints for the feature.

### Express.js Routes

```typescript
// src/routes/auth.routes.ts

import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';

const router = Router();

router.post('/auth/login', AuthController.login);
router.post('/auth/logout', AuthController.logout);
router.post('/auth/register', AuthController.register);
router.post('/auth/reset-password', AuthController.resetPassword);
router.get('/auth/verify', AuthController.verifyToken);

export default router;
```

**What the script detects:**
- `/auth/login` endpoint
- `auth` in route path
- Controller methods

### FastAPI Routes

```python
# src/routes/auth.py

from fastapi import APIRouter, Depends
from src.controllers.auth import AuthController

router = APIRouter(prefix="/auth", tags=["authentication"])

@router.post("/login")
async def login(credentials: LoginCredentials):
    """User login endpoint"""
    return await AuthController.login(credentials)

@router.post("/logout")
async def logout(token: str = Depends(get_current_token)):
    """User logout endpoint"""
    return await AuthController.logout(token)
```

**What the script detects:**
- `@router.post("/login")` decorator
- `/auth` prefix
- Function names and docstrings

---

## 6. Database Migrations (Evidence Score: +2)

Database schema changes for the feature.

### SQL Migrations

```sql
-- migrations/001_create_users_table.sql

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- Session storage for authentication
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(500) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**What the script detects:**
- `CREATE TABLE users` - User table
- `password_hash` column - Authentication field
- `sessions` table - Session management
- File in `migrations/` directory

### ORM Models

**TypeScript (Prisma):**
```prisma
// prisma/schema.prisma

model User {
  id           String    @id @default(uuid())
  email        String    @unique
  passwordHash String
  sessions     Session[]
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
}

model Session {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  token     String
  expiresAt DateTime
  createdAt DateTime @default(now())
}
```

**What the script detects:**
- `model User` - User model
- `passwordHash` field
- `Session` model
- Authentication-related models

---

## 7. Spec File Status Markers

In addition to code evidence, spec files themselves contain status markers.

### Frontmatter Status

```markdown
---
title: User Authentication
status: complete
last_updated: 2025-11-02T18:00:00Z
updated_by: sync-analyzer
created: 2025-10-15
priority: high
status_history:
  - status: pending, date: 2025-10-15T10:00:00Z, by: developer
  - status: in-progress, date: 2025-10-20T14:00:00Z, by: developer
  - status: complete, date: 2025-11-02T18:00:00Z, by: sync-analyzer
---
```

**Status values:**
- `complete` - Feature fully implemented
- `in-progress` - Currently being worked on
- `pending` - Not yet started
- `blocked` - Blocked by dependency or issue

### Task Checkboxes

**Complete tasks:**
```markdown
## Requirements

- [x] User login with email and password
- [x] Password hashing with bcrypt
- [x] JWT token generation
- [x] Token validation middleware
- [x] Logout functionality
```

**Incomplete tasks:**
```markdown
## Requirements

- [ ] Multi-factor authentication
- [ ] OAuth integration with Google
- [ ] Password reset flow
```

---

## Evidence Scoring Examples

### High Evidence Score (4-5 points)

**Feature: User Authentication**

Evidence found:
- ✓ Test file: `tests/auth/login.test.ts` (+2)
- ✓ Implementation: `src/auth/login.ts` (+1)
- ✓ Config: `config/auth.json` (+1)
- ✓ Docs: `README.md` section (+1)

**Total: 5 points - Very likely complete**

### Moderate Evidence Score (2-3 points)

**Feature: Rate Limiting**

Evidence found:
- ✓ Implementation: `src/middleware/rate-limit.ts` (+1)
- ✓ Config: `config/rate-limits.json` (+1)

**Total: 2 points - Likely complete, but verify tests exist**

### Low Evidence Score (0-1 points)

**Feature: Analytics Dashboard**

Evidence found:
- ✓ Docs mention: `README.md` (+1)

**Total: 1 point - Probably incomplete**

---

## Best Practices for Discoverable Implementation

To make your implementations easily discovered by sync scripts:

1. **Use descriptive names** that match spec terminology
2. **Write tests** for all features (strongest evidence)
3. **Document features** in README or inline comments
4. **Create config files** for feature settings
5. **Update CHANGELOG** when completing features
6. **Mark completed tasks** in specs immediately

---

## Troubleshooting Detection

### Feature not detected despite being complete

**Possible causes:**
- Code uses different terminology than spec
- Feature split across many small files
- Missing tests
- Low keyword overlap

**Solutions:**
- Ensure function/class names match spec keywords
- Add comprehensive tests
- Document feature in README
- Manually mark as complete and add implementation notes

### False positives

**Possible causes:**
- Partial implementation
- Old/dead code not removed
- Tests without implementation
- Configuration without code

**Solutions:**
- Increase minimum evidence score (`--min-evidence 3`)
- Review flagged items manually
- Remove dead code and unused configs
- Ensure tests match implementations

---

*Use these patterns consistently to maintain accurate sync between specifications and implementation.*
