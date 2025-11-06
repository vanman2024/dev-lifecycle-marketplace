# BUILD-GUIDE.md Template

> **Purpose**: This template provides a standardized structure for BUILD-GUIDE.md files that list available commands per development phase.

## Project: {{PROJECT_NAME}}

**Tech Stack**: {{TECH_STACK}}
**Generated**: {{DATE}}

---

## Overview

This BUILD-GUIDE lists available slash commands organized by development phase. Use these commands to build your project infrastructure and features systematically.

**Key Principles**:
- **Infrastructure First**: Complete Phase 0-2 before feature implementation
- **Validation Between Phases**: Verify each phase completes successfully
- **Plugin-First**: Use available slash commands before writing custom code
- **Specs for Custom**: Create specs in `specs/features/` for unique business logic

---

## Phase 0: Environment Setup

**Goal**: Establish development environment and verify tooling

**Available Commands**:
```bash
/foundation:detect              # Detect tech stack, populate .claude/project.json
/foundation:env-check --fix     # Verify required tools (Node, Python, git, CLIs)
/foundation:github-init         # Create GitHub repo with security setup
/foundation:hooks-setup         # Install git hooks (pre-commit, secret scanning)
/foundation:doppler-setup       # Setup Doppler for secret management (optional)
```

**Validation**:
- [ ] `.claude/project.json` exists with detected tech stack
- [ ] All required tools installed (node, python, git)
- [ ] GitHub repository created with branch protection
- [ ] Git hooks installed (`.git/hooks/pre-commit` exists)
- [ ] `.gitignore` protects `.mcp.json`, `.env`, secrets

**Next**: Phase 1 - Database & Auth Setup

---

## Phase 1: Database & Authentication

**Goal**: Setup database infrastructure and authentication system

**Available Commands** (Example - Supabase):
```bash
/supabase:init                  # Initialize Supabase project
/supabase:setup-pgvector        # Setup vector database for AI features
/supabase:add-auth              # Configure authentication (OAuth providers)
/supabase:add-rls               # Create Row Level Security policies
/supabase:validate-setup        # Verify Supabase configuration
```

**Alternative Tech Stacks**:
- PostgreSQL: Custom setup with migrations
- MongoDB: Use MongoDB Atlas commands
- Firebase: Use Firebase CLI

**Validation**:
- [ ] Database accessible and migrations applied
- [ ] Authentication providers configured
- [ ] RLS policies tested for data isolation
- [ ] Environment variables set (SUPABASE_URL, SUPABASE_ANON_KEY)

**Next**: Phase 2 - Backend Infrastructure

---

## Phase 2: Backend Infrastructure

**Goal**: Setup API server and core backend services

**Available Commands** (Example - FastAPI):
```bash
/fastapi-backend:init           # Initialize FastAPI project structure
/fastapi-backend:integrate-supabase  # Connect FastAPI to Supabase
/fastapi-backend:add-auth       # Add authentication middleware
/fastapi-backend:add-endpoint   # Generate CRUD endpoints
/fastapi-backend:setup-database # Configure async SQLAlchemy
```

**Alternative Tech Stacks**:
- Next.js API Routes: `/nextjs-frontend:init`
- Express.js: Custom setup with TypeScript
- Django: Custom setup with Django REST Framework

**Validation**:
- [ ] API server runs locally (check health endpoint)
- [ ] Database connection verified
- [ ] Authentication middleware working
- [ ] CORS configured for frontend origin

**Next**: Phase 3 - Frontend Foundation

---

## Phase 3: Frontend Foundation

**Goal**: Setup frontend application with UI components

**Available Commands** (Example - Next.js):
```bash
/nextjs-frontend:init           # Initialize Next.js 15 with TypeScript
/nextjs-frontend:integrate-supabase  # Add Supabase client
/nextjs-frontend:integrate-ai-sdk    # Add Vercel AI SDK
/nextjs-frontend:search-components   # Find shadcn/ui components
/nextjs-frontend:add-component       # Install UI components
/nextjs-frontend:add-page            # Generate new pages with routing
```

