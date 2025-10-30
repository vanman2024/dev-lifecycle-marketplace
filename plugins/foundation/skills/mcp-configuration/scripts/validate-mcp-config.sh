#!/bin/bash
# validate-mcp-config.sh - Validate .mcp.json structure and server definitions
# Usage: bash validate-mcp-config.sh [config-path]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_PATH="${1:-./.mcp.json}"
ERRORS=0
WARNINGS=0

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}
print_section() { echo -e "\n${GREEN}=== $1 ===${NC}"; }

# Check if config exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo -e "${RED}ERROR: Configuration file not found: $CONFIG_PATH${NC}"
    exit 1
fi

echo "Validating MCP configuration: $CONFIG_PATH"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}WARNING: jq not installed - performing basic validation only${NC}"
    echo "Install jq for comprehensive validation: apt-get install jq"

    # Basic JSON syntax check
    if python3 -c "import json; json.load(open('$CONFIG_PATH'))" 2>/dev/null; then
        print_success "Valid JSON syntax"
        exit 0
    else
        print_error "Invalid JSON syntax"
        exit 1
    fi
fi

# ============================================================
# JSON Syntax Validation
# ============================================================
print_section "JSON Syntax"

if jq empty "$CONFIG_PATH" 2>/dev/null; then
    print_success "Valid JSON syntax"
else
    print_error "Invalid JSON syntax"
    echo "Error details:"
    jq empty "$CONFIG_PATH" 2>&1
    exit 1
fi

# ============================================================
# Structure Validation
# ============================================================
print_section "Configuration Structure"

# Check for mcpServers object
if jq -e '.mcpServers' "$CONFIG_PATH" > /dev/null 2>&1; then
    print_success "mcpServers object present"
else
    print_error "Missing required 'mcpServers' object"
fi

# Check if mcpServers is an object (not array)
if jq -e '.mcpServers | type == "object"' "$CONFIG_PATH" | grep -q true; then
    print_success "mcpServers is an object"
else
    print_error "mcpServers must be an object, not an array"
fi

# Count servers
SERVER_COUNT=$(jq '.mcpServers | length' "$CONFIG_PATH")
echo "Found $SERVER_COUNT MCP server(s)"

if [ "$SERVER_COUNT" -eq 0 ]; then
    print_warning "No MCP servers configured"
fi

# ============================================================
# Server Configuration Validation
# ============================================================
if [ "$SERVER_COUNT" -gt 0 ]; then
    print_section "Server Configurations"

    # Get all server names
    SERVER_NAMES=$(jq -r '.mcpServers | keys[]' "$CONFIG_PATH")

    for SERVER_NAME in $SERVER_NAMES; do
        echo ""
        echo "Validating server: $SERVER_NAME"

        # Check required 'type' field
        SERVER_TYPE=$(jq -r ".mcpServers.\"$SERVER_NAME\".type // \"missing\"" "$CONFIG_PATH")

        if [ "$SERVER_TYPE" = "missing" ]; then
            print_error "  Missing required field: type"
            continue
        fi

        # Validate server type
        if [[ "$SERVER_TYPE" =~ ^(stdio|http|sse)$ ]]; then
            print_success "  Valid type: $SERVER_TYPE"
        else
            print_error "  Invalid type: $SERVER_TYPE (must be stdio, http, or sse)"
            continue
        fi

        # Type-specific validation
        if [ "$SERVER_TYPE" = "stdio" ]; then
            # Check command
            COMMAND=$(jq -r ".mcpServers.\"$SERVER_NAME\".command // \"missing\"" "$CONFIG_PATH")
            if [ "$COMMAND" = "missing" ]; then
                print_error "  Missing required field for stdio: command"
            else
                print_success "  Command: $COMMAND"

                # Try to find command in PATH
                if command -v "$COMMAND" &> /dev/null; then
                    print_success "  Command found in PATH: $(which "$COMMAND")"
                elif [ -f "$COMMAND" ]; then
                    print_success "  Command found at path: $COMMAND"
                else
                    print_warning "  Command not found in PATH: $COMMAND"
                    print_warning "    This may be ok if command will be available at runtime"
                fi
            fi

            # Check args
            if jq -e ".mcpServers.\"$SERVER_NAME\".args" "$CONFIG_PATH" > /dev/null 2>&1; then
                ARGS_TYPE=$(jq -r ".mcpServers.\"$SERVER_NAME\".args | type" "$CONFIG_PATH")
                if [ "$ARGS_TYPE" = "array" ]; then
                    ARGS_COUNT=$(jq ".mcpServers.\"$SERVER_NAME\".args | length" "$CONFIG_PATH")
                    print_success "  Args array with $ARGS_COUNT element(s)"
                else
                    print_error "  Args must be an array, not $ARGS_TYPE"
                fi
            else
                print_warning "  No args specified (optional)"
            fi

        elif [[ "$SERVER_TYPE" =~ ^(http|sse)$ ]]; then
            # Check URL
            URL=$(jq -r ".mcpServers.\"$SERVER_NAME\".url // \"missing\"" "$CONFIG_PATH")
            if [ "$URL" = "missing" ]; then
                print_error "  Missing required field for $SERVER_TYPE: url"
            else
                # Basic URL validation
                if [[ "$URL" =~ ^https?:// ]]; then
                    print_success "  Valid URL: $URL"
                else
                    print_warning "  URL doesn't start with http:// or https://: $URL"
                fi
            fi
        fi

        # Check environment variables
        if jq -e ".mcpServers.\"$SERVER_NAME\".env" "$CONFIG_PATH" > /dev/null 2>&1; then
            ENV_VARS=$(jq -r ".mcpServers.\"$SERVER_NAME\".env | keys[]" "$CONFIG_PATH")
            ENV_COUNT=$(jq ".mcpServers.\"$SERVER_NAME\".env | length" "$CONFIG_PATH")
            print_success "  Environment variables: $ENV_COUNT defined"

            # Check for ${VAR} syntax
            for VAR_NAME in $ENV_VARS; do
                VAR_VALUE=$(jq -r ".mcpServers.\"$SERVER_NAME\".env.\"$VAR_NAME\"" "$CONFIG_PATH")
                if [[ "$VAR_VALUE" =~ ^\$\{.*\}$ ]]; then
                    print_success "    $VAR_NAME uses variable substitution"
                else
                    print_warning "    $VAR_NAME has hardcoded value (consider using \${VAR})"
                fi
            done
        fi
    done
fi

# ============================================================
# Security Checks
# ============================================================
print_section "Security Checks"

# Check for hardcoded secrets (basic patterns)
if jq -r '.. | strings' "$CONFIG_PATH" | grep -qiE '(api[_-]?key|password|secret|token)["\s]*:["\s]*[^$]'; then
    print_warning "Possible hardcoded secrets detected"
    print_warning "  Consider using environment variables: \${API_KEY}"
else
    print_success "No obvious hardcoded secrets found"
fi

# Check if .env is in .gitignore (if .gitignore exists)
if [ -f ".gitignore" ]; then
    if grep -q "^\.env$" .gitignore; then
        print_success ".env is in .gitignore"
    else
        print_warning ".env not found in .gitignore"
        print_warning "  Add '.env' to .gitignore to avoid committing secrets"
    fi
fi

# ============================================================
# Summary
# ============================================================
print_section "Validation Summary"

echo "Configuration: $CONFIG_PATH"
echo "Servers: $SERVER_COUNT"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Configuration is valid!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "\n${YELLOW}⚠ Configuration is valid but has warnings${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Configuration has errors that must be fixed${NC}"
    exit 1
fi
