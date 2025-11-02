# Foundation Plugin

**MCP ecosystem management and minimal environment setup for dev-lifecycle-marketplace**

## Overview

The foundation plugin provides essential infrastructure management for development lifecycle workflows. It handles MCP server configuration, project tech stack detection, and environment validation - the foundational layer that other lifecycle plugins build upon.

## Commands

### `/foundation:mcp-manage`
Add, install, remove, list MCP servers and manage API keys

**Actions:**
- `add` - Add new MCP server to .mcp.json
- `install` - Install and configure MCP server package
- `remove` - Remove MCP server from configuration
- `list` - Display all configured MCP servers
- `clear` - Remove all MCP servers (with backup)
- `keys` - Configure API keys for MCP servers

**Usage:**
```bash
/foundation:mcp-manage add playwright
/foundation:mcp-manage install supabase
/foundation:mcp-manage list
/foundation:mcp-manage keys openai
```

### `/foundation:mcp-registry` (v2.1+)
Manage universal MCP server registry (single source of truth)

**NEW**: Registry-based workflow for managing MCP servers across multiple formats (Claude Code, VS Code, Gemini, Qwen, Codex).

**Actions:**
- `init` - Initialize universal registry at ~/.claude/mcp-registry/
- `add` - Add server to registry
- `remove` - Remove server from registry
- `list` - List all servers in registry
- `search` - Search for servers by keyword

**Usage:**
```bash
# Initialize registry
/foundation:mcp-registry init

# Add servers to registry
/foundation:mcp-registry add context7
/foundation:mcp-registry add filesystem

# List all servers
/foundation:mcp-registry list

# Search for servers
/foundation:mcp-registry search github
```

**Registry Structure:**
- Location: `~/.claude/mcp-registry/servers.json`
- Single source of truth for all MCP server definitions
- Supports 4 transport types: stdio, http-local, http-remote, http-remote-auth
- Environment variables referenced as `${VAR}` (values in project .env)

### `/foundation:mcp-sync` (v2.1+)
Sync universal registry to target format(s)

Convert registry to Claude Code (.mcp.json) or VS Code (.vscode/mcp.json) format.

**Formats:**
- `claude` - Sync to .mcp.json (Claude Code format)
- `vscode` - Sync to .vscode/mcp.json (VS Code format)
- `both` - Sync to both formats

**Usage:**
```bash
# Sync all servers to Claude Code format
/foundation:mcp-sync claude

# Sync specific servers to VS Code
/foundation:mcp-sync vscode context7 filesystem

# Sync all to both formats
/foundation:mcp-sync both
```

**Format Differences:**
- **Claude Code (.mcp.json)**: Root key `mcpServers`, best for stdio servers
- **VS Code (.vscode/mcp.json)**: Root key `servers`, supports all transport types including http-remote-auth

### `/foundation:detect`
Detect project tech stack and populate .claude/project.json

Analyzes project structure, dependencies, and configuration to identify:
- Primary framework (Next.js, FastAPI, Django, Go, Rust, etc.)
- Languages and versions
- AI stack (Vercel AI SDK, Claude Agent SDK, Mem0, etc.)
- Database and storage (Supabase, PostgreSQL, etc.)
- MCP servers configured
- Testing frameworks
- Deployment targets

**Usage:**
```bash
/foundation:detect
/foundation:detect /path/to/project
```

### `/foundation:env-check`
Verify required tools are installed for detected tech stack

Checks that all required tools are present and properly versioned:
- Node.js, npm/pnpm/yarn
- Python, pip/poetry/uv
- Go, Rust, etc.
- AI SDK CLIs

**Usage:**
```bash
/foundation:env-check
/foundation:env-check --fix
```

### `/foundation:env-vars`
Manage environment variables for project configuration

**Actions:**
- `add` - Add/update environment variable in .env
- `remove` - Remove environment variable
- `list` - Display all variables (masked)
- `check` - Validate required variables are set
- `template` - Generate .env.example

**Usage:**
```bash
/foundation:env-vars add DATABASE_URL "postgres://..."
/foundation:env-vars list
/foundation:env-vars check
/foundation:env-vars template
```

### `/foundation:hooks-setup`
Install standardized git hooks for security and quality enforcement

Installs three essential git hooks:
- **pre-commit**: Scans for API keys, tokens, passwords, and secrets
- **commit-msg**: Validates conventional commit message format
- **pre-push**: Runs security scans (npm audit, safety check)

**Usage:**
```bash
/foundation:hooks-setup
/foundation:hooks-setup /path/to/project
```

**What it checks:**
- AWS keys, OpenAI keys, Bearer tokens
- Database connection strings
- Private keys and certificates
- Generic API keys and secrets
- Commit message format (feat|fix|docs|style|refactor|test|chore|perf|ci|build)
- Dependency vulnerabilities (npm audit, safety)

## Agent

### `stack-detector`
Analyzes project structure and detects complete tech stack including frameworks, languages, AI SDKs, databases, and deployment targets.

**Capabilities:**
- Framework & language detection (30+ frameworks)
- AI stack recognition (SDKs, providers, memory, vector DBs)
- Database & storage detection
- Infrastructure identification
- Generates .claude/project.json

## Skills

### `mcp-configuration`
MCP server configuration templates, .mcp.json management, API key handling, and universal registry management (v2.1+)

