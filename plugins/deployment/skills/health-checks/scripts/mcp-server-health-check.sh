#!/usr/bin/env bash

# MCP Server Health Check Script
# Validates MCP servers including tool discovery and execution tests
# Usage: ./mcp-server-health-check.sh <mcp_url> [test_tool_name]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
MCP_URL="${1:-}"
TEST_TOOL="${2:-}"
TIMEOUT="${TIMEOUT:-20}"
RETRIES="${RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-5}"

# Validate arguments
if [ -z "$MCP_URL" ]; then
    echo -e "${RED}Error: MCP server URL is required${NC}"
    echo "Usage: $0 <mcp_url> [test_tool_name]"
    echo ""
    echo "Examples:"
    echo "  $0 http://localhost:3000/mcp"
    echo "  $0 https://mcp.example.com"
    echo "  $0 http://localhost:3000/mcp list_tools"
    exit 2
fi

# Check dependencies
for cmd in curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed${NC}"
        echo "Install with: sudo apt-get install $cmd"
        exit 2
    fi
done

# Function to make MCP request
mcp_request() {
    local method="$1"
    local params="${2:-{}}"

    local request_body=$(jq -n \
        --arg method "$method" \
        --argjson params "$params" \
        '{
            jsonrpc: "2.0",
            id: 1,
            method: $method,
            params: $params
        }')

    echo "$request_body" | curl -s -X POST "$MCP_URL" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --max-time "$TIMEOUT" \
        -d @- 2>/dev/null
}

