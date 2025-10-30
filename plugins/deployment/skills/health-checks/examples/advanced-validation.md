# Advanced Validation Examples

This guide demonstrates complex validation scenarios with multiple endpoints, dependencies, and custom validation logic.

## Table of Contents

1. [Microservices Validation](#microservices-validation)
2. [Dependency Chain Validation](#dependency-chain-validation)
3. [Multi-Region Validation](#multi-region-validation)
4. [Blue-Green Deployment Validation](#blue-green-deployment-validation)
5. [Custom Validation Logic](#custom-validation-logic)
6. [Progressive Health Checks](#progressive-health-checks)

---

## Microservices Validation

Validate an entire microservices architecture:

```bash
#!/bin/bash
# validate-microservices.sh

set -euo pipefail

# Configuration
ENVIRONMENT="${1:-production}"
PARALLEL_CHECKS="${PARALLEL_CHECKS:-true}"

# Service endpoints
declare -A SERVICES=(
    ["frontend"]="https://app.example.com"
    ["api-gateway"]="https://api.example.com"
    ["auth-service"]="https://auth.example.com"
    ["user-service"]="https://users.example.com"
    ["payment-service"]="https://payments.example.com"
    ["notification-service"]="https://notifications.example.com"
    ["mcp-server"]="https://mcp.example.com"
)

# Expected health check responses
declare -A EXPECTED_JSON=(
    ["api-gateway"]=".status:ok"
    ["auth-service"]=".healthy:true"
    ["user-service"]=".status:operational"
    ["payment-service"]=".service.status:up"
    ["notification-service"]=".health:green"
)

# Track results
TOTAL_SERVICES=${#SERVICES[@]}
PASSED=0
FAILED=0

# Function to check single service
check_service() {
    local name="$1"
    local url="$2"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Checking: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Determine check type based on service
    if [[ "$name" == "mcp-server" ]]; then
        if bash scripts/mcp-server-health-check.sh "$url"; then
            echo "✓ $name is healthy"
            return 0
        else
            echo "✗ $name failed health check"
            return 1
        fi
    elif [[ -v "EXPECTED_JSON[$name]" ]]; then
        # Parse expected JSON path and value
        IFS=: read -r json_path expected_value <<< "${EXPECTED_JSON[$name]}"

        if bash scripts/api-health-check.sh \
            "$url/health" \
            "Bearer ${API_TOKEN:-}" \
            "$json_path" \
            "$expected_value"; then
            echo "✓ $name is healthy"
            return 0
        else
            echo "✗ $name failed health check"
            return 1
        fi
    else
        # Simple HTTP check
        if bash scripts/http-health-check.sh "$url" 200 3000; then
            echo "✓ $name is healthy"
            return 0
        else
            echo "✗ $name failed health check"
            return 1
        fi
    fi
}

export -f check_service
export API_TOKEN

# Run checks
echo "═══════════════════════════════════════════════"
echo "Microservices Health Check"
echo "Environment: $ENVIRONMENT"
echo "Total Services: $TOTAL_SERVICES"
echo "Parallel: $PARALLEL_CHECKS"
echo "═══════════════════════════════════════════════"

if [ "$PARALLEL_CHECKS" = "true" ]; then
    # Run checks in parallel
    echo -e "\nRunning parallel health checks...\n"

    for service_name in "${!SERVICES[@]}"; do
        check_service "$service_name" "${SERVICES[$service_name]}" &
    done

    # Wait for all background jobs and capture exit codes
    for job in $(jobs -p); do
        if wait "$job"; then
            ((PASSED++))
        else
            ((FAILED++))
        fi
    done
else
    # Run checks sequentially
    echo -e "\nRunning sequential health checks...\n"

    for service_name in "${!SERVICES[@]}"; do
        if check_service "$service_name" "${SERVICES[$service_name]}"; then
            ((PASSED++))
        else
            ((FAILED++))
        fi
        echo ""
    done
fi

# Summary
echo "═══════════════════════════════════════════════"
echo "Health Check Summary"
echo "═══════════════════════════════════════════════"
echo "Total:  $TOTAL_SERVICES"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "═══════════════════════════════════════════════"

if [ $FAILED -eq 0 ]; then
    echo "✓ All services are healthy"
    exit 0
else
    echo "✗ Some services failed health checks"
    exit 1
fi
```

**Usage:**
```bash
export API_TOKEN="your_token"
bash validate-microservices.sh production
```

---

## Dependency Chain Validation

Validate services in dependency order (database → cache → API → frontend):

```bash
#!/bin/bash
# validate-dependency-chain.sh

set -euo pipefail

# Track overall status
CHAIN_HEALTHY=true

# Step 1: Database
echo "Step 1: Validating Database..."
if ! bash scripts/api-health-check.sh \
    https://db.example.com/health \
    "" \
    ".database.connected" \
    "true"; then
    echo "✗ Database is down - aborting chain validation"
    exit 1
fi
echo "✓ Database is healthy"

# Step 2: Cache (depends on database)
echo -e "\nStep 2: Validating Cache..."
if ! bash scripts/api-health-check.sh \
    https://cache.example.com/health \
    "" \
    ".cache.status" \
    "connected"; then
    echo "✗ Cache is down - continuing with degraded performance warning"
    CHAIN_HEALTHY=false
else
    echo "✓ Cache is healthy"
fi

# Step 3: API (depends on database and cache)
echo -e "\nStep 3: Validating API..."
if ! bash scripts/api-health-check.sh \
    https://api.example.com/health \
    "Bearer $API_TOKEN" \
    ".dependencies.all_healthy" \
    "true"; then
    echo "✗ API reports unhealthy dependencies"

    # Check which dependency is failing
    response=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
        https://api.example.com/health)

    echo "Dependency status:"
    echo "$response" | jq '.dependencies'

    CHAIN_HEALTHY=false
else
    echo "✓ API is healthy"
fi

# Step 4: Frontend (depends on API)
echo -e "\nStep 4: Validating Frontend..."
if ! bash scripts/http-health-check.sh \
    https://app.example.com \
    200 3000 "Welcome"; then
    echo "✗ Frontend is not responding correctly"
    CHAIN_HEALTHY=false
else
    echo "✓ Frontend is healthy"
fi

# Step 5: Performance validation
echo -e "\nStep 5: Validating End-to-End Performance..."
if ! bash scripts/performance-tester.sh \
    https://app.example.com \
    25 250 15; then
    echo "✗ Performance test failed"
    CHAIN_HEALTHY=false
else
    echo "✓ Performance is acceptable"
fi

# Final status
echo -e "\n═══════════════════════════════════════════════"
if [ "$CHAIN_HEALTHY" = true ]; then
    echo "✓ Entire dependency chain is healthy"
    exit 0
else
    echo "✗ Some services in the chain have issues"
    exit 1
fi
```

---

## Multi-Region Validation

Validate deployment across multiple geographic regions:

```bash
#!/bin/bash
# validate-multi-region.sh

set -euo pipefail

# Region configurations
declare -A REGIONS=(
    ["us-east-1"]="https://us-east.example.com"
    ["us-west-2"]="https://us-west.example.com"
    ["eu-west-1"]="https://eu.example.com"
    ["ap-southeast-1"]="https://asia.example.com"
)

# Regional SSL hostnames
declare -A SSL_HOSTS=(
    ["us-east-1"]="us-east.example.com"
    ["us-west-2"]="us-west.example.com"
    ["eu-west-1"]="eu.example.com"
    ["ap-southeast-1"]="asia.example.com"
)

# Track results per region
declare -A REGION_STATUS

validate_region() {
    local region="$1"
    local url="$2"
    local hostname="$3"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Validating Region: $region"
    echo "URL: $url"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local checks_passed=0
    local checks_total=4

    # Check 1: Basic HTTP health
    echo -e "\n[1/4] HTTP Health Check..."
    if bash scripts/http-health-check.sh "$url" 200 3000; then
        echo "✓ HTTP check passed"
        ((checks_passed++))
    else
        echo "✗ HTTP check failed"
    fi

    # Check 2: API health
    echo -e "\n[2/4] API Health Check..."
    if bash scripts/api-health-check.sh \
        "$url/api/health" \
        "Bearer $API_TOKEN" \
        ".region" \
        "$region"; then
        echo "✓ API check passed"
        ((checks_passed++))
    else
        echo "✗ API check failed"
    fi

    # Check 3: SSL certificate
    echo -e "\n[3/4] SSL Certificate Check..."
    if bash scripts/ssl-tls-validator.sh "$hostname" 443 30; then
        echo "✓ SSL check passed"
        ((checks_passed++))
    else
        echo "✗ SSL check failed"
    fi

    # Check 4: Performance
    echo -e "\n[4/4] Performance Check..."
    if bash scripts/performance-tester.sh "$url" 20 200 15; then
        echo "✓ Performance check passed"
        ((checks_passed++))
    else
        echo "✗ Performance check failed"
    fi

    # Calculate success rate
    local success_rate=$((checks_passed * 100 / checks_total))

    echo -e "\nRegion $region: $checks_passed/$checks_total checks passed ($success_rate%)"

    if [ $checks_passed -eq $checks_total ]; then
        REGION_STATUS[$region]="✓ HEALTHY"
        return 0
    elif [ $checks_passed -ge 3 ]; then
        REGION_STATUS[$region]="⚠ DEGRADED"
        return 1
    else
        REGION_STATUS[$region]="✗ UNHEALTHY"
        return 1
    fi
}

export -f validate_region
export API_TOKEN

# Main execution
echo "═══════════════════════════════════════════════"
echo "Multi-Region Health Validation"
echo "Regions: ${#REGIONS[@]}"
echo "═══════════════════════════════════════════════"

HEALTHY_REGIONS=0
DEGRADED_REGIONS=0
UNHEALTHY_REGIONS=0

# Validate each region in parallel
for region in "${!REGIONS[@]}"; do
    validate_region "$region" "${REGIONS[$region]}" "${SSL_HOSTS[$region]}" &
done

# Wait for all validations
wait

# Count region statuses
for region in "${!REGION_STATUS[@]}"; do
    if [[ "${REGION_STATUS[$region]}" == *"HEALTHY"* ]]; then
        ((HEALTHY_REGIONS++))
    elif [[ "${REGION_STATUS[$region]}" == *"DEGRADED"* ]]; then
        ((DEGRADED_REGIONS++))
    else
        ((UNHEALTHY_REGIONS++))
    fi
done

# Display summary
echo -e "\n═══════════════════════════════════════════════"
echo "Multi-Region Summary"
echo "═══════════════════════════════════════════════"

for region in "${!REGION_STATUS[@]}"; do
    echo "$region: ${REGION_STATUS[$region]}"
done

echo -e "\nOverall Status:"
echo "  Healthy:   $HEALTHY_REGIONS"
echo "  Degraded:  $DEGRADED_REGIONS"
echo "  Unhealthy: $UNHEALTHY_REGIONS"
echo "═══════════════════════════════════════════════"

# Determine exit code
if [ $UNHEALTHY_REGIONS -gt 0 ]; then
    echo "✗ Some regions are unhealthy"
    exit 1
elif [ $DEGRADED_REGIONS -gt 0 ]; then
    echo "⚠ Some regions are degraded"
    exit 1
else
    echo "✓ All regions are healthy"
    exit 0
fi
```

---

## Blue-Green Deployment Validation

Validate both blue and green environments before switching traffic:

```bash
#!/bin/bash
# validate-blue-green.sh

set -euo pipefail

BLUE_URL="${1:-https://blue.example.com}"
GREEN_URL="${2:-https://green.example.com}"
SWITCH_TO="${3:-green}"

validate_environment() {
    local env_name="$1"
    local env_url="$2"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Validating $env_name Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Comprehensive health checks
    local all_passed=true

    # HTTP health
    if ! bash scripts/http-health-check.sh "$env_url" 200 2000; then
        all_passed=false
    fi

    # API health with version check
    if ! bash scripts/api-health-check.sh \
        "$env_url/api/health" \
        "Bearer $API_TOKEN"; then
        all_passed=false
    fi

    # Performance baseline
    if ! bash scripts/performance-tester.sh "$env_url" 100 1000 10; then
        all_passed=false
    fi

    if [ "$all_passed" = true ]; then
        echo "✓ $env_name environment is healthy"
        return 0
    else
        echo "✗ $env_name environment has issues"
        return 1
    fi
}

# Validate current (blue) environment
echo "Step 1: Validating current (BLUE) environment..."
if ! validate_environment "BLUE" "$BLUE_URL"; then
    echo "✗ Current environment is unhealthy - cannot proceed with deployment"
    exit 1
fi

# Validate new (green) environment
echo -e "\nStep 2: Validating new (GREEN) environment..."
if ! validate_environment "GREEN" "$GREEN_URL"; then
    echo "✗ New environment is unhealthy - cannot switch traffic"
    exit 1
fi

# Compare versions
echo -e "\nStep 3: Comparing versions..."
BLUE_VERSION=$(curl -s "$BLUE_URL/api/version" | jq -r '.version')
GREEN_VERSION=$(curl -s "$GREEN_URL/api/version" | jq -r '.version')

echo "Blue version:  $BLUE_VERSION"
echo "Green version: $GREEN_VERSION"

if [ "$BLUE_VERSION" = "$GREEN_VERSION" ]; then
    echo "⚠ Warning: Versions are identical"
fi

# Performance comparison
echo -e "\nStep 4: Comparing performance..."
echo "This would typically involve A/B testing and metric comparison"

# Final decision
echo -e "\n═══════════════════════════════════════════════"
echo "Both environments are healthy"
echo "Safe to switch traffic to: $SWITCH_TO"
echo "═══════════════════════════════════════════════"

exit 0
```

---

## Custom Validation Logic

Create custom validation scripts with business-specific logic:

```bash
#!/bin/bash
# validate-business-critical.sh

# Custom validation that checks business-critical functionality

set -euo pipefail

BASE_URL="${1:-https://api.example.com}"

echo "Running business-critical validation..."

# 1. User registration flow
echo -e "\n[1/5] Testing user registration endpoint..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/register" \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test123"}')

if echo "$REGISTER_RESPONSE" | jq -e '.success == true' > /dev/null; then
    echo "✓ Registration endpoint working"
else
    echo "✗ Registration endpoint failed"
    exit 1
fi

# 2. Authentication flow
echo -e "\n[2/5] Testing authentication..."
AUTH_RESPONSE=$(curl -s -X POST "$BASE_URL/api/login" \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test123"}')

AUTH_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.token // empty')

if [ -n "$AUTH_TOKEN" ]; then
    echo "✓ Authentication working"
else
    echo "✗ Authentication failed"
    exit 1
fi

# 3. Payment processing (test mode)
echo -e "\n[3/5] Testing payment processing..."
PAYMENT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/payments" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"amount":100,"currency":"USD","test":true}')

if echo "$PAYMENT_RESPONSE" | jq -e '.status == "success"' > /dev/null; then
    echo "✓ Payment processing working"
else
    echo "✗ Payment processing failed"
    exit 1
fi

# 4. Database write operation
echo -e "\n[4/5] Testing database writes..."
WRITE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/data" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"key":"test","value":"validation"}')

if echo "$WRITE_RESPONSE" | jq -e '.saved == true' > /dev/null; then
    echo "✓ Database writes working"
else
    echo "✗ Database writes failed"
    exit 1
fi

# 5. Database read operation
echo -e "\n[5/5] Testing database reads..."
READ_RESPONSE=$(curl -s -X GET "$BASE_URL/api/data/test" \
    -H "Authorization: Bearer $AUTH_TOKEN")

if echo "$READ_RESPONSE" | jq -e '.value == "validation"' > /dev/null; then
    echo "✓ Database reads working"
else
    echo "✗ Database reads failed"
    exit 1
fi

echo -e "\n✓ All business-critical validations passed"
exit 0
```

---

## Progressive Health Checks

Gradually increase load and complexity:

```bash
#!/bin/bash
# progressive-validation.sh

set -euo pipefail

URL="${1:-https://example.com}"

echo "═══════════════════════════════════════════════"
echo "Progressive Health Check Validation"
echo "═══════════════════════════════════════════════"

# Level 1: Basic connectivity
echo -e "\nLevel 1: Basic Connectivity (Light)"
if ! bash scripts/http-health-check.sh "$URL"; then
    echo "✗ Failed at Level 1"
    exit 1
fi
echo "✓ Level 1 passed"
sleep 2

# Level 2: Light load
echo -e "\nLevel 2: Light Load (10 concurrent, 100 requests)"
if ! bash scripts/performance-tester.sh "$URL" 10 100 10; then
    echo "✗ Failed at Level 2"
    exit 1
fi
echo "✓ Level 2 passed"
sleep 5

# Level 3: Medium load
echo -e "\nLevel 3: Medium Load (50 concurrent, 500 requests)"
if ! bash scripts/performance-tester.sh "$URL" 50 500 10; then
    echo "✗ Failed at Level 3"
    exit 1
fi
echo "✓ Level 3 passed"
sleep 10

# Level 4: Heavy load
echo -e "\nLevel 4: Heavy Load (100 concurrent, 1000 requests)"
if ! bash scripts/performance-tester.sh "$URL" 100 1000 15; then
    echo "✗ Failed at Level 4"
    exit 1
fi
echo "✓ Level 4 passed"

# Level 5: Sustained load
echo -e "\nLevel 5: Sustained Load (50 concurrent, 2000 requests)"
if ! bash scripts/performance-tester.sh "$URL" 50 2000 20; then
    echo "✗ Failed at Level 5"
    exit 1
fi
echo "✓ Level 5 passed"

echo -e "\n═══════════════════════════════════════════════"
echo "✓ All progressive validation levels passed"
echo "═══════════════════════════════════════════════"

exit 0
```

**Usage:**
```bash
bash progressive-validation.sh https://example.com
```

---

These advanced examples demonstrate real-world validation scenarios for complex deployment architectures.
