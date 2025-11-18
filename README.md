# Development Lifecycle Marketplace

**Tech-agnostic workflow automation - from init to deploy in 7 lifecycle phases.**

**Version**: 2.0.0 (Rebuilt October 2025 + November 2025 additions)

---

## What This Is

The **dev-lifecycle-marketplace** provides structured development workflow plugins that work with ANY tech stack. These plugins handle **HOW you develop** (process and methodology), not **WHAT you develop with** (specific SDKs or frameworks).

**Key Concept:** Lifecycle plugins are completely tech-agnostic. They detect your project's tech stack and adapt accordingly.

---

## Architecture: 7 Lifecycle Plugins

### 1. **foundation** - Foundation & Setup
Initialize projects, detect tech stack, configure environment

**Commands:**
- `/foundation:init` - Initialize project structure
- `/foundation:detect-stack` - Detect and document tech stack
- `/foundation:setup-env` - Setup environment configuration
- `/foundation:verify-setup` - Verify project setup

**What it does:**
- Creates `.claude/project.json` with detected framework, languages, structure
- Initializes git repository if needed
- Sets up MCP configuration
- Bootstraps project from scratch OR detects existing project

**Components:**
- 4 commands
- 1 agent (stack-detector)
- 3 skills (framework-detection, environment-setup, project-initialization)

---

### 2. **planning** - Planning & Architecture
Create specifications, architecture designs, roadmaps, and ADRs

**Commands:**
- `/planning:plan` - Create comprehensive project plans
- `/planning:spec` - Write feature specifications
- `/planning:architecture` - Design system architecture
- `/planning:roadmap` - Create project roadmaps
- `/planning:decisions` - Document architectural decisions (ADRs)

**What it does:**
- Reads `.claude/project.json` to understand your project
- Creates detailed specifications and architecture documents
- Generates roadmaps with timelines
- Documents architectural decisions as ADRs
- Provides planning templates and patterns

**Components:**
- 5 commands
- 4 agents (spec-writer, architecture-designer, roadmap-planner, decision-documenter)
- 3 skills (specification-templates, architecture-patterns, adr-templates)

---

### 3. **iterate** - Iterative Development
Task management, code adjustments, refactoring, feature enhancement

**Commands:**
- `/iterate:adjust` - Adjust implementation based on feedback
- `/iterate:sync` - Sync implementation with specifications
- `/iterate:tasks` - Transform sequential tasks into layered tasks with agent assignments

**What it does:**
- Manages iterative development workflows
- Adjusts and refactors code based on feedback
- Enhances existing features
- Transforms tasks.md into organized layered-tasks.md with agent assignments
- Preserves critical task-layering agent from legacy system

**Components:**
- 3 commands
- 4 agents (implementation-adjuster, feature-enhancer, code-refactorer, task-layering)
- 1 skill (task-management)

**Special Note:** Preserves the critical task-layering agent that intelligently assigns agents to tasks.

---

### 4. **implementation** - Execution Orchestration
Automated feature building from layered tasks with tech-specific command mapping

**Commands:**
- `/implementation:execute` - Execute all layered tasks (L0→L3) sequentially
- `/implementation:execute-layer` - Execute specific layer only
- `/implementation:status` - Show execution progress
- `/implementation:continue` - Resume execution after pause/failure
- `/implementation:map-task` - Preview task-to-command mapping (dry-run)

**What it does:**
- Bridges the gap between planning and quality phases
- Automatically maps task descriptions to tech-specific commands
- Executes layered tasks with proper dependency management
- Tracks progress with `.claude/execution/` status files
- Handles retries and error recovery
- Auto-syncs with `/iterate:sync` after each layer

**Components:**
- 5 commands
- 4 agents (execution-orchestrator, task-mapper, command-executor, progress-tracker)
- 3 skills (command-mapping, execution-tracking, parallel-execution)

**Example Workflow:**
```bash
/planning:add-feature "AI chat interface"
/iterate:tasks F001
/implementation:execute F001  # Automatically executes all mapped commands
```

---

### 5. **quality** - Code Quality & Validation
Code validation, security scanning, and compliance checking

**Commands:**
- `/quality:validate-code` - Validate code against specs and security rules
- `/quality:security` - Run security scans and vulnerability checks
- `/quality:performance` - Analyze performance and identify bottlenecks

