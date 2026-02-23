# Generic Auth Injection Examples

## Bearer Token

For APIs that accept a static or pre-generated JWT:

```bash
# Inject bearer token auth
bash scripts/inject-auth.sh api-tests.postman_collection.json bearer_token

# Set the token and run
export AUTH_TOKEN="your_auth_token_here"
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json
```

## API Key

For APIs that use API key authentication:

```bash
# Inject API key auth
bash scripts/inject-auth.sh api-tests.postman_collection.json api_key

# Set the key and run
export API_KEY="your_api_key_here"
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json
```

The API key is sent as `X-API-Key` header by default.

## No Auth (Public APIs)

For public endpoints, skip auth injection:

```bash
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json
```

Or explicitly:

```bash
bash scripts/run-api-contract-tests.sh api-tests.postman_collection.json --auth none
```
