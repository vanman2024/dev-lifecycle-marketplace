# Example: API Contract Analysis

This example demonstrates detecting breaking changes in a REST API using OpenAPI specifications.

## Scenario

A web service is upgrading from v1 to v2, introducing several API changes. We need to detect and classify breaking changes.

## Input Files

### Old API Spec (v1)

**File:** `api-v1.yaml`

```yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 1.0.0

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  users:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  total:
                    type: integer

  /users/{id}:
    get:
      summary: Get user by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: User found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

    delete:
      summary: Delete user
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '204':
          description: User deleted

  /auth/login:
    post:
      summary: Login
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
      responses:
        '200':
          description: Login successful
          content:
            application/json:
              schema:
                type: object
                properties:
                  token:
                    type: string

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        username:
          type: string
        email:
          type: string
        created_at:
          type: string
          format: date-time
```

### New API Spec (v2)

**File:** `api-v2.yaml`

```yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 2.0.0

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: cursor
          in: query
          schema:
            type: string
        - name: limit
          in: query
          schema:
            type: integer
        - name: filter
          in: query
          required: true  # BREAKING: New required parameter
          schema:
            type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:  # BREAKING: Changed from 'users' to 'data'
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  meta:
                    type: object
                    properties:
                      next_cursor:
                        type: string

  /users/{id}:
    get:
      summary: Get user by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string  # BREAKING: Changed from integer to string
      responses:
        '200':
          description: User found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

    # BREAKING: DELETE method removed

  /auth/token:  # BREAKING: Renamed from /auth/login
    post:
      summary: Get authentication token
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                username:
                  type: string
                password:
                  type: string
                mfa_code:  # Non-breaking: Optional field added
                  type: string
      responses:
        '200':
          description: Token generated
          content:
            application/json:
              schema:
                type: object
                properties:
                  access_token:
                    type: string
                  refresh_token:  # Non-breaking: New field added
                    type: string

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string  # BREAKING: Changed from integer to string
        username:
          type: string
        email:
          type: string
        profile:  # Non-breaking: New optional field
          type: object
        created_at:
          type: string
          format: date-time
```

## Running the Analysis

```bash
# Run OpenAPI diff script
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/breaking-change-detection/scripts/openapi-diff.sh \
  api-v1.yaml \
  api-v2.yaml \
  --output breaking-changes-report.md
```

## Expected Output

```
🔍 Analyzing OpenAPI specifications...
   Old: api-v1.yaml
   New: api-v2.yaml

📊 Checking for removed endpoints...
❌ BREAKING: Removed endpoints detected
   - /auth/login

📊 Checking for changed HTTP methods...
❌ BREAKING: Removed methods on /users/{id}
   - delete

📊 Checking for new required parameters...
❌ BREAKING: Added required parameters on GET /users
   - filter

📊 Checking for response schema changes...
⚠️  NON-BREAKING: Response schema modified on GET /users
⚠️  NON-BREAKING: Response schema modified on POST /auth/token

================================
📋 Summary
================================
Breaking changes: 3
Non-breaking changes: 2

📄 Report written to: breaking-changes-report.md

❌ Breaking changes detected - MAJOR version bump required
```

## Generated Report

**File:** `breaking-changes-report.md`

```markdown
# OpenAPI Breaking Change Report

**Generated:** 2024-11-05 18:00:00 UTC
**Old Spec:** api-v1.yaml
**New Spec:** api-v2.yaml

## Summary

- **Breaking Changes:** 3
- **Non-Breaking Changes:** 2

⚠️ **RECOMMENDATION:** This API change requires a **MAJOR version bump** (e.g., v2.0.0)

## Detected Changes

### ❌ BREAKING: Removed Endpoint
**Path:** `/auth/login`
**Impact:** Clients calling this endpoint will receive 404 errors

### ❌ BREAKING: Removed HTTP Method
**Path:** `/users/{id}`
**Method:** `DELETE`
**Impact:** Clients using this method will receive 405 Method Not Allowed

### ❌ BREAKING: Added Required Parameter
**Path:** `/users`
**Method:** `GET`
**Parameter:** `filter`
**Impact:** Existing clients not providing this parameter will receive 400 errors
```

## Migration Guide Creation

Based on the detected breaking changes, create a migration guide:

### For Clients Using `/auth/login`

**Before (v1):**
```javascript
const response = await fetch('/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'user@example.com',
    password: 'password123'
  })
});

const { token } = await response.json();
```

**After (v2):**
```javascript
const response = await fetch('/auth/token', {  // Changed endpoint
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'user@example.com',
    password: 'password123'
  })
});

const { access_token, refresh_token } = await response.json();  // Changed response structure
```

### For Clients Using `DELETE /users/{id}`

**Before (v1):**
```javascript
await fetch(`/users/${userId}`, {
  method: 'DELETE'
});
```

**After (v2):**
```javascript
// DELETE endpoint removed - use soft delete via PATCH instead
await fetch(`/users/${userId}`, {
  method: 'PATCH',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    status: 'deleted'
  })
});
```

### For Clients Using `GET /users`

**Before (v1):**
```javascript
const response = await fetch('/users?page=1&limit=20');
const { users, total } = await response.json();
```

**After (v2):**
```javascript
const response = await fetch('/users?filter=active&limit=20');  // filter now required
const { data, meta } = await response.json();  // Response structure changed

// Handle pagination with cursors
let cursor = null;
do {
  const url = cursor ? `/users?filter=active&cursor=${cursor}` : '/users?filter=active';
  const response = await fetch(url);
  const { data, meta } = await response.json();

  processUsers(data);
  cursor = meta.next_cursor;
} while (cursor);
```

## CI/CD Integration

Add to your pipeline:

```yaml
# .github/workflows/api-validation.yml
name: API Breaking Change Detection

on:
  pull_request:
    paths:
      - 'api/**/*.yaml'

jobs:
  detect-breaking-changes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - name: Get old spec
        run: git show HEAD~1:api/openapi.yaml > old-spec.yaml

      - name: Detect breaking changes
        run: |
          bash scripts/openapi-diff.sh old-spec.yaml api/openapi.yaml

      - name: Fail if breaking without version bump
        if: failure()
        run: |
          OLD_VERSION=$(git show HEAD~1:VERSION | jq -r '.version' | cut -d. -f1)
          NEW_VERSION=$(cat VERSION | jq -r '.version' | cut -d. -f1)

          if [ "$NEW_VERSION" -le "$OLD_VERSION" ]; then
            echo "Breaking changes detected but major version not bumped!"
            exit 1
          fi
```

## Key Takeaways

1. **Endpoint Removals:** Always breaking - provide deprecation period
2. **Method Removals:** Always breaking - suggest alternatives
3. **Required Parameters:** Breaking - make them optional or provide defaults
4. **Response Structure Changes:** Potentially breaking - use API versioning
5. **Type Changes:** Breaking - maintain backward compatibility or version

## Best Practices

1. **Version your API:** Use `/v1/` and `/v2/` prefixes
2. **Deprecate before removing:** Give clients 6-12 months notice
3. **Support multiple versions:** Run v1 and v2 simultaneously during migration
4. **Document everything:** Provide comprehensive migration guides
5. **Automate detection:** Run breaking change analysis on every PR

## Related Resources

- Migration Guide Template: `templates/migration-guide-api.md`
- Breaking Change Report: `templates/breaking-change-report.md`
- CI/CD Integration: `templates/ci-cd-breaking-check.yaml`
