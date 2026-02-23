# Supabase Auth Injection Example

## Scenario

Add Supabase cookie-based authentication to API contract tests.

## Setup

### 1. Environment Variables

Create a `.env.test` file (never commit this):
```bash
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=your_test_password_here
```

### 2. Inject Auth

```bash
bash scripts/inject-auth.sh api-tests.postman_collection.json supabase_cookie
```

This adds a collection-level pre-request script that:
1. Reads Supabase URL and anon key from environment
2. Authenticates with test user credentials
3. Stores the access token in environment variable
4. Adds `Authorization: Bearer <token>` to all requests

### 3. Run Tests

```bash
# Load env vars and run
export $(cat .env.test | xargs)
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json
```

## How Auth Injection Works

The injected pre-request script calls Supabase's `/auth/v1/token` endpoint to get a JWT:

```javascript
pm.sendRequest({
  url: supabaseUrl + "/auth/v1/token?grant_type=password",
  method: "POST",
  header: {
    "Content-Type": "application/json",
    "apikey": supabaseKey
  },
  body: {
    mode: "raw",
    raw: JSON.stringify({ email, password })
  }
}, (err, res) => {
  if (!err && res.code === 200) {
    pm.environment.set("AUTH_TOKEN", res.json().access_token);
  }
});
```

## Notes

- The test user must exist in your Supabase project
- Use a dedicated test user account, not a real user
- Rotate test credentials regularly
- Never hardcode credentials - always use environment variables
