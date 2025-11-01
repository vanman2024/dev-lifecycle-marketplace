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
MCP server configuration templates, .mcp.json management, API key handling

**Provides:**
- 5 helper scripts (init, add, validate, keys, install)
- 6 configuration templates (basic, stdio, HTTP, FastMCP, TypeScript, multi-server)
- 5 comprehensive examples (15,000+ words of documentation)

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
│   ├── detect.md
│   ├── env-check.md
│   └── env-vars.md
├── agents/
│   └── stack-detector.md
├── skills/
│   ├── mcp-configuration/
│   │   ├── SKILL.md
│   │   ├── scripts/ (5 scripts)
│   │   ├── templates/ (6 templates)
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

## Workflow Example

```bash
# 1. Detect project tech stack
/foundation:detect
# Creates .claude/project.json with detected stack

# 2. Check environment
/foundation:env-check
# Verifies all required tools are installed

# 3. Configure MCP servers
/foundation:mcp-manage add playwright
/foundation:mcp-manage install supabase

# 4. Setup environment variables
/foundation:env-vars template
# Edit .env with required values
/foundation:env-vars check

# 5. Now ready for other lifecycle commands
/planning:spec create my-feature
/iterate:tasks my-feature
```

## Version

**1.0.0** - Initial release with complete MCP management, tech stack detection, and environment validation
