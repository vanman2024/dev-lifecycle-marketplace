#!/usr/bin/env bash
# validate-spec.sh - Validate specification completeness and format
# Usage: validate-spec.sh <spec-file>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

# Helper functions
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((ERRORS++))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    ((WARNINGS++))
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
Usage: validate-spec.sh <spec-file>

Validates specification completeness and format.

Arguments:
  spec-file     Path to specification file to validate

Options:
  -h, --help    Show this help message

Validation Checks:
  - Frontmatter presence and completeness
  - Required sections presence
  - Task breakdown format
  - Requirements categorization
  - Success criteria measurability
  - Date formats
  - Status and priority values

Examples:
  validate-spec.sh specs/001-user-auth.md
  validate-spec.sh --help
EOF
}

# Parse arguments
SPEC_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            SPEC_FILE="$1"
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$SPEC_FILE" ]]; then
    log_error "Spec file is required"
    show_usage
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    log_error "Spec file not found: $SPEC_FILE"
    exit 1
fi

log_info "Validating specification: $(basename "$SPEC_FILE")"
echo ""

# Extract content
CONTENT=$(cat "$SPEC_FILE")
LINE_COUNT=$(wc -l < "$SPEC_FILE")

# Check for frontmatter
if ! echo "$CONTENT" | grep -q "^---$"; then
    log_error "Missing frontmatter (YAML front matter not found)"
else
    log_success "Frontmatter present"
fi

# Validate frontmatter fields
echo ""
log_info "Validating frontmatter fields..."

# Check spec-id
if ! grep -q "^spec-id:" "$SPEC_FILE"; then
    log_error "Missing required field: spec-id"
else
    SPEC_ID=$(grep -m1 "^spec-id:" "$SPEC_FILE" | sed 's/spec-id: *//' | xargs)
    if [[ ! "$SPEC_ID" =~ ^[0-9]+$ ]]; then
        log_error "Invalid spec-id format (must be numeric): $SPEC_ID"
    else
        log_success "Valid spec-id: $SPEC_ID"
    fi
fi

# Check title
if ! grep -q "^title:" "$SPEC_FILE"; then
    log_error "Missing required field: title"
else
    TITLE=$(grep -m1 "^title:" "$SPEC_FILE" | sed 's/title: *//' | xargs)
    if [[ -z "$TITLE" ]]; then
        log_error "Title is empty"
    else
        log_success "Valid title: $TITLE"
    fi
fi

# Check status
if ! grep -q "^status:" "$SPEC_FILE"; then
    log_error "Missing required field: status"
else
    STATUS=$(grep -m1 "^status:" "$SPEC_FILE" | sed 's/status: *//' | xargs)
    if [[ ! "$STATUS" =~ ^(draft|in-progress|review|approved|implemented|rejected)$ ]]; then
        log_error "Invalid status: $STATUS (must be draft, in-progress, review, approved, implemented, or rejected)"
    else
        log_success "Valid status: $STATUS"
    fi
fi

# Check priority
if ! grep -q "^priority:" "$SPEC_FILE"; then
    log_error "Missing required field: priority"
else
    PRIORITY=$(grep -m1 "^priority:" "$SPEC_FILE" | sed 's/priority: *//' | xargs)
    if [[ ! "$PRIORITY" =~ ^(low|medium|high|critical)$ ]]; then
        log_error "Invalid priority: $PRIORITY (must be low, medium, high, or critical)"
    else
        log_success "Valid priority: $PRIORITY"
    fi
fi

# Check owner
if ! grep -q "^owner:" "$SPEC_FILE"; then
    log_error "Missing required field: owner"
else
    OWNER=$(grep -m1 "^owner:" "$SPEC_FILE" | sed 's/owner: *//' | xargs)
    if [[ -z "$OWNER" ]]; then
        log_error "Owner is empty"
    else
        log_success "Valid owner: $OWNER"
    fi
fi

# Check created date
if ! grep -q "^created:" "$SPEC_FILE"; then
    log_error "Missing required field: created"
