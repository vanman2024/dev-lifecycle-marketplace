# Clerk JWT Auth Injection Example

## Scenario

Add Clerk JWT authentication to API contract tests.

## Setup

### 1. Environment Variables

```bash
CLERK_SECRET_KEY=your_clerk_secret_key_here
AUTH_TOKEN=your_clerk_session_token_here
```

### 2. Inject Auth

```bash
bash scripts/inject-auth.sh api-tests.postman_collection.json clerk_jwt
```

### 3. Get a Test Token

For testing, generate a JWT from your Clerk dashboard or use the API:

```bash
# Get a session token for testing (example)
curl -X POST "https://api.clerk.dev/v1/testing_tokens" \
  -H "Authorization: Bearer your_clerk_secret_key_here" \
  -H "Content-Type: application/json"
```

### 4. Run Tests

```bash
export AUTH_TOKEN="<clerk-jwt-token>"
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json
```

## Notes

- Clerk JWTs expire - generate fresh tokens for each test run
- Use Clerk's Testing Tokens feature for CI environments
- Never hardcode Clerk secret keys
