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
- Server scaffolding scripts
- Testing automation
- Deployment helpers

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
