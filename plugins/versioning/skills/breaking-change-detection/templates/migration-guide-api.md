# API Migration Guide: [OLD_VERSION] → [NEW_VERSION]

**API Version:** [NEW_VERSION]
**Release Date:** [DATE]
**Migration Deadline:** [DATE]

---

## API Breaking Changes Summary

| Change Type | Count | Severity |
|-------------|-------|----------|
| Removed Endpoints | [NUM] | 🔴 CRITICAL |
| Changed Request/Response | [NUM] | 🟠 HIGH |
| New Required Parameters | [NUM] | 🟠 HIGH |
| Authentication Changes | [NUM] | 🟡 MEDIUM |

---

## Endpoint Changes

### Removed Endpoints

#### `[HTTP_METHOD] /api/v1/[endpoint]`

**Status:** ❌ REMOVED
**Reason:** [Explanation]
**Alternative:** Use `[HTTP_METHOD] /api/v2/[new-endpoint]`

##### Migration Example

**Old Request (v1):**
```http
GET /api/v1/users?include=profile
Authorization: Bearer {token}
```

**Old Response:**
```json
{
  "users": [
    {
      "id": 123,
      "name": "John Doe",
      "profile": {...}
    }
  ]
}
```

**New Request (v2):**
```http
GET /api/v2/users?expand=profile
Authorization: Bearer {token}
```

**New Response:**
```json
{
  "data": [
    {
      "id": 123,
      "attributes": {
        "name": "John Doe"
      },
      "relationships": {
        "profile": {...}
      }
    }
  ],
  "meta": {
    "count": 1
  }
}
```

**Code Migration:**

JavaScript/TypeScript:
```typescript
// Before
const response = await fetch('/api/v1/users?include=profile', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const users = await response.json().users;

// After
const response = await fetch('/api/v2/users?expand=profile', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const users = await response.json().data;
```

Python:
```python
# Before
response = requests.get(
    '/api/v1/users?include=profile',
    headers={'Authorization': f'Bearer {token}'}
)
users = response.json()['users']

# After
response = requests.get(
    '/api/v2/users?expand=profile',
    headers={'Authorization': f'Bearer {token}'}
)
users = response.json()['data']
```

---

### Changed Request Parameters

#### `POST /api/v[X]/[endpoint]`

**Change:** Required parameter added
**New Parameter:** `[parameter_name]` (required)
**Type:** `[type]`

##### Before

```http
POST /api/v1/orders
Content-Type: application/json

{
  "items": [
    {"product_id": 123, "quantity": 2}
  ]
}
```

##### After

```http
POST /api/v2/orders
Content-Type: application/json

{
  "customer_id": "cust_123",  // NEW REQUIRED FIELD
  "items": [
    {"product_id": 123, "quantity": 2}
  ]
}
```

##### Migration Code

```typescript
// Before
const createOrder = async (items: OrderItem[]) => {
  return await api.post('/api/v1/orders', { items });
};

// After
const createOrder = async (customerId: string, items: OrderItem[]) => {
  return await api.post('/api/v2/orders', {
    customer_id: customerId,  // Now required
    items
  });
};
```

---

### Changed Response Format

#### `GET /api/v[X]/[endpoint]`

**Change:** Response structure modified
**Impact:** Clients must update response parsing

##### Before (v1)

```json
{
  "id": 123,
  "name": "Product",
  "price": 99.99,
  "created": "2024-01-01"
}
```

##### After (v2)

```json
{
  "id": 123,
  "attributes": {
    "name": "Product",
    "price": {
      "amount": 9999,
      "currency": "USD"
    }
  },
  "meta": {
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

##### Adapter Pattern

Create an adapter to handle both versions during migration:

```typescript
interface Product {
  id: number;
  name: string;
  price: number;
  created: Date;
}

function adaptProductResponse(response: any, version: 'v1' | 'v2'): Product {
  if (version === 'v1') {
    return {
      id: response.id,
      name: response.name,
      price: response.price,
      created: new Date(response.created)
    };
  } else {
    return {
      id: response.id,
      name: response.attributes.name,
      price: response.attributes.price.amount / 100,
      created: new Date(response.meta.created_at)
    };
  }
}
```

---

## Authentication Changes

### [Authentication Change Description]

**Old Method:** [OLD_AUTH_METHOD]
**New Method:** [NEW_AUTH_METHOD]

#### Before

```http
GET /api/v1/resource
Authorization: ApiKey {api_key}
```

#### After

```http
GET /api/v2/resource
Authorization: Bearer {jwt_token}
```

#### Migration Steps

1. **Generate JWT tokens:**
   ```bash
   curl -X POST https://api.example.com/auth/token \
     -H "Content-Type: application/json" \
     -d '{"api_key": "your_api_key"}'
   ```

2. **Update client code:**
   ```typescript
   // Before
   const headers = {
     'Authorization': `ApiKey ${apiKey}`
   };

   // After
   const headers = {
     'Authorization': `Bearer ${jwtToken}`
   };
   ```

3. **Implement token refresh:**
   ```typescript
   async function refreshToken(refreshToken: string): Promise<string> {
     const response = await fetch('/auth/refresh', {
       method: 'POST',
       headers: { 'Authorization': `Bearer ${refreshToken}` }
     });
     const { access_token } = await response.json();
     return access_token;
   }
   ```

---

## Error Response Changes

### New Error Format

**Old Format:**
```json
{
  "error": "Invalid request",
  "code": 400
}
```

**New Format:**
```json
{
  "errors": [
    {
      "status": "400",
      "code": "INVALID_REQUEST",
      "title": "Invalid Request",
      "detail": "The 'customer_id' field is required",
      "source": {
        "pointer": "/data/attributes/customer_id"
      }
    }
  ]
}
```

### Error Handling Migration

```typescript
// Before
try {
  await api.createOrder(items);
} catch (error) {
  console.error(error.response.data.error);
}