**Alternative Tech Stacks**:
- Astro: `/website-builder:init`
- Vue/Nuxt: Custom setup
- React SPA: Create React App or Vite

**Validation**:
- [ ] Frontend runs locally (npm run dev)
- [ ] API calls to backend work (check network tab)
- [ ] Authentication flow functional (login/logout)
- [ ] UI components render correctly

**Next**: Phase 4 - AI Features (Optional)

---

## Phase 4: AI Features (Optional)

**Goal**: Add AI/LLM capabilities to your application

**Available Commands**:
```bash
# Memory Layer
/mem0:init-platform             # Use Mem0 Platform (managed service)
/mem0:init-oss                  # Use Mem0 OSS (self-hosted)
/mem0:add-user-memory           # Add user-specific memory
/mem0:add-conversation-memory   # Add conversation context

# LLM Integration
/vercel-ai-sdk:new-ai-app       # Initialize AI-powered app
/vercel-ai-sdk:add-provider     # Add LLM provider (OpenAI, Anthropic, etc.)
/vercel-ai-sdk:add-streaming    # Add streaming responses
/vercel-ai-sdk:add-chat         # Add chat interface
/vercel-ai-sdk:add-tools        # Add function calling

# RAG Pipeline (if needed)
/rag-pipeline:init              # Initialize RAG system
/rag-pipeline:add-vector-db     # Setup vector database
/rag-pipeline:add-embeddings    # Configure embedding models
/rag-pipeline:build-ingestion   # Create document ingestion pipeline
```

**Validation**:
- [ ] AI responses streaming correctly
- [ ] Memory persisting between conversations
- [ ] RAG retrieving relevant documents
- [ ] Token usage tracking working

**Next**: Phase 5 - Feature Implementation

---

## Phase 5: Feature Implementation

**Goal**: Build custom business logic features from specs

**Approach**:
1. **Review Specs**: Check `specs/features/` for feature specifications
2. **Use Plugins When Available**: Prefer slash commands over custom code
3. **Write Custom Code**: For unique business logic not covered by plugins
4. **Follow Layered Tasks**: Use `layered-tasks.md` for execution order

**Example Workflow**:
```bash
# For Feature 001: User Authentication
/iterate:tasks spec-001         # Generate layered task breakdown

# Use available commands
/supabase:add-auth              # Authentication infrastructure
/nextjs-frontend:add-page auth  # Auth UI pages

# Write custom code for unique logic
# - Custom password validation rules
# - Business-specific user roles
# - Custom OAuth callbacks
```

**Plugin-Built vs Custom**:
- ✅ **Use Plugins**: Auth, CRUD, UI components, deployment
- ✏️ **Write Custom**: Business rules, domain logic, workflows

**Validation**:
- [ ] All spec requirements met (check `spec.md`)
- [ ] Tasks marked complete in `layered-tasks.md`
- [ ] Code follows security rules (no hardcoded secrets)
- [ ] Tests written for custom logic

**Next**: Phase 6 - Testing & Quality

---

## Phase 6: Testing & Quality

**Goal**: Comprehensive testing and security validation

**Available Commands**:
```bash
/quality:test                   # Run all tests (Newman + Playwright + Security)
/quality:security               # Security scanning (npm audit, secret detection)
/quality:performance            # Performance testing
```

**Test Types**:
- **API Tests**: Newman/Postman collections
- **E2E Tests**: Playwright browser automation
- **Security**: npm audit, safety, bandit
- **Load Tests**: K6 or Artillery (optional)

**Validation**:
- [ ] All API tests pass
- [ ] E2E tests cover critical user flows
- [ ] No security vulnerabilities detected
- [ ] Performance benchmarks met

