#!/bin/bash
# find-completed-tasks.sh
# Identify tasks that are completed in code but not marked complete in specs

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
Usage: $0 [spec-directory] [code-directory]

Identify tasks completed in code but not marked complete in specs.

Arguments:
    spec-directory   Directory containing spec files (default: specs/)
    code-directory   Directory containing code (default: src/)

Options:
    -h, --help       Show this help message
    -v, --verbose    Show detailed output
    -j, --json       Output results as JSON
    --min-evidence N Minimum evidence score (default: 2)

Examples:
    $0
    $0 specs/ src/
    $0 --verbose --min-evidence 3

Exit codes:
    0 - Success
    1 - Invalid arguments
    2 - Directory not found
EOF
}

# Parse arguments
SPEC_DIR="specs"
CODE_DIR="src"
VERBOSE=0
JSON_OUTPUT=0
MIN_EVIDENCE=2

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -j|--json)
            JSON_OUTPUT=1
            shift
            ;;
        --min-evidence)
            MIN_EVIDENCE="$2"
            shift 2
            ;;
        --min-evidence=*)
            MIN_EVIDENCE="${1#*=}"
            shift
            ;;
        *)
            if [[ "$SPEC_DIR" == "specs" ]]; then
                SPEC_DIR="$1"
            elif [[ "$CODE_DIR" == "src" ]]; then
                CODE_DIR="$1"
            else
                echo "Error: Unknown argument: $1" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate directories
if [[ ! -d "$SPEC_DIR" ]]; then
    echo "Warning: Spec directory not found: $SPEC_DIR (trying current directory)" >&2
    SPEC_DIR="."
fi

if [[ ! -d "$CODE_DIR" ]]; then
    echo "Warning: Code directory not found: $CODE_DIR (trying current directory)" >&2
    CODE_DIR="."
fi

# Find all spec files
find_spec_files() {
    local spec_dir="$1"
    find "$spec_dir" -type f -name "*.md" 2>/dev/null
}

# Extract incomplete tasks from spec file
extract_incomplete_tasks() {
    local spec_file="$1"
    local tasks=()

    # Look for unchecked checkbox items: - [ ]
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]\[[[:space:]]\][[:space:]](.+)$ ]]; then
            tasks+=("${BASH_REMATCH[1]}")
        fi
    done < "$spec_file"

    printf '%s\n' "${tasks[@]}"
}

# Extract keywords from task description
extract_keywords() {
    local task="$1"

    # Remove special characters, convert to lowercase, extract significant words
    echo "$task" | \
        sed 's/[^a-zA-Z0-9 ]/ /g' | \
        tr '[:upper:]' '[:lower:]' | \
        grep -oE '\w{4,}' | \
        grep -vE '^(the|and|for|with|that|this|from|have|will|should|must|can|need|make|create|add|update|implement|ensure)$' | \
        sort -u
}

# Check for implementation evidence
# Returns evidence score (0-5)
check_evidence() {
    local task="$1"
    local code_dir="$2"
    local keywords
    keywords=$(extract_keywords "$task")

    if [[ -z "$keywords" ]]; then
        echo "0"
        return
    fi

    local evidence_score=0
    local evidence_details=()

    # Check for test files
    for keyword in $keywords; do
        if grep -rql "describe.*$keyword\|it.*$keyword\|test.*$keyword" "$code_dir" 2>/dev/null | head -1 | grep -q "test\|spec"; then
            evidence_score=$((evidence_score + 2))
            evidence_details+=("test")
            break
        fi
    done

    # Check for implementation files
    for keyword in $keywords; do
        if grep -rql "function.*$keyword\|class.*$keyword\|const.*$keyword.*=" "$code_dir" 2>/dev/null | head -1; then
            evidence_score=$((evidence_score + 1))
            evidence_details+=("implementation")
            break
        fi
    done

    # Check for configuration
    for keyword in $keywords; do
        if grep -rql "$keyword" "$code_dir" 2>/dev/null | head -1 | grep -qE "config\|settings\|env"; then
            evidence_score=$((evidence_score + 1))
            evidence_details+=("config")
            break
        fi
    done

    # Check for documentation
    for keyword in $keywords; do
        if grep -rql "# .*$keyword\|## .*$keyword\|### .*$keyword" "$code_dir" 2>/dev/null | head -1 | grep -q "README\|CHANGELOG\|\.md$"; then
            evidence_score=$((evidence_score + 1))
            evidence_details+=("docs")
            break
        fi
    done

    # Return score and details
    echo "$evidence_score|${evidence_details[*]}"
}

# Find files containing evidence
find_evidence_files() {
    local task="$1"
    local code_dir="$2"
    local keywords
    keywords=$(extract_keywords "$task")

    local files=()

    for keyword in $keywords; do
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                files+=("$file")
            fi
        done < <(grep -rl "$keyword" "$code_dir" 2>/dev/null | head -3)
    done

    # Remove duplicates
    printf '%s\n' "${files[@]}" | sort -u | head -5
}