// After
try {
  await api.createOrder(customerId, items);
} catch (error) {
  const errors = error.response.data.errors;
  errors.forEach(err => {
    console.error(`${err.code}: ${err.detail}`);
  });
}
```

---

## Rate Limiting Changes

### New Rate Limits

| Endpoint | Old Limit | New Limit |
|----------|-----------|-----------|
| `GET /api/v2/*` | 1000/hour | 100/minute |
| `POST /api/v2/*` | 100/hour | 20/minute |
| `DELETE /api/v2/*` | 50/hour | 10/minute |

### Response Headers

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
Retry-After: 60
```

### Handle Rate Limiting

```typescript
async function apiCallWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.response?.status === 429) {
        const retryAfter = parseInt(error.response.headers['retry-after'] || '60');
        await sleep(retryAfter * 1000);
        continue;
      }
      throw error;
    }
  }
  throw new Error('Max retries exceeded');
}
```

---

## Pagination Changes

### Old Pagination (Offset-based)

```http
GET /api/v1/users?page=2&per_page=20
```

Response:
```json
{
  "users": [...],
  "page": 2,
  "per_page": 20,
  "total": 150
}
```

### New Pagination (Cursor-based)

```http
GET /api/v2/users?limit=20&cursor=eyJpZCI6MTIzfQ==
```

Response:
```json
{
  "data": [...],
  "meta": {
    "next_cursor": "eyJpZCI6MTQzfQ==",
    "has_more": true
  }
}
```

### Pagination Migration

```typescript
// Before: Offset-based
async function getAllUsers(): Promise<User[]> {
  const users: User[] = [];
  let page = 1;
  let hasMore = true;

  while (hasMore) {
    const response = await fetch(`/api/v1/users?page=${page}&per_page=20`);
    const data = await response.json();
    users.push(...data.users);
    hasMore = page * 20 < data.total;
    page++;
  }

  return users;
}

// After: Cursor-based
async function getAllUsers(): Promise<User[]> {
  const users: User[] = [];
  let cursor: string | null = null;

  do {
    const url = cursor
      ? `/api/v2/users?limit=20&cursor=${cursor}`
      : '/api/v2/users?limit=20';

    const response = await fetch(url);
    const data = await response.json();
    users.push(...data.data);
    cursor = data.meta.has_more ? data.meta.next_cursor : null;
  } while (cursor);

  return users;
}
```

---

## SDK Migration

### JavaScript/TypeScript SDK

```bash
# Update SDK
npm install @company/api-sdk@^2.0.0

# Or with yarn
yarn add @company/api-sdk@^2.0.0
```

**Code Changes:**

```typescript
// Before (v1)
import { ApiClient } from '@company/api-sdk';

const client = new ApiClient({
  apiKey: 'your_api_key'
});

const users = await client.users.list();

// After (v2)
import { ApiClient } from '@company/api-sdk';

const client = new ApiClient({
  accessToken: 'your_jwt_token'
});

const users = await client.users.list({
  limit: 20
});
```

---

## Testing Your Migration

### 1. Parallel Testing

Run both versions simultaneously:

```typescript
const resultsV1 = await apiV1.getUsers();
const resultsV2 = await apiV2.getUsers();

compareResults(resultsV1, resultsV2);
```

### 2. Feature Flags

Use feature flags to toggle between versions:

```typescript
const apiVersion = featureFlags.get('api-version') || 'v1';
const api = apiVersion === 'v2' ? apiV2 : apiV1;

const users = await api.getUsers();
```

### 3. Integration Tests

```typescript
describe('API v2 Migration', () => {
  test('users endpoint returns correct format', async () => {
    const response = await fetch('/api/v2/users');
    const data = await response.json();

    expect(data).toHaveProperty('data');
    expect(data).toHaveProperty('meta');
    expect(Array.isArray(data.data)).toBe(true);
  });
});
```

---

## Support & Resources

- **API Documentation:** [URL]
- **Interactive API Explorer:** [URL]
- **Postman Collection:** [URL]
- **SDK Repository:** [GITHUB_URL]
- **Support Email:** [EMAIL]
- **Developer Forum:** [URL]

---

**Last Updated:** [TIMESTAMP]
