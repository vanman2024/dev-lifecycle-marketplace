#!/usr/bin/env bash
# Script: scaffold-{{THING}}.sh
# Purpose: Scaffold {{THING}} structure - mechanical creation (NO AI needed)
# Plugin: {{PLUGIN_NAME}}
# Skill: {{SKILL_NAME}}
# Usage: ./scaffold-{{THING}}.sh <name> [options]

set -euo pipefail

# Configuration
NAME="${1:-}"
OUTPUT_DIR="${2:-./}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate inputs
if [[ -z "$NAME" ]]; then
    echo "Usage: $0 <name> [output-directory]"
    echo ""
    echo "Example: $0 my-project ./projects"
    exit 1
fi

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

TARGET_DIR="$OUTPUT_DIR/$NAME"

# Check if already exists
if [[ -d "$TARGET_DIR" ]]; then
    echo "ERROR: Directory already exists: $TARGET_DIR"
    exit 1
fi

echo -e "${YELLOW}[INFO] Scaffolding $NAME structure...${NC}"

# ============================================
# CREATE DIRECTORY STRUCTURE
# ============================================

# TODO: Add your directory structure here
# Example:

# mkdir -p "$TARGET_DIR/src"
# mkdir -p "$TARGET_DIR/tests"
# mkdir -p "$TARGET_DIR/docs"
# mkdir -p "$TARGET_DIR/scripts"
# mkdir -p "$TARGET_DIR/config"

# ============================================
# CREATE BOILERPLATE FILES
# ============================================

# TODO: Add your boilerplate files here
# Example:

# # Create README
# cat > "$TARGET_DIR/README.md" << 'EOF'
# # {{NAME}}
#
# Description here
#
# ## Setup
#
# Installation instructions
# EOF

# # Create .gitignore
# cat > "$TARGET_DIR/.gitignore" << 'EOF'
# node_modules/
# .env
# *.pyc
# __pycache__/
# EOF

# # Create main entry point
# touch "$TARGET_DIR/src/main.py"

# ============================================
# REPORT RESULTS
# ============================================

echo -e "${GREEN}✅ Scaffolded: $TARGET_DIR${NC}"
echo ""
echo "Structure created:"
tree -L 2 "$TARGET_DIR" 2>/dev/null || find "$TARGET_DIR" -maxdepth 2 -type d

echo ""
echo "Next steps:"
echo "  cd $TARGET_DIR"
echo "  # Continue with development"

exit 0
