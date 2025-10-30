#!/usr/bin/env bash
set -euo pipefail

# Comprehensive Security Report Generator
# Aggregates results from all security scans and generates unified reports
# Supports multiple output formats: HTML, JSON, Markdown, SARIF

SCAN_RESULTS_DIR="${1:-.}"
OUTPUT_FORMAT="${2:-html}"
OUTPUT_FILE="${3:-security-report}"
VERBOSE="${VERBOSE:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${GREEN}[INFO]${NC} $1" >&2
    fi
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

# Usage
show_usage() {
    cat <<EOF
Usage: $0 <scan-results-directory> [format] [output-file]

Arguments:
  scan-results-directory  Directory containing JSON scan results
  format                  html|json|markdown|sarif (default: html)
  output-file            Output filename without extension (default: security-report)

Expected scan result files:
  - secrets-scan.json      (from scan-secrets.sh)
  - dependencies-scan.json (from scan-dependencies.sh)
  - owasp-scan.json       (from scan-owasp.sh)
  - headers-scan.json     (from check-security-headers.sh)

Examples:
  $0 ./scan-results html security-report
  $0 ./scan-results json report
  VERBOSE=true $0 ./scan-results markdown
EOF
    exit 1
}

if [[ ! -d "$SCAN_RESULTS_DIR" ]]; then
    error "Scan results directory does not exist: $SCAN_RESULTS_DIR"
    show_usage
fi

log "Generating security report from: $SCAN_RESULTS_DIR"

# Initialize aggregated data
TOTAL_FINDINGS=0
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

declare -A SCAN_SUMMARIES=()

# Load scan results
load_scan_result() {
    local scan_type="$1"
    local filename="$2"
    local filepath="$SCAN_RESULTS_DIR/$filename"

    if [[ ! -f "$filepath" ]]; then
        log "Warning: $filename not found, skipping $scan_type scan"
        return
    fi

    log "Loading $scan_type scan results from $filename"

    local data
    data=$(cat "$filepath")

    # Extract summary statistics
    local total
    local critical high medium low

    total=$(echo "$data" | jq -r '.total_findings // .total_vulnerabilities // .total_checks // 0')
    critical=$(echo "$data" | jq -r '.severity_breakdown.critical // 0')
    high=$(echo "$data" | jq -r '.severity_breakdown.high // 0')
    medium=$(echo "$data" | jq -r '.severity_breakdown.medium // 0')
    low=$(echo "$data" | jq -r '.severity_breakdown.low // 0')

    TOTAL_FINDINGS=$((TOTAL_FINDINGS + total))
    CRITICAL_COUNT=$((CRITICAL_COUNT + critical))
    HIGH_COUNT=$((HIGH_COUNT + high))
    MEDIUM_COUNT=$((MEDIUM_COUNT + medium))
    LOW_COUNT=$((LOW_COUNT + low))

    SCAN_SUMMARIES["$scan_type"]="$data"

    info "$scan_type: $total findings ($critical critical, $high high, $medium medium, $low low)"
}

# Calculate risk score (0-100)
calculate_risk_score() {
    local score=0

    # Weight by severity
    score=$((score + CRITICAL_COUNT * 10))
    score=$((score + HIGH_COUNT * 5))
    score=$((score + MEDIUM_COUNT * 2))
    score=$((score + LOW_COUNT * 1))

    # Cap at 100
    if [[ $score -gt 100 ]]; then
        score=100
    fi

    echo "$score"
}

# Determine risk level
get_risk_level() {
    local score=$1

    if [[ $score -ge 80 ]]; then
        echo "CRITICAL"
    elif [[ $score -ge 60 ]]; then
        echo "HIGH"
    elif [[ $score -ge 40 ]]; then
        echo "MEDIUM"
    elif [[ $score -gt 0 ]]; then
        echo "LOW"
    else
        echo "MINIMAL"
    fi
}

