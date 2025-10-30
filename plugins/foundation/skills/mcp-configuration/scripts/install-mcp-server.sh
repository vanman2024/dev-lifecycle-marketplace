#!/bin/bash
# install-mcp-server.sh - Install and configure MCP server packages
# Usage: bash install-mcp-server.sh --type TYPE --package PACKAGE [OPTIONS]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
INSTALL_TYPE=""
PACKAGE_NAME=""
GLOBAL=false
ADD_TO_CONFIG=false
CONFIG_PATH="./.mcp.json"
VENV_PATH=""

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

print_usage() {
    echo "Usage: bash install-mcp-server.sh [OPTIONS]"
    echo ""
    echo "Required Options:"
    echo "  --type TYPE           Installation type: python, typescript, npm"
    echo "  --package NAME        Package name to install"
    echo ""
    echo "Optional:"
    echo "  --global              Install globally (default: local)"
    echo "  --add-to-config       Automatically add to .mcp.json"
    echo "  --config PATH         Config file path (default: ./.mcp.json)"
    echo "  --venv PATH           Python virtual environment path (for python type)"
    echo ""
    echo "Examples:"
    echo "  # Install Python FastMCP globally"
    echo "  bash install-mcp-server.sh --type python --package fastmcp --global"
    echo ""
    echo "  # Install TypeScript MCP server locally"
    echo "  bash install-mcp-server.sh --type typescript --package @modelcontextprotocol/sdk"
    echo ""
    echo "  # Install and add to config"
    echo "  bash install-mcp-server.sh --type npm --package @modelcontextprotocol/server-filesystem \\"
    echo "    --global --add-to-config"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            INSTALL_TYPE="$2"
            shift 2
            ;;
        --package)
            PACKAGE_NAME="$2"
            shift 2
            ;;
        --global)
            GLOBAL=true
            shift
            ;;
        --add-to-config)
            ADD_TO_CONFIG=true
            shift
            ;;
        --config)
            CONFIG_PATH="$2"
            shift 2
            ;;
        --venv)
            VENV_PATH="$2"
            shift 2
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$INSTALL_TYPE" ]; then
    print_error "Installation type is required (--type)"
    print_usage
    exit 1
fi

if [ -z "$PACKAGE_NAME" ]; then
    print_error "Package name is required (--package)"
    print_usage
    exit 1
fi

# Validate installation type
if [[ ! "$INSTALL_TYPE" =~ ^(python|typescript|npm)$ ]]; then
    print_error "Invalid type: $INSTALL_TYPE (must be python, typescript, or npm)"
    exit 1
fi

# ============================================================
# Installation Functions
# ============================================================

