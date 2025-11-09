#!/usr/bin/env bash
set -euo pipefail

# HTTP Security Headers Validator
# Validates security headers for web applications against best practices
# Returns: JSON report with missing/misconfigured headers and recommendations

TARGET="${1:-}"
OUTPUT_FORMAT="${2:-json}"
VERBOSE="${VERBOSE:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../templates/security-headers-config.json"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Results
declare -a FINDINGS=()
FINDING_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${GREEN}[INFO]${NC} $1" >&2
    fi
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

# Usage
show_usage() {
    cat <<EOF
Usage: $0 <url|config-file> [output-format]

Arguments:
  url            URL to check headers (e.g., https://example.com)
  config-file    Path to configuration file to validate
  output-format  json|text (default: json)

Environment:
  VERBOSE=true   Enable verbose logging

Examples:
  $0 https://example.com
  $0 ./nginx.conf
  VERBOSE=true $0 https://example.com text
EOF
    exit 1
}

if [[ -z "$TARGET" ]]; then
    show_usage
fi

# Recommended security headers
declare -A REQUIRED_HEADERS=(
    ["Content-Security-Policy"]="default-src 'self'"
    ["Strict-Transport-Security"]="max-age=31536000; includeSubDomains"
    ["X-Frame-Options"]="DENY"
    ["X-Content-Type-Options"]="nosniff"
    ["Referrer-Policy"]="strict-origin-when-cross-origin"
    ["Permissions-Policy"]="geolocation=(), microphone=(), camera=()"
)

declare -A OPTIONAL_HEADERS=(
    ["X-XSS-Protection"]="0"
    ["Cross-Origin-Opener-Policy"]="same-origin"
    ["Cross-Origin-Resource-Policy"]="same-origin"
    ["Cross-Origin-Embedder-Policy"]="require-corp"
)

# Fetch headers from URL
fetch_headers() {
    local url="$1"

    log "Fetching headers from: $url"

    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required but not installed"
        exit 1
    fi

    local headers
    if ! headers=$(curl -sI -L "$url" 2>&1); then
        error "Failed to fetch headers from $url"
        exit 1
    fi

    echo "$headers"
}

# Check individual header
check_header() {
    local header_name="$1"
    local recommended_value="$2"
    local actual_value="$3"
    local severity="$4"

    if [[ -z "$actual_value" ]]; then
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FINDING_COUNT=$((FINDING_COUNT + 1))

        local finding
        finding=$(cat <<EOF
{
  "id": $FINDING_COUNT,
  "header": "$header_name",
  "status": "missing",
  "severity": "$severity",
  "recommended_value": "$recommended_value",
  "actual_value": null,
  "description": "Header is missing from response",
  "remediation": "Add header: $header_name: $recommended_value"
}
EOF
)
        FINDINGS+=("$finding")
        warn "MISSING: $header_name"
    else
        # Header exists, check if value is secure
        local status="pass"
        local description="Header is present"

        # Specific validation for known headers
        case "$header_name" in
            "Strict-Transport-Security")
                if [[ ! "$actual_value" =~ max-age=([0-9]+) ]]; then
                    status="warn"
                    description="max-age directive missing or invalid"
                    WARN_COUNT=$((WARN_COUNT + 1))
                elif [[ ${BASH_REMATCH[1]} -lt 31536000 ]]; then
                    status="warn"
                    description="max-age is less than 1 year (recommended: 31536000)"
                    WARN_COUNT=$((WARN_COUNT + 1))
                fi
                ;;
            "X-Frame-Options")
                if [[ ! "$actual_value" =~ ^(DENY|SAMEORIGIN)$ ]]; then
                    status="warn"
                    description="Value should be DENY or SAMEORIGIN"
                    WARN_COUNT=$((WARN_COUNT + 1))
                fi
                ;;
            "X-Content-Type-Options")
                if [[ "$actual_value" != "nosniff" ]]; then
                    status="warn"
                    description="Value should be 'nosniff'"
                    WARN_COUNT=$((WARN_COUNT + 1))
                fi
                ;;
            "Content-Security-Policy")
                if [[ ! "$actual_value" =~ default-src ]]; then
                    status="warn"
                    description="CSP should include default-src directive"
                    WARN_COUNT=$((WARN_COUNT + 1))
                fi
                if [[ "$actual_value" =~ \'unsafe-inline\'|\'unsafe-eval\' ]]; then
                    status="warn"
                    description="CSP contains unsafe-inline or unsafe-eval (security risk)"
                    WARN_COUNT=$((WARN_COUNT + 1))
                fi
                ;;
        esac

        if [[ "$status" == "pass" ]]; then
            PASS_COUNT=$((PASS_COUNT + 1))
        fi

        FINDING_COUNT=$((FINDING_COUNT + 1))
        local finding
        finding=$(cat <<EOF
{
  "id": $FINDING_COUNT,
  "header": "$header_name",
  "status": "$status",
  "severity": "$severity",
  "recommended_value": "$recommended_value",
  "actual_value": "$actual_value",
  "description": "$description",
  "remediation": $(if [[ "$status" != "pass" ]]; then echo "\"Review and update header value\""; else echo "null"; fi)
}
EOF
)
        FINDINGS+=("$finding")

        if [[ "$status" == "pass" ]]; then
            log "PASS: $header_name"
        else
            warn "WARN: $header_name - $description"
        fi
    fi
}

# Validate headers from URL
validate_url() {
    local url="$1"
    local headers
    headers=$(fetch_headers "$url")

    log "Validating security headers..."

    # Check required headers
    for header in "${!REQUIRED_HEADERS[@]}"; do
        local recommended="${REQUIRED_HEADERS[$header]}"
        local actual
        actual=$(echo "$headers" | grep -i "^$header:" | cut -d' ' -f2- | tr -d '\r' || true)
        check_header "$header" "$recommended" "$actual" "high"
    done

    # Check optional headers
    for header in "${!OPTIONAL_HEADERS[@]}"; do
        local recommended="${OPTIONAL_HEADERS[$header]}"
        local actual
        actual=$(echo "$headers" | grep -i "^$header:" | cut -d' ' -f2- | tr -d '\r' || true)
        check_header "$header" "$recommended" "$actual" "medium"
    done
}

# Generate JSON output
generate_json_output() {
    local findings_json
    findings_json=$(printf '%s\n' "${FINDINGS[@]}" | jq -s .)

    local score
    if [[ $FINDING_COUNT -gt 0 ]]; then
        score=$(( (PASS_COUNT * 100) / FINDING_COUNT ))
    else
        score=0
    fi

    cat <<EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "target": "$TARGET",
  "security_score": $score,
  "total_checks": $FINDING_COUNT,
  "passed": $PASS_COUNT,
  "warnings": $WARN_COUNT,
  "failed": $FAIL_COUNT,
  "findings": $findings_json,
  "recommendations": {
    "nginx": "See templates/security-headers-config.json for nginx configuration",
    "apache": "See templates/security-headers-config.json for apache configuration",
    "express": "Use helmet middleware: npm install helmet"
  }
}
EOF
}

