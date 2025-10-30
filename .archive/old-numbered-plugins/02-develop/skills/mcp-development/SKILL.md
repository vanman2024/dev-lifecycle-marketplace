---
name: MCP Development
description: Provides FastMCP templates, patterns, and reference materials. Use when building MCP servers, implementing FastMCP tools/resources/prompts, or working with MCP protocol compliance.
allowed-tools: Read, Bash
---

# MCP Development Skill

Provides templates, scripts, and reference documentation for building and testing MCP servers with FastMCP.

## What This Skill Provides

### Templates
Location: `skills/mcp-development/templates/`
- Complete FastMCP server structure
- Tool implementation patterns (standalone vs class-based)
- Resource and prompt templates
- Testing templates

### Scripts
Location: `skills/mcp-development/scripts/`

**Scaffolder Scripts (Structure Creation - MECHANICAL):**
- `scaffold-mcp-server.sh <server-name> [output-dir]` - Creates MCP server directory structure with boilerplate

**Validator Scripts (Pattern Recognition):**
- `validate-server.sh <server-path>` - Validates MCP server structure
- `fix-server.sh <server-path>` - Auto-fixes common server issues
- `validate-tool.sh <tool-file>` - Validates tool implementation
- `fix-tool.sh <tool-file>` - Auto-fixes tool patterns

**Analyzer Scripts (Detection):**
- `detect-platform.sh` - Detects Python environment and dependencies
- `analyze-dependencies.sh <server-path>` - Checks FastMCP dependencies

**Helper Scripts (Utilities):**
- `list-servers.sh` - Lists available MCP server templates
- `validate-config.sh <config-file>` - Validates MCP configuration

**How to Invoke Scripts:**
Commands execute scripts using bash:
```bash
# Scaffold structure first (mechanical)
bash skills/mcp-development/scripts/scaffold-mcp-server.sh my-api ./servers/http

# Then AI fills in the content using templates

# Then validate (pattern-based, no AI)
bash skills/mcp-development/scripts/validate-server.sh servers/http/my-api-http-mcp

# Auto-fix issues if found (deterministic, no AI)
bash skills/mcp-development/scripts/fix-server.sh servers/http/my-api-http-mcp
```

**The Flow:**
1. **Scaffolder** creates dirs + empty/minimal files
2. **AI** fills in tools/resources/prompts using templates
3. **Validator** checks structure patterns
4. **Fix** auto-corrects common issues

### Reference Materials
- FastMCP documentation links
- Pattern examples (agent-guiding resources/prompts)
- Protocol compliance patterns
- Error handling best practices

## When Claude Auto-Invokes This Skill

This skill is automatically used when:
- Building new MCP servers
- Implementing FastMCP tools, resources, or prompts
- Setting up MCP testing frameworks
- Working with MCP protocol requirements
- Debugging MCP server issues

## Key Patterns Provided

### Server Organization
- Tools: Standalone (@mcp.tool()) vs Class-based (mcp.tool(instance.method))
- Resources: Static content and dynamic templates
- Prompts: Agent-guiding prompts with parameters
- Context: Logging, progress, sampling, elicitation

### Testing Patterns
- FastMCP Client in-memory testing
- Direct function testing with mocks
- HTTP protocol compliance testing

## Examples

See `examples.md` for complete usage patterns.
See `reference.md` for API documentation.
