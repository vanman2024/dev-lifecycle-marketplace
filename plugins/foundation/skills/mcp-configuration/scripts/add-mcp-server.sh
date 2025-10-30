#!/bin/bash
# add-mcp-server.sh - Add new MCP server to existing configuration
# Usage: bash add-mcp-server.sh --name NAME --type TYPE --command CMD [OPTIONS]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
CONFIG_PATH="./.mcp.json"
SERVER_NAME=""
SERVER_TYPE=""
COMMAND=""
ARGS=""
URL=""
ENV_VARS=""

# Function to print messages
print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_usage() {
    echo "Usage: bash add-mcp-server.sh [OPTIONS]"
    echo ""
    echo "Required Options:"
    echo "  --name NAME           Server name (unique identifier)"
    echo "  --type TYPE           Server type: stdio, http, or sse"
    echo ""
    echo "For stdio servers:"
    echo "  --command CMD         Command to run (e.g., python, node, npx)"
    echo "  --args ARGS           Command arguments (quoted string or JSON array)"
    echo ""
    echo "For http/sse servers:"
    echo "  --url URL             Server URL"
    echo ""
    echo "Optional:"
    echo "  --config PATH         Config file path (default: ./.mcp.json)"
    echo "  --env-var KEY=VALUE   Environment variable (can be used multiple times)"
    echo ""
    echo "Examples:"
    echo "  # Add stdio server"
    echo "  bash add-mcp-server.sh --name filesystem --type stdio \\"
    echo "    --command npx --args '@modelcontextprotocol/server-filesystem /path'"
    echo ""
    echo "  # Add http server with API key"
    echo "  bash add-mcp-server.sh --name api --type http \\"
    echo "    --url 'https://api.example.com' --env-var API_KEY='\${API_KEY}'"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            SERVER_NAME="$2"
            shift 2
            ;;
        --type)
            SERVER_TYPE="$2"
            shift 2
            ;;
        --command)
            COMMAND="$2"
            shift 2
            ;;
        --args)
            ARGS="$2"
            shift 2
            ;;
        --url)
            URL="$2"
            shift 2
            ;;
        --config)
            CONFIG_PATH="$2"
            shift 2
            ;;
        --env-var)
            if [ -z "$ENV_VARS" ]; then
                ENV_VARS="$2"
            else
                ENV_VARS="$ENV_VARS,$2"
            fi
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
if [ -z "$SERVER_NAME" ]; then
    print_error "Server name is required (--name)"
    print_usage
    exit 1
fi

if [ -z "$SERVER_TYPE" ]; then
    print_error "Server type is required (--type)"
    print_usage
    exit 1
fi

# Validate server type
if [[ ! "$SERVER_TYPE" =~ ^(stdio|http|sse)$ ]]; then
    print_error "Invalid server type: $SERVER_TYPE (must be stdio, http, or sse)"
    exit 1
fi

# Type-specific validation
if [ "$SERVER_TYPE" = "stdio" ]; then
    if [ -z "$COMMAND" ]; then
        print_error "Command is required for stdio servers (--command)"
        exit 1
    fi
elif [[ "$SERVER_TYPE" =~ ^(http|sse)$ ]]; then
    if [ -z "$URL" ]; then
        print_error "URL is required for http/sse servers (--url)"
        exit 1
    fi
fi

# Check if config file exists
if [ ! -f "$CONFIG_PATH" ]; then
    print_error "Configuration file not found: $CONFIG_PATH"
    print_info "Run: bash scripts/init-mcp-config.sh $CONFIG_PATH"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    print_warning "jq not found, using manual JSON manipulation"
    USE_JQ=false
else
    USE_JQ=true
fi

print_info "Adding MCP server: $SERVER_NAME"
print_info "Type: $SERVER_TYPE"

# Build server configuration
if [ "$USE_JQ" = true ]; then
    # Use jq for safe JSON manipulation
    TMP_FILE=$(mktemp)

    if [ "$SERVER_TYPE" = "stdio" ]; then
        # Parse args into JSON array
        if [[ "$ARGS" =~ ^\[.*\]$ ]]; then
            ARGS_JSON="$ARGS"
        else
            # Split by space and create JSON array
            ARGS_JSON=$(echo "$ARGS" | jq -R 'split(" ")')
        fi

        # Build stdio server config
        SERVER_CONFIG=$(jq -n \
            --arg type "$SERVER_TYPE" \
            --arg command "$COMMAND" \
            --argjson args "$ARGS_JSON" \
            '{type: $type, command: $command, args: $args}')
    else
        # Build http/sse server config
        SERVER_CONFIG=$(jq -n \
            --arg type "$SERVER_TYPE" \
            --arg url "$URL" \
            '{type: $type, url: $url}')
    fi

    # Add environment variables if provided
    if [ -n "$ENV_VARS" ]; then
        ENV_JSON=$(echo "$ENV_VARS" | awk -F',' '{
            printf "{"
            for(i=1; i<=NF; i++) {
                split($i, kv, "=")
                printf "\"%s\":\"%s\"", kv[1], kv[2]
                if(i<NF) printf ","
            }
            printf "}"
        }')
        SERVER_CONFIG=$(echo "$SERVER_CONFIG" | jq --argjson env "$ENV_JSON" '. + {env: $env}')
    fi

    # Add server to config
    jq --arg name "$SERVER_NAME" --argjson server "$SERVER_CONFIG" \
        '.mcpServers[$name] = $server' "$CONFIG_PATH" > "$TMP_FILE"

    mv "$TMP_FILE" "$CONFIG_PATH"

else
    # Fallback: manual JSON manipulation (less safe but works without jq)
    print_warning "Using basic JSON manipulation - config may need manual review"

    # This is a simplified approach - in production, jq is strongly recommended
    print_error "jq is required for safe JSON manipulation"
    print_info "Install jq: apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
    exit 1
fi

print_info "✓ Server added successfully: $SERVER_NAME"
print_info ""
print_info "Next steps:"
print_info "  1. Validate config: bash scripts/validate-mcp-config.sh $CONFIG_PATH"
print_info "  2. Restart Claude Code to load new server"
print_info ""
print_info "Current configuration:"
cat "$CONFIG_PATH"

exit 0