else
    CREATED=$(grep -m1 "^created:" "$SPEC_FILE" | sed 's/created: *//' | xargs)
    if [[ ! "$CREATED" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        log_error "Invalid created date format: $CREATED (must be YYYY-MM-DD)"
    else
        log_success "Valid created date: $CREATED"
    fi
fi

# Check updated date
if ! grep -q "^updated:" "$SPEC_FILE"; then
    log_error "Missing required field: updated"
else
    UPDATED=$(grep -m1 "^updated:" "$SPEC_FILE" | sed 's/updated: *//' | xargs)
    if [[ ! "$UPDATED" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        log_error "Invalid updated date format: $UPDATED (must be YYYY-MM-DD)"
    else
        log_success "Valid updated date: $UPDATED"

        # Check if spec is outdated
        CURRENT_DATE=$(date +%Y-%m-%d)
        DAYS_OLD=$(( ($(date -d "$CURRENT_DATE" +%s) - $(date -d "$UPDATED" +%s)) / 86400 ))
        if [[ $DAYS_OLD -gt 30 ]]; then
            log_warning "Spec not updated in $DAYS_OLD days (consider reviewing)"
        fi
    fi
fi

# Check tags
if ! grep -q "^tags:" "$SPEC_FILE"; then
    log_warning "Missing optional field: tags"
else
    TAGS=$(grep -m1 "^tags:" "$SPEC_FILE" | sed 's/tags: *//' | xargs)
    if [[ "$TAGS" == "[]" ]]; then
        log_warning "Tags are empty (consider adding relevant tags)"
    else
        log_success "Valid tags: $TAGS"
    fi
fi

# Validate required sections
echo ""
log_info "Validating required sections..."

required_sections=(
    "Problem Statement"
    "Proposed Solution"
    "Requirements"
    "Task Breakdown"
    "Success Criteria"
)

for section in "${required_sections[@]}"; do
    if ! grep -qi "^## $section" "$SPEC_FILE"; then
        log_error "Missing required section: $section"
    else
        # Check if section has content
        SECTION_CONTENT=$(sed -n "/^## $section/,/^## /p" "$SPEC_FILE" | tail -n +2 | head -n -1 | xargs)
        if [[ -z "$SECTION_CONTENT" ]]; then
            log_warning "Section '$section' is empty"
        else
            log_success "Section present: $section"
        fi
    fi
done

# Check optional sections
optional_sections=(
    "Technical Design"
    "Dependencies"
    "Timeline"
    "Risks"
    "Alternatives Considered"
)

for section in "${optional_sections[@]}"; do
    if ! grep -qi "^## $section" "$SPEC_FILE"; then
        log_warning "Missing optional section: $section"
    fi
done

# Validate task breakdown format
echo ""
log_info "Validating task breakdown format..."

if grep -qi "^## Task Breakdown" "$SPEC_FILE"; then
    TASK_SECTION=$(sed -n "/^## Task Breakdown/,/^## /p" "$SPEC_FILE")
    TASK_COUNT=$(echo "$TASK_SECTION" | grep -c "^\s*[0-9]\+\.\s*\[" || true)

    if [[ $TASK_COUNT -eq 0 ]]; then
        log_error "No tasks found in Task Breakdown section (use numbered list with checkboxes)"
    else
        log_success "Found $TASK_COUNT tasks"

        # Check for task estimates
        TASKS_WITH_ESTIMATES=$(echo "$TASK_SECTION" | grep -c "(estimate:" || true)
        if [[ $TASKS_WITH_ESTIMATES -lt $TASK_COUNT ]]; then
            log_warning "$((TASK_COUNT - TASKS_WITH_ESTIMATES)) tasks missing time estimates"
        fi
    fi
fi

# Validate requirements categorization
echo ""
log_info "Validating requirements structure..."

if grep -qi "^## Requirements" "$SPEC_FILE"; then
    if ! grep -qi "^### Functional Requirements" "$SPEC_FILE"; then
        log_warning "Missing Functional Requirements subsection"
    fi
    if ! grep -qi "^### Non-Functional Requirements" "$SPEC_FILE"; then
        log_warning "Missing Non-Functional Requirements subsection"
    fi
fi

# Validate success criteria
echo ""
log_info "Validating success criteria..."

if grep -qi "^## Success Criteria" "$SPEC_FILE"; then
    SUCCESS_SECTION=$(sed -n "/^## Success Criteria/,/^## /p" "$SPEC_FILE")
    CRITERIA_COUNT=$(echo "$SUCCESS_SECTION" | grep -c "^\s*-\s*\[" || true)

    if [[ $CRITERIA_COUNT -eq 0 ]]; then
        log_error "No success criteria found (use checklist format)"
    else
        log_success "Found $CRITERIA_COUNT success criteria"

        # Check for measurable criteria
        VAGUE_KEYWORDS="improve|better|enhance|optimize"
        VAGUE_COUNT=$(echo "$SUCCESS_SECTION" | grep -iEc "$VAGUE_KEYWORDS" || true)
        if [[ $VAGUE_COUNT -gt 0 ]]; then
            log_warning "Some success criteria may be vague (found $VAGUE_COUNT potentially vague terms)"
        fi
    fi
fi

# Check spec length
echo ""
log_info "Checking spec length..."

if [[ $LINE_COUNT -gt 1000 ]]; then
    log_warning "Spec is very long ($LINE_COUNT lines) - consider splitting into multiple specs"
elif [[ $LINE_COUNT -lt 50 ]]; then
    log_warning "Spec is very short ($LINE_COUNT lines) - may need more detail"
else
    log_success "Spec length is reasonable ($LINE_COUNT lines)"
fi

# Final summary
echo ""
echo "=================================="
echo "Validation Summary"
echo "=================================="

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    log_success "All validation checks passed!"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    log_warning "Validation passed with $WARNINGS warning(s)"
    exit 0
else
    log_error "Validation failed with $ERRORS error(s) and $WARNINGS warning(s)"
    exit 1
fi
