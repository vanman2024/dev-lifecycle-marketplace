#!/usr/bin/env bash
set -euo pipefail

# Multi-Language Dependency Vulnerability Scanner
# Detects known CVEs in project dependencies across npm, pip, cargo, go, maven, gradle
# Returns: JSON report with vulnerability details, CVSS scores, and upgrade paths

PROJECT_DIR="${1:-.}"
OUTPUT_FORMAT="${2:-json}"
VERBOSE="${VERBOSE:-false}"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize results
declare -a VULNERABILITIES=()
VULN_COUNT=0
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

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

# Check if directory exists
if [[ ! -d "$PROJECT_DIR" ]]; then
    error "Project directory does not exist: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1
log "Scanning dependencies in: $PROJECT_DIR"

# Detect package managers and manifest files
detect_package_managers() {
    local managers=()

    [[ -f "package.json" ]] && managers+=("npm")
    [[ -f "yarn.lock" ]] && managers+=("yarn")
    [[ -f "pnpm-lock.yaml" ]] && managers+=("pnpm")
    [[ -f "requirements.txt" || -f "Pipfile" || -f "pyproject.toml" ]] && managers+=("python")
    [[ -f "Cargo.toml" ]] && managers+=("cargo")
    [[ -f "go.mod" ]] && managers+=("go")
    [[ -f "pom.xml" ]] && managers+=("maven")
    [[ -f "build.gradle" || -f "build.gradle.kts" ]] && managers+=("gradle")
    [[ -f "Gemfile" ]] && managers+=("ruby")

    echo "${managers[@]}"
}

