# Development Lifecycle Marketplace

**Tech-agnostic workflow automation - from spec to production in 5 lifecycle phases.**

---

## What This Is

The **dev-lifecycle-marketplace** provides structured development workflow plugins that work with ANY tech stack. These plugins handle **HOW you develop** (process and methodology), not **WHAT you develop with** (specific SDKs or frameworks).

**Key Concept:** Lifecycle plugins are completely tech-agnostic. They detect your project's tech stack and adapt accordingly.

---

## Architecture: 5 Lifecycle Plugins

### 1. **01-core** - Foundation & Setup
Initialize projects, detect tech stack, configure version control, set up MCP servers

**Commands:**
- `/core:init` - Initialize project structure
- `/core:detect` - Detect and document tech stack
- `/core:project-setup` - Complete project setup
- `/core:upgrade-to` - Upgrade dependencies

**What it does:**
- Creates `.claude/project.json` with detected framework, languages, structure
- Initializes git repository if needed
- Sets up MCP configuration
- Bootstraps project from scratch OR detects existing project

---

### 2. **02-develop** - Code Generation & Implementation
Build features, scaffold code, implement functionality

**Commands:**
- `/develop:feature` - Implement new features
- `/develop:component` - Create components
- `/develop:api` - Build API endpoints
- `/develop:scaffold` - Generate boilerplate code

**What it does:**
- Reads `.claude/project.json` to understand your tech stack
- Generates code following your project's patterns
- Uses framework-specific conventions (Next.js vs Django vs Rails, etc.)
- Integrates with planning specs

---

### 3. **03-planning** - Spec → Architecture
Create specifications, plans, architecture, documentation

**Commands:**
- `/planning:spec-create` - Create project specifications
- `/planning:architecture` - Design system architecture
- `/planning:roadmap` - Create development roadmap

**What it does:**
- Generates specs in `specs/` directory
- Creates architecture documentation
- Plans features and milestones
- Documents technical decisions

---

### 4. **04-iterate** - Refinement & Adjustment
Modify, refactor, enhance, sync during active development

**Commands:**
- `/iterate:adjust` - Modify existing features
- `/iterate:sync` - Coordinate multi-agent work
- `/iterate:tasks` - Task management

**What it does:**
- Makes targeted adjustments to code
- Coordinates changes across multiple agents
- Manages task lists and priorities
- Refactors code while preserving functionality

---

### 5. **05-quality** - Testing & Validation
Test, validate, secure, optimize, ensure compliance

**Commands:**
- `/quality:test` - Run all tests
- `/quality:test-generate` - Generate test suites
- `/quality:validate` - Comprehensive validation
- `/quality:security` - Security audit
- `/quality:performance` - Performance analysis

**What it does:**
- Detects your test framework (Jest, Pytest, Go test, RSpec, etc.)
- Generates framework-appropriate tests
- Runs security audits
- Validates compliance
- Checks performance

**Testing Infrastructure:**
The root directory contains testing harnesses that 05-quality configures:
- `test-automation.js` - Test orchestration
- `test-real-mcp.js` - MCP testing utilities
- `playwright-mcp-wrapper.js` - Playwright wrapper for E2E tests
- `package.json` - Testing framework dependencies

These get adapted based on your detected project type.

---

## How It Works: Tech-Agnostic Design

### Detection System

All lifecycle plugins read `.claude/project.json`:

```json
{
  "framework": "nextjs",
  "language": "typescript",
  "ui_library": "react",
  "css": "tailwind",
  "database": "supabase",
  "ai_sdk": "vercel-ai-sdk",
  "test_framework": "jest",
  "package_manager": "npm"
}
```

This file is created by `/core:detect` and used by ALL other lifecycle commands.

### Example: Testing Different Frameworks

When you run `/quality:test`:

**Next.js project detected:**
```bash
npm run test  # Runs Jest tests
```

**Python/Django project detected:**
```bash
pytest tests/  # Runs Pytest
```

**Go project detected:**
```bash
go test ./...  # Runs Go tests
```

**Rails project detected:**
```bash
bundle exec rspec  # Runs RSpec
```

Same command, different execution based on detected stack!

---

## How It Works with Tech Plugins

