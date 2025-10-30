---
description: Verify required tools are installed for detected tech stack
argument-hint: [--fix]
allowed-tools: Read(*), Write(*), Bash(*), Glob(*), Grep(*), AskUserQuestion(*)
---

**Arguments**: $ARGUMENTS

Goal: Check that all required tools for the detected tech stack are installed and properly configured

Core Principles:
- Detect required tools from .claude/project.json
- Check versions match requirements
- Provide installation instructions for missing tools
- Support --fix flag for automatic installation

## Phase 1: Discovery

Goal: Load detected stack and determine required tools

Actions:
- Load project configuration: @.claude/project.json
- Parse detected framework, languages, and AI stack
- Determine required tools based on stack:
  - Node.js projects: node, npm/pnpm/yarn
  - Python projects: python, pip/poetry/uv
  - Go projects: go
  - Rust projects: cargo
  - AI projects: Additional SDK CLIs
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
