#!/bin/bash
# compare-specs-vs-code.sh
# Compare specification requirements against actual code implementation

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
Usage: $0 <spec-file> [code-directory]

Compare specification requirements against code implementation.

Arguments:
    spec-file        Path to specification markdown file
    code-directory   Directory to search for implementation (default: current directory)

Options:
    -h, --help      Show this help message
    -v, --verbose   Show detailed output
    -j, --json      Output results as JSON

Examples:
    $0 specs/auth-feature.md src/
    $0 specs/api.md --verbose
    $0 specs/feature.md src/ --json

Exit codes:
    0 - Success
    1 - Invalid arguments
    2 - File not found
    4 - Parsing error
EOF
}

# Parse arguments
SPEC_FILE=""
CODE_DIR="."
VERBOSE=0
JSON_OUTPUT=0

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
        *)
            if [[ -z "$SPEC_FILE" ]]; then
                SPEC_FILE="$1"
            elif [[ -z "$CODE_DIR" ]] || [[ "$CODE_DIR" == "." ]]; then
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

# Validate arguments
if [[ -z "$SPEC_FILE" ]]; then
    echo "Error: spec-file is required" >&2
    usage
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "Error: Spec file not found: $SPEC_FILE" >&2
    exit 2
fi

if [[ ! -d "$CODE_DIR" ]]; then
    echo "Error: Code directory not found: $CODE_DIR" >&2
    exit 2
fi

# Extract requirements from spec file
extract_requirements() {
    local spec_file="$1"
    local requirements=()

    # Look for common requirement patterns:
    # - [ ] Task item
    # - TODO: Description
    # - ### Feature Name
    # - **Requirement:** Description

    # Extract checkbox items
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]\[[[:space:]xX]?\][[:space:]](.+)$ ]]; then
            requirements+=("${BASH_REMATCH[1]}")
        fi
    done < "$spec_file"

    # Extract TODO items
    while IFS= read -r line; do
        if [[ "$line" =~ TODO:[[:space:]](.+)$ ]]; then
            requirements+=("${BASH_REMATCH[1]}")
        fi
    done < "$spec_file"

    # Extract feature headings (### level)
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]](.+)$ ]]; then
            requirements+=("${BASH_REMATCH[1]}")
        fi
    done < "$spec_file"

    printf '%s\n' "${requirements[@]}"
}

