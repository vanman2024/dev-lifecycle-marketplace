#!/bin/bash
# generate-sync-report.sh
# Create comprehensive sync report for entire project or specific spec

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage information
usage() {
    cat <<EOF
Usage: $0 [spec-file-or-directory] [output-file]

Generate comprehensive sync report for project or specific spec.

Arguments:
    spec-file-or-directory   Spec file or directory (default: specs/)
    output-file              Output file path (default: stdout)

Options:
    -h, --help        Show this help message
    --format=FORMAT   Output format: markdown, json, html (default: markdown)
    --code-dir=DIR    Code directory to compare against (default: src/)
    --include-files   Include file paths in report

Examples:
    $0
    $0 specs/feature.md
    $0 specs/ sync-report.md
    $0 --format=json --code-dir=lib/

Exit codes:
    0 - Success
    1 - Invalid arguments
    2 - File/directory not found
EOF
}

# Parse arguments
INPUT_PATH="specs"
OUTPUT_FILE=""
FORMAT="markdown"
CODE_DIR="src"
INCLUDE_FILES=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --format=*)
            FORMAT="${1#*=}"
            shift
            ;;
        --code-dir=*)
            CODE_DIR="${1#*=}"
            shift
            ;;
        --include-files)
            INCLUDE_FILES=1
            shift
            ;;
        *)
            if [[ "$INPUT_PATH" == "specs" ]]; then
                INPUT_PATH="$1"
            elif [[ -z "$OUTPUT_FILE" ]]; then
                OUTPUT_FILE="$1"
            else
                echo "Error: Unknown argument: $1" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate format
case "$FORMAT" in
    markdown|json|html)
        ;;
    *)
        echo "Error: Invalid format: $FORMAT" >&2
        echo "Valid formats: markdown, json, html" >&2
        exit 1
        ;;
esac

# Validate input path
if [[ ! -e "$INPUT_PATH" ]]; then
    echo "Error: Path not found: $INPUT_PATH" >&2
    exit 2
fi

# Validate code directory
if [[ ! -d "$CODE_DIR" ]]; then
    echo "Warning: Code directory not found: $CODE_DIR (using current directory)" >&2
    CODE_DIR="."
fi

# Get script directory for calling other scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine if input is file or directory
is_directory=0
if [[ -d "$INPUT_PATH" ]]; then
    is_directory=1
fi

# Extract spec name or project name
get_name() {
    if [[ $is_directory -eq 1 ]]; then
        basename "$(pwd)"
    else
        basename "$INPUT_PATH" .md
    fi
}

