#!/usr/bin/env bash
# Script: registry-init.sh
# Purpose: Initialize MCP server registry - creates directory structure (MECHANICAL)
# Plugin: 01-core
# Skill: mcp-configuration
# Usage: ./registry-init.sh

set -euo pipefail

# Configuration
REGISTRY_DIR="${HOME}/.claude/mcp-registry"
SERVERS_FILE="${REGISTRY_DIR}/servers.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[INFO] Initializing MCP Registry${NC}"
echo ""

# ============================================
# CREATE REGISTRY DIRECTORY
# ============================================

if [[ -d "$REGISTRY_DIR" ]]; then
    echo -e "${YELLOW}[WARN] Registry already exists at: $REGISTRY_DIR${NC}"
    echo "Do you want to reset it? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Keeping existing registry"
        exit 0
    fi
    echo "Backing up existing registry..."
    mv "$REGISTRY_DIR" "${REGISTRY_DIR}.backup-$(date +%Y%m%d_%H%M%S)"
fi

mkdir -p "$REGISTRY_DIR"
echo -e "${GREEN}✅ Created registry directory: $REGISTRY_DIR${NC}"

# ============================================
# CREATE INITIAL SERVERS.JSON
# ============================================

cat > "$SERVERS_FILE" << 'EOF'
{
  "_meta": {
    "version": "1.0.0",
    "description": "Universal MCP Server Registry",
    "transport_types": ["stdio", "http-local", "http-remote", "http-remote-auth"]
  },
  "servers": {}
}
EOF

echo -e "${GREEN}✅ Created servers registry: $SERVERS_FILE${NC}"

# ============================================
# CREATE README
# ============================================

cat > "${REGISTRY_DIR}/README.md" << 'EOF'
# MCP Server Registry

Universal registry for MCP servers across all CLI tools (Claude Code, Codex, Gemini, Qwen, VS Code, Cursor).

## Structure

- `servers.json` - Universal server definitions
- `backups/` - Automatic backups

## Transport Types

1. **stdio** - Local subprocess (command + args)
2. **http-local** - HTTP on localhost (you start it)
3. **http-remote** - Remote HTTP (plain URL)
4. **http-remote-auth** - Remote HTTP with authentication

## Usage

```bash
# Initialize registry
bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh

# Scan existing servers
bash plugins/01-core/skills/mcp-configuration/scripts/registry-scan.sh /Projects/Mcp-Servers

# Add server to project
/core:mcp-add <server-name>

# Transform for other tools
bash plugins/01-core/skills/mcp-configuration/scripts/transform-toml.sh codex
bash plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh gemini
```

## Server Definition Format

```json
{
  "servers": {
    "server-name": {
      "name": "Display Name",
      "description": "What this server does",
      "transport": "http-local|http-remote|http-remote-auth|stdio",

      // For http-local
      "path": "/absolute/path/to/server",
      "command": "python src/server.py",
      "url": "http://localhost:PORT",

      // For http-remote
      "httpUrl": "https://api.example.com/mcp/",

      // For http-remote-auth
      "headers": {
        "Authorization": "Bearer ${TOKEN}"
      },

      // For stdio
      "command": "npx",
      "args": ["-y", "package-name"],

      // Optional
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```
EOF

echo -e "${GREEN}✅ Created README: ${REGISTRY_DIR}/README.md${NC}"

# ============================================
# CREATE BACKUPS DIRECTORY
# ============================================

mkdir -p "${REGISTRY_DIR}/backups"
echo -e "${GREEN}✅ Created backups directory${NC}"

# ============================================
# REPORT RESULTS
# ============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ MCP Registry Initialized${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Registry location: $REGISTRY_DIR"
echo "Servers file: $SERVERS_FILE"
echo ""
echo "Next steps:"
echo "  1. Scan existing MCP servers:"
echo "     bash plugins/01-core/skills/mcp-configuration/scripts/registry-scan.sh /Projects/Mcp-Servers"
echo ""
echo "  2. Add servers to your project:"
echo "     /core:mcp-add <server-name>"
echo ""
echo "  3. Transform for other CLI tools:"
echo "     bash plugins/01-core/skills/mcp-configuration/scripts/transform-toml.sh"
echo ""

exit 0