# Generate JSON report
generate_json_report() {
    local risk_score
    risk_score=$(calculate_risk_score)
    local risk_level
    risk_level=$(get_risk_level "$risk_score")

    local scan_details="{"
    for scan_type in "${!SCAN_SUMMARIES[@]}"; do
        scan_details+="\"$scan_type\": ${SCAN_SUMMARIES[$scan_type]},"
    done
    scan_details="${scan_details%,}}"

    cat <<EOF
{
  "report_metadata": {
    "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "report_version": "1.0",
    "generator": "security-patterns skill",
    "scan_directory": "$SCAN_RESULTS_DIR"
  },
  "executive_summary": {
    "total_findings": $TOTAL_FINDINGS,
    "risk_score": $risk_score,
    "risk_level": "$risk_level",
    "severity_breakdown": {
      "critical": $CRITICAL_COUNT,
      "high": $HIGH_COUNT,
      "medium": $MEDIUM_COUNT,
      "low": $LOW_COUNT
    }
  },
  "scan_results": $scan_details,
  "recommendations": {
    "immediate_actions": [
      "Address all critical severity findings within 24 hours",
      "Review and fix high severity vulnerabilities within 1 week",
      "Plan remediation for medium/low findings in next sprint"
    ],
    "long_term_improvements": [
      "Integrate security scans into CI/CD pipeline",
      "Establish security baseline and track improvements",
      "Conduct quarterly security audits",
      "Provide security training for development team"
    ]
  }
}
EOF
}

