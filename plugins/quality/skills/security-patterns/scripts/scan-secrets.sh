#!/usr/bin/env bash
set -euo pipefail

# Comprehensive Secret and Credential Scanner
# Detects exposed API keys, tokens, passwords, certificates, and sensitive data
# Returns: JSON report with findings including file, line, severity, and remediation

TARGET_DIR="${1:-.}"
OUTPUT_FORMAT="${2:-json}"
VERBOSE="${VERBOSE:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_FILE="$SCRIPT_DIR/../templates/secret-patterns.json"

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Severity levels
declare -A SEVERITY_SCORES=(
    ["CRITICAL"]=10
    ["HIGH"]=7
    ["MEDIUM"]=4
    ["LOW"]=2
)

# Initialize findings array
declare -a FINDINGS=()
FINDING_COUNT=0

# Log function
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

# Check if target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

log "Starting secret scan in: $TARGET_DIR"

# Define comprehensive secret patterns
# AWS Access Keys
declare -A PATTERNS=(
    # AWS Keys
    ["aws_access_key"]='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}'
    ["aws_secret_key"]='aws_secret_access_key["\s:=]+[A-Za-z0-9/+=]{40}'

    # GitHub Tokens
    ["github_pat"]='ghp_[0-9a-zA-Z]{36}|github_pat_[0-9a-zA-Z]{22}_[0-9a-zA-Z]{59}'
    ["github_oauth"]='gho_[0-9a-zA-Z]{36}'
    ["github_app"]='ghu_[0-9a-zA-Z]{36}|ghs_[0-9a-zA-Z]{36}'
    ["github_refresh"]='ghr_[0-9a-zA-Z]{36}'

    # API Keys (Generic)
    ["api_key"]='api[_-]?key["\s:=]+[A-Za-z0-9_\-]{20,}'
    ["apikey"]='apikey["\s:=]+[A-Za-z0-9_\-]{20,}'

    # Google Cloud
    ["gcp_api_key"]='AIza[0-9A-Za-z_\-]{35}'
    ["gcp_service_account"]='type["\s:=]+service_account'

    # Slack Tokens
    ["slack_token"]='xox[pbar]-[0-9]{10,13}-[0-9]{10,13}-[0-9]{10,13}-[a-z0-9]{32}'
    ["slack_webhook"]='https://hooks\.slack\.com/services/T[a-zA-Z0-9_]{8}/B[a-zA-Z0-9_]{8}/[a-zA-Z0-9_]{24}'

    # Stripe Keys
    ["stripe_secret"]='sk_live_[0-9a-zA-Z]{24,}'
    ["stripe_restricted"]='rk_live_[0-9a-zA-Z]{24,}'

    # Private Keys
    ["rsa_private_key"]='-----BEGIN RSA PRIVATE KEY-----'
    ["ssh_private_key"]='-----BEGIN OPENSSH PRIVATE KEY-----'
    ["pgp_private_key"]='-----BEGIN PGP PRIVATE KEY BLOCK-----'
    ["ec_private_key"]='-----BEGIN EC PRIVATE KEY-----'

    # Database Connection Strings
    ["postgres_url"]='postgres://[a-zA-Z0-9_]+:[a-zA-Z0-9_!@#$%^&*]+@[a-zA-Z0-9\.\-]+:[0-9]+/[a-zA-Z0-9_]+'
    ["mysql_url"]='mysql://[a-zA-Z0-9_]+:[a-zA-Z0-9_!@#$%^&*]+@[a-zA-Z0-9\.\-]+:[0-9]+/[a-zA-Z0-9_]+'
    ["mongodb_url"]='mongodb(\+srv)?://[a-zA-Z0-9_]+:[a-zA-Z0-9_!@#$%^&*]+@[a-zA-Z0-9\.\-]+/[a-zA-Z0-9_]+'

    # JWT Tokens
    ["jwt_token"]='eyJ[A-Za-z0-9_\-]+\.eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+'

    # OAuth Secrets
    ["oauth_secret"]='oauth[_-]?secret["\s:=]+[A-Za-z0-9_\-]{20,}'
    ["client_secret"]='client[_-]?secret["\s:=]+[A-Za-z0-9_\-]{20,}'

    # Generic Passwords
    ["password"]='password["\s:=]+["\x27][^"\x27]{6,}["\x27]'
    ["passwd"]='passwd["\s:=]+["\x27][^"\x27]{6,}["\x27]'

    # Azure Keys
    ["azure_connection"]='DefaultEndpointsProtocol=https;AccountName=[a-z0-9]+;AccountKey=[A-Za-z0-9+/=]{88};'

    # Twilio
    ["twilio_api_key"]='SK[a-z0-9]{32}'

    # SendGrid
    ["sendgrid_api_key"]='SG\.[a-zA-Z0-9_\-]{22}\.[a-zA-Z0-9_\-]{43}'

    # Mailgun
    ["mailgun_api_key"]='key-[0-9a-zA-Z]{32}'

    # NPM Tokens
    ["npm_token"]='npm_[A-Za-z0-9]{36}'

    # PyPI Tokens
    ["pypi_token"]='pypi-AgEIcHlwaS5vcmc[A-Za-z0-9\-_]{50,}'

    # Airtable API Keys
    ["airtable_key"]='(key|pat)[a-zA-Z0-9]{14,}'
    ["airtable_env"]='AIRTABLE_API_KEY["\s:=]+[A-Za-z0-9]{10,}'

    # Anthropic API Keys
    ["anthropic_key"]='sk-ant-[a-zA-Z0-9\-_]{95,}'

    # OpenAI API Keys
    ["openai_key"]='sk-[a-zA-Z0-9]{32,}'

    # Context7 API Keys
    ["context7_key"]='ctx7-[a-zA-Z0-9]{32,}'

    # Supabase Keys
    ["supabase_key"]='supabase_[a-zA-Z0-9_]{20,}'
)

