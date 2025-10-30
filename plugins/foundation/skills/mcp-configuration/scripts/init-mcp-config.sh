#!/bin/bash
# init-mcp-config.sh - Initialize .mcp.json with proper structure
# Usage: bash init-mcp-config.sh [path]
# Default path: ./.mcp.json

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default config path
CONFIG_PATH="${1:-./.mcp.json}"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if config already exists
if [ -f "$CONFIG_PATH" ]; then
    print_warning "Configuration file already exists: $CONFIG_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Aborted. Existing configuration preserved."
        exit 0
    fi
fi

# Create directory if it doesn't exist
CONFIG_DIR=$(dirname "$CONFIG_PATH")
if [ ! -d "$CONFIG_DIR" ]; then
    print_info "Creating directory: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

# Create basic .mcp.json structure
print_info "Creating MCP configuration file: $CONFIG_PATH"

cat > "$CONFIG_PATH" << 'EOF'
{
  "mcpServers": {}
}
EOF

# Verify file was created
if [ -f "$CONFIG_PATH" ]; then
    print_info "✓ Configuration file created successfully"
    print_info "Location: $(realpath "$CONFIG_PATH")"
    print_info ""
    print_info "Next steps:"
    print_info "  1. Add MCP servers using: bash scripts/add-mcp-server.sh"
    print_info "  2. Validate config using: bash scripts/validate-mcp-config.sh $CONFIG_PATH"
    print_info ""
    print_info "Example: Add filesystem server"
    print_info "  bash scripts/add-mcp-server.sh --name filesystem --type stdio \\"
    print_info "    --command npx --args '@modelcontextprotocol/server-filesystem /path/to/files'"
else
    print_error "Failed to create configuration file"
    exit 1
fi

exit 0