Lifecycle plugins work TOGETHER with tech-specific plugins from [ai-dev-marketplace](https://github.com/vanman2024/ai-dev-marketplace):

```
┌─────────────────────────────────────────┐
│  dev-lifecycle-marketplace (THIS REPO)  │  ← HOW you develop
│  - 01-core, 02-develop, 03-planning     │    (Process & workflow)
│  - 04-iterate, 05-quality               │
└─────────────────────────────────────────┘
              ↓ works with
┌─────────────────────────────────────────┐
│  ai-dev-marketplace                     │  ← WHAT you develop with
│  - vercel-ai-sdk, mem0, supabase        │    (SDKs & frameworks)
│  - nextjs, react, etc.                  │
└─────────────────────────────────────────┘
```

### Complete Workflow Example

```bash
# 1. Initialize with lifecycle (tech-agnostic)
/core:init my-ai-chatbot

# 2. Install tech plugins from ai-dev-marketplace
claude plugin install vercel-ai-sdk --source github:vanman2024/ai-dev-marketplace
claude plugin install supabase --source github:vanman2024/ai-dev-marketplace

# 3. Create architecture plan (lifecycle)
/planning:spec-create ai-chatbot

# 4. Initialize tech tools (tech-specific)
/vercel-ai-sdk:new-app my-chatbot
/supabase:init

# 5. Build features (tech-specific)
/vercel-ai-sdk:add-streaming
/vercel-ai-sdk:add-data-features

# 6. Test and validate (lifecycle - detects Jest/Vitest automatically)
/quality:test-generate
/quality:test

# 7. Iterate and refine (lifecycle)
/iterate:adjust "Add conversation search"

# 8. Final validation (lifecycle)
/quality:security
/quality:performance

# 9. Deploy (lifecycle - detects Vercel/AWS/etc.)
/deploy:run
```

**Result:** Lifecycle provides structure, tech plugins provide implementation.

---

## Framework Agnostic Examples

### Detecting Your Stack

```bash
/core:detect

# Output for Next.js project:
# ✅ Framework: Next.js 14 (App Router)
# ✅ Language: TypeScript
# ✅ UI: React + Tailwind CSS
# ✅ Package Manager: npm
# ✅ Saved to .claude/project.json

# Output for Django project:
# ✅ Framework: Django 5.0
# ✅ Language: Python 3.11
# ✅ Database: PostgreSQL
# ✅ Package Manager: pip
# ✅ Saved to .claude/project.json

# Output for Go project:
# ✅ Framework: Go 1.21
# ✅ Web Framework: Gin
# ✅ Database: PostgreSQL
# ✅ Package Manager: go mod
# ✅ Saved to .claude/project.json
```

### Generating Tests (Framework-Aware)

```bash
/quality:test-generate

# For TypeScript/Jest:
# ✅ Created tests/api/chat.test.ts
# ✅ Created tests/components/ChatUI.test.tsx
# ✅ Using Jest + React Testing Library

# For Python/Pytest:
# ✅ Created tests/test_api.py
# ✅ Created tests/test_models.py
# ✅ Using Pytest + fixtures

# For Go:
# ✅ Created api/chat_test.go
# ✅ Created models/conversation_test.go
# ✅ Using Go testing package
```

---

## When to Use Lifecycle Plugins

### ✅ Use Lifecycle Plugins When:
- You want structured development phases
- Working on complex multi-phase projects
- Coordinating multiple agents
- Need consistent workflow across different tech stacks
- Want automated testing/validation infrastructure

### ⚠️ Don't Need Lifecycle Plugins When:
- Quick prototyping with single tech stack
- Already have your own workflow/process
- Just want to use specific SDK (Vercel AI, etc.)
- Prefer manual control over each step

**Lifecycle plugins are OPTIONAL** - tech plugins work standalone!

---

## Installation

### Option 1: Install from GitHub

```bash
# Install entire lifecycle marketplace
claude marketplace add dev-lifecycle-marketplace \
  --source github:vanman2024/dev-lifecycle-marketplace

# Install individual lifecycle plugins
claude plugin install 01-core \
  --source github:vanman2024/dev-lifecycle-marketplace/plugins/01-core
```

### Option 2: Clone and Install Locally

```bash
# Clone repository
git clone https://github.com/vanman2024/dev-lifecycle-marketplace.git
cd dev-lifecycle-marketplace

# Install plugins
claude plugin install 01-core --project
claude plugin install 02-develop --project
claude plugin install 03-planning --project
claude plugin install 04-iterate --project
claude plugin install 05-quality --project
```

### Option 3: Use with Tech Stack Marketplace

Some tech stack marketplaces automatically include lifecycle plugins:

```bash
# Install a curated tech stack that includes lifecycle
claude marketplace add ai-chatbot-stack-complete \
  --source github:vanman2024/ai-chatbot-stack-marketplace

# This might include:
# - dev-lifecycle-marketplace (lifecycle workflow)
# - vercel-ai-sdk, mem0, supabase (tech stack)
```

---

## Testing Infrastructure

The root directory contains testing harnesses that work across frameworks:

### test-automation.js
- Test orchestration and execution
- Framework detection (Jest, Vitest, Pytest, RSpec, Go test)
- Parallel test running
- Coverage reporting

### test-real-mcp.js
- MCP server testing utilities
- Tool validation
- Integration testing helpers

### playwright-mcp-wrapper.js
- E2E testing with Playwright
- Browser automation
- Visual regression testing

### package.json
- Testing framework dependencies
- Test runner configurations
- Coverage tools

**How it works:**
1. `/core:detect` identifies your test framework
2. `/quality:test-generate` creates tests using your framework
3. `/quality:test` uses the appropriate harness to run tests

---

## Status

**Current Plugins:**
- ✅ 01-core (Foundation & Setup)
- ✅ 02-develop (Code Generation)
- ✅ 03-planning (Spec → Architecture)
- ✅ 04-iterate (Refinement)
- ✅ 05-quality (Testing & Validation)

**Coming Soon:**
- 06-deploy (Deployment & Monitoring)

---

## Related Repositories

- **[ai-dev-marketplace](https://github.com/vanman2024/ai-dev-marketplace)** - Tech-specific plugins (SDKs, frameworks, platforms)
- **[ai-tech-stack-marketplaces](https://github.com/vanman2024/)** - Curated tech stack combinations

---

## Contributing

Contributions welcome! Lifecycle plugins should remain **completely tech-agnostic**.

**Guidelines:**
- Never hardcode framework-specific logic in lifecycle plugins
- Always read `.claude/project.json` for tech stack info
- Provide clear fallbacks when detection fails
- Test with multiple frameworks (Next.js, Django, Go, Rails, etc.)
- Document what project structures are supported

---

## License

MIT License - See LICENSE file

---

**Tech-agnostic workflow automation. Works with ANY stack.**
