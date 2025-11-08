---
description: Verify required tools are installed for detected tech stack
argument-hint: [--fix]
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Check that all required tools for the detected tech stack are installed and properly configured

Core Principles:
- Scan codebase to detect tech stack (no .claude/project.json dependency)
- Check versions match requirements
- Provide installation instructions for missing tools
- Support --fix flag for automatic installation

## Available Skills

This commands has access to the following skills from the foundation plugin:

- **environment-setup**: Environment verification, tool checking, version validation, and path configuration. Use when checking system requirements, verifying tool installations, validating versions, checking PATH configuration, or when user mentions environment setup, system check, tool verification, version check, missing tools, or installation requirements.
- **git-hooks**: 
- **mcp-configuration**: Comprehensive MCP server configuration templates, .mcp.json management, API key handling, and server installation helpers. Use when configuring MCP servers, managing .mcp.json files, setting up API keys, installing MCP servers, validating MCP configs, or when user mentions MCP setup, server configuration, MCP environment, API key storage, or MCP installation.
- **mcp-server-config**: Manage .mcp.json MCP server configurations. Use when configuring MCP servers, adding server entries, managing MCP config files, or when user mentions .mcp.json, MCP server setup, server configuration.
- **project-detection**: Comprehensive tech stack detection, framework identification, dependency analysis, and project.json generation. Use when analyzing project structure, detecting frameworks, identifying dependencies, discovering AI stack components, detecting databases, or when user mentions project detection, tech stack analysis, framework discovery, or project.json generation.

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---


## Phase 1: Discovery

Goal: Scan project to detect tech stack and determine required tools

Actions:
- Scan for manifest files to detect stack:
  - !{bash ls package.json pyproject.toml go.mod Cargo.toml 2>/dev/null}
  - Check package.json dependencies for frameworks (Next.js, React, etc.)
  - Check pyproject.toml for Python frameworks (FastAPI, Django, etc.)
  - Look for framework-specific files (next.config.js, manage.py, etc.)
- Determine required tools based on detected files:
  - package.json → node, npm/pnpm/yarn
  - pyproject.toml → python, pip/poetry/uv
  - go.mod → go
  - Cargo.toml → cargo
  - AI dependencies → Additional SDK CLIs
- Check for --fix flag in $ARGUMENTS

## Phase 2: Validation

Goal: Check each required tool

Actions:
- For each required tool, check if installed:
  - !{bash command -v node && node --version}
  - !{bash command -v python && python --version}
  - !{bash command -v go && go version}
  - !{bash command -v cargo && cargo --version}
- Check version compatibility
- Detect package manager (npm, pnpm, yarn, pip, poetry, uv)
- Check AI SDK CLIs if applicable:
  - !{bash command -v vercel}
  - !{bash command -v supabase}

## Phase 3: Execution

Goal: Report status or fix missing tools

Actions:
- **If all tools present:**
  - Report success with versions
  - Skip to Phase 4

- **If tools missing and --fix flag:**
  - Show installation commands
  - Ask user to confirm installation
  - If confirmed, install missing tools
  - Example: !{bash curl -fsSL https://get.pnpm.io/install.sh | sh}

- **If tools missing without --fix:**
  - Report missing tools
  - Provide installation instructions

## Phase 4: Summary

Goal: Display tool status

Actions:
- Show status table with tool versions and status
- Format: Tool name, version, status (✓ or ✗)
- If missing tools, suggest: "/foundation:env-check --fix"
- If all present: "Environment ready for {detected-stack}"
