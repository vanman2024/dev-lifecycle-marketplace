#!/bin/bash
# generate-project-json.sh - Master script to generate complete .claude/project.json
# Usage: ./generate-project-json.sh <project-path>

set -euo pipefail

PROJECT_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Project Detection & Analysis ===${NC}"
echo -e "${YELLOW}Project Path: $PROJECT_PATH${NC}"
echo ""

# Step 1: Detect frameworks
echo -e "${GREEN}[1/5] Detecting frameworks...${NC}"
FRAMEWORKS_JSON=$(bash "$SCRIPT_DIR/detect-frameworks.sh" "$PROJECT_PATH" 2>/dev/null || echo '{"detected_frameworks":[],"count":0}')
FRAMEWORK_COUNT=$(echo "$FRAMEWORKS_JSON" | grep -o '"count"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: //')
echo -e "  Found $FRAMEWORK_COUNT frameworks"

# Step 2: Detect dependencies
echo -e "${GREEN}[2/5] Analyzing dependencies...${NC}"
DEPS_JSON=$(bash "$SCRIPT_DIR/detect-dependencies.sh" "$PROJECT_PATH" 2>/dev/null || echo '{"dependencies":[],"count":0}')
DEPS_COUNT=$(echo "$DEPS_JSON" | grep -o '"count"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: //')
echo -e "  Found $DEPS_COUNT dependencies"

# Step 3: Detect AI stack
echo -e "${GREEN}[3/5] Discovering AI stack...${NC}"
AI_JSON=$(bash "$SCRIPT_DIR/detect-ai-stack.sh" "$PROJECT_PATH" 2>/dev/null || echo '{"ai_stack":[],"count":0}')
AI_COUNT=$(echo "$AI_JSON" | grep -o '"count"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: //')
echo -e "  Found $AI_COUNT AI components"

# Step 4: Detect databases
echo -e "${GREEN}[4/5] Detecting databases...${NC}"
DB_JSON=$(bash "$SCRIPT_DIR/detect-database.sh" "$PROJECT_PATH" 2>/dev/null || echo '{"databases":[],"count":0}')
DB_COUNT=$(echo "$DB_JSON" | grep -o '"count"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: //')
echo -e "  Found $DB_COUNT database components"

# Step 5: Determine primary language
echo -e "${GREEN}[5/5] Detecting primary language...${NC}"
PRIMARY_LANG="unknown"

if [[ -f "$PROJECT_PATH/package.json" ]]; then
    if [[ -f "$PROJECT_PATH/tsconfig.json" ]]; then
        PRIMARY_LANG="typescript"
    else
        PRIMARY_LANG="javascript"
    fi
elif [[ -f "$PROJECT_PATH/requirements.txt" ]] || [[ -f "$PROJECT_PATH/setup.py" ]]; then
    PRIMARY_LANG="python"
elif [[ -f "$PROJECT_PATH/go.mod" ]]; then
    PRIMARY_LANG="go"
elif [[ -f "$PROJECT_PATH/Cargo.toml" ]]; then
    PRIMARY_LANG="rust"
elif [[ -f "$PROJECT_PATH/Gemfile" ]]; then
    PRIMARY_LANG="ruby"
elif [[ -f "$PROJECT_PATH/composer.json" ]]; then
    PRIMARY_LANG="php"
elif [[ -f "$PROJECT_PATH/pom.xml" ]]; then
    PRIMARY_LANG="java"
elif [[ -f "$PROJECT_PATH/build.gradle" ]]; then
    PRIMARY_LANG="kotlin"
fi

echo -e "  Primary language: $PRIMARY_LANG"

# Detect build tools
BUILD_TOOLS=()
if [[ -f "$PROJECT_PATH/vite.config.js" ]] || [[ -f "$PROJECT_PATH/vite.config.ts" ]]; then
    BUILD_TOOLS+=("vite")
fi
if [[ -f "$PROJECT_PATH/webpack.config.js" ]]; then
    BUILD_TOOLS+=("webpack")
fi
if [[ -f "$PROJECT_PATH/turbo.json" ]]; then
    BUILD_TOOLS+=("turborepo")
fi
if [[ -f "$PROJECT_PATH/nx.json" ]]; then
    BUILD_TOOLS+=("nx")
fi

