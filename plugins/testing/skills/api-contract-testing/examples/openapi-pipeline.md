# OpenAPI to Newman Pipeline Example

## Scenario

Convert an OpenAPI spec to a tested Postman collection with auth.

## Steps

### 1. Generate Collection from OpenAPI

```bash
bash scripts/openapi-to-collection.sh openapi.yaml api-tests.postman_collection.json
```

Output:
```
=== OpenAPI to Postman Collection ===
Spec:    openapi.yaml
Output:  api-tests.postman_collection.json

Using Portman config: templates/portman-config.json
Collection generated: api-tests.postman_collection.json
Requests: 15
```

### 2. Inject Auth (Supabase)

```bash
bash scripts/inject-auth.sh api-tests.postman_collection.json supabase_cookie
```

### 3. Run Tests

```bash
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json \
  --env templates/newman-environment.json
```

Output:
```
=== API Contract Tests ===
Collection: api-tests.postman_collection.json
Auth: supabase_cookie

Running Newman...

=== Results ===
Assertions: 45/45 passed (0 failed)
```

### 4. Run in CI

```bash
bash scripts/run-newman-ci.sh api-tests.postman_collection.json
```

Produces JUnit XML and JSON reports for CI integration.
