# Development Lifecycle Marketplace

**Tech-agnostic workflow automation - from init to deploy in 5 lifecycle phases.**

**Version**: 2.0.0 (Rebuilt October 2025)

---

## What This Is

The **dev-lifecycle-marketplace** provides structured development workflow plugins that work with ANY tech stack. These plugins handle **HOW you develop** (process and methodology), not **WHAT you develop with** (specific SDKs or frameworks).

**Key Concept:** Lifecycle plugins are completely tech-agnostic. They detect your project's tech stack and adapt accordingly.

---

## Architecture: 5 Lifecycle Plugins

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

### 4. **quality** - Testing & Quality Assurance
Standardized testing with Newman/Postman, Playwright, security scanning

**Commands:**
- `/quality:test` - Run comprehensive test suite (Newman API, Playwright E2E, security scans)
- `/quality:security` - Run security scans and vulnerability checks
- `/quality:performance` - Analyze performance and identify bottlenecks

**What it does:**
- **Newman/Postman**: API testing with collections, environments, assertions
- **Playwright**: E2E browser testing with page object models
- **DigitalOcean Webhooks**: $4-6/month webhook testing infrastructure
- **Security Scanning**: npm audit, safety, bandit, secret detection
- **Performance Analysis**: Lighthouse, profiling, bottleneck identification

**Components:**
- 3 commands
- 4 agents (test-generator, security-scanner, performance-analyzer, compliance-checker)
- 3 skills (newman-testing, playwright-e2e, security-patterns)

**Note:** Skills have comprehensive documentation but require full implementation (scripts, templates, examples).

---

### 5. **deployment** - Deployment Orchestration
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
| planning | 5 | 4 | 3 | 12 |
| iterate | 3 | 4 | 1 | 8 |
| quality | 3 | 4 | 3 | 10 |
| deployment | 4 | 3 | 3 | 10 |
| **TOTAL** | **19** | **16** | **13** | **48** |

---

## Quick Start

### 1. Initialize New Project
```bash
/foundation:init my-new-project
```

### 2. Create Specifications
```bash
/planning:spec "user authentication feature"
```

### 3. Manage Tasks
```bash
/iterate:tasks
```

### 4. Run Tests
```bash
/quality:test
```

### 5. Deploy
```bash
/deployment:deploy
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