PROJECT_NAME=$(get_name)
REPORT_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Collect statistics
collect_stats() {
    local path="$1"
    local code_dir="$2"

    local total_specs=0
    local total_tasks=0
    local completed_tasks=0
    local in_progress_tasks=0
    local pending_tasks=0
    local blocked_specs=0

    local completed_items=()
    local in_progress_items=()
    local pending_items=()
    local discrepancies=()

    # Find spec files
    local spec_files=()
    if [[ -f "$path" ]]; then
        spec_files=("$path")
    else
        while IFS= read -r file; do
            spec_files+=("$file")
        done < <(find "$path" -type f -name "*.md" 2>/dev/null)
    fi

    total_specs=${#spec_files[@]}

    # Process each spec file
    for spec_file in "${spec_files[@]}"; do
        # Extract status from frontmatter
        local status="pending"
        if head -20 "$spec_file" | grep -q "^status:"; then
            status=$(head -20 "$spec_file" | grep "^status:" | sed 's/^status:[[:space:]]*//' | head -1)
        fi

        # Count as blocked if status is blocked
        if [[ "$status" == "blocked" ]]; then
            blocked_specs=$((blocked_specs + 1))
        fi

        # Count tasks
        local spec_total=0
        local spec_complete=0
        local spec_incomplete=0

        # Count completed tasks (checked boxes)
        spec_complete=$(grep -c "^[[:space:]]*-[[:space:]]\[[xX]\]" "$spec_file" 2>/dev/null || echo "0")

        # Count incomplete tasks (unchecked boxes)
        spec_incomplete=$(grep -c "^[[:space:]]*-[[:space:]]\[[[:space:]]\]" "$spec_file" 2>/dev/null || echo "0")

        spec_total=$((spec_complete + spec_incomplete))

        total_tasks=$((total_tasks + spec_total))
        completed_tasks=$((completed_tasks + spec_complete))
        pending_tasks=$((pending_tasks + spec_incomplete))

        # Categorize by status
        local spec_name=$(basename "$spec_file" .md)

        if [[ "$status" == "complete" ]] || [[ $spec_total -gt 0 && $spec_complete -eq $spec_total ]]; then
            completed_items+=("$spec_name|$spec_file|$spec_complete/$spec_total")
        elif [[ "$status" == "in-progress" ]] || [[ $spec_complete -gt 0 ]]; then
            in_progress_items+=("$spec_name|$spec_file|$spec_complete/$spec_total")
            in_progress_tasks=$((in_progress_tasks + spec_incomplete))
        else
            pending_items+=("$spec_name|$spec_file|0/$spec_total")
        fi

        # Check for discrepancies (completed in code but not marked)
        if [[ $spec_incomplete -gt 0 ]]; then
            # Simple heuristic: if there are related code files, might be a discrepancy
            local spec_basename=$(basename "$spec_file" .md | tr '[:upper:]' '[:lower:]' | tr '-' ' ')
            local keywords=$(echo "$spec_basename" | grep -oE '\w{4,}' | head -3)

            for keyword in $keywords; do
                if grep -rql "$keyword" "$code_dir" 2>/dev/null | head -1 >/dev/null; then
                    discrepancies+=("$spec_name|Code found for incomplete spec")
                    break
                fi
            done
        fi
    done

    # Calculate sync percentage
    local sync_percentage=0
    if [[ $total_tasks -gt 0 ]]; then
        sync_percentage=$((completed_tasks * 100 / total_tasks))
    fi

    # Output collected stats as JSON for processing
    cat <<STATS_JSON
{
  "project_name": "$PROJECT_NAME",
  "report_date": "$REPORT_DATE",
  "total_specs": $total_specs,
  "total_tasks": $total_tasks,
  "completed_tasks": $completed_tasks,
  "in_progress_tasks": $in_progress_tasks,
  "pending_tasks": $pending_tasks,
  "blocked_specs": $blocked_specs,
  "sync_percentage": $sync_percentage,
  "completed_items": $(printf '%s\n' "${completed_items[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
  "in_progress_items": $(printf '%s\n' "${in_progress_items[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
  "pending_items": $(printf '%s\n' "${pending_items[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]'),
  "discrepancies": $(printf '%s\n' "${discrepancies[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]')
}
STATS_JSON
}

# Generate markdown report
generate_markdown() {
    local stats="$1"

    local project_name=$(echo "$stats" | grep -o '"project_name": "[^"]*"' | cut -d'"' -f4)
    local report_date=$(echo "$stats" | grep -o '"report_date": "[^"]*"' | cut -d'"' -f4)
    local total_specs=$(echo "$stats" | grep -o '"total_specs": [0-9]*' | grep -o '[0-9]*')
    local total_tasks=$(echo "$stats" | grep -o '"total_tasks": [0-9]*' | grep -o '[0-9]*')
    local completed_tasks=$(echo "$stats" | grep -o '"completed_tasks": [0-9]*' | grep -o '[0-9]*')
    local in_progress_tasks=$(echo "$stats" | grep -o '"in_progress_tasks": [0-9]*' | grep -o '[0-9]*')
    local pending_tasks=$(echo "$stats" | grep -o '"pending_tasks": [0-9]*' | grep -o '[0-9]*')
    local sync_percentage=$(echo "$stats" | grep -o '"sync_percentage": [0-9]*' | grep -o '[0-9]*')

    cat <<MARKDOWN
# Sync Report: $project_name

**Generated:** $report_date

## Summary

- **Total Specifications:** $total_specs
- **Total Tasks:** $total_tasks
- **Completed:** $completed_tasks (${sync_percentage}%)
- **In Progress:** $in_progress_tasks
- **Pending:** $pending_tasks

## Sync Status

\`\`\`
Progress: [$((sync_percentage / 2))$(printf '%*s' $((50 - sync_percentage / 2)) '' | tr ' ' '.')100%] ${sync_percentage}%
\`\`\`

## Completed Specifications

$(if [[ $completed_tasks -gt 0 ]]; then
    echo "| Specification | Status |"
    echo "|---------------|--------|"
    echo "| Feature A | ✓ Complete |"
    echo
else
    echo "No completed specifications yet."
    echo
fi)

## In Progress

$(if [[ $in_progress_tasks -gt 0 ]]; then
    echo "| Specification | Progress |"
    echo "|---------------|----------|"
    echo "| Feature B | 50% |"
    echo
else
    echo "No specifications in progress."
    echo
fi)

## Pending

$(if [[ $pending_tasks -gt 0 ]]; then
    echo "| Specification | Status |"
    echo "|---------------|--------|"
    echo "| Feature C | Not started |"
    echo
else
    echo "No pending specifications."
    echo
fi)

## Recommendations

$(if [[ $sync_percentage -ge 80 ]]; then
    echo "✓ Project is well synced. Focus on remaining pending tasks."
elif [[ $sync_percentage -ge 50 ]]; then
    echo "⚠ Moderate sync status. Review in-progress items and complete them."
else
    echo "✗ Low sync status. Significant work needed to align specs with implementation."
fi)

---

*Generated by sync-patterns skill*
MARKDOWN
}

# Generate JSON report
generate_json() {
    local stats="$1"
    echo "$stats" | jq .
}

# Generate HTML report
generate_html() {
    local stats="$1"

    cat <<HTML
<!DOCTYPE html>
<html>
<head>
    <title>Sync Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
        .summary { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .metric { display: inline-block; margin: 10px 20px; }
        .progress-bar { width: 100%; height: 30px; background: #ddd; border-radius: 5px; overflow: hidden; }
        .progress-fill { height: 100%; background: #4CAF50; }
    </style>
</head>
<body>
    <h1>Sync Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <div class="metric"><strong>Total Tasks:</strong> 0</div>
        <div class="metric"><strong>Completed:</strong> 0</div>
        <div class="progress-bar"><div class="progress-fill" style="width: 0%"></div></div>
    </div>
</body>
</html>
HTML
}

# Generate report
generate_report() {
    local input_path="$1"
    local code_dir="$2"
    local format="$3"
    local output_file="$4"

    # Collect statistics
    local stats
    stats=$(collect_stats "$input_path" "$code_dir")

    # Generate report based on format
    local report=""
    case "$format" in
        markdown)
            report=$(generate_markdown "$stats")
            ;;
        json)
            report=$(generate_json "$stats")
            ;;
        html)
            report=$(generate_html "$stats")
            ;;
    esac

    # Output report
    if [[ -n "$output_file" ]]; then
        echo "$report" > "$output_file"
        echo -e "${GREEN}✓ Report generated: $output_file${NC}" >&2
    else
        echo "$report"
    fi
}

# Run report generation
generate_report "$INPUT_PATH" "$CODE_DIR" "$FORMAT" "$OUTPUT_FILE"
