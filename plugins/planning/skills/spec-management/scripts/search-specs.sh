#!/usr/bin/env bash
# search-specs.sh - Search specification content with context
# Usage: search-specs.sh <query> [--section SECTION]

set -euo pipefail

# Configuration
SPECS_DIR="${SPECS_DIR:-./specs}"
CONTEXT_LINES=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Helper functions
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Show usage
show_usage() {
    cat <<EOF
Usage: search-specs.sh <query> [OPTIONS]

Searches specification content with context.

Arguments:
  query         Search query (supports regex)

Options:
  -d, --dir DIR         Specs directory (default: ./specs)
  -s, --section SECTION Filter by section (e.g., "Requirements", "Task Breakdown")
  -t, --tag TAG         Filter specs by tag
  -S, --status STATUS   Filter specs by status
  -p, --priority PRIO   Filter specs by priority
  -C, --context N       Number of context lines (default: 2)
  -i, --ignore-case     Case-insensitive search
  -w, --word            Match whole words only
  -c, --count           Only show count of matches
  -h, --help            Show this help message

Examples:
  search-specs.sh "authentication"
  search-specs.sh "API" --section "Requirements"
  search-specs.sh --tag security "oauth"
  search-specs.sh --status draft --ignore-case "todo"
  search-specs.sh --count "database"

Environment Variables:
  SPECS_DIR             Directory for specifications (default: ./specs)
EOF
}

# Parse arguments
QUERY=""
SECTION_FILTER=""
TAG_FILTER=""
STATUS_FILTER=""
PRIORITY_FILTER=""
IGNORE_CASE=false
WORD_MATCH=false
COUNT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            SPECS_DIR="$2"
            shift 2
            ;;
        -s|--section)
            SECTION_FILTER="$2"
            shift 2
            ;;
        -t|--tag)
            TAG_FILTER="$2"
            shift 2
            ;;
        -S|--status)
            STATUS_FILTER="$2"
            shift 2
            ;;
        -p|--priority)
            PRIORITY_FILTER="$2"
            shift 2
            ;;
        -C|--context)
            CONTEXT_LINES="$2"
            shift 2
            ;;
        -i|--ignore-case)
            IGNORE_CASE=true
            shift
            ;;
        -w|--word)
            WORD_MATCH=true
            shift
            ;;
        -c|--count)
            COUNT_ONLY=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            if [[ -z "$QUERY" ]]; then
                QUERY="$1"
            else
                log_error "Unknown option: $1"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$QUERY" ]]; then
    log_error "Search query is required"
    show_usage
    exit 1
fi

# Check if specs directory exists
if [[ ! -d "$SPECS_DIR" ]]; then
    log_error "Specs directory not found: $SPECS_DIR"
    exit 1
fi

# Find all spec files
SPEC_FILES=$(find "$SPECS_DIR" -maxdepth 1 -name "[0-9][0-9][0-9]-*.md" | sort)

if [[ -z "$SPEC_FILES" ]]; then
    log_error "No specifications found in $SPECS_DIR"
    exit 1
fi

# Build grep options
GREP_OPTS="-n"
if [[ "$IGNORE_CASE" == "true" ]]; then
    GREP_OPTS="$GREP_OPTS -i"
fi
if [[ "$WORD_MATCH" == "true" ]]; then
    GREP_OPTS="$GREP_OPTS -w"
fi

# Search results
TOTAL_MATCHES=0
SPECS_WITH_MATCHES=0