**What it does:**
- **Code Validation**: Review implementation against spec requirements
- **Security Scanning**: npm audit, safety, bandit, secret detection
- **Performance Analysis**: Lighthouse, profiling, bottleneck identification
- **Compliance Checking**: Licensing, code standards, regulatory requirements

**Components:**
- 3 commands
- 4 agents (code-validator, security-scanner, performance-analyzer, compliance-checker)
- 2 skills (security-patterns, validation-rules)

---

### 6. **testing** - Test Execution
Test suite execution with Newman/Postman (API) and Playwright (E2E)

**Commands:**
- `/testing:test` - Run comprehensive test suite (Newman API + Playwright E2E)
- `/testing:test-frontend` - Frontend-specific tests (component, visual, a11y, performance)
- `/testing:generate-tests` - Generate test suites from implementation

**What it does:**
- **Newman/Postman**: API testing with collections, environments, assertions, reporting
- **Playwright**: E2E browser testing with page object models, visual regression
- **DigitalOcean Webhooks**: $4-6/month webhook testing infrastructure
- **Frontend Testing**: Component tests (Jest/Vitest + RTL), visual regression, accessibility, performance
- **Test Generation**: Auto-generate tests from implementation code

**Components:**
- 3 commands
- 3 agents (test-suite-generator, frontend-test-generator, test-generator)
- 4 skills (newman-testing, playwright-e2e, frontend-testing, newman-runner, postman-collection-manager)

**Note:** Separate from quality plugin - quality validates, testing executes.

---

### 7. **deployment** - Deployment Orchestration
Automated deployment with platform detection

**Commands:**
- `/deployment:deploy` - Deploy application to detected platform
- `/deployment:prepare` - Prepare project for deployment
- `/deployment:validate` - Validate deployment configuration
- `/deployment:rollback` - Rollback to previous deployment

**What it does:**
- **Platform Detection**: Auto-detects project type and routes to appropriate platform
- **FastMCP Cloud**: MCP server hosting
- **Vercel**: Next.js/frontend deployments
- **Railway**: Backend/database deployments
- **DigitalOcean**: Full-stack hosting ($4-6/month)
- **Netlify/Cloudflare Pages**: Static site deployments

**Components:**
- 4 commands
- 3 agents (deployment-detector, deployment-deployer, deployment-validator)
- 3 skills (platform-detection, deployment-scripts, health-checks)

---

## Plugin Component Summary

| Plugin | Commands | Agents | Skills | Total |
|--------|----------|--------|--------|-------|
| foundation | 4 | 1 | 3 | 8 |
| planning | 5 | 4 | 4 | 13 |
| implementation | 5 | 4 | 3 | 12 |
| iterate | 3 | 4 | 1 | 8 |
| quality | 3 | 4 | 2 | 9 |
| testing | 3 | 3 | 5 | 11 |
| deployment | 4 | 3 | 3 | 10 |
| **TOTAL** | **27** | **23** | **21** | **71** |

---

## Quick Start

### Complete Workflow Example

```bash
# 1. Initialize Project
/foundation:init my-new-project
/foundation:detect

# 2. Create Feature Specifications
/planning:add-feature "user authentication"

# 3. Layer Tasks for Parallel Execution
/iterate:tasks F001

# 4. Execute Implementation Automatically
/implementation:execute F001

# 5. Validate Code Quality
/quality:validate-code F001

# 6. Run Test Suites
/testing:test F001

# 7. Deploy to Production
/deployment:deploy
```

### Workflow Generation

```bash
# Generate infrastructure workflow (one-time setup)
/foundation:generate-workflow "AI Tech Stack 1"

# Generate feature implementation workflow (ongoing)
/planning:generate-feature-workflow

# Filter workflows
/foundation:generate-workflow "Stack Name" --summary
/planning:generate-feature-workflow --priority P0 --split
```

---

## Migration from v1.x

If you're upgrading from the old numbered plugin structure (01-core, 02-develop, etc.), see [MIGRATION.md](./MIGRATION.md) for detailed migration instructions.

**Quick Summary:**
- `01-core` → `foundation`
- `02-develop` → (removed - functionality distributed)
- `03-planning` → `planning`
- `04-iterate` → `iterate`
- `05-quality` → `quality`
- `06-deployment` → `deployment`

