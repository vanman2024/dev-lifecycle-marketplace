#!/usr/bin/env bash
# Script: scaffold-mcp-server.sh
# Purpose: Scaffold MCP server directory structure - mechanical creation (NO AI needed)
# Plugin: develop
# Skill: mcp-development
# Usage: ./scaffold-mcp-server.sh <server-name> [output-dir]

set -euo pipefail

# Configuration
SERVER_NAME="${1:-}"
OUTPUT_DIR="${2:-./servers/http}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate inputs
if [[ -z "$SERVER_NAME" ]]; then
    echo "Usage: $0 <server-name> [output-directory]"
    echo ""
    echo "Example: $0 my-api ./servers/http"
    echo "Creates: ./servers/http/my-api-http-mcp/"
    exit 1
fi

# Normalize server name
NORMALIZED_NAME=$(echo "$SERVER_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
TARGET_DIR="$OUTPUT_DIR/${NORMALIZED_NAME}-http-mcp"

# Check if already exists
if [[ -d "$TARGET_DIR" ]]; then
    echo "ERROR: Directory already exists: $TARGET_DIR"
    exit 1
fi

echo -e "${YELLOW}[INFO] Scaffolding MCP server: $NORMALIZED_NAME${NC}"

# ============================================
# CREATE DIRECTORY STRUCTURE
# ============================================

mkdir -p "$TARGET_DIR/src"
mkdir -p "$TARGET_DIR/tests"
mkdir -p "$TARGET_DIR/docs"

# ============================================
# CREATE BOILERPLATE FILES (EMPTY/MINIMAL)
# ============================================

# Create empty server.py (structure only)
cat > "$TARGET_DIR/src/server.py" << 'EOF'
#!/usr/bin/env python3
"""
MCP Server (to be implemented)
"""
import os
import logging
from fastmcp import FastMCP

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize server
mcp = FastMCP("Server Name")

# TODO: Add tools, resources, prompts

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8030"))
    mcp.run(transport="streamable-http", host="0.0.0.0", port=port, path="/")
EOF

# Create requirements.txt
cat > "$TARGET_DIR/requirements.txt" << 'EOF'
fastmcp>=0.2.0
EOF

# Create .gitignore
cat > "$TARGET_DIR/.gitignore" << 'EOF'
__pycache__/
*.pyc
.env
.venv/
venv/
*.egg-info/
dist/
build/
EOF

# Create empty README.md
cat > "$TARGET_DIR/README.md" << EOF
# ${NORMALIZED_NAME} MCP Server

## Description

TODO: Add description

## Setup

\`\`\`bash
pip install -r requirements.txt
\`\`\`

## Usage

\`\`\`bash
python src/server.py
\`\`\`

## Tools

TODO: Document tools

## Resources

TODO: Document resources
EOF

# Create .env.example
cat > "$TARGET_DIR/.env.example" << 'EOF'
PORT=8030
# Add other environment variables here
EOF

# Create empty __init__.py
touch "$TARGET_DIR/src/__init__.py"

# ============================================
# REPORT RESULTS
# ============================================

echo -e "${GREEN}✅ Scaffolded: $TARGET_DIR${NC}"
echo ""
echo "Structure created:"
tree -L 2 "$TARGET_DIR" 2>/dev/null || find "$TARGET_DIR" -maxdepth 2

echo ""
echo "Files created:"
echo "  ✅ src/server.py (minimal boilerplate)"
echo "  ✅ requirements.txt"
echo "  ✅ README.md"
echo "  ✅ .gitignore"
echo "  ✅ .env.example"

echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Implement tools, resources, prompts in src/server.py"
echo "  3. Run: python src/server.py"
echo "  4. Validate: bash skills/mcp-development/scripts/validate-server.sh $TARGET_DIR"

exit 0
