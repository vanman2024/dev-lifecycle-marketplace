---
allowed-tools: Task(*), Read(*), Write(*), Bash(*), Glob(*), AskUserQuestion(*)
description: Initialize project - detect OR bootstrap new project, create .claude/project.json
argument-hint: [--bootstrap] [--force]
---

**Arguments**: $ARGUMENTS

## Step 1: Check if Project Already Initialized

Check for existing project configuration:

!{bash test -f ".claude/project.json" && echo "PROJECT_EXISTS" || echo "PROJECT_NEW"}

**If PROJECT_EXISTS and no --force flag:**
- Load existing configuration: @.claude/project.json
- Display current project state
- Ask user: "Project already initialized. Use --force to reinitialize or run /core:detect to update detection."
- Exit

**If --force flag provided:**
- Backup existing: !{bash cp .claude/project.json .claude/project.json.backup-$(date +%Y%m%d_%H%M%S)}
- Continue to detection

## Step 2: Determine Initialization Mode

**Bootstrap Mode** (--bootstrap flag OR no existing code detected):
- User is starting a brand new project
- Will scaffold minimal structure
- Guide user through setup wizard

**Detection Mode** (default - existing code detected):
- Project has existing code
- Will analyze and detect framework/stack
- Will preserve existing structure

Check for existing code:

!{bash find . -maxdepth 2 -type f \( -name "package.json" -o -name "requirements.txt" -o -name "Cargo.toml" -o -name "go.mod" -o -name "pom.xml" \) 2>/dev/null | head -5}

**If files found:** Detection mode
**If no files found:** Ask user to confirm bootstrap mode

## Step 3: Bootstrap Mode (New Project)

**If bootstrap mode:**

Ask user for project details:

AskUserQuestion:
- Project type? (landing-page, website, web-app, ai-app, saas, api, cli, library)
- Framework preference? (Next.js, React, Vue, Django, FastAPI, Express, Go, Rust)
- Language? (TypeScript, JavaScript, Python, Go, Rust, Java)

Create minimal project structure:

!{bash mkdir -p .claude src tests docs}

Create initial project.json:

Write .claude/project.json with detected/chosen values:
- type, framework, language from user choices
- initialized timestamp
- structure paths (src/, tests/, docs/)
- status: "bootstrapped"

## Step 4: Detection Mode (Existing Project)

**If detection mode:**

Delegate to project-detector agent:

Task(
  description="Detect project framework and structure",
  subagent_type="project-detector",
  prompt="Analyze this project and detect its framework, stack, and structure.

**Detection Requirements:**
- Identify framework (Next.js, Django, FastAPI, Express, Go, Rust, etc.)
- Detect language and version
- Find project structure (src/, components/, pages/, etc.)
- Identify package manager (npm, yarn, pnpm, pip, cargo, go mod)
- Detect testing framework (Jest, Pytest, Go test, etc.)
- Find build tools (Vite, Webpack, etc.)
- Identify any monorepo setup (Turborepo, Nx, etc.)

**Analysis Sources:**
- Configuration files (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
- Directory structure
- Import patterns in code
- Build scripts and tooling

**Deliverables:**
- Write complete analysis to .claude/project.json
- Include detected framework, language, structure, tools
- Mark as 'detected' status
- Preserve project-agnostic format for plugin usage

**CRITICAL - Project-Agnostic Output:**
The project.json MUST be usable by ALL plugins without hardcoded assumptions.
Include paths for: components, pages, api routes, tests, docs, config, etc."
)

Wait for detection to complete.

## Step 5: Validate Project Configuration

Read the generated configuration:

@.claude/project.json

Verify required fields:
- type (project type)
- framework (detected or chosen)
- language (detected or chosen)
- structure (directory paths)

## Step 6: Initialize Git (Optional)

Check if git is initialized:

!{bash test -d ".git" && echo "GIT_EXISTS" || echo "GIT_NEW"}

**If GIT_NEW:**
- Ask user: "Initialize git repository?"
- If yes: !{bash git init && echo "Git initialized"}
- Create .gitignore if needed

## Step 7: Report Initialization Complete

Display summary:
- Project type: [TYPE]
- Framework: [FRAMEWORK]
- Language: [LANGUAGE]
- Structure detected/created
- Configuration saved to .claude/project.json

**Next steps:**
- Run `/core:detect` to update detection
- Run `/planning:spec` to create specifications
- Run `/develop:feature` to start building

**Configuration location:** .claude/project.json
