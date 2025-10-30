#!/usr/bin/env bash
# create-spec.sh - Create new numbered specification with template
# Usage: create-spec.sh <spec-name> [description]

set -euo pipefail

# Configuration
SPECS_DIR="${SPECS_DIR:-./specs}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
TEMPLATE_FILE="${TEMPLATE_DIR}/spec-template.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    cat <<EOF
Usage: create-spec.sh <spec-name> [description]

Creates a new numbered specification from template.

Arguments:
  spec-name     Name of the specification (will be slugified)
  description   Optional short description (default: empty)

Options:
  -d, --dir DIR     Specs directory (default: ./specs)
  -p, --priority P  Priority: low, medium, high, critical (default: medium)
  -o, --owner O     Spec owner (default: current user)
  -t, --tags T      Comma-separated tags (default: none)
  -h, --help        Show this help message

Examples:
  create-spec.sh user-authentication
  create-spec.sh api-rate-limiting "Add rate limiting to API endpoints"
  create-spec.sh --priority high --tags "security,api" oauth-integration

Environment Variables:
  SPECS_DIR         Directory for specifications (default: ./specs)
EOF
}

# Parse arguments
SPEC_NAME=""
DESCRIPTION=""
PRIORITY="medium"
OWNER="${USER:-unknown}"
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            SPECS_DIR="$2"
            shift 2
            ;;
        -p|--priority)
            PRIORITY="$2"
            shift 2
            ;;
        -o|--owner)
            OWNER="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            if [[ -z "$SPEC_NAME" ]]; then
                SPEC_NAME="$1"
            else
                DESCRIPTION="$1"
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$SPEC_NAME" ]]; then
    log_error "Spec name is required"
    show_usage
    exit 1
fi

# Validate priority
if [[ ! "$PRIORITY" =~ ^(low|medium|high|critical)$ ]]; then
    log_error "Invalid priority: $PRIORITY (must be low, medium, high, or critical)"
    exit 1
fi

# Create specs directory if it doesn't exist
mkdir -p "$SPECS_DIR"

# Find next available spec number
NEXT_NUM=1
if [[ -d "$SPECS_DIR" ]]; then
    EXISTING_NUMS=$(find "$SPECS_DIR" -maxdepth 1 -name "[0-9][0-9][0-9]-*.md" 2>/dev/null | sed 's/.*\/\([0-9]\{3\}\)-.*/\1/' | sort -n | tail -1)
    if [[ -n "$EXISTING_NUMS" ]]; then
        NEXT_NUM=$((10#$EXISTING_NUMS + 1))
    fi
fi

# Format spec number with zero padding
SPEC_NUM=$(printf "%03d" "$NEXT_NUM")

# Slugify spec name
SPEC_SLUG=$(echo "$SPEC_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# Create spec filename
SPEC_FILENAME="${SPEC_NUM}-${SPEC_SLUG}.md"
SPEC_PATH="${SPECS_DIR}/${SPEC_FILENAME}"

# Check if spec already exists
if [[ -f "$SPEC_PATH" ]]; then
    log_error "Spec already exists: $SPEC_PATH"
    exit 1
fi

# Check if template exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    log_warning "Template not found: $TEMPLATE_FILE"
    log_info "Creating spec with minimal template"
fi

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Convert tags to YAML array format
TAGS_YAML="[]"
if [[ -n "$TAGS" ]]; then
    TAGS_YAML="["
    IFS=',' read -ra TAG_ARRAY <<< "$TAGS"
    for i in "${!TAG_ARRAY[@]}"; do
        TAG="${TAG_ARRAY[$i]}"
        TAG=$(echo "$TAG" | xargs) # trim whitespace
        if [[ $i -gt 0 ]]; then
            TAGS_YAML+=", "
        fi
        TAGS_YAML+="\"$TAG\""
    done
    TAGS_YAML+="]"
fi

# Create spec from template or minimal template
if [[ -f "$TEMPLATE_FILE" ]]; then
    # Use template and substitute variables
    cp "$TEMPLATE_FILE" "$SPEC_PATH"

    # Replace placeholders
    sed -i "s/{{SPEC_ID}}/$SPEC_NUM/g" "$SPEC_PATH"
    sed -i "s/{{TITLE}}/$SPEC_NAME/g" "$SPEC_PATH"
    sed -i "s/{{STATUS}}/draft/g" "$SPEC_PATH"
    sed -i "s/{{PRIORITY}}/$PRIORITY/g" "$SPEC_PATH"
    sed -i "s/{{OWNER}}/$OWNER/g" "$SPEC_PATH"
    sed -i "s/{{CREATED}}/$CURRENT_DATE/g" "$SPEC_PATH"
    sed -i "s/{{UPDATED}}/$CURRENT_DATE/g" "$SPEC_PATH"
    sed -i "s/{{TAGS}}/$TAGS_YAML/g" "$SPEC_PATH"

    if [[ -n "$DESCRIPTION" ]]; then
        sed -i "s/{{DESCRIPTION}}/$DESCRIPTION/g" "$SPEC_PATH"
    else
        sed -i "s/{{DESCRIPTION}}/Brief description of the feature/g" "$SPEC_PATH"
    fi
else
    # Create minimal spec
    cat > "$SPEC_PATH" <<EOF
---
spec-id: $SPEC_NUM
title: $SPEC_NAME
status: draft
priority: $PRIORITY
owner: $OWNER
created: $CURRENT_DATE
updated: $CURRENT_DATE
tags: $TAGS_YAML
---

# $SPEC_NAME

## Problem Statement

${DESCRIPTION:-Describe the problem this feature solves.}

## Proposed Solution

Describe how this feature will solve the problem.

## Requirements

### Functional Requirements
- Requirement 1
- Requirement 2

### Non-Functional Requirements
- Performance requirement
- Security requirement

## Task Breakdown

1. [ ] Task 1 (estimate: X hours)
2. [ ] Task 2 (estimate: X hours)

## Success Criteria

- [ ] Measurable outcome 1
- [ ] Measurable outcome 2

## Timeline

Estimated completion: TBD
EOF
fi

log_success "Created spec: $SPEC_PATH"
log_info "Spec ID: $SPEC_NUM"
log_info "Status: draft"
log_info "Priority: $PRIORITY"

# Output spec path for scripting
echo "$SPEC_PATH"
