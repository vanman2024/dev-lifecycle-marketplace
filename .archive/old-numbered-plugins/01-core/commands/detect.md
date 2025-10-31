---
allowed-tools: Task, Read, Write, Bash, Glob
description: Analyze existing project structure and detect framework/stack
argument-hint: [--update] [--verbose]
---

**Arguments**: $ARGUMENTS

## Step 1: Check Current Directory

Verify we're in a project directory:

!{bash pwd}
!{bash ls -la | head -10}

## Step 2: Quick Scan for Project Files

Look for configuration files that indicate project type:

!{bash find . -maxdepth 2 -type f \( -name "package.json" -o -name "requirements.txt" -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "go.mod" -o -name "pom.xml" -o -name "composer.json" \) 2>/dev/null}

**If no project files found:**
- Display: "No project configuration files detected. This may be an empty directory."
- Suggest: "Run /core:init --bootstrap to create a new project"
- Exit

## Step 3: Delegate to Project Detector Agent

Task(
  description="Detect project framework and structure",
  subagent_type="project-detector",
  prompt="Analyze this project comprehensively and detect its complete technology stack and structure.

**Detection Scope:**

1. **Framework & Language:**
   - Identify primary framework (Next.js, React, Vue, Django, FastAPI, Express, Go, Rust, etc.)
   - Detect language and version (TypeScript, JavaScript, Python, Go, Rust, Java, etc.)
   - Find framework version from package files

2. **Project Structure:**
   - Map directory structure (src/, components/, pages/, api/, tests/, docs/, etc.)
   - Identify architectural patterns (monorepo, microservices, modular monolith)
   - Detect entry points and main files

3. **Tooling & Build System:**
   - Package manager (npm, yarn, pnpm, pip, poetry, cargo, go mod, maven, gradle)
   - Build tools (Vite, Webpack, Rollup, esbuild, Turbopack)
   - Task runners (npm scripts, make, just)

4. **Testing Framework:**
   - Unit testing (Jest, Vitest, Pytest, Go test, Rust test)
   - E2E testing (Playwright, Cypress, Selenium)
   - Test locations and patterns

5. **Development Tools:**
   - Linters (ESLint, Pylint, Clippy, golangci-lint)
   - Formatters (Prettier, Black, rustfmt, gofmt)
   - Type checkers (TypeScript, mypy, Flow)

6. **Infrastructure & Deployment:**
   - Containerization (Docker, docker-compose)
   - CI/CD configs (.github/workflows, .gitlab-ci.yml, etc.)
   - Deployment platforms (Vercel, Netlify, AWS, Railway, etc.)

7. **Dependencies & APIs:**
   - External APIs and SDKs used
   - Database connectors (Prisma, SQLAlchemy, GORM, Diesel)
   - Key dependencies and their purposes

**Analysis Method:**
- Read all configuration files (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
- Analyze directory structure patterns
- Check import statements in source files
- Review build and deployment scripts
- Identify monorepo structure if present (Turborepo, Nx, Lerna, workspaces)

**Output Format:**
Write complete analysis to .claude/project.json with structure:
- type: Project type (web-app, api, cli, library, etc.)
- framework: Primary framework detected
- language: Primary language and version
- structure: Directory mappings (components, pages, api, tests, etc.)
- tools: Build, test, lint, format tools
- dependencies: Key dependencies and their roles
- infrastructure: Docker, CI/CD, deployment info
- status: 'detected'
- detected_at: ISO timestamp

**CRITICAL - Project-Agnostic Format:**
The output MUST be usable by ALL lifecycle plugins without assumptions.
Include flexible path mappings that work for any project structure."
)

Wait for detection to complete.

## Step 4: Load and Display Results

Read the generated configuration:

@.claude/project.json

## Step 5: Display Summary

Show detected information:
- Project type and framework
- Primary language
- Key structure paths
- Build and test tools
- Deployment configuration

**If --verbose flag:**
- Display full dependency list
- Show all detected tools
- List all directory mappings

## Step 6: Save Detection Report

If --update flag provided or existing config needs refresh:
- Backup old config if it exists
- Write new detection results
- Display: "Project configuration updated in .claude/project.json"

## Step 7: Next Steps

Suggest appropriate commands based on detected project type:
- Run /planning:spec to create specifications
- Run /develop:feature to start building
- Run /quality:test to run detected test framework
- Run /deploy:deploy-prepare for deployment setup

**Configuration saved:** .claude/project.json
