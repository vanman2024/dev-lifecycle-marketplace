#!/usr/bin/env bash
set -euo pipefail

# OWASP Top 10 Vulnerability Pattern Scanner
# Detects common OWASP Top 10 2021 vulnerability patterns in source code
# Returns: JSON report with OWASP category mappings and remediation guidance

CODEBASE_DIR="${1:-.}"
OUTPUT_FORMAT="${2:-json}"
VERBOSE="${VERBOSE:-false}"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Results
declare -a FINDINGS=()
FINDING_COUNT=0

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

if [[ ! -d "$CODEBASE_DIR" ]]; then
    error "Codebase directory does not exist: $CODEBASE_DIR"
    exit 1
fi

log "Scanning for OWASP patterns in: $CODEBASE_DIR"

# OWASP vulnerability patterns
# Each pattern includes: category, name, regex, severity, description, remediation

declare -A OWASP_CATEGORIES=(
    ["A01"]="Broken Access Control"
    ["A02"]="Cryptographic Failures"
    ["A03"]="Injection"
    ["A04"]="Insecure Design"
    ["A05"]="Security Misconfiguration"
    ["A06"]="Vulnerable and Outdated Components"
    ["A07"]="Identification and Authentication Failures"
    ["A08"]="Software and Data Integrity Failures"
    ["A09"]="Security Logging and Monitoring Failures"
    ["A10"]="Server-Side Request Forgery (SSRF)"
)

# A01: Broken Access Control patterns
declare -a A01_PATTERNS=(
    "authorization_bypass|if.*admin.*==.*true|if.*isAdmin|bypassAuth"
    "insecure_direct_object_reference|getUserById.*req\.params|getFile.*req\.query"
    "missing_access_control|@RequestMapping.*public|app\.get.*'\/admin'"
)

# A02: Cryptographic Failures patterns
declare -a A02_PATTERNS=(
    "weak_crypto|DES|RC4|MD5|SHA1(?!.*HMAC)"
    "hardcoded_crypto_key|AES.*key.*=.*[\"'][a-zA-Z0-9]{16,}[\"']"
    "insecure_random|Math\.random\(\)|Random\(\)(?!.*secure)"
    "missing_encryption|http://.*password|http://.*token"
)

# A03: Injection patterns
declare -a A03_PATTERNS=(
    "sql_injection|executeQuery.*\+|SELECT.*FROM.*\+|query\(.*\$\{|raw\(.*\+|knex\.raw\(.*\+"
    "command_injection|exec\(.*\+|spawn\(.*\+|system\(.*\$|shell_exec\(.*\$"
    "ldap_injection|search\(.*\+.*objectClass|LdapContext.*search\(.*\+"
    "xpath_injection|evaluate\(.*\+|compile\(.*\+.*xpath"
    "nosql_injection|\$where.*\+|\$ne.*\$|new.*RegExp\(.*req\."
)

# A04: Insecure Design patterns
declare -a A04_PATTERNS=(
    "missing_rate_limit|POST.*\/login(?!.*rateLimit)|POST.*\/api(?!.*rateLimit)"
    "missing_timeout|fetch\((?!.*timeout)|axios\.get\((?!.*timeout)"
    "unlimited_resource|while.*true|for.*Infinity|while.*1\s*\)"
)

# A05: Security Misconfiguration patterns
declare -a A05_PATTERNS=(
    "debug_enabled|DEBUG.*=.*true|NODE_ENV.*=.*development|debug:\s*true"
    "cors_wildcard|Access-Control-Allow-Origin.*\*|cors\(\{.*origin:.*\*"
    "insecure_cookie|cookie.*secure:.*false|httpOnly:.*false"
    "error_disclosure|app\.use.*errorHandler|res\.send.*err\.stack"
    "default_credentials|username.*admin.*password.*admin|user:.*root"
)

# A06: Vulnerable Components (version checks)
declare -a A06_PATTERNS=(
    "outdated_jquery|jquery.*1\.|jquery.*2\."
    "outdated_lodash|lodash.*[0-3]\."
    "outdated_moment|moment.*2\.[0-9]\."
)

# A07: Authentication Failures patterns
declare -a A07_PATTERNS=(
    "weak_password_policy|password.*length.*<.*6|minLength:.*[1-5]"
    "missing_mfa|login.*success(?!.*twoFactor)|authenticate\((?!.*mfa)"
    "session_fixation|session\.regenerate(?!.*after.*login)|req\.session\.id"
    "credential_stuffing|login.*without.*captcha|POST.*\/login(?!.*captcha)"
)

# A08: Data Integrity Failures patterns
declare -a A08_PATTERNS=(
    "insecure_deserialization|unserialize\(|pickle\.loads\(|eval\(.*JSON\.parse"
    "missing_integrity_check|<script.*src=.*http(?!.*integrity)|npm.*install(?!.*\-\-verify)"
)

# A09: Logging Failures patterns
declare -a A09_PATTERNS=(
    "missing_security_logging|login.*success(?!.*log)|authentication(?!.*log)"
    "sensitive_data_logged|log.*password|console\.log.*token|logger.*apiKey"
    "insufficient_monitoring|try.*catch(?!.*log)|error.*\{(?!.*log)"
)

# A10: SSRF patterns
declare -a A10_PATTERNS=(
    "ssrf_vulnerable|fetch\(.*req\.|axios\(.*req\.|http\.get\(.*params"
    "unvalidated_redirect|redirect\(.*req\.|Location:.*\$\{.*req"
)

