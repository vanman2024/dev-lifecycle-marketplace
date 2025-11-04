#!/bin/bash
#
# Generate GitHub Actions Workflow from Template
#
# Usage: ./generate-workflow.sh <platform> <output-path>
#
# Exit Codes:
#   0 - Workflow generated successfully
#   1 - Generation failed

set -e

PLATFORM="$1"
OUTPUT_PATH="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Validate inputs
if [[ -z "$PLATFORM" ]] || [[ -z "$OUTPUT_PATH" ]]; then
    log_error "Usage: $0 <platform> <output-path>"
    exit 1
fi

# Template file path
TEMPLATE_FILE="$SCRIPT_DIR/../templates/${PLATFORM}-workflow.yml"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    log_error "Template not found: $TEMPLATE_FILE"
    echo "Available templates:"
    ls -1 "$SCRIPT_DIR/../templates/" | grep "workflow.yml"
    exit 1
fi

# Create output directory if needed
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
    log_info "Created directory: $OUTPUT_DIR"
fi

# Copy template to output path
cp "$TEMPLATE_FILE" "$OUTPUT_PATH"
log_info "Generated workflow: $OUTPUT_PATH"
log_info "Template: $TEMPLATE_FILE"

exit 0
