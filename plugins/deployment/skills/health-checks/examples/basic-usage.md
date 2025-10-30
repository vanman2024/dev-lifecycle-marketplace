# Basic Usage Examples

This guide demonstrates simple health check workflows for common deployment scenarios.

## Table of Contents

1. [Single Endpoint Check](#single-endpoint-check)
2. [Multi-Endpoint Validation](#multi-endpoint-validation)
3. [Quick Post-Deployment Check](#quick-post-deployment-check)
4. [SSL Certificate Validation](#ssl-certificate-validation)
5. [Basic Performance Test](#basic-performance-test)

---

## Single Endpoint Check

### HTTP Endpoint

Check if a website is reachable and responding with HTTP 200:

```bash
# Basic check
bash scripts/http-health-check.sh https://example.com

# Check with specific status code
bash scripts/http-health-check.sh https://example.com 200

# Check with response time threshold
bash scripts/http-health-check.sh https://example.com 200 2000
```

**Expected Output:**
```
Attempt 1/3: Checking https://example.com
✓ Status code: 200 (expected: 200)
✓ Response time: 1234ms (max: 2000ms)

Response headers:
HTTP/2 200
content-type: text/html; charset=utf-8
...

SUCCESS: https://example.com is healthy
```

### API Endpoint

Check a REST API health endpoint:

```bash
# Public API (no authentication)
bash scripts/api-health-check.sh https://api.example.com/health

# API with Bearer token
bash scripts/api-health-check.sh https://api.example.com/health "Bearer YOUR_TOKEN"

# Check specific JSON field
bash scripts/api-health-check.sh \
  https://api.example.com/health \
  "Bearer YOUR_TOKEN" \
  ".status" \
  "ok"
```

**Expected Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Attempt 1/3: Checking API endpoint
URL: https://api.example.com/health
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Status code: 200 (Success)
⧗ Response time: 456ms
✓ Valid JSON response

Response body:
{
  "status": "ok",
  "version": "1.0.0",
  "uptime": 86400
}

SUCCESS: API endpoint is healthy
```

---

## Multi-Endpoint Validation

Check multiple endpoints in sequence:

```bash
#!/bin/bash
# check-all-endpoints.sh

set -e

echo "Checking all application endpoints..."

# Frontend
echo -e "\n=== Frontend ==="
bash scripts/http-health-check.sh https://example.com 200 3000

# API
echo -e "\n=== API ==="
bash scripts/api-health-check.sh \
  https://api.example.com/health \
  "Bearer $API_TOKEN" \
  ".status" "healthy"

# MCP Server
echo -e "\n=== MCP Server ==="
bash scripts/mcp-server-health-check.sh https://mcp.example.com

echo -e "\n✓ All endpoints are healthy!"
```

**Usage:**
```bash
export API_TOKEN="your_token_here"
bash check-all-endpoints.sh
```

---

## Quick Post-Deployment Check

Minimal health check after deploying:

```bash
#!/bin/bash
# quick-deployment-check.sh

URL="${1:-https://example.com}"
MAX_RETRIES=5
RETRY_DELAY=10

echo "Waiting for deployment to be ready..."

for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $i/$MAX_RETRIES..."

    if bash scripts/http-health-check.sh "$URL" 200 5000; then
        echo "✓ Deployment is healthy!"
        exit 0
    fi

    if [ $i -lt $MAX_RETRIES ]; then
        echo "Waiting ${RETRY_DELAY}s before retry..."
        sleep $RETRY_DELAY
    fi
done

echo "✗ Deployment failed health check"
exit 1
```

**Usage:**
```bash
# After deployment
bash quick-deployment-check.sh https://newly-deployed.example.com
```

---

## SSL Certificate Validation

Check SSL certificate validity and expiration:

```bash
# Check certificate with default 30-day warning
bash scripts/ssl-tls-validator.sh example.com

# Check with custom port
bash scripts/ssl-tls-validator.sh example.com 8443

# Check with 60-day warning threshold
bash scripts/ssl-tls-validator.sh example.com 443 60
```

**Expected Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SSL/TLS Certificate Validation
Host: example.com:443
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Testing SSL/TLS connectivity...
✓ Successfully connected to example.com:443

Step 2: Retrieving certificate information...
✓ Certificate retrieved successfully

Step 3: Validating certificate details...
Subject: CN=example.com
Issuer: CN=Let's Encrypt Authority X3
Valid from: Jan 15 00:00:00 2024 GMT
Valid until: Apr 15 23:59:59 2024 GMT

Step 4: Checking certificate expiration...
✓ Certificate is valid (75 days remaining)

SUCCESS: SSL/TLS certificate validation passed
```

---

## Basic Performance Test

Run a simple performance test:

```bash
# Light test: 10 concurrent, 100 total requests
bash scripts/performance-tester.sh https://example.com 10 100

# Medium test: 50 concurrent, 500 total requests
bash scripts/performance-tester.sh https://example.com 50 500

# Heavy test: 100 concurrent, 1000 total requests, 20s timeout
bash scripts/performance-tester.sh https://example.com 100 1000 20
```

**Expected Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Performance Testing
URL: https://example.com
Concurrent requests: 50
Total requests: 500
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Warmup request...
✓ Warmup complete

Step 2: Running performance test...
Sending 500 requests with 50 concurrent connections...
Progress: 500/500 requests completed
✓ Test completed in 12s

Step 3: Analyzing results...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Performance Test Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Request Statistics:
  Total requests:        500
  Successful requests:   498
  Failed requests:       2
  Test duration:         12s
  Requests per second:   41.67

Response Time (ms):
  Average:               243ms
  Minimum:               156ms
  Maximum:               1234ms
  50th percentile (p50): 231ms
  90th percentile (p90): 456ms
  95th percentile (p95): 678ms
  99th percentile (p99): 1123ms

HTTP Status Codes:
  200: 498
  503: 2

SUCCESS: Performance test passed
```

---

## Environment-Specific Checks

### Staging Environment

```bash
#!/bin/bash
# check-staging.sh

export BASE_URL="https://staging.example.com"
export API_URL="https://api.staging.example.com"

bash scripts/http-health-check.sh "$BASE_URL"
bash scripts/api-health-check.sh "$API_URL/health"
bash scripts/performance-tester.sh "$BASE_URL" 10 100
```

### Production Environment

```bash
#!/bin/bash
# check-production.sh

export BASE_URL="https://example.com"
export API_URL="https://api.example.com"

bash scripts/http-health-check.sh "$BASE_URL"
bash scripts/api-health-check.sh "$API_URL/health" "Bearer $PROD_API_TOKEN"
bash scripts/ssl-tls-validator.sh example.com 443 30
bash scripts/performance-tester.sh "$BASE_URL" 50 500
```

---

## Error Handling

All scripts return appropriate exit codes:

```bash
# Capture exit code
if bash scripts/http-health-check.sh https://example.com; then
    echo "Health check passed"
else
    exit_code=$?
    echo "Health check failed with code: $exit_code"

    case $exit_code in
        1) echo "Health check failed" ;;
        2) echo "Invalid arguments" ;;
        3) echo "Timeout or network error" ;;
        4) echo "SSL/TLS validation failed" ;;
        5) echo "Performance threshold exceeded" ;;
    esac
fi
```

---

## Tips for Basic Usage

1. **Start simple**: Begin with HTTP checks before adding complexity
2. **Use environment variables**: Store tokens and URLs in env vars
3. **Check exit codes**: Always verify script exit codes for automation
4. **Add retries**: Use RETRIES and RETRY_DELAY environment variables
5. **Test locally first**: Validate health checks work before CI/CD integration

**Environment Variables:**

```bash
export TIMEOUT=15              # Override default timeout
export RETRIES=5               # Override default retry count
export RETRY_DELAY=10          # Override default retry delay
export OUTPUT_DIR=/tmp/health  # Override performance test output
```

**Example with environment variables:**

```bash
TIMEOUT=20 RETRIES=5 bash scripts/api-health-check.sh https://api.example.com/health
```