---

## Key Changes in v2.0

### Architecture Improvements

1. **Clean Naming**: Removed numbered prefixes for better usability
2. **Standardized Testing**: Newman/Postman for APIs, Playwright for E2E
3. **Standardized Deployment**: Platform auto-detection with FastMCP Cloud, Vercel, Railway, DigitalOcean
4. **Preserved Critical Components**: task-layering agent migrated successfully
5. **Removed 02-develop**: Functionality distributed to other plugins

### Quality Plugin Standardization

- **Newman/Postman**: Standardized API testing framework
- **Playwright**: Standardized E2E testing framework
- **DigitalOcean**: Cost-effective webhook testing ($4-6/month)
- **Security Scanning**: Comprehensive vulnerability detection

### Deployment Plugin Standardization

- **Auto-detection**: Detects project type and routes to appropriate platform
- **Multi-platform**: FastMCP Cloud, Vercel, Railway, DigitalOcean, Netlify
- **Cost-optimized**: DigitalOcean option at $4-6/month

---

## Development Workflow

### Typical Full-Stack Project Workflow

1. **Initialize** (`/foundation:init`)
   - Set up project structure
   - Detect/configure tech stack
   - Initialize git repository

2. **Plan** (`/planning:spec`, `/planning:architecture`)
   - Write feature specifications
   - Design system architecture
   - Create project roadmap

3. **Develop** (External plugins or manual development)
   - Implement features based on specifications
   - Follow architecture patterns

4. **Iterate** (`/iterate:adjust`, `/iterate:tasks`)
   - Manage task layers with agent assignments
   - Adjust implementation based on feedback
   - Refactor and enhance features

5. **Test** (`/quality:test`, `/quality:security`)
   - Run API tests with Newman
   - Run E2E tests with Playwright
   - Perform security scans

6. **Deploy** (`/deployment:deploy`)
   - Auto-detect platform
   - Deploy to production
   - Validate deployment

---

## Plugin Dependencies

- **All plugins** use `.claude/project.json` for tech stack detection
- **Planning** outputs specs that **iterate** can reference
- **Quality** validates implementations
- **Deployment** requires successful quality checks

---

## Tech Stack Agnostic

These plugins work with:
- **Languages**: TypeScript, JavaScript, Python, Go, Rust, Java, etc.
- **Frontend**: React, Next.js, Vue, Svelte, Angular, etc.
- **Backend**: Express, FastAPI, Django, Rails, Go, etc.
- **Databases**: PostgreSQL, MongoDB, MySQL, Supabase, etc.
- **Testing**: Jest, Vitest, pytest, Playwright, Newman, etc.
- **Deployment**: Vercel, Railway, DigitalOcean, Netlify, etc.

---

## Documentation

### Core Documentation
- [MIGRATION.md](./MIGRATION.md) - Migration guide from v1.x
- [REBUILD-SUMMARY.md](./REBUILD-SUMMARY.md) - Detailed rebuild documentation
- [CHANGELOG.md](./CHANGELOG.md) - Version history

### Technical Documentation
- **[docs/README.md](./docs/README.md)** - Documentation overview and organization
- **[docs/INDEX.md](./docs/INDEX.md)** - Quick reference guide (start here!)

### By Category
- **Setup**: [docs/setup/](./docs/setup/) - Configuration and installation guides
- **Fixes**: [docs/fixes/](./docs/fixes/) - Bug fixes and solutions
- **Reports**: [docs/reports/](./docs/reports/) - Integration and technical analysis
- **Verification**: [docs/verification/](./docs/verification/) - Testing procedures
- **Security**: [docs/security/](./docs/security/) - Security rules ⚠️ **READ THIS!**

---

## Support

- **Issues**: Report at repository issues
- **Questions**: See plugin-specific README files
- **Contributions**: Follow contribution guidelines

---

## License

MIT License - See [LICENSE](./LICENSE) for details

---

## Version History

- **v2.0.0** (October 2025): Complete rebuild with clean naming, standardized testing/deployment
- **v1.0.0** (Initial): Numbered plugin structure (01-core through 06-deployment)

---

**Generated**: October 29, 2025
**Framework**: domain-plugin-builder v1.0.0
