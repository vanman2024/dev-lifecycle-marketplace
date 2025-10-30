#!/usr/bin/env bash

# SSL/TLS Certificate Validation Script
# Validates SSL/TLS certificates with expiration checking and cipher suite verification
# Usage: ./ssl-tls-validator.sh <hostname> [port] [min_days_valid]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
HOSTNAME="${1:-}"
PORT="${2:-443}"
MIN_DAYS_VALID="${3:-30}"
TIMEOUT="${TIMEOUT:-10}"

# Validate arguments
if [ -z "$HOSTNAME" ]; then
    echo -e "${RED}Error: Hostname is required${NC}"
    echo "Usage: $0 <hostname> [port] [min_days_valid]"
    echo ""
    echo "Examples:"
    echo "  $0 example.com"
    echo "  $0 api.example.com 443"
    echo "  $0 example.com 8443 60"
    exit 2
fi

# Check dependencies
for cmd in openssl date; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed${NC}"
        exit 2
    fi
done

echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}SSL/TLS Certificate Validation${NC}"
echo -e "${MAGENTA}Host: $HOSTNAME:$PORT${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Step 1: Test SSL/TLS connectivity
echo -e "\n${BLUE}Step 1: Testing SSL/TLS connectivity...${NC}"
if timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>&1 | grep -q "CONNECTED"; then
    echo -e "${GREEN}✓ Successfully connected to $HOSTNAME:$PORT${NC}"
else
    echo -e "${RED}✗ Failed to connect to $HOSTNAME:$PORT${NC}"
    exit 3
fi

# Step 2: Retrieve certificate information
echo -e "\n${BLUE}Step 2: Retrieving certificate information...${NC}"
CERT_INFO=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>/dev/null | openssl x509 -noout -text 2>/dev/null)

if [ -z "$CERT_INFO" ]; then
    echo -e "${RED}✗ Failed to retrieve certificate information${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Certificate retrieved successfully${NC}"

# Step 3: Extract and validate certificate details
echo -e "\n${BLUE}Step 3: Validating certificate details...${NC}"

# Subject
SUBJECT=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | sed 's/subject=//')
echo -e "${BLUE}Subject:${NC} $SUBJECT"

# Issuer
ISSUER=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//')
echo -e "${BLUE}Issuer:${NC} $ISSUER"

# Validity dates
NOT_BEFORE=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>/dev/null | openssl x509 -noout -startdate 2>/dev/null | cut -d= -f2)
NOT_AFTER=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

echo -e "${BLUE}Valid from:${NC} $NOT_BEFORE"
echo -e "${BLUE}Valid until:${NC} $NOT_AFTER"

# Step 4: Check certificate expiration
echo -e "\n${BLUE}Step 4: Checking certificate expiration...${NC}"

# Convert dates to epoch for comparison
if date --version &>/dev/null 2>&1; then
    # GNU date
    EXPIRY_EPOCH=$(date -d "$NOT_AFTER" +%s 2>/dev/null || echo "0")
    CURRENT_EPOCH=$(date +%s)
else
    # BSD date (macOS)
    EXPIRY_EPOCH=$(date -j -f "%b %d %T %Y %Z" "$NOT_AFTER" +%s 2>/dev/null || echo "0")
    CURRENT_EPOCH=$(date +%s)
fi

