---
description: Install standardized git hooks (secret scanning, commit message validation, security checks) and GitHub Actions security workflow
argument-hint: [project-path]
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

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

Goal: Install standardized git hooks AND GitHub Actions workflow into the project to enforce security best practices both locally (git hooks) and on the server (GitHub Actions)

Core Principles:
- Security first - prevent secrets from being committed
- Enforce conventions - validate commit messages
- Tech-agnostic - works with any language/framework
- Non-invasive - hooks can be bypassed with --no-verify if needed

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

Goal: Understand the project and git repository setup

Actions:
- Parse $ARGUMENTS for project path (default: current directory)
- Check if this is a git repository:
  - !{bash git rev-parse --git-dir 2>/dev/null || echo "Not a git repo"}
- Locate .git/hooks directory:
  - !{bash ls -la .git/hooks/ 2>/dev/null | head -10}
- Check for existing hooks that might be overwritten:
  - !{bash ls .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push 2>/dev/null || echo "No existing hooks"}

## Phase 2: Execution

Goal: Install git hook scripts AND GitHub Actions workflow using installation script

Actions:
- Get the marketplace plugin directory to locate hook templates
- Run the installation script:
  - !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/git-hooks/scripts/install-hooks.sh}
- Installation script will:
  - Copy hook templates from skills/git-hooks/templates/
  - Install pre-commit, commit-msg, and pre-push hooks (local security)
  - Create .github/workflows/security-scan.yml (server-side security)
  - Make hooks executable
  - Display confirmation

## Phase 3: Verification

Goal: Verify hooks and GitHub workflow are properly installed

Actions:
- List installed local hooks:
  - !{bash ls -lh .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push 2>/dev/null}
- Verify hooks are executable:
  - !{bash test -x .git/hooks/pre-commit && echo "✓ pre-commit is executable" || echo "✗ pre-commit not executable"}
  - !{bash test -x .git/hooks/commit-msg && echo "✓ commit-msg is executable" || echo "✗ commit-msg not executable"}
  - !{bash test -x .git/hooks/pre-push && echo "✓ pre-push is executable" || echo "✗ pre-push not executable"}
- Verify GitHub workflow was created:
  - !{bash test -f .github/workflows/security-scan.yml && echo "✓ GitHub Actions workflow created" || echo "✗ GitHub workflow not found"}

## Phase 4: Summary

Goal: Report installation status and usage

Actions:
- Display success message with installed hooks and workflow
- Explain what each LOCAL hook does:
  - **pre-commit**: Scans staged files for API keys, tokens, passwords, and secrets
  - **commit-msg**: Validates commit messages follow conventional commits format (feat|fix|docs|style|refactor|test|chore|perf|ci|build)
  - **pre-push**: Runs security scans before pushing (npm audit, safety check)
- Explain what the GITHUB WORKFLOW does:
  - **security-scan.yml**: Runs comprehensive security scans on push/PR/weekly schedule
  - Scans for: secrets, dependency vulnerabilities, OWASP patterns
  - Generates security reports and comments on PRs
  - Fails builds if critical vulnerabilities detected
- Show how to bypass hooks if needed:
  - "Use `git commit --no-verify` to bypass local hooks (not recommended)"
  - "Use `git push --no-verify` to bypass local pre-push hook"
  - "GitHub Actions cannot be bypassed - runs on server"
- Suggest testing the hooks:
  - "Test pre-commit: Try committing a file with 'password=secret123'"
  - "Test commit-msg: Try committing with message 'fixed bug' (should fail)"
  - "Test GitHub workflow: Commit and push to trigger security scan"
- Next steps:
  - "Local hooks are now active for all commits and pushes"
  - "GitHub workflow will run automatically on push/PR"
  - "Commit and push .github/workflows/security-scan.yml to activate server-side scanning"
  - "Run /foundation:env-check to verify other tools"