# Scan for pattern category
scan_category() {
    local category="$1"
    local category_name="${OWASP_CATEGORIES[$category]}"
    shift
    local patterns=("$@")

    log "Scanning for $category: $category_name"

    for pattern_def in "${patterns[@]}"; do
        IFS='|' read -r pattern_name pattern_regex <<< "$pattern_def"

        local matches
        matches=$(grep -rn -E "$pattern_regex" "$CODEBASE_DIR" \
            --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
            --include="*.py" --include="*.java" --include="*.go" --include="*.rb" \
            --include="*.php" --include="*.cs" \
            --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.git \
            --exclude-dir=dist --exclude-dir=build \
            2>/dev/null || true)

        if [[ -n "$matches" ]]; then
            while IFS=: read -r file line content; do
                [[ -n "$file" ]] || continue

                FINDING_COUNT=$((FINDING_COUNT + 1))

                local severity="high"
                [[ "$category" =~ ^(A01|A02|A03|A07)$ ]] && severity="critical"
                [[ "$category" =~ ^(A04|A09)$ ]] && severity="medium"

                local remediation
                case "$category" in
                    A01) remediation="Implement proper authorization checks before allowing access" ;;
                    A02) remediation="Use strong cryptographic algorithms (AES-256, SHA-256+) and secure key management" ;;
                    A03) remediation="Use parameterized queries, prepared statements, and input validation" ;;
                    A04) remediation="Implement rate limiting, timeouts, and resource constraints" ;;
                    A05) remediation="Review and harden configuration, disable debug mode in production" ;;
                    A06) remediation="Update to latest secure versions of all dependencies" ;;
                    A07) remediation="Implement strong password policies, MFA, and session management" ;;
                    A08) remediation="Avoid deserialization of untrusted data, use integrity checks" ;;
                    A09) remediation="Implement comprehensive security logging and monitoring" ;;
                    A10) remediation="Validate and sanitize all URLs, use allowlists for external requests" ;;
                esac

                local finding
                finding=$(cat <<EOF
{
  "id": $FINDING_COUNT,
  "owasp_category": "$category",
  "category_name": "$category_name",
  "vulnerability_type": "$pattern_name",
  "severity": "$severity",
  "file": "$file",
  "line": $line,
  "code_snippet": $(echo "$content" | jq -R -s .),
  "remediation": "$remediation",
  "owasp_reference": "https://owasp.org/Top10/$(echo $category | tr '[:upper:]' '[:lower:]')/"
}
EOF
)
                FINDINGS+=("$finding")

                if [[ "$VERBOSE" == "true" ]]; then
                    warn "Found $severity $category in $file:$line"
                fi
            done <<< "$matches"
        fi
    done
}

# File extensions to scan
FILE_PATTERNS=(
    "*.js" "*.jsx" "*.ts" "*.tsx"
    "*.py" "*.pyw"
    "*.java" "*.kt"
    "*.go"
    "*.rb"
    "*.php"
    "*.cs"
)

# Generate JSON output
generate_json_output() {
    local findings_json
    findings_json=$(printf '%s\n' "${FINDINGS[@]}" | jq -s .)

    # Count by category
    local category_counts
    category_counts=$(printf '%s\n' "${FINDINGS[@]}" | jq -s '
        group_by(.owasp_category) |
        map({
            category: .[0].owasp_category,
            name: .[0].category_name,
            count: length
        }) |
        from_entries
    ' 2>/dev/null || echo "{}")

    # Count by severity
    local critical_count high_count medium_count low_count
    critical_count=$(printf '%s\n' "${FINDINGS[@]}" | jq -s '[.[] | select(.severity == "critical")] | length' 2>/dev/null || echo 0)
    high_count=$(printf '%s\n' "${FINDINGS[@]}" | jq -s '[.[] | select(.severity == "high")] | length' 2>/dev/null || echo 0)
    medium_count=$(printf '%s\n' "${FINDINGS[@]}" | jq -s '[.[] | select(.severity == "medium")] | length' 2>/dev/null || echo 0)
    low_count=$(printf '%s\n' "${FINDINGS[@]}" | jq -s '[.[] | select(.severity == "low")] | length' 2>/dev/null || echo 0)

    cat <<EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "codebase_directory": "$CODEBASE_DIR",
  "total_findings": $FINDING_COUNT,
  "severity_breakdown": {
    "critical": $critical_count,
    "high": $high_count,
    "medium": $medium_count,
    "low": $low_count
  },
  "owasp_categories": $category_counts,
  "findings": $findings_json
}
EOF
}

# Main execution
main() {
    log "Starting OWASP vulnerability scan..."

    # Scan each OWASP category
    scan_category "A01" "${A01_PATTERNS[@]}"
    scan_category "A02" "${A02_PATTERNS[@]}"
    scan_category "A03" "${A03_PATTERNS[@]}"
    scan_category "A04" "${A04_PATTERNS[@]}"
    scan_category "A05" "${A05_PATTERNS[@]}"
    scan_category "A06" "${A06_PATTERNS[@]}"
    scan_category "A07" "${A07_PATTERNS[@]}"
    scan_category "A08" "${A08_PATTERNS[@]}"
    scan_category "A09" "${A09_PATTERNS[@]}"
    scan_category "A10" "${A10_PATTERNS[@]}"

    if [[ $FINDING_COUNT -eq 0 ]]; then
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            echo '{"scan_timestamp":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","codebase_directory":"'$CODEBASE_DIR'","total_findings":0,"severity_breakdown":{"critical":0,"high":0,"medium":0,"low":0},"owasp_categories":{},"findings":[]}'
        else
            echo -e "${GREEN}No OWASP vulnerabilities found!${NC}"
        fi
        exit 0
    else
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            generate_json_output
        else
            echo -e "${RED}Found $FINDING_COUNT potential OWASP vulnerabilities!${NC}"
            generate_json_output
        fi
        exit 1
    fi
}

# Check for required tools
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed. Install with: apt-get install jq"; exit 1; }

main