# Main search logic
find_completed() {
    local spec_dir="$1"
    local code_dir="$2"
    local min_evidence="$3"

    local total_incomplete=0
    local likely_complete=0

    declare -A completed_tasks
    declare -A task_evidence
    declare -A task_files

    # Process each spec file
    while IFS= read -r spec_file; do
        local tasks
        mapfile -t tasks < <(extract_incomplete_tasks "$spec_file")

        for task in "${tasks[@]}"; do
            if [[ -z "$task" ]]; then
                continue
            fi

            total_incomplete=$((total_incomplete + 1))

            # Check for evidence
            local evidence_result
            evidence_result=$(check_evidence "$task" "$code_dir")
            local score="${evidence_result%%|*}"
            local details="${evidence_result#*|}"

            if [[ $score -ge $min_evidence ]]; then
                likely_complete=$((likely_complete + 1))
                completed_tasks["$task"]="$spec_file"
                task_evidence["$task"]="$score|$details"

                # Find evidence files
                local files
                files=$(find_evidence_files "$task" "$code_dir")
                task_files["$task"]="$files"
            fi
        done
    done < <(find_spec_files "$spec_dir")

    # Output results
    if [[ $JSON_OUTPUT -eq 1 ]]; then
        # JSON output
        echo "{"
        echo "  \"spec_directory\": \"$spec_dir\","
        echo "  \"code_directory\": \"$code_dir\","
        echo "  \"total_incomplete_tasks\": $total_incomplete,"
        echo "  \"likely_completed_tasks\": $likely_complete,"
        echo "  \"min_evidence_score\": $min_evidence,"
        echo "  \"completed_tasks\": ["
        local first=1
        for task in "${!completed_tasks[@]}"; do
            local spec_file="${completed_tasks[$task]}"
            local evidence="${task_evidence[$task]}"
            local score="${evidence%%|*}"
            local details="${evidence#*|}"
            local files="${task_files[$task]}"

            [[ $first -eq 0 ]] && echo ","
            echo "    {"
            echo "      \"task\": \"$task\","
            echo "      \"spec_file\": \"$spec_file\","
            echo "      \"evidence_score\": $score,"
            echo "      \"evidence_types\": [\"${details// /\", \"}\"],"
            echo "      \"files\": ["
            if [[ -n "$files" ]]; then
                echo "        \"$(echo "$files" | head -1)\""
            fi
            echo "      ]"
            echo -n "    }"
            first=0
        done
        echo
        echo "  ]"
        echo "}"
    else
        # Human-readable output
        echo -e "${BLUE}=== Find Completed Tasks ===${NC}"
        echo
        echo -e "${BLUE}Spec Directory:${NC} $spec_dir"
        echo -e "${BLUE}Code Directory:${NC} $code_dir"
        echo
        echo -e "${BLUE}Summary:${NC}"
        echo "  Total Incomplete Tasks: $total_incomplete"
        echo -e "  ${GREEN}Likely Completed: $likely_complete${NC}"
        echo "  Min Evidence Score: $min_evidence"
        echo

        if [[ $likely_complete -gt 0 ]]; then
            echo -e "${GREEN}=== Tasks That Appear Completed ===${NC}"
            echo
            for task in "${!completed_tasks[@]}"; do
                local spec_file="${completed_tasks[$task]}"
                local evidence="${task_evidence[$task]}"
                local score="${evidence%%|*}"
                local details="${evidence#*|}"
                local files="${task_files[$task]}"

                echo -e "  ${GREEN}✓${NC} $task"
                echo -e "    ${BLUE}Spec:${NC} $spec_file"
                echo -e "    ${BLUE}Evidence Score:${NC} $score/5 ($details)"

                if [[ $VERBOSE -eq 1 ]] && [[ -n "$files" ]]; then
                    echo -e "    ${BLUE}Found in:${NC}"
                    echo "$files" | while IFS= read -r file; do
                        echo "      - $file"
                    done
                fi
                echo
            done

            echo -e "${YELLOW}=== Recommended Actions ===${NC}"
            echo "  1. Review the tasks listed above"
            echo "  2. Verify they are actually complete"
            echo "  3. Update spec files to mark tasks as complete:"
            echo "     Change: - [ ] Task"
            echo "     To:     - [x] Task"
            echo
            echo "  Or use update-spec-status.sh to mark entire specs complete"
        else
            echo -e "${GREEN}✓ All incomplete tasks appear to be genuinely incomplete${NC}"
        fi
    fi
}

# Run search
find_completed "$SPEC_DIR" "$CODE_DIR" "$MIN_EVIDENCE"
