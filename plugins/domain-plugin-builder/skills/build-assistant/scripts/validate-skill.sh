#!/usr/bin/env bash
# Script: validate-skill.sh
# Purpose: Validate Agent Skill directory compliance with Claude Code standards
# Subsystem: build-system
# Called by: /build:skill command after generation
# Outputs: Validation report to stdout

set -euo pipefail

SKILL_DIR="${1:?Usage: $0 <skill-directory>}"

echo "[INFO] Validating skill directory: $SKILL_DIR"

# Check directory exists
if [[ ! -d "$SKILL_DIR" ]]; then
    echo "❌ ERROR: Directory not found: $SKILL_DIR"
    exit 1
fi

# Check SKILL.md exists
if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
    echo "❌ ERROR: Missing SKILL.md file"
    exit 1
fi

# Check frontmatter exists
if ! grep -q "^---$" "$SKILL_DIR/SKILL.md"; then
    echo "❌ ERROR: Missing frontmatter in SKILL.md"
    exit 1
fi

# Check required frontmatter fields
REQUIRED_FIELDS=("name:" "description:")
for field in "${REQUIRED_FIELDS[@]}"; do
    if ! grep -q "^$field" "$SKILL_DIR/SKILL.md"; then
        echo "❌ ERROR: Missing required field: $field"
        exit 1
    fi
done

# Check description includes trigger keywords
if ! grep -q "Use when" "$SKILL_DIR/SKILL.md"; then
    echo "⚠️  WARNING: Description should include 'Use when' trigger context"
fi

echo "✅ Skill validation passed"
exit 0