# Process each spec file
while IFS= read -r spec_file; do
    if [[ ! -f "$spec_file" ]]; then
        continue
    fi

    # Apply metadata filters
    if [[ -n "$TAG_FILTER" ]]; then
        tags=$(grep -m1 "^tags:" "$spec_file" | sed 's/tags: *//' | xargs || echo "[]")
        if [[ ! "$tags" =~ $TAG_FILTER ]]; then
            continue
        fi
    fi

    if [[ -n "$STATUS_FILTER" ]]; then
        status=$(grep -m1 "^status:" "$spec_file" | sed 's/status: *//' | xargs || echo "")
        if [[ "$status" != "$STATUS_FILTER" ]]; then
            continue
        fi
    fi

    if [[ -n "$PRIORITY_FILTER" ]]; then
        priority=$(grep -m1 "^priority:" "$spec_file" | sed 's/priority: *//' | xargs || echo "")
        if [[ "$priority" != "$PRIORITY_FILTER" ]]; then
            continue
        fi
    fi

    # Get spec title
    SPEC_TITLE=$(grep -m1 "^title:" "$spec_file" | sed 's/title: *//' | xargs || echo "Unknown")
    SPEC_ID=$(grep -m1 "^spec-id:" "$spec_file" | sed 's/spec-id: *//' | xargs || echo "000")

    # Extract section if specified
    SEARCH_CONTENT="$spec_file"
    TEMP_FILE=""

    if [[ -n "$SECTION_FILTER" ]]; then
        TEMP_FILE=$(mktemp)
        # Extract section content
        sed -n "/^## $SECTION_FILTER/,/^## /p" "$spec_file" > "$TEMP_FILE"
        SEARCH_CONTENT="$TEMP_FILE"
    fi

    # Search in spec
    if [[ "$COUNT_ONLY" == "true" ]]; then
        MATCH_COUNT=$(grep -c $GREP_OPTS "$QUERY" "$SEARCH_CONTENT" 2>/dev/null || echo "0")
        if [[ $MATCH_COUNT -gt 0 ]]; then
            echo -e "${CYAN}[$SPEC_ID]${NC} ${MAGENTA}$SPEC_TITLE${NC}: $MATCH_COUNT match(es)"
            ((TOTAL_MATCHES += MATCH_COUNT))
            ((SPECS_WITH_MATCHES++))
        fi
    else
        # Check if there are matches
        if grep -q $GREP_OPTS "$QUERY" "$SEARCH_CONTENT" 2>/dev/null; then
            ((SPECS_WITH_MATCHES++))

            # Print spec header
            echo ""
            echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║${NC} Spec: ${MAGENTA}[$SPEC_ID] $SPEC_TITLE${NC}"
            echo -e "${CYAN}║${NC} File: $(basename "$spec_file")"
            if [[ -n "$SECTION_FILTER" ]]; then
                echo -e "${CYAN}║${NC} Section: $SECTION_FILTER"
            fi
            echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"

            # Show matches with context
            while IFS= read -r match_line; do
                LINE_NUM=$(echo "$match_line" | cut -d: -f1)
                CONTENT=$(echo "$match_line" | cut -d: -f2-)

                # Highlight match in content
                if [[ "$IGNORE_CASE" == "true" ]]; then
                    HIGHLIGHTED=$(echo "$CONTENT" | sed "s/$QUERY/${GREEN}&${NC}/gi")
                else
                    HIGHLIGHTED=$(echo "$CONTENT" | sed "s/$QUERY/${GREEN}&${NC}/g")
                fi

                echo -e "${YELLOW}Line $LINE_NUM:${NC} $HIGHLIGHTED"

                # Show context lines
                if [[ $CONTEXT_LINES -gt 0 && -n "$SECTION_FILTER" ]]; then
                    # Context for section content
                    START_LINE=$((LINE_NUM - CONTEXT_LINES))
                    END_LINE=$((LINE_NUM + CONTEXT_LINES))
                    if [[ $START_LINE -lt 1 ]]; then
                        START_LINE=1
                    fi

                    sed -n "${START_LINE},$((LINE_NUM - 1))p" "$SEARCH_CONTENT" | while IFS= read -r ctx_line; do
                        echo -e "  ${NC}$ctx_line${NC}"
                    done

                    sed -n "$((LINE_NUM + 1)),${END_LINE}p" "$SEARCH_CONTENT" | while IFS= read -r ctx_line; do
                        echo -e "  ${NC}$ctx_line${NC}"
                    done
                fi

                ((TOTAL_MATCHES++))
            done < <(grep $GREP_OPTS "$QUERY" "$SEARCH_CONTENT" 2>/dev/null || true)
        fi
    fi

    # Cleanup temp file
    if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
done <<< "$SPEC_FILES"

# Print summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
if [[ $SPECS_WITH_MATCHES -eq 0 ]]; then
    log_error "No matches found for query: $QUERY"
    exit 1
else
    log_success "Found $TOTAL_MATCHES match(es) in $SPECS_WITH_MATCHES spec(s)"
fi
