#!/bin/bash
# validate-detection.sh - Validates detection accuracy and completeness
# Usage: ./validate-detection.sh <project-path> [project.json-path]

set -euo pipefail

PROJECT_PATH="${1:-.}"
PROJECT_JSON="${2:-$PROJECT_PATH/.claude/project.json}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

VALIDATION_PASSED=true
WARNINGS=0
ERRORS=0

echo -e "${BLUE}=== Project Detection Validation ===${NC}"
echo -e "${YELLOW}Project: $PROJECT_PATH${NC}"
echo -e "${YELLOW}Config: $PROJECT_JSON${NC}"
echo ""

# Check if project.json exists
if [[ ! -f "$PROJECT_JSON" ]]; then
    echo -e "${RED}✗ ERROR: project.json not found at $PROJECT_JSON${NC}"
    echo -e "  Run: ./generate-project-json.sh $PROJECT_PATH"
    exit 1
fi

echo -e "${GREEN}✓ project.json exists${NC}"

# Validate JSON syntax
if command -v jq &> /dev/null; then
    if jq empty "$PROJECT_JSON" 2>/dev/null; then
        echo -e "${GREEN}✓ Valid JSON syntax${NC}"
    else
        echo -e "${RED}✗ Invalid JSON syntax${NC}"
        VALIDATION_PASSED=false
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠ jq not installed, skipping JSON validation${NC}"
    ((WARNINGS++))
fi

# Validate required fields
echo ""
echo -e "${BLUE}Checking required fields...${NC}"

REQUIRED_FIELDS=("name" "language" "frameworks" "dependencies" "ai_stack" "databases" "metadata")

for field in "${REQUIRED_FIELDS[@]}"; do
    if command -v jq &> /dev/null; then
        if jq -e ".$field" "$PROJECT_JSON" >/dev/null 2>&1; then
            echo -e "${GREEN}  ✓ $field${NC}"
        else
            echo -e "${RED}  ✗ $field (missing)${NC}"
            VALIDATION_PASSED=false
            ((ERRORS++))
        fi
    fi
done

# Check for empty detections
echo ""
echo -e "${BLUE}Checking detection completeness...${NC}"

if command -v jq &> /dev/null; then
    FRAMEWORK_COUNT=$(jq '.frameworks | length' "$PROJECT_JSON" 2>/dev/null || echo "0")
    if [[ "$FRAMEWORK_COUNT" -eq 0 ]]; then
        echo -e "${YELLOW}  ⚠ No frameworks detected${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}  ✓ Frameworks: $FRAMEWORK_COUNT${NC}"
    fi

    DEPS_COUNT=$(jq '.dependencies.all | length' "$PROJECT_JSON" 2>/dev/null || echo "0")
    if [[ "$DEPS_COUNT" -eq 0 ]]; then
        echo -e "${YELLOW}  ⚠ No dependencies detected${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}  ✓ Dependencies: $DEPS_COUNT${NC}"
    fi

    AI_COUNT=$(jq '.ai_stack | length' "$PROJECT_JSON" 2>/dev/null || echo "0")
    if [[ "$AI_COUNT" -eq 0 ]]; then
        echo -e "${YELLOW}  ⚠ No AI stack detected${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}  ✓ AI Stack: $AI_COUNT components${NC}"
    fi

    DB_COUNT=$(jq '.databases | length' "$PROJECT_JSON" 2>/dev/null || echo "0")
    if [[ "$DB_COUNT" -eq 0 ]]; then
        echo -e "${YELLOW}  ⚠ No databases detected${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}  ✓ Databases: $DB_COUNT components${NC}"
    fi
fi

# Cross-validate with actual project files
echo ""
echo -e "${BLUE}Cross-validating with project files...${NC}"