# Search for implementation evidence
search_implementation() {
    local requirement="$1"
    local code_dir="$2"

    # Extract keywords from requirement (remove common words)
    local keywords=$(echo "$requirement" | \
        sed 's/[^a-zA-Z0-9 ]/ /g' | \
        tr '[:upper:]' '[:lower:]' | \
        grep -oE '\w{4,}' | \
        grep -vE '^(the|and|for|with|that|this|from|have|will|should|must|can|need)$' | \
        head -5)

    if [[ -z "$keywords" ]]; then
        return 1
    fi

    # Search for keywords in code
    local found_files=()
    for keyword in $keywords; do
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                found_files+=("$file")
            fi
        done < <(grep -ril "$keyword" "$code_dir" 2>/dev/null | head -3)
    done

    if [[ ${#found_files[@]} -gt 0 ]]; then
        # Remove duplicates and print
        printf '%s\n' "${found_files[@]}" | sort -u
        return 0
    else
        return 1
    fi
}

# Check if requirement is marked complete in spec
is_marked_complete() {
    local spec_file="$1"
    local requirement="$2"

    # Look for [x] or [X] checkbox
    if grep -q "^\s*-\s*\[[xX]\]\s*${requirement}" "$spec_file"; then
        return 0
    else
        return 1
    fi
}

# Main comparison logic
compare() {
    local spec_file="$1"
    local code_dir="$2"

    local total=0
    local implemented=0
    local pending=0

    local implemented_list=()
    local pending_list=()

    # Extract requirements
    local requirements
    mapfile -t requirements < <(extract_requirements "$spec_file")

    if [[ ${#requirements[@]} -eq 0 ]]; then
        echo "Warning: No requirements found in spec file" >&2
        exit 0
    fi

    total=${#requirements[@]}

    # Check each requirement
    for requirement in "${requirements[@]}"; do
        if [[ -z "$requirement" ]]; then
            continue
        fi

        local is_complete=0
        local found_files=""

        # Check if marked complete in spec
        if is_marked_complete "$spec_file" "$requirement"; then
            is_complete=1
        else
            # Search for implementation
            if found_files=$(search_implementation "$requirement" "$code_dir" 2>/dev/null); then
                is_complete=1
            fi
        fi

        if [[ $is_complete -eq 1 ]]; then
            implemented=$((implemented + 1))
            implemented_list+=("$requirement|$found_files")
        else
            pending=$((pending + 1))
            pending_list+=("$requirement")
        fi
    done

    # Calculate coverage percentage
    local coverage=0
    if [[ $total -gt 0 ]]; then
        coverage=$((implemented * 100 / total))
    fi

    # Output results
    if [[ $JSON_OUTPUT -eq 1 ]]; then
        # JSON output
        echo "{"
        echo "  \"spec_file\": \"$spec_file\","
        echo "  \"code_directory\": \"$code_dir\","
        echo "  \"total_requirements\": $total,"
        echo "  \"implemented\": $implemented,"
        echo "  \"pending\": $pending,"
        echo "  \"coverage_percentage\": $coverage,"
        echo "  \"implemented_items\": ["
        local first=1
        for item in "${implemented_list[@]}"; do
            local req="${item%%|*}"
            local files="${item#*|}"
            [[ $first -eq 0 ]] && echo ","
            echo -n "    {\"requirement\": \"$req\", \"files\": ["
            if [[ -n "$files" ]]; then
                echo -n "\"$(echo "$files" | head -1)\""
            fi
            echo -n "]}"
            first=0
        done
        echo
        echo "  ],"
        echo "  \"pending_items\": ["
        first=1
        for item in "${pending_list[@]}"; do
            [[ $first -eq 0 ]] && echo ","
            echo -n "    \"$item\""
            first=0
        done
        echo
        echo "  ]"
        echo "}"
    else
        # Human-readable output
        echo -e "${BLUE}=== Spec vs Code Comparison ===${NC}"
        echo
        echo -e "${BLUE}Spec File:${NC} $spec_file"
        echo -e "${BLUE}Code Directory:${NC} $code_dir"
        echo
        echo -e "${BLUE}Summary:${NC}"
        echo "  Total Requirements: $total"
        echo -e "  ${GREEN}Implemented: $implemented${NC}"
        echo -e "  ${YELLOW}Pending: $pending${NC}"
        echo -e "  ${BLUE}Coverage: $coverage%${NC}"
        echo

        if [[ $implemented -gt 0 ]]; then
            echo -e "${GREEN}=== Implemented Features ===${NC}"
            for item in "${implemented_list[@]}"; do
                local req="${item%%|*}"
                local files="${item#*|}"
                echo -e "  ${GREEN}✓${NC} $req"
                if [[ $VERBOSE -eq 1 ]] && [[ -n "$files" ]]; then
                    echo "    Found in: $(echo "$files" | head -1)"
                fi
            done
            echo
        fi

        if [[ $pending -gt 0 ]]; then
            echo -e "${YELLOW}=== Pending Features ===${NC}"
            for item in "${pending_list[@]}"; do
                echo -e "  ${YELLOW}○${NC} $item"
            done
            echo
        fi

        # Coverage assessment
        if [[ $coverage -ge 80 ]]; then
            echo -e "${GREEN}✓ High coverage - spec is mostly implemented${NC}"
        elif [[ $coverage -ge 50 ]]; then
            echo -e "${YELLOW}⚠ Moderate coverage - some features pending${NC}"
        else
            echo -e "${RED}✗ Low coverage - most features not yet implemented${NC}"
        fi
    fi
}

# Run comparison
compare "$SPEC_FILE" "$CODE_DIR"