# Generate HTML report
generate_html_report() {
    local risk_score
    risk_score=$(calculate_risk_score)
    local risk_level
    risk_level=$(get_risk_level "$risk_score")

    local risk_color
    case "$risk_level" in
        CRITICAL) risk_color="#d32f2f" ;;
        HIGH) risk_color="#f57c00" ;;
        MEDIUM) risk_color="#fbc02d" ;;
        LOW) risk_color="#689f38" ;;
        MINIMAL) risk_color="#388e3c" ;;
    esac

    cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Scan Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; border-radius: 8px 8px 0 0; }
        .header h1 { font-size: 32px; margin-bottom: 10px; }
        .header p { opacity: 0.9; font-size: 14px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 30px; }
        .summary-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid; }
        .summary-card.critical { border-color: #d32f2f; }
        .summary-card.high { border-color: #f57c00; }
        .summary-card.medium { border-color: #fbc02d; }
        .summary-card.low { border-color: #689f38; }
        .summary-card h3 { font-size: 14px; color: #666; margin-bottom: 10px; text-transform: uppercase; }
        .summary-card .value { font-size: 36px; font-weight: bold; color: #333; }
        .risk-score { text-align: center; padding: 30px; }
        .risk-circle { width: 150px; height: 150px; margin: 0 auto 20px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: $risk_color; color: white; font-size: 48px; font-weight: bold; box-shadow: 0 4px 12px rgba(0,0,0,0.2); }
        .risk-level { font-size: 24px; font-weight: bold; color: $risk_color; }
        .section { padding: 30px; border-top: 1px solid #e0e0e0; }
        .section h2 { margin-bottom: 20px; color: #333; }
        .scan-result { background: #f8f9fa; padding: 15px; margin-bottom: 15px; border-radius: 6px; border-left: 4px solid #667eea; }
        .scan-result h3 { margin-bottom: 10px; color: #667eea; }
        .scan-result .stat { display: inline-block; margin-right: 20px; }
        .recommendations { background: #e3f2fd; padding: 20px; border-radius: 6px; border-left: 4px solid #2196f3; }
        .recommendations ul { margin-left: 20px; margin-top: 10px; }
        .recommendations li { margin-bottom: 8px; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; color: white; }
        .badge.critical { background: #d32f2f; }
        .badge.high { background: #f57c00; }
        .badge.medium { background: #fbc02d; color: #333; }
        .badge.low { background: #689f38; }
        .footer { padding: 20px; text-align: center; color: #666; font-size: 12px; border-top: 1px solid #e0e0e0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Security Scan Report</h1>
            <p>Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")</p>
        </div>

        <div class="risk-score">
            <div class="risk-circle">$risk_score</div>
            <div class="risk-level">$risk_level RISK</div>
        </div>

        <div class="summary">
            <div class="summary-card critical">
                <h3>Critical</h3>
                <div class="value">$CRITICAL_COUNT</div>
            </div>
            <div class="summary-card high">
                <h3>High</h3>
                <div class="value">$HIGH_COUNT</div>
            </div>
            <div class="summary-card medium">
                <h3>Medium</h3>
                <div class="value">$MEDIUM_COUNT</div>
            </div>
            <div class="summary-card low">
                <h3>Low</h3>
                <div class="value">$LOW_COUNT</div>
            </div>
        </div>

        <div class="section">
            <h2>Scan Results</h2>
EOF

    # Add scan summaries
    for scan_type in "${!SCAN_SUMMARIES[@]}"; do
        local data="${SCAN_SUMMARIES[$scan_type]}"
        local total
        total=$(echo "$data" | jq -r '.total_findings // .total_vulnerabilities // .total_checks // 0')

        cat <<EOF
            <div class="scan-result">
                <h3>$(echo "$scan_type" | tr '[:lower:]' '[:upper:]' | tr '_' ' ')</h3>
                <div class="stat"><strong>Total Findings:</strong> $total</div>
            </div>
EOF
    done

    cat <<EOF
        </div>

        <div class="section">
            <div class="recommendations">
                <h2>Recommendations</h2>
                <h3>Immediate Actions</h3>
                <ul>
                    <li>Address all critical severity findings within 24 hours</li>
                    <li>Review and fix high severity vulnerabilities within 1 week</li>
                    <li>Plan remediation for medium/low findings in next sprint</li>
                </ul>
                <h3 style="margin-top: 20px;">Long-term Improvements</h3>
                <ul>
                    <li>Integrate security scans into CI/CD pipeline</li>
                    <li>Establish security baseline and track improvements</li>
                    <li>Conduct quarterly security audits</li>
                    <li>Provide security training for development team</li>
                </ul>
            </div>
        </div>

        <div class="footer">
            <p>Generated by security-patterns skill | For detailed findings, see individual scan JSON files</p>
        </div>
    </div>
</body>
</html>
EOF
}

# Generate Markdown report
generate_markdown_report() {
    local risk_score
    risk_score=$(calculate_risk_score)
    local risk_level
    risk_level=$(get_risk_level "$risk_score")

    cat <<EOF
# Security Scan Report

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Executive Summary

**Risk Score:** $risk_score/100
**Risk Level:** $risk_level

### Severity Breakdown

| Severity | Count |
|----------|-------|
| Critical | $CRITICAL_COUNT |
| High     | $HIGH_COUNT |
| Medium   | $MEDIUM_COUNT |
| Low      | $LOW_COUNT |
| **Total** | **$TOTAL_FINDINGS** |

## Scan Results
EOF

    for scan_type in "${!SCAN_SUMMARIES[@]}"; do
        local data="${SCAN_SUMMARIES[$scan_type]}"
        local total
        total=$(echo "$data" | jq -r '.total_findings // .total_vulnerabilities // .total_checks // 0')

        cat <<EOF

### $(echo "$scan_type" | tr '[:lower:]' '[:upper:]' | tr '_' ' ')

- **Total Findings:** $total
EOF
    done

    cat <<EOF

## Recommendations

### Immediate Actions
- Address all critical severity findings within 24 hours
- Review and fix high severity vulnerabilities within 1 week
- Plan remediation for medium/low findings in next sprint

### Long-term Improvements
- Integrate security scans into CI/CD pipeline
- Establish security baseline and track improvements
- Conduct quarterly security audits
- Provide security training for development team
EOF
}

# Main execution
main() {
    # Load all scan results
    load_scan_result "secrets" "secrets-scan.json"
    load_scan_result "dependencies" "dependencies-scan.json"
    load_scan_result "owasp" "owasp-scan.json"
    load_scan_result "headers" "headers-scan.json"

    info "Total findings across all scans: $TOTAL_FINDINGS"
    info "Risk score: $(calculate_risk_score)/100"

    # Generate report in requested format
    case "$OUTPUT_FORMAT" in
        html)
            generate_html_report > "${OUTPUT_FILE}.html"
            info "HTML report generated: ${OUTPUT_FILE}.html"
            ;;
        json)
            generate_json_report > "${OUTPUT_FILE}.json"
            info "JSON report generated: ${OUTPUT_FILE}.json"
            ;;
        markdown|md)
            generate_markdown_report > "${OUTPUT_FILE}.md"
            info "Markdown report generated: ${OUTPUT_FILE}.md"
            ;;
        *)
            error "Unsupported output format: $OUTPUT_FORMAT"
            show_usage
            ;;
    esac

    if [[ $CRITICAL_COUNT -gt 0 || $HIGH_COUNT -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Check for required tools
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed. Install with: apt-get install jq"; exit 1; }

main