# Detect test frameworks
TEST_FRAMEWORKS=()
if [[ -f "$PROJECT_PATH/package.json" ]]; then
    if grep -q '"jest"' "$PROJECT_PATH/package.json"; then
        TEST_FRAMEWORKS+=("jest")
    fi
    if grep -q '"vitest"' "$PROJECT_PATH/package.json"; then
        TEST_FRAMEWORKS+=("vitest")
    fi
    if grep -q '"@playwright/test"' "$PROJECT_PATH/package.json"; then
        TEST_FRAMEWORKS+=("playwright")
    fi
    if grep -q '"cypress"' "$PROJECT_PATH/package.json"; then
        TEST_FRAMEWORKS+=("cypress")
    fi
fi

if [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
    if grep -qi "pytest" "$PROJECT_PATH/requirements.txt"; then
        TEST_FRAMEWORKS+=("pytest")
    fi
fi

# Detect package manager
PACKAGE_MANAGER="unknown"
if [[ -f "$PROJECT_PATH/pnpm-lock.yaml" ]]; then
    PACKAGE_MANAGER="pnpm"
elif [[ -f "$PROJECT_PATH/yarn.lock" ]]; then
    PACKAGE_MANAGER="yarn"
elif [[ -f "$PROJECT_PATH/package-lock.json" ]]; then
    PACKAGE_MANAGER="npm"
elif [[ -f "$PROJECT_PATH/bun.lockb" ]]; then
    PACKAGE_MANAGER="bun"
fi

# Create .claude directory if it doesn't exist
mkdir -p "$PROJECT_PATH/.claude"

# Generate project.json
OUTPUT_FILE="$PROJECT_PATH/.claude/project.json"

echo ""
echo -e "${BLUE}=== Generating $OUTPUT_FILE ===${NC}"

# Build JSON (properly formatted)
cat > "$OUTPUT_FILE" <<EOF
{
  "name": "$(basename "$PROJECT_PATH")",
  "version": "1.0.0",
  "description": "Auto-detected project configuration",
  "language": "$PRIMARY_LANG",
  "package_manager": "$PACKAGE_MANAGER",
  "frameworks": $(echo "$FRAMEWORKS_JSON" | grep -A 1000 '"detected_frameworks"' | grep -B 1000 ']' | head -n -1 | tail -n +2),
  "dependencies": {
    "production": $(echo "$DEPS_JSON" | grep -A 1000 '"dependencies"' | grep -B 1000 ']' | head -n -1 | tail -n +2 | grep '"type":"production"' || echo "[]"),
    "development": $(echo "$DEPS_JSON" | grep -A 1000 '"dependencies"' | grep -B 1000 ']' | head -n -1 | tail -n +2 | grep '"type":"development"' || echo "[]"),
    "all": $(echo "$DEPS_JSON" | grep -A 1000 '"dependencies"' | grep -B 1000 ']' | head -n -1 | tail -n +2)
  },
  "ai_stack": $(echo "$AI_JSON" | grep -A 1000 '"ai_stack"' | grep -B 1000 ']' | head -n -1 | tail -n +2),
  "databases": $(echo "$DB_JSON" | grep -A 1000 '"databases"' | grep -B 1000 ']' | head -n -1 | tail -n +2),
  "build_tools": [$(IFS=,; echo "${BUILD_TOOLS[*]}" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/') ],
  "test_frameworks": [$(IFS=,; echo "${TEST_FRAMEWORKS[*]}" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/') ],
  "metadata": {
    "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "detection_version": "1.0.0",
    "project_path": "$PROJECT_PATH"
  }
}
EOF

echo -e "${GREEN}Successfully generated: $OUTPUT_FILE${NC}"
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "  Language:         $PRIMARY_LANG"
echo -e "  Package Manager:  $PACKAGE_MANAGER"
echo -e "  Frameworks:       $FRAMEWORK_COUNT"
echo -e "  Dependencies:     $DEPS_COUNT"
echo -e "  AI Stack:         $AI_COUNT components"
echo -e "  Databases:        $DB_COUNT components"
echo -e "  Build Tools:      ${#BUILD_TOOLS[@]}"
echo -e "  Test Frameworks:  ${#TEST_FRAMEWORKS[@]}"
echo ""

# Validate JSON
if command -v jq &> /dev/null; then
    if jq empty "$OUTPUT_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ Generated JSON is valid${NC}"
    else
        echo -e "${RED}✗ Generated JSON is invalid${NC}" >&2
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ jq not installed, skipping JSON validation${NC}"
fi

echo -e "${GREEN}Project detection complete!${NC}"
