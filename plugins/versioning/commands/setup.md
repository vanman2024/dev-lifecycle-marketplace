---
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion, Task
description: Setup semantic versioning with validation and templates for Python and TypeScript projects
argument-hint: [python|typescript|javascript]
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

Launch version-setup-orchestrator agent to handle complex setup:

```
Task(
  description="Setup semantic versioning",
  subagent_type="versioning:version-setup-orchestrator",
  prompt="You are the version-setup-orchestrator agent.

**Project Type**: $PROJECT_TYPE (python/typescript/javascript)

**Tasks**:

1. Create VERSION file:
   - Read current version from project manifest (pyproject.toml or package.json)
   - Default to 0.1.0 if not found
   - Create VERSION file with JSON structure:
     {
       \"version\": \"<current_version>\",
       \"commit\": \"initial\",
       \"build_date\": \"<iso_timestamp>\",
       \"build_type\": \"development\"
     }

2. Install GitHub Actions workflow:
   - Copy template from version-manager skill:
     * Python: templates/workflows/python-version-management.yml
     * TypeScript/JavaScript: templates/workflows/npm-version-management.yml
   - Place in .github/workflows/version-management.yml
   - Verify workflow file created

3. Create commit message template:
   - Copy from version-manager skill: templates/commit-msg-template.txt
   - Place in .gitmessage
   - Configure git: git config commit.template .gitmessage

4. Create conventional commits guide:
   - Generate CONVENTIONAL_COMMITS.md from skill examples
   - Include: feat, fix, docs, style, refactor, test, chore
   - Provide examples for each type

5. Add .gitignore entries:
   - Ensure VERSION file is tracked (NOT ignored)
   - Add version-related build artifacts to .gitignore

**Deliverable**: Setup completion status with file locations
"
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