**Next**: Phase 7 - Deployment

---

## Phase 7: Deployment

**Goal**: Deploy to production with monitoring

**Available Commands**:
```bash
# Deployment Preparation
/deployment:prepare             # Pre-flight checks (deps, env vars, build)
/deployment:setup-cicd          # Configure GitHub Actions CI/CD
/deployment:validate            # Validate deployment readiness

# Platform Deployment
/deployment:deploy              # Auto-detect platform and deploy
# Platform-specific (if needed):
# /vercel:deploy                # Next.js to Vercel
# /railway:deploy               # Backend to Railway
# /digitalocean:deploy          # Full-stack to DigitalOcean

# Post-Deployment
/deployment:setup-monitoring    # Integrate Sentry + DataDog
/deployment:capture-baseline    # Capture performance baselines
```

**Validation**:
- [ ] Application deployed and accessible
- [ ] Health checks passing
- [ ] Environment variables configured
- [ ] Monitoring and error tracking active
- [ ] Domain/SSL configured

**Next**: Phase 8 - Versioning & Release

---

## Phase 8: Versioning & Release

**Goal**: Tag releases and generate changelogs

**Available Commands**:
```bash
/versioning:setup               # Initialize semantic versioning
/versioning:analyze-breaking    # Detect breaking changes
/versioning:bump major          # Increment version (major/minor/patch)
/versioning:generate-release-notes  # Create release notes with AI
/versioning:approve-release     # Multi-stakeholder approval workflow
```

**Validation**:
- [ ] Version tagged in git
- [ ] CHANGELOG.md updated
- [ ] GitHub release created
- [ ] Breaking changes documented
- [ ] Migration guide provided (if needed)

---

## Maintenance & Iteration

### Ongoing Commands

```bash
# Iterate on features
/iterate:adjust                 # Make targeted code changes
/iterate:refactor               # Improve code structure
/iterate:enhance                # Add optimizations
/iterate:sync                   # Update specs with implementation

# Planning updates
/planning:add-feature           # Add new feature spec
/planning:update-feature        # Modify existing spec
/planning:architecture          # Update architecture docs
```

### Periodic Tasks

- **Weekly**: Run `/quality:security` for vulnerability checks
- **Monthly**: Review and update dependencies
- **Per Release**: Run full `/quality:test` suite
- **After Major Changes**: Update architecture docs

---

## Custom Code Guidelines

When plugins don't cover your needs, write custom code following these rules:

### Security
- ❌ Never hardcode API keys, secrets, or credentials
- ✅ Always use environment variables: `process.env.API_KEY`
- ✅ Use placeholders in `.env.example`: `API_KEY=your_key_here`

### Organization
- Store custom scripts in: `scripts/`
- Store custom utilities in: `lib/` or `utils/`
- Document custom code in: `docs/custom/`

### Testing
- Write tests for all custom logic
- Place tests next to code: `lib/util.ts` → `lib/util.test.ts`
- Run tests before commits

---

## Troubleshooting

### Command Not Found
```bash
# Verify command is registered
grep 'SlashCommand(/your-plugin:your-command)' ~/.claude/settings.json

# Re-register all commands
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/build-system-automation/scripts/register-all-commands.sh
```

### Command Failed
1. Check command documentation: `/help plugin:command`
2. Verify prerequisites (tools installed, auth configured)
3. Check logs and error messages
4. Validate environment variables set

### Phase Validation Failed
- Review validation checklist
- Check expected outputs exist
- Run validation scripts
- Review logs for specific errors

---

## References

- **Plugin Documentation**: `~/.claude/plugins/marketplaces/*/plugins/*/README.md`
- **Command Registry**: `/tmp/command-registry.json` (run build-command-registry.sh)
- **Architecture Docs**: `docs/architecture/`
- **Feature Specs**: `specs/features/`

---

**Generated with Claude Code Build System**
*Template Version: 1.0*
