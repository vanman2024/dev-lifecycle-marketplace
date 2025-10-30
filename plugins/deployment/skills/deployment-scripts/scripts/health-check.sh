#!/usr/bin/env bash
#
# health-check.sh - Post-deployment health and smoke testing
#
# Usage: bash health-check.sh <url> [timeout]
#

set -euo pipefail

URL="${1:-}"
TIMEOUT="${2:-30}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Check if URL is provided
if [[ -z "$URL" ]]; then
    print_error "URL not specified"
    echo "Usage: $0 <url> [timeout]"
    exit 1
fi

# Ensure URL has protocol
if [[ ! "$URL" =~ ^https?:// ]]; then
    URL="https://$URL"
fi

print_info "Running health checks for: $URL"
print_info "Timeout: ${TIMEOUT}s"
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0

# Check 1: Basic connectivity
print_info "Check 1: Basic connectivity"
if curl -f -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$URL" &> /dev/null; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$URL")
    print_success "HTTP $HTTP_CODE - Site is reachable"
    ((CHECKS_PASSED++))

    # Check if 2xx or 3xx
    if [[ "$HTTP_CODE" =~ ^[23][0-9][0-9]$ ]]; then
        print_success "HTTP status is OK ($HTTP_CODE)"
    else
        print_warning "HTTP status is not 2xx/3xx ($HTTP_CODE)"
    fi
else
    print_error "Site is not reachable"
    ((CHECKS_FAILED++))
fi

echo ""

# Check 2: Response time
print_info "Check 2: Response time"
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" --max-time "$TIMEOUT" "$URL" || echo "timeout")

if [[ "$RESPONSE_TIME" != "timeout" ]]; then
    print_success "Response time: ${RESPONSE_TIME}s"
    ((CHECKS_PASSED++))

    # Warn if slow
    if (( $(echo "$RESPONSE_TIME > 3.0" | bc -l) )); then
        print_warning "Response time is slow (>3s)"
    fi
else
    print_error "Request timed out"
    ((CHECKS_FAILED++))
fi

echo ""

# Check 3: SSL certificate (if HTTPS)
if [[ "$URL" =~ ^https:// ]]; then
    print_info "Check 3: SSL certificate"

    SSL_INFO=$(curl -vI --max-time "$TIMEOUT" "$URL" 2>&1 | grep -E "(SSL certificate|expire)" || true)

    if echo "$SSL_INFO" | grep -q "SSL certificate verify ok"; then
        print_success "SSL certificate is valid"
        ((CHECKS_PASSED++))
    else
        print_warning "Could not verify SSL certificate"
    fi

    # Check certificate expiry
    if command -v openssl &> /dev/null; then
        DOMAIN=$(echo "$URL" | sed -e 's|^https://||' -e 's|/.*||')
        EXPIRY=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2 || echo "")

        if [[ -n "$EXPIRY" ]]; then
            print_info "SSL expires: $EXPIRY"
        fi
    fi

    echo ""
fi

# Check 4: Common health endpoints
print_info "Check 4: Health endpoints"
HEALTH_ENDPOINTS=("/health" "/api/health" "/healthz" "/_health" "/status")

for endpoint in "${HEALTH_ENDPOINTS[@]}"; do
    HEALTH_URL="${URL}${endpoint}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$HEALTH_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" =~ ^2[0-9][0-9]$ ]]; then
        print_success "Health endpoint found: $endpoint (HTTP $HTTP_CODE)"
        ((CHECKS_PASSED++))
        break
    fi
done

echo ""

# Check 5: Content validation
print_info "Check 5: Content validation"
CONTENT=$(curl -s --max-time "$TIMEOUT" "$URL" || echo "")

if [[ -n "$CONTENT" ]]; then
    CONTENT_LENGTH=${#CONTENT}
    print_success "Content received: $CONTENT_LENGTH bytes"
    ((CHECKS_PASSED++))

    # Check for common error indicators
    if echo "$CONTENT" | grep -qi "error\|exception\|500\|502\|503\|504"; then
        print_warning "Content contains error indicators"
    fi

    # Check for DOCTYPE (HTML)
    if echo "$CONTENT" | grep -qi "<!DOCTYPE"; then
        print_success "Valid HTML document detected"
    fi

    # Check for JSON
    if echo "$CONTENT" | python3 -m json.tool &> /dev/null; then
        print_success "Valid JSON response detected"
    fi
else
    print_error "No content received"
    ((CHECKS_FAILED++))
fi

echo ""

# Check 6: Common static assets
print_info "Check 6: Static assets"
ASSET_PATHS=("/favicon.ico" "/robots.txt" "/sitemap.xml")

for asset in "${ASSET_PATHS[@]}"; do
    ASSET_URL="${URL}${asset}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$ASSET_URL" 2>/dev/null || echo "000")

    if [[ "$HTTP_CODE" =~ ^2[0-9][0-9]$ ]]; then
        print_success "Found: $asset"
    else
        print_info "Not found: $asset (optional)"
    fi
done

echo ""

# Check 7: Headers
print_info "Check 7: Security headers"
HEADERS=$(curl -I -s --max-time "$TIMEOUT" "$URL" || echo "")

# Check security headers
SECURITY_HEADERS=(
    "Strict-Transport-Security"
    "X-Content-Type-Options"
    "X-Frame-Options"
    "Content-Security-Policy"
)

for header in "${SECURITY_HEADERS[@]}"; do
    if echo "$HEADERS" | grep -qi "$header:"; then
        print_success "Security header present: $header"
        ((CHECKS_PASSED++))
    else
        print_info "Missing security header: $header (recommended)"
    fi
done

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Health Check Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Checks passed: $CHECKS_PASSED"
echo "Checks failed: $CHECKS_FAILED"
echo ""

if [[ $CHECKS_FAILED -eq 0 ]]; then
    print_success "All critical checks passed!"
    print_info "Deployment appears healthy"
    exit 0
else
    print_warning "Some checks failed"
    print_info "Review failures and investigate if necessary"
    exit 1
fi
