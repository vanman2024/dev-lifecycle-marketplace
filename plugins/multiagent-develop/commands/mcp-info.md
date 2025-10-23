---
allowed-tools: Bash(*), Read(*)
description: Show MCP server information (list, status, check, inventory)
argument-hint: [action]
---

User input: $ARGUMENTS

**MCP Server Information**

View MCP servers, status, and configuration.

## Usage

```bash
# List available servers from registry
/mcp:info list
/mcp:info

# Show current status
/mcp:info status

# Check which API keys are configured
/mcp:info check

# Show inventory tracking
/mcp:info inventory
```

## Implementation

```bash
ACTION="${1:-list}"

case "$ACTION" in
  list|"")
    # Display all available MCP servers from registry
    Read($HOME/.claude/marketplaces/.../mcp-servers-registry.json)
    ;;
  status)
    # Show current MCP configuration status
    ;;
  check)
    # Check which MCP API keys are configured in env
    ;;
  inventory)
    # Generate/update API keys inventory tracking
    ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Valid: list, status, check, inventory"
    exit 1
    ;;
esac
```
