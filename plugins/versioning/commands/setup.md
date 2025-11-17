---
description: Setup semantic versioning with validation and templates for Python and TypeScript projects
argument-hint: [python|typescript|javascript]
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

**Arguments**: $ARGUMENTS

Goal: Setup automated semantic versioning with GitHub Actions, conventional commits, and package publishing

Core Principles:
- Detect project type or accept user override
- Validate prerequisites before setup
- Copy appropriate workflow templates from skills
- Create VERSION file and sync with project manifests
- Provide clear next steps for completion

## Available Skills

- **version-manager**: Workflow templates, validation scripts, and version file management

To use a skill: `!{skill skill-name}`

---

## Phase 1: Detect Project Type

Actions:
- Parse $ARGUMENTS for project type (python, typescript, javascript)
- If not provided, detect from files:
  - Python: pyproject.toml, setup.py, or requirements.txt exists
  - TypeScript: package.json + tsconfig.json exists
  - JavaScript: package.json exists (no tsconfig.json)
- If unable to detect, use AskUserQuestion:
  - "Which project type?" Options: Python, TypeScript, JavaScript

## Phase 2: Validate Prerequisites

Actions:
- Verify git repository: `!{bash git rev-parse --git-dir 2>&1}`
- Check git config: `!{bash git config user.name && git config user.email}`
- For Python: Verify pyproject.toml has [project] section
- For TypeScript/JavaScript: Verify package.json exists
- Check for existing VERSION file: `!{bash test -f VERSION && echo "exists" || echo "not found"}`
- Verify .github/workflows directory: `!{bash mkdir -p .github/workflows}`

If prerequisites fail, display error and provide fix instructions.

## Phase 3: Delegate to Setup Agent

Route to appropriate setup agent based on project type:

**For Python projects:**
```
Task(
  description="Setup Python versioning",
  subagent_type="versioning:python-version-setup",
  prompt="Setup Python backend versioning with bump-my-version, GitHub Actions, and PyPI publishing support.

**Input Parameters**:
- project_path: current directory
- release_branches: ['main', 'master']
- github_actions: true
- pypi_publish: false (default, can be enabled via flag)

Execute all setup steps and return completion status."
)
```

**For TypeScript/JavaScript projects:**
```
Task(
  description="Setup TypeScript/JavaScript versioning",
  subagent_type="versioning:typescript-version-setup",
  prompt="Setup TypeScript frontend versioning with semantic-release, GitHub Actions, and NPM publishing support.

**Input Parameters**:
- project_path: current directory
- release_branches: ['main', 'master']
- github_actions: true
- npm_publish: false (default, can be enabled via flag)

Execute all setup steps and return completion status."
)
```

## Phase 4: Verify Setup

Actions:
- Confirm VERSION file exists: `!{bash cat VERSION | jq .}`
- Confirm workflow exists: `!{bash test -f .github/workflows/version-management.yml && echo "✓ Created" || echo "✗ Missing"}`
- Confirm commit template: `!{bash test -f .gitmessage && echo "✓ Created" || echo "✗ Missing"}`
- Display created files and their purposes

## Phase 5: Summary

Actions:
- Display setup completion:
  ```
  ✅ Semantic Versioning Setup Complete

  Project Type: $PROJECT_TYPE
  Current Version: <version from VERSION file>

  Files Created:
  - VERSION (version tracking)
  - .github/workflows/version-management.yml (automated releases)
  - .gitmessage (commit template)
  - CONVENTIONAL_COMMITS.md (commit guidelines)
  ```

- Provide next steps:
  1. Review CONVENTIONAL_COMMITS.md for commit format
  2. Make a commit using conventional format: `git commit -m "feat: add new feature"`
  3. Push to main branch to trigger automated versioning
  4. Configure repository secrets (for publishing):
     - Python: PYPI_API_TOKEN
     - TypeScript/JavaScript: NPM_TOKEN
  5. Use `/versioning:bump` to manually bump version
  6. Use `/versioning:info` to check current status

- Display helpful commands:
  - View version: `/versioning:info status`
  - Bump version: `/versioning:bump patch`
  - Generate changelog: Use GitHub Actions (automatic on push)