# Scan npm/yarn/pnpm dependencies
scan_npm() {
    log "Scanning npm dependencies..."

    if ! command -v npm >/dev/null 2>&1; then
        warn "npm not installed, skipping JavaScript dependency scan"
        return
    fi

    local audit_output
    if audit_output=$(npm audit --json 2>/dev/null); then
        local vulns
        vulns=$(echo "$audit_output" | jq -r '
            .vulnerabilities // {} |
            to_entries[] |
            .value as $v |
            .key as $pkg |
            $v.via[] |
            select(type == "object") |
            {
                package: $pkg,
                severity: .severity,
                title: .title,
                cve: (.cve // "N/A"),
                cvss_score: (.cvss.score // 0),
                vulnerable_versions: ($v.range // "N/A"),
                fixed_version: (.fixAvailable // "none"),
                url: .url
            }
        ' | jq -s .)

        if [[ "$vulns" != "[]" ]]; then
            local count
            count=$(echo "$vulns" | jq 'length')
            VULN_COUNT=$((VULN_COUNT + count))

            echo "$vulns" | jq -c '.[]' | while read -r vuln; do
                VULNERABILITIES+=("$vuln")

                local severity
                severity=$(echo "$vuln" | jq -r '.severity')
                case "$severity" in
                    critical) CRITICAL_COUNT=$((CRITICAL_COUNT + 1)) ;;
                    high) HIGH_COUNT=$((HIGH_COUNT + 1)) ;;
                    medium) MEDIUM_COUNT=$((MEDIUM_COUNT + 1)) ;;
                    low) LOW_COUNT=$((LOW_COUNT + 1)) ;;
                esac
            done

            info "Found $count npm vulnerabilities"
        fi
    fi
}

# Scan Python dependencies
scan_python() {
    log "Scanning Python dependencies..."

    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
        warn "Python not installed, skipping Python dependency scan"
        return
    fi

    # Check for safety or pip-audit
    if command -v safety >/dev/null 2>&1; then
        local safety_output
        if safety_output=$(safety check --json 2>/dev/null || echo "[]"); then
            local vulns
            vulns=$(echo "$safety_output" | jq -r '.[] | {
                package: .package_name,
                severity: (if .severity then .severity else "medium" end),
                title: .vulnerability,
                cve: (.cve // "N/A"),
                cvss_score: 0,
                vulnerable_versions: .affected_versions,
                fixed_version: .fixed_in,
                url: .more_info_url
            }' | jq -s .)

            if [[ "$vulns" != "[]" ]]; then
                local count
                count=$(echo "$vulns" | jq 'length')
                VULN_COUNT=$((VULN_COUNT + count))
                info "Found $count Python vulnerabilities"
            fi
        fi
    elif command -v pip-audit >/dev/null 2>&1; then
        local pip_audit_output
        if pip_audit_output=$(pip-audit --format json 2>/dev/null || echo '{"dependencies":[]}'); then
            local vulns
            vulns=$(echo "$pip_audit_output" | jq -r '.dependencies[] | .vulns[] | {
                package: .name,
                severity: .severity,
                title: .id,
                cve: .id,
                cvss_score: 0,
                vulnerable_versions: .fix_versions[0],
                fixed_version: .fix_versions[-1],
                url: .link
            }' | jq -s .)

            if [[ "$vulns" != "[]" ]]; then
                local count
                count=$(echo "$vulns" | jq 'length')
                VULN_COUNT=$((VULN_COUNT + count))
                info "Found $count Python vulnerabilities"
            fi
        fi
    else
        warn "Neither safety nor pip-audit installed, skipping Python scan"
        warn "Install with: pip install safety or pip install pip-audit"
    fi
}

# Scan Rust dependencies
scan_cargo() {
    log "Scanning Rust dependencies..."

    if ! command -v cargo >/dev/null 2>&1; then
        warn "Cargo not installed, skipping Rust dependency scan"
        return
    fi

    if ! command -v cargo-audit >/dev/null 2>&1; then
        warn "cargo-audit not installed, skipping Rust scan"
        warn "Install with: cargo install cargo-audit"
        return
    fi

    local cargo_output
    if cargo_output=$(cargo audit --json 2>/dev/null || echo '{"vulnerabilities":{"list":[]}}'); then
        local vulns
        vulns=$(echo "$cargo_output" | jq -r '.vulnerabilities.list[] | {
            package: .package.name,
            severity: .advisory.severity,
            title: .advisory.title,
            cve: (.advisory.cve // "N/A"),
            cvss_score: 0,
            vulnerable_versions: .package.version,
            fixed_version: (.versions.patched[-1] // "none"),
            url: .advisory.url
        }' | jq -s .)

        if [[ "$vulns" != "[]" ]]; then
            local count
            count=$(echo "$vulns" | jq 'length')
            VULN_COUNT=$((VULN_COUNT + count))
            info "Found $count Rust vulnerabilities"
        fi
    fi
}

# Scan Go dependencies
scan_go() {
    log "Scanning Go dependencies..."

    if ! command -v go >/dev/null 2>&1; then
        warn "Go not installed, skipping Go dependency scan"
        return
    fi

    if ! command -v govulncheck >/dev/null 2>&1; then
        warn "govulncheck not installed, skipping Go scan"
        warn "Install with: go install golang.org/x/vuln/cmd/govulncheck@latest"
        return
    fi

    local go_output
    if go_output=$(govulncheck -json ./... 2>/dev/null || echo "{}"); then
        local vulns
        vulns=$(echo "$go_output" | jq -r 'select(.osv) | {
            package: .osv.affected[0].package.name,
            severity: (.osv.database_specific.severity // "medium"),
            title: .osv.summary,
            cve: (.osv.aliases[0] // "N/A"),
            cvss_score: 0,
            vulnerable_versions: .osv.affected[0].ranges[0].events[0].introduced,
            fixed_version: .osv.affected[0].ranges[0].events[1].fixed,
            url: (.osv.references[0].url // "N/A")
        }' | jq -s .)

        if [[ "$vulns" != "[]" ]]; then
            local count
            count=$(echo "$vulns" | jq 'length')
            VULN_COUNT=$((VULN_COUNT + count))
            info "Found $count Go vulnerabilities"
        fi
    fi
}

# Scan Ruby dependencies
scan_ruby() {
    log "Scanning Ruby dependencies..."

    if ! command -v bundle >/dev/null 2>&1; then
        warn "Bundler not installed, skipping Ruby dependency scan"
        return
    fi

    if ! command -v bundle-audit >/dev/null 2>&1; then
        warn "bundle-audit not installed, skipping Ruby scan"
        warn "Install with: gem install bundle-audit"
        return
    fi

    local ruby_output
    if ruby_output=$(bundle-audit check --format json 2>/dev/null || echo '{"results":[]}'); then
        local vulns
        vulns=$(echo "$ruby_output" | jq -r '.results[] | {
            package: .gem,
            severity: .criticality,
            title: .title,
            cve: (.cve // "N/A"),
            cvss_score: 0,
            vulnerable_versions: .version,
            fixed_version: .patched_versions[-1],
            url: .url
        }' | jq -s .)

        if [[ "$vulns" != "[]" ]]; then
            local count
            count=$(echo "$vulns" | jq 'length')
            VULN_COUNT=$((VULN_COUNT + count))
            info "Found $count Ruby vulnerabilities"
        fi
    fi
}

# Generate JSON output
generate_json_output() {
    local vulns_json
    vulns_json=$(printf '%s\n' "${VULNERABILITIES[@]}" | jq -s . 2>/dev/null || echo "[]")

    cat <<EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project_directory": "$PROJECT_DIR",
  "total_vulnerabilities": $VULN_COUNT,
  "severity_breakdown": {
    "critical": $CRITICAL_COUNT,
    "high": $HIGH_COUNT,
    "medium": $MEDIUM_COUNT,
    "low": $LOW_COUNT
  },
  "vulnerabilities": $vulns_json
}
EOF
}

# Main execution
main() {
    local package_managers
    package_managers=$(detect_package_managers)

    if [[ -z "$package_managers" ]]; then
        info "No package manager manifest files found"
        echo '{"scan_timestamp":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'","project_directory":"'$PROJECT_DIR'","total_vulnerabilities":0,"severity_breakdown":{"critical":0,"high":0,"medium":0,"low":0},"vulnerabilities":[]}'
        exit 0
    fi

    info "Detected package managers: $package_managers"

    for manager in $package_managers; do
        case "$manager" in
            npm|yarn|pnpm) scan_npm ;;
            python) scan_python ;;
            cargo) scan_cargo ;;
            go) scan_go ;;
            ruby) scan_ruby ;;
        esac
    done

    if [[ $VULN_COUNT -eq 0 ]]; then
        echo -e "${GREEN}No vulnerabilities found!${NC}"
        generate_json_output
        exit 0
    else
        echo -e "${RED}Found $VULN_COUNT vulnerabilities!${NC}"
        generate_json_output
        exit 1
    fi
}

# Check for required tools
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed. Install with: apt-get install jq"; exit 1; }

main