# Determine severity based on pattern type
get_severity() {
    local pattern_name="$1"
    case "$pattern_name" in
        aws_*|rsa_private_key|ssh_private_key|pgp_private_key|ec_private_key)
            echo "CRITICAL"
            ;;
        *_secret|*_password|*_token|postgres_url|mysql_url|mongodb_url|airtable_*|anthropic_key|openai_key|context7_key|supabase_key)
            echo "HIGH"
            ;;
        api_key|apikey|jwt_token)
            echo "MEDIUM"
            ;;
        *)
            echo "LOW"
            ;;
    esac
}

# File extensions to scan
FILE_PATTERNS=(
    "*.js" "*.jsx" "*.ts" "*.tsx"
    "*.py" "*.pyw"
    "*.java" "*.kt"
    "*.go"
    "*.rs"
    "*.rb"
    "*.php"
    "*.cs"
    "*.swift"
    "*.env" "*.env.*"
    "*.yaml" "*.yml"
    "*.json"
    "*.xml"
    "*.conf" "*.config"
    "*.sh" "*.bash"
)

# Directories to exclude
EXCLUDE_DIRS=(
    "node_modules"
    "venv" ".venv" "env"
    ".git"
    "dist" "build"
    "coverage"
    "__pycache__"
    ".next"
    "target"
)

# Build find command with exclusions
build_find_command() {
    local cmd="find \"$TARGET_DIR\" -type f \\( "

    for pattern in "${FILE_PATTERNS[@]}"; do
        cmd+=" -name \"$pattern\" -o"
    done
    cmd="${cmd% -o} \\)"

    for exclude in "${EXCLUDE_DIRS[@]}"; do
        cmd+=" -not -path \"*/$exclude/*\""
    done

    echo "$cmd"
}

# Scan files for patterns
scan_files() {
    local find_cmd
    find_cmd=$(build_find_command)

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        for pattern_name in "${!PATTERNS[@]}"; do
            local pattern="${PATTERNS[$pattern_name]}"
            local severity
            severity=$(get_severity "$pattern_name")

            while IFS=: read -r line_num line_content; do
                [[ -n "$line_num" ]] || continue

                FINDING_COUNT=$((FINDING_COUNT + 1))

                # Create finding JSON
                local finding
                finding=$(cat <<EOF
{
  "id": "$FINDING_COUNT",
  "type": "$pattern_name",
  "severity": "$severity",
  "file": "$file",
  "line": $line_num,
  "content": $(echo "$line_content" | jq -R -s .),
  "remediation": "Remove hardcoded secret and use environment variables or secret management service"
}
EOF
)
                FINDINGS+=("$finding")

                if [[ "$VERBOSE" == "true" ]]; then
                    warn "Found $severity: $pattern_name in $file:$line_num"
                fi
            done < <(grep -nE "$pattern" "$file" 2>/dev/null || true)
        done
    done < <(eval "$find_cmd")
}

# Generate JSON output
generate_json_output() {
    local total_critical=0
    local total_high=0
    local total_medium=0
    local total_low=0

    for finding in "${FINDINGS[@]}"; do
        local severity
        severity=$(echo "$finding" | jq -r '.severity')
        case "$severity" in
            CRITICAL) total_critical=$((total_critical + 1)) ;;
            HIGH) total_high=$((total_high + 1)) ;;
            MEDIUM) total_medium=$((total_medium + 1)) ;;
            LOW) total_low=$((total_low + 1)) ;;
        esac
    done

    local findings_json
    findings_json=$(printf '%s\n' "${FINDINGS[@]}" | jq -s .)

    cat <<EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "target_directory": "$TARGET_DIR",
  "total_findings": $FINDING_COUNT,
  "severity_breakdown": {
    "critical": $total_critical,
    "high": $total_high,
    "medium": $total_medium,
    "low": $total_low
  },
  "findings": $findings_json
}
EOF
}

# Main execution
main() {
    log "Scanning for secrets..."
    scan_files

    if [[ $FINDING_COUNT -eq 0 ]]; then
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            echo '{"scan_timestamp":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","target_directory":"'$TARGET_DIR'","total_findings":0,"severity_breakdown":{"critical":0,"high":0,"medium":0,"low":0},"findings":[]}'
        else
            echo -e "${GREEN}No secrets found!${NC}"
        fi
        exit 0
    else
        if [[ "$OUTPUT_FORMAT" == "json" ]]; then
            generate_json_output
        else
            echo -e "${RED}Found $FINDING_COUNT potential secrets!${NC}"
            generate_json_output
        fi
        exit 1
    fi
}

# Check for required tools
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed. Install with: apt-get install jq"; exit 1; }

main
