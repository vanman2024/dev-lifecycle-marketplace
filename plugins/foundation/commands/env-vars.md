---
description: Manage environment variables for project configuration
argument-hint: <action> [key] [value]
allowed-tools: Read, Write, Bash, AskUserQuestion, Task
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

Goal: Scan codebase to detect ALL environment variables used, generate .env file, and manage environment configuration

Core Principles:
- **Scan actual codebase** to detect environment variable usage
- Secure handling - never log sensitive values
- Support .env files and Doppler integration
- **Use env-detector agent** for comprehensive multi-source analysis
- Generate complete .env template from detected variables

## Available Skills

This command has access to foundation plugin skills:

- **environment-setup**: Tool verification and system checks
- **mcp-configuration**: MCP server configuration management
- **project-detection**: Tech stack and dependency detection

To use a skill: `!{skill skill-name}`

---

## Phase 1: Parse Action

Goal: Understand what the user wants to do

Actions:
- Parse $ARGUMENTS for action:
  - **scan**: Detect required environment variables (dry-run, no files created)
  - **generate**: Create .env and .env.example files with placeholders
  - **setup-multi-env**: Generate multi-environment configs (dev, staging, prod)
  - **add**: Add/update a single variable
  - **remove**: Remove a variable
  - **list**: Show all variables (mask values)
  - **check**: Compare .env against codebase requirements
  - **sync-from-doppler**: Download from Doppler → .env
  - **sync-to-doppler**: Upload from .env → Doppler
- Extract additional parameters (key, value, environment, project name)
- If action unclear, use AskUserQuestion:
  - "What would you like to do?"
  - Options: scan, generate, setup-multi-env, add, remove, list, check, sync

## Phase 2: Validate Prerequisites

Goal: Check requirements before execution

Actions:
- Check if .env exists: @.env (ignore if missing)
- For Doppler actions (sync-from-doppler, sync-to-doppler):
  - Verify Doppler CLI: !{bash which doppler && doppler --version || echo "not-installed"}
  - If not installed: "Run '/foundation:doppler-setup' to install Doppler CLI"
  - Verify authentication: !{bash doppler me 2>&1}
  - If not authenticated: "Run 'doppler login' or '/foundation:doppler-setup'"
- Display prerequisites status

## Phase 3: Execute Action via Agent

Goal: Delegate complex logic to specialized agent

Actions:
- **Launch env-vars-manager agent** with action and context:

```
Task(
  description="Manage environment variables",
  subagent_type="foundation:env-vars-manager",
  prompt="You are the env-vars-manager agent.

**Action**: $ARGUMENTS

**Context**:
- Current directory: $(pwd)
- .env exists: yes/no
- Doppler status: installed/not-installed

**Instructions**:

For 'scan' action:
- Detect environment variables from ALL sources (priority order):
  1. specs/*.md files (analyze service requirements)
  2. package.json/requirements.txt dependencies (detect SDKs)
  3. Code scans (search for process.env.*, os.getenv patterns)
- Merge and deduplicate results
- Display detection report WITHOUT creating files
- Show: services detected, required variables, detection sources
- Suggest: 'Run /foundation:env-vars generate to create files'

For 'generate' action:
- Use scan results to generate .env with placeholders
- Format with service sections and comments
- Create .env.example (same structure, safe to commit)
- Ensure .env in .gitignore
- Report: files created, variable count, services detected

For 'setup-multi-env' action:
- Ask for project name and environments (dev, staging, prod)
- Generate .env.{environment} files for each
- Include environment-specific placeholders
- Create Doppler project setup guide
- Report: files created for each environment

For 'add' action:
- Validate key format (UPPERCASE_SNAKE_CASE)
- Add/update variable in .env
- Never log the value
- Report: 'Added {key} to .env'

For 'remove' action:
- Remove variable from .env
- Report: 'Removed {key} from .env'

For 'list' action:
- Display all variables with masked values
- Show KEY=*** for sensitive keys
- Report count and file location

For 'check' action:
- Compare .env against codebase requirements
- Report missing variables (with usage locations)
- Report unused variables (cleanup candidates)
- Suggest fixes

For 'sync-from-doppler' action:
- Parse environment from arguments (default: dev)
- Download: doppler secrets download --config $ENV --no-file --format env > .env
- Report: variables synced, environment, backup location

For 'sync-to-doppler' action:
- Parse .env file
- Upload each variable: doppler secrets set KEY=value --config $ENV
- Report: variables uploaded, environment

**Deliverable**: Execution results with clear status messages
"
)
```

## Phase 4: Summary

Goal: Report results and next steps

Actions:
- Display agent execution results
- For 'scan' action:
  - "Found {count} required variables from {sources}"
  - "Run '/foundation:env-vars generate' to create .env files"
- For 'generate' action:
  - "Created .env and .env.example with {count} variables"
  - "Update placeholder values in .env before running your app"
- For Doppler actions:
  - "Synced {count} variables with Doppler ({environment})"
  - "Run 'doppler run -- <command>' to use secrets"
- For 'check' action:
  - "✓ All required variables present" OR
  - "⚠️ Missing {count} variables (see above)"
- Provide context-appropriate next steps