install_python_package() {
    print_step "Installing Python package: $PACKAGE_NAME"

    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 not found. Install Python first."
        exit 1
    fi

    PYTHON_CMD="python3"
    PIP_CMD="pip3"

    # Use virtual environment if specified
    if [ -n "$VENV_PATH" ]; then
        if [ ! -d "$VENV_PATH" ]; then
            print_info "Creating virtual environment: $VENV_PATH"
            $PYTHON_CMD -m venv "$VENV_PATH"
        fi

        print_info "Using virtual environment: $VENV_PATH"
        PYTHON_CMD="$VENV_PATH/bin/python"
        PIP_CMD="$VENV_PATH/bin/pip"
    fi

    # Install package
    if [ "$GLOBAL" = true ] && [ -z "$VENV_PATH" ]; then
        print_info "Installing globally (may require sudo)"
        $PIP_CMD install "$PACKAGE_NAME"
    else
        print_info "Installing locally"
        $PIP_CMD install --user "$PACKAGE_NAME"
    fi

    # Verify installation
    if $PIP_CMD show "$PACKAGE_NAME" &> /dev/null; then
        print_info "✓ Package installed successfully"

        # Get version
        VERSION=$($PIP_CMD show "$PACKAGE_NAME" | grep "^Version:" | cut -d' ' -f2)
        print_info "Version: $VERSION"

        # Suggest command for .mcp.json
        echo ""
        print_info "Suggested .mcp.json configuration:"
        echo "  {"
        echo "    \"type\": \"stdio\","
        echo "    \"command\": \"$PYTHON_CMD\","
        echo "    \"args\": [\"-m\", \"$PACKAGE_NAME\"]"
        echo "  }"
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

install_typescript_package() {
    print_step "Installing TypeScript package: $PACKAGE_NAME"

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        print_error "npm not found. Install Node.js and npm first."
        exit 1
    fi

    # Install package
    if [ "$GLOBAL" = true ]; then
        print_info "Installing globally"
        npm install -g "$PACKAGE_NAME"
    else
        print_info "Installing locally"

        # Initialize package.json if needed
        if [ ! -f "package.json" ]; then
            print_info "Creating package.json"
            npm init -y
        fi

        npm install "$PACKAGE_NAME"
    fi

    # Verify installation
    if npm list "$PACKAGE_NAME" &> /dev/null || npm list -g "$PACKAGE_NAME" &> /dev/null; then
        print_info "✓ Package installed successfully"

        # Get version
        if [ "$GLOBAL" = true ]; then
            VERSION=$(npm list -g "$PACKAGE_NAME" --depth=0 2>/dev/null | grep "$PACKAGE_NAME" | cut -d'@' -f2)
        else
            VERSION=$(npm list "$PACKAGE_NAME" --depth=0 2>/dev/null | grep "$PACKAGE_NAME" | cut -d'@' -f2)
        fi
        print_info "Version: $VERSION"

        # Suggest command
        echo ""
        print_info "Suggested .mcp.json configuration:"
        if [ "$GLOBAL" = true ]; then
            echo "  {"
            echo "    \"type\": \"stdio\","
            echo "    \"command\": \"npx\","
            echo "    \"args\": [\"$PACKAGE_NAME\"]"
            echo "  }"
        else
            echo "  {"
            echo "    \"type\": \"stdio\","
            echo "    \"command\": \"node\","
            echo "    \"args\": [\"node_modules/$PACKAGE_NAME/dist/index.js\"]"
            echo "  }"
        fi
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

install_npm_package() {
    print_step "Installing npm package: $PACKAGE_NAME"

    # npm packages use the same logic as TypeScript
    install_typescript_package
}

# ============================================================
# Execute Installation
# ============================================================

case $INSTALL_TYPE in
    python)
        install_python_package
        ;;
    typescript)
        install_typescript_package
        ;;
    npm)
        install_npm_package
        ;;
esac

# ============================================================
# Add to .mcp.json if requested
# ============================================================

if [ "$ADD_TO_CONFIG" = true ]; then
    print_step "Adding to MCP configuration"

    if [ ! -f "$CONFIG_PATH" ]; then
        print_warning "Config file not found: $CONFIG_PATH"
        print_info "Creating new config file"
        bash "$(dirname "$0")/init-mcp-config.sh" "$CONFIG_PATH"
    fi

    # Extract server name from package name
    SERVER_NAME=$(echo "$PACKAGE_NAME" | sed 's|@.*\/||' | sed 's|[-/]|_|g')

    print_info "Adding server: $SERVER_NAME"

    # Determine command based on installation type
    case $INSTALL_TYPE in
        python)
            if [ -n "$VENV_PATH" ]; then
                CMD="$VENV_PATH/bin/python"
            else
                CMD="python3"
            fi
            bash "$(dirname "$0")/add-mcp-server.sh" \
                --name "$SERVER_NAME" \
                --type stdio \
                --command "$CMD" \
                --args "-m $PACKAGE_NAME" \
                --config "$CONFIG_PATH"
            ;;
        typescript|npm)
            if [ "$GLOBAL" = true ]; then
                bash "$(dirname "$0")/add-mcp-server.sh" \
                    --name "$SERVER_NAME" \
                    --type stdio \
                    --command "npx" \
                    --args "$PACKAGE_NAME" \
                    --config "$CONFIG_PATH"
            else
                bash "$(dirname "$0")/add-mcp-server.sh" \
                    --name "$SERVER_NAME" \
                    --type stdio \
                    --command "node" \
                    --args "node_modules/$PACKAGE_NAME/dist/index.js" \
                    --config "$CONFIG_PATH"
            fi
            ;;
    esac

    print_info "✓ Server added to config: $CONFIG_PATH"
fi

# ============================================================
# Post-installation instructions
# ============================================================

echo ""
print_info "Installation complete!"
echo ""
print_info "Next steps:"
print_info "  1. Validate config: bash scripts/validate-mcp-config.sh $CONFIG_PATH"
print_info "  2. Restart Claude Code to load the new server"
print_info "  3. Test server functionality"

exit 0
