---
name: API Contract Testing
description: OpenAPI to Portman to Newman pipeline with auth injection for API contract testing. Use when building API tests from OpenAPI specs, injecting authentication into test collections, running contract tests, or when user mentions OpenAPI, Portman, API contract, Swagger, API testing pipeline, auth injection.
---

# API Contract Testing

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides a complete pipeline for API contract testing: OpenAPI spec -> Portman config -> Postman collection -> Newman execution with auth injection. Replaces the legacy `newman-testing` and `postman-collection-manager` skills with a unified, production-ready approach.

## Instructions

### 1. The Pipeline

```
OpenAPI Spec (openapi.yaml/json)
  -> Portman (transforms to Postman collection with tests)
    -> Auth Injection (adds authentication to requests)
      -> Newman (executes tests with reporting)
```

### 2. Quick Start

**Generate collection from OpenAPI:**
```bash
bash scripts/openapi-to-collection.sh openapi.yaml api-tests.postman_collection.json
```

**Run tests with auth:**
```bash
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json --auth supabase
```

**Full pipeline:**
```bash
bash scripts/openapi-to-collection.sh openapi.yaml collection.json
bash scripts/inject-auth.sh collection.json supabase_cookie
bash scripts/run-api-contract-tests.sh collection.json
```

### 3. Auth Strategy Injection

The pipeline supports multiple auth strategies:

| Strategy | Auth Header | Token Source |
|----------|-------------|--------------|
| `supabase_cookie` | Cookie-based | Supabase auth session |
| `clerk_jwt` | Authorization: Bearer | Clerk JWT token |
| `auth0_token` | Authorization: Bearer | Auth0 access token |
| `bearer_token` | Authorization: Bearer | Generic JWT |
| `api_key` | X-API-Key | API key from env |
| `none` | No auth | Public endpoints |

**Auth injection reads credentials from environment variables (never hardcoded):**
```bash
# Supabase
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Clerk
CLERK_SECRET_KEY=your_clerk_secret_key_here

# Generic
API_KEY=your_api_key_here
AUTH_TOKEN=your_auth_token_here
```

### 4. Portman Configuration

Portman generates test assertions from OpenAPI specs:
- Status code validation
- Response schema validation
- Required field checks
- Content-type validation

See `templates/portman-config.json` for the default configuration.

### 5. Syncing Collections from Routes

For projects without OpenAPI specs, sync collections from route files:
```bash
bash scripts/sync-from-routes.sh src/app/api/ collection.json
```

This scans route files for HTTP handlers and creates a basic collection.

### 6. CI Integration

```bash
bash scripts/run-newman-ci.sh collection.json
```

CI-optimized runner with:
- JUnit XML output for CI reporting
- Non-zero exit code on failure
- Summary report to stdout
- Results artifact for upload

## Available Scripts

1. **openapi-to-collection.sh** - Convert OpenAPI spec to Postman collection via Portman
2. **run-api-contract-tests.sh** - Execute Newman with auth injection and reporting
3. **inject-auth.sh** - Inject authentication strategy into collection
4. **sync-from-routes.sh** - Sync collection from route file directory
5. **run-newman-ci.sh** - CI-optimized Newman runner with JUnit output

## Available Templates

1. **portman-config.json** - Default Portman configuration for test generation
2. **newman-environment.json** - Environment variable template for Newman
3. **collection-with-auth.json** - Example collection with auth pre-request scripts
4. **github-actions-api-tests.yml** - GitHub Actions workflow for API contract tests

## Available Examples

1. **openapi-pipeline.md** - Full OpenAPI to Newman pipeline walkthrough
2. **auth-injection-supabase.md** - Supabase cookie auth injection example
3. **auth-injection-clerk.md** - Clerk JWT auth injection example
4. **auth-injection-generic.md** - Generic bearer token and API key examples

## Requirements

- Node.js for Newman and Portman
- `npm install -g newman` for test execution
- `npm install -g @apideck/portman` for OpenAPI conversion (optional)
- `jq` for JSON manipulation
- Environment variables for auth credentials

## Progressive Disclosure

- Read `examples/openapi-pipeline.md` for the full pipeline
- Read `examples/auth-injection-supabase.md` for Supabase auth setup
- Read `templates/portman-config.json` for Portman configuration options