# Function to check MCP server health
check_mcp_server() {
    local attempt="$1"

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Attempt $attempt/$RETRIES: Checking MCP Server${NC}"
    echo -e "${CYAN}URL: $MCP_URL${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Step 1: Basic connectivity check
    echo -e "\n${BLUE}Step 1: Checking basic connectivity...${NC}"
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time "$TIMEOUT" \
        -H "Content-Type: application/json" \
        "$MCP_URL" 2>/dev/null || echo "000")

    if [ "$http_code" = "000" ]; then
        echo -e "${RED}✗ Cannot connect to MCP server${NC}"
        return 1
    elif [[ ! "$http_code" =~ ^[245][0-9][0-9]$ ]]; then
        echo -e "${YELLOW}⚠ Unexpected HTTP status: $http_code${NC}"
    else
        echo -e "${GREEN}✓ Server is reachable (HTTP $http_code)${NC}"
    fi

    # Step 2: Initialize MCP session
    echo -e "\n${BLUE}Step 2: Initializing MCP session...${NC}"
    local init_params='{
        "protocolVersion": "2024-11-05",
        "capabilities": {
            "tools": {}
        },
        "clientInfo": {
            "name": "health-check",
            "version": "1.0.0"
        }
    }'

    local init_response
    init_response=$(mcp_request "initialize" "$init_params")

    if [ -z "$init_response" ]; then
        echo -e "${RED}✗ No response from initialize request${NC}"
        return 1
    fi

    # Check for errors in response
    local error_msg
    error_msg=$(echo "$init_response" | jq -r '.error.message // empty' 2>/dev/null)
    if [ -n "$error_msg" ]; then
        echo -e "${RED}✗ Initialize error: $error_msg${NC}"
        echo "$init_response" | jq '.' 2>/dev/null
        return 1
    fi

    # Check result
    local protocol_version
    protocol_version=$(echo "$init_response" | jq -r '.result.protocolVersion // empty' 2>/dev/null)
    if [ -n "$protocol_version" ]; then
        echo -e "${GREEN}✓ MCP initialized successfully${NC}"
        echo -e "  Protocol version: $protocol_version"

        # Display server info
        local server_name
        local server_version
        server_name=$(echo "$init_response" | jq -r '.result.serverInfo.name // empty' 2>/dev/null)
        server_version=$(echo "$init_response" | jq -r '.result.serverInfo.version // empty' 2>/dev/null)

        if [ -n "$server_name" ]; then
            echo -e "  Server: $server_name $server_version"
        fi

        # Display capabilities
        echo -e "\n${BLUE}Server capabilities:${NC}"
        echo "$init_response" | jq '.result.capabilities // {}' 2>/dev/null
    else
        echo -e "${RED}✗ Invalid initialize response${NC}"
        echo "$init_response" | jq '.' 2>/dev/null
        return 1
    fi

    # Step 3: List available tools
    echo -e "\n${BLUE}Step 3: Discovering available tools...${NC}"
    local tools_response
    tools_response=$(mcp_request "tools/list" "{}")

    if [ -z "$tools_response" ]; then
        echo -e "${YELLOW}⚠ No response from tools/list request${NC}"
    else
        error_msg=$(echo "$tools_response" | jq -r '.error.message // empty' 2>/dev/null)
        if [ -n "$error_msg" ]; then
            echo -e "${YELLOW}⚠ Tools list error: $error_msg${NC}"
        else
            local tool_count
            tool_count=$(echo "$tools_response" | jq -r '.result.tools | length // 0' 2>/dev/null)

            if [ "$tool_count" -gt 0 ]; then
                echo -e "${GREEN}✓ Found $tool_count available tools${NC}"
                echo -e "\n${BLUE}Available tools:${NC}"
                echo "$tools_response" | jq -r '.result.tools[] | "  - \(.name): \(.description // "No description")"' 2>/dev/null
            else
                echo -e "${YELLOW}⚠ No tools available${NC}"
            fi
        fi
    fi

    # Step 4: Test specific tool if requested
    if [ -n "$TEST_TOOL" ]; then
        echo -e "\n${BLUE}Step 4: Testing tool: $TEST_TOOL${NC}"

        local tool_params="{\"name\": \"$TEST_TOOL\"}"
        local tool_response
        tool_response=$(mcp_request "tools/call" "$tool_params")

        if [ -z "$tool_response" ]; then
            echo -e "${YELLOW}⚠ No response from tool call${NC}"
        else
            error_msg=$(echo "$tool_response" | jq -r '.error.message // empty' 2>/dev/null)
            if [ -n "$error_msg" ]; then
                echo -e "${YELLOW}⚠ Tool call error: $error_msg${NC}"
            else
                echo -e "${GREEN}✓ Tool executed successfully${NC}"
                echo -e "\n${BLUE}Tool response:${NC}"
                echo "$tool_response" | jq '.result // {}' 2>/dev/null
            fi
        fi
    fi

    # Step 5: List available resources (optional)
    echo -e "\n${BLUE}Step 5: Discovering available resources...${NC}"
    local resources_response
    resources_response=$(mcp_request "resources/list" "{}")

    if [ -z "$resources_response" ]; then
        echo -e "${YELLOW}⚠ No response from resources/list request${NC}"
    else
        error_msg=$(echo "$resources_response" | jq -r '.error.message // empty' 2>/dev/null)
        if [ -n "$error_msg" ]; then
            echo -e "${YELLOW}⚠ Resources list error: $error_msg${NC}"
        else
            local resource_count
            resource_count=$(echo "$resources_response" | jq -r '.result.resources | length // 0' 2>/dev/null)

            if [ "$resource_count" -gt 0 ]; then
                echo -e "${GREEN}✓ Found $resource_count available resources${NC}"
                echo -e "\n${BLUE}Available resources:${NC}"
                echo "$resources_response" | jq -r '.result.resources[] | "  - \(.uri): \(.name // "No name")"' 2>/dev/null
            else
                echo -e "${YELLOW}⚠ No resources available${NC}"
            fi
        fi
    fi

    # Overall assessment
    echo -e "\n${GREEN}✓ MCP server health check PASSED${NC}"
    return 0
}

# Main execution with retries
attempt=1
while [ $attempt -le $RETRIES ]; do
    if check_mcp_server "$attempt"; then
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}SUCCESS: MCP server is healthy and operational${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
    fi

    if [ $attempt -lt $RETRIES ]; then
        echo -e "${YELLOW}Retrying in ${RETRY_DELAY}s...${NC}\n"
        sleep "$RETRY_DELAY"
    fi

    ((attempt++))
done

echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}FAILURE: MCP server failed health check after $RETRIES attempts${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
exit 1
