# multiagent-develop

**Lifecycle Phase:** Development (Phase 3 of 6)

**Purpose:** Code Generation & Implementation - Build features, scaffold code, implement functionality, and create MCP servers.

---

## Overview

The `multiagent-develop` plugin is part of the 6-phase project automation lifecycle. It handles all code generation and implementation tasks, adapting to any detected framework or stack.

**Consolidates:**
- `multiagent-frontend` → React/Vue/Svelte components
- `multiagent-backend` → API/server code
- `multiagent-implementation` → general implementation
- `multiagent-ai-infrastructure` → AI/LLM integration
- `multiagent-mcp` → MCP server building commands

---

## Available Commands

### Development Commands

**`/feature`** - Add New Feature from Specification
**`/component`** - Generate UI Component for Detected Framework
**`/api`** - Create API Endpoint for Detected Backend
**`/scaffold`** - Scaffold Complete Module (Frontend + Backend + Tests)
**`/ai-integration`** - Add AI/LLM Capabilities to Application

### MCP Development Commands

**`/mcp-build`** - Build Complete FastMCP Server
**`/mcp-test`** - Comprehensive MCP Server Testing (4-phase, 32 steps)
**`/setup`** - Configure MCP API Keys
**`/manage`** - Manage MCP Server Configurations
**`/info`** - List Available MCP Servers
**`/clear`** - Clear MCP Server Configurations

---

## Available Agents

- `feature-builder` - Implements features from specifications
- `frontend-generator` - Generates frontend components
- `backend-generator` - Creates backend APIs
- `ai-integrator` - Adds AI/LLM capabilities

---

## Available Skills

- `code-generation` - Framework-agnostic code generation
- `component-templates` - UI component library
- `api-patterns` - REST/GraphQL/tRPC patterns
- `mcp-development` - FastMCP server templates

---

## License

MIT License - See [LICENSE](LICENSE) for details.