if [ "$EXPIRY_EPOCH" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Could not parse expiry date${NC}"
else
    DAYS_UNTIL_EXPIRY=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

    if [ "$DAYS_UNTIL_EXPIRY" -lt 0 ]; then
        echo -e "${RED}✗ Certificate has EXPIRED (${DAYS_UNTIL_EXPIRY#-} days ago)${NC}"
        exit 4
    elif [ "$DAYS_UNTIL_EXPIRY" -lt "$MIN_DAYS_VALID" ]; then
        echo -e "${YELLOW}⚠ Certificate expires soon (${DAYS_UNTIL_EXPIRY} days remaining, minimum: ${MIN_DAYS_VALID})${NC}"
        exit 4
    else
        echo -e "${GREEN}✓ Certificate is valid (${DAYS_UNTIL_EXPIRY} days remaining)${NC}"
    fi
fi

# Step 5: Check certificate chain
echo -e "\n${BLUE}Step 5: Validating certificate chain...${NC}"
CHAIN_OUTPUT=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" -showcerts </dev/null 2>&1)

CHAIN_COUNT=$(echo "$CHAIN_OUTPUT" | grep -c "BEGIN CERTIFICATE" || echo "0")
echo -e "${BLUE}Certificate chain depth:${NC} $CHAIN_COUNT"

if echo "$CHAIN_OUTPUT" | grep -q "Verify return code: 0"; then
    echo -e "${GREEN}✓ Certificate chain is valid${NC}"
elif echo "$CHAIN_OUTPUT" | grep -q "Verify return code:"; then
    VERIFY_CODE=$(echo "$CHAIN_OUTPUT" | grep "Verify return code:" | head -1)
    echo -e "${YELLOW}⚠ Certificate chain verification: $VERIFY_CODE${NC}"
else
    echo -e "${YELLOW}⚠ Could not verify certificate chain${NC}"
fi

# Step 6: Check supported protocols
echo -e "\n${BLUE}Step 6: Checking supported SSL/TLS protocols...${NC}"

# Test protocols
for protocol in ssl3 tls1 tls1_1 tls1_2 tls1_3; do
    if timeout 3 openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" -"$protocol" </dev/null 2>&1 | grep -q "Protocol.*:.*TLS"; then
        PROTOCOL_VERSION=$(echo "$protocol" | sed 's/_/\./g' | tr '[:lower:]' '[:upper:]')

        # Warn on insecure protocols
        if [[ "$protocol" =~ ^(ssl3|tls1|tls1_1)$ ]]; then
            echo -e "${YELLOW}⚠ $PROTOCOL_VERSION is supported (insecure, should be disabled)${NC}"
        else
            echo -e "${GREEN}✓ $PROTOCOL_VERSION is supported${NC}"
        fi
    fi
done

# Step 7: Check cipher suites
echo -e "\n${BLUE}Step 7: Checking cipher suites...${NC}"

CIPHER_INFO=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" -cipher 'ALL' </dev/null 2>&1 | grep "Cipher" | head -1)
echo -e "${BLUE}Negotiated cipher:${NC} $CIPHER_INFO"

# Check for weak ciphers
WEAK_CIPHERS=$(timeout 5 openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" -cipher 'LOW:EXP:NULL:MD5' </dev/null 2>&1 | grep "Cipher" || echo "")
if [ -n "$WEAK_CIPHERS" ]; then
    echo -e "${YELLOW}⚠ Weak ciphers are supported (security risk)${NC}"
else
    echo -e "${GREEN}✓ No weak ciphers detected${NC}"
fi

# Step 8: Check SAN (Subject Alternative Names)
echo -e "\n${BLUE}Step 8: Checking Subject Alternative Names...${NC}"
SAN=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" </dev/null 2>/dev/null | openssl x509 -noout -text 2>/dev/null | grep -A1 "Subject Alternative Name" || echo "")

if [ -n "$SAN" ]; then
    echo -e "${GREEN}✓ SAN extension found${NC}"
    echo "$SAN" | grep -v "Subject Alternative Name" | sed 's/^[ \t]*/  /'

    # Check if hostname matches SAN
    if echo "$SAN" | grep -q "$HOSTNAME"; then
        echo -e "${GREEN}✓ Hostname matches SAN${NC}"
    else
        echo -e "${YELLOW}⚠ Hostname may not match SAN entries${NC}"
    fi
else
    echo -e "${YELLOW}⚠ No SAN extension found${NC}"
fi

# Step 9: Check OCSP stapling
echo -e "\n${BLUE}Step 9: Checking OCSP stapling...${NC}"
OCSP_STATUS=$(timeout "$TIMEOUT" openssl s_client -connect "$HOSTNAME:$PORT" -servername "$HOSTNAME" -status </dev/null 2>&1 | grep "OCSP" || echo "")

if echo "$OCSP_STATUS" | grep -q "OCSP Response Status: successful"; then
    echo -e "${GREEN}✓ OCSP stapling is enabled${NC}"
elif [ -n "$OCSP_STATUS" ]; then
    echo -e "${YELLOW}⚠ OCSP stapling status: $OCSP_STATUS${NC}"
else
    echo -e "${YELLOW}⚠ OCSP stapling not detected${NC}"
fi

# Final summary
echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}SUCCESS: SSL/TLS certificate validation passed${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

exit 0