# Generate text output
generate_text_output() {
    echo "Security Headers Report"
    echo "======================="
    echo "Target: $TARGET"
    echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    echo "Summary:"
    echo "  Total Checks: $FINDING_COUNT"
    echo "  Passed: $PASS_COUNT"
    echo "  Warnings: $WARN_COUNT"
    echo "  Failed: $FAIL_COUNT"
    echo ""
    echo "Findings:"
    echo ""

    for finding in "${FINDINGS[@]}"; do
        local header
        local status
        local description
        header=$(echo "$finding" | jq -r '.header')
        status=$(echo "$finding" | jq -r '.status')
        description=$(echo "$finding" | jq -r '.description')

        case "$status" in
            pass)
                echo -e "${GREEN}✓${NC} $header: $description"
                ;;
            warn)
                echo -e "${YELLOW}⚠${NC} $header: $description"
                ;;
            missing)
                echo -e "${RED}✗${NC} $header: $description"
                ;;
        esac
    done
}

# Main execution
main() {
    if [[ "$TARGET" =~ ^https?:// ]]; then
        validate_url "$TARGET"
    else
        error "File-based validation not yet implemented"
        exit 1
    fi

    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        generate_json_output
    else
        generate_text_output
    fi

    if [[ $FAIL_COUNT -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Check for required tools
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed. Install with: apt-get install jq"; exit 1; }
command -v curl >/dev/null 2>&1 || { error "curl is required but not installed. Install with: apt-get install curl"; exit 1; }

main