**Provides:**
- 13 helper scripts (v2.1: added registry-init, registry-add, registry-list, registry-sync, transform-claude, transform-vscode, manage-api-keys improvements)
- 6 configuration templates (basic, stdio, HTTP, FastMCP, TypeScript, multi-server)
- 2 registry templates (.env.example, marketplace.json reference)
- 5 comprehensive examples (15,000+ words of documentation)

**Registry Workflow (v2.1+):**
- Universal registry at ~/.claude/mcp-registry/servers.json
- Single source of truth for all MCP server definitions
- Transform to Claude Code, VS Code, or both formats on demand
- API keys stored in project .env files (never in configs)
- Marketplace servers tracked separately (VS Code pre-installed servers)

### `project-detection`
Tech stack detection scripts, framework identification, dependency analysis

**Provides:**
- 6 detection scripts (frameworks, dependencies, AI stack, database, generate, validate)
- 6 pattern templates (30+ frameworks, 8+ languages)
- 5 examples covering simple to complex projects

**Detects:**
- 30+ frameworks across 8 languages
- AI SDKs and vector databases
- 20+ ORMs and database systems
- Build tools and test frameworks

### `environment-setup`
Environment checking scripts, tool verification, path validation

**Provides:**
- 5 verification scripts (environment, tools, versions, PATH, env-vars)
- 6 templates (reports, requirements, configurations)
- 5 usage examples

**Checks:**
- 10+ programming languages
- Version managers (nvm, pyenv, rbenv, rustup)
- PATH configuration
- Environment variables

## Integration

### With AI Tech Stacks

Foundation plugin is AI-aware and detects AI Tech Stack components:
- Vercel AI SDK, Claude Agent SDK, Mem0
- AI providers (Anthropic, OpenAI, Google AI)
- Vector databases (pgvector, Pinecone, Weaviate)
- MCP servers and FastMCP

### With Lifecycle Plugins

Other lifecycle plugins use foundation for:
- **Planning**: Reads .claude/project.json for framework-specific specs
- **Iterate**: Uses detected stack for task organization
- **Quality**: Adapts testing based on detected frameworks
- **Deployment**: Deploys based on detected infrastructure

## File Structure

```
foundation/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── mcp-manage.md
│   ├── mcp-registry.md (v2.1)
│   ├── mcp-sync.md (v2.1)
│   ├── detect.md
│   ├── env-check.md
│   ├── env-vars.md
│   └── hooks-setup.md
├── agents/
│   └── stack-detector.md
├── skills/
│   ├── mcp-configuration/
│   │   ├── SKILL.md
│   │   ├── scripts/ (13 scripts - v2.1 added 7)
│   │   ├── templates/ (8 templates - v2.1 added 2)
│   │   └── examples/ (5 examples)
│   ├── project-detection/
│   │   ├── SKILL.md
│   │   ├── scripts/ (6 scripts)
│   │   ├── templates/ (6 templates)
│   │   └── examples/ (5 examples)
│   └── environment-setup/
│       ├── SKILL.md
│       ├── scripts/ (5 scripts)
│       ├── templates/ (6 templates)
│       └── examples/ (5 examples)
└── README.md
```

**Global Registry** (v2.1):
```
~/.claude/mcp-registry/
├── servers.json          # Universal server definitions
├── marketplace.json      # VS Code marketplace reference
├── backups/              # Automatic backups
└── README.md             # Registry documentation
```

## Workflow Examples

### Registry-Based Workflow (v2.1+ Recommended)

```bash
# 1. Initialize universal registry (one-time setup)
/foundation:mcp-registry init

# 2. Add servers to registry
/foundation:mcp-registry add context7
/foundation:mcp-registry add filesystem

# 3. Sync registry to project
/foundation:mcp-sync both  # Syncs to both Claude and VS Code formats

# 4. Configure API keys in project .env
bash plugins/foundation/skills/mcp-configuration/scripts/manage-api-keys.sh --action add --key-name CONTEXT7_API_KEY

# 5. Detect project tech stack
/foundation:detect

# 6. Check environment
/foundation:env-check

# 7. Now ready for other lifecycle commands
/planning:spec create my-feature
/iterate:tasks my-feature
```

### Direct Management Workflow (Backward Compatible)

```bash
# 1. Detect project tech stack
/foundation:detect

# 2. Check environment
/foundation:env-check

# 3. Configure MCP servers directly
/foundation:mcp-manage add playwright
/foundation:mcp-manage install supabase

# 4. Setup environment variables
/foundation:env-vars template
/foundation:env-vars check

# 5. Now ready for other lifecycle commands
/planning:spec create my-feature
/iterate:tasks my-feature
```

## Version

**2.1.0** - Universal MCP Registry, format conversion, improved API key management
- Added /foundation:mcp-registry command for universal registry management
- Added /foundation:mcp-sync command for format conversion (Claude Code ↔ VS Code)
- 7 new scripts: registry-init, registry-add, registry-list, registry-sync, transform-claude, transform-vscode
- .env.example template with all known MCP API keys
- marketplace.json reference for VS Code pre-installed servers
- Updated /foundation:mcp-manage with registry workflow recommendations

**1.0.0** - Initial release with complete MCP management, tech stack detection, and environment validation