# Check if detected language matches actual files
if command -v jq &> /dev/null; then
    DETECTED_LANG=$(jq -r '.language' "$PROJECT_JSON" 2>/dev/null || echo "unknown")

    case "$DETECTED_LANG" in
        typescript|javascript)
            if [[ ! -f "$PROJECT_PATH/package.json" ]]; then
                echo -e "${RED}  ✗ Language is $DETECTED_LANG but package.json not found${NC}"
                ((ERRORS++))
            else
                echo -e "${GREEN}  ✓ Language matches project files${NC}"
            fi
            ;;
        python)
            if [[ ! -f "$PROJECT_PATH/requirements.txt" ]] && [[ ! -f "$PROJECT_PATH/setup.py" ]] && [[ ! -f "$PROJECT_PATH/pyproject.toml" ]]; then
                echo -e "${RED}  ✗ Language is Python but no Python package files found${NC}"
                ((ERRORS++))
            else
                echo -e "${GREEN}  ✓ Language matches project files${NC}"
            fi
            ;;
        go)
            if [[ ! -f "$PROJECT_PATH/go.mod" ]]; then
                echo -e "${RED}  ✗ Language is Go but go.mod not found${NC}"
                ((ERRORS++))
            else
                echo -e "${GREEN}  ✓ Language matches project files${NC}"
            fi
            ;;
        rust)
            if [[ ! -f "$PROJECT_PATH/Cargo.toml" ]]; then
                echo -e "${RED}  ✗ Language is Rust but Cargo.toml not found${NC}"
                ((ERRORS++))
            else
                echo -e "${GREEN}  ✓ Language matches project files${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}  ⚠ Unable to validate language: $DETECTED_LANG${NC}"
            ((WARNINGS++))
            ;;
    esac
fi

# Check for common misdetections
echo ""
echo -e "${BLUE}Checking for common issues...${NC}"

# Check if Next.js detected but next.config missing
if command -v jq &> /dev/null; then
    if jq -e '.frameworks[] | select(.name == "Next.js")' "$PROJECT_JSON" >/dev/null 2>&1; then
        if [[ ! -f "$PROJECT_PATH/next.config.js" ]] && [[ ! -f "$PROJECT_PATH/next.config.ts" ]] && [[ ! -f "$PROJECT_PATH/next.config.mjs" ]]; then
            echo -e "${YELLOW}  ⚠ Next.js detected but no next.config file found${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}  ✓ Next.js detection validated${NC}"
        fi
    fi

    # Check if Prisma detected but schema missing
    if jq -e '.databases[] | select(.name == "Prisma")' "$PROJECT_JSON" >/dev/null 2>&1; then
        if [[ ! -f "$PROJECT_PATH/prisma/schema.prisma" ]]; then
            echo -e "${YELLOW}  ⚠ Prisma detected but schema.prisma not found${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}  ✓ Prisma detection validated${NC}"
        fi
    fi

    # Check if Supabase detected but config missing
    if jq -e '.databases[] | select(.name == "Supabase")' "$PROJECT_JSON" >/dev/null 2>&1; then
        if [[ ! -f "$PROJECT_PATH/.env" ]] || ! grep -q "SUPABASE" "$PROJECT_PATH/.env" 2>/dev/null; then
            echo -e "${YELLOW}  ⚠ Supabase detected but no SUPABASE env vars found${NC}"
            ((WARNINGS++))
        fi
    fi
fi

# Summary
echo ""
echo -e "${BLUE}=== Validation Summary ===${NC}"

if [[ "$ERRORS" -eq 0 ]] && [[ "$WARNINGS" -eq 0 ]]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo -e "${GREEN}  No errors, no warnings${NC}"
    exit 0
elif [[ "$ERRORS" -eq 0 ]]; then
    echo -e "${YELLOW}⚠ Validation passed with warnings${NC}"
    echo -e "${YELLOW}  Warnings: $WARNINGS${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed${NC}"
    echo -e "${RED}  Errors: $ERRORS${NC}"
    echo -e "${YELLOW}  Warnings: $WARNINGS${NC}"
    exit 1
fi
