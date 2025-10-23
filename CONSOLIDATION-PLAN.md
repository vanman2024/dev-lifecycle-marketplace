# Project Automation - Plugin Consolidation Plan

## Goal
Consolidate 28 scattered plugins → 6 lifecycle-ordered plugins that work together systematically.

---

## Current State: 28 Plugins in multiagent-marketplace

1. multiagent-ai-infrastructure
2. multiagent-backend
3. multiagent-build-system (KEEP SEPARATE - build tooling)
4. multiagent-compliance
5. multiagent-core
6. multiagent-cto
7. multiagent-deployment
8. multiagent-docs
9. multiagent-enhancement
10. multiagent-frontend
11. multiagent-git
12. multiagent-github
13. multiagent-idea
14. multiagent-implementation
15. multiagent-iterate
16. multiagent-mcp
17. multiagent-memory
18. multiagent-notes
19. multiagent-observability
20. multiagent-performance
21. multiagent-profile
22. multiagent-refactoring
23. multiagent-reliability
24. multiagent-security
25. multiagent-supervisor
26. multiagent-validation
27. multiagent-version
28. multiagent-website-builder (KEEP SEPARATE - specialized tool)

---

## New Structure: 6 Lifecycle Plugins

### 1. **core** (Foundation & Setup)
**Purpose:** Initialize projects, detect stack, set up version control, manage memory, configure MCP environment

**Consolidates:**
- multiagent-core → detection, initialization
- multiagent-git → git setup and workflows
- multiagent-github → GitHub integration
- multiagent-version → versioning strategy
- multiagent-memory → memory/knowledge management
- multiagent-mcp → MCP environment setup/configuration ONLY (not building)

**Commands:**
- `/init` - Initialize project (detect OR bootstrap)
- `/detect` - Analyze existing project
- `/git-setup` - Configure git workflows
- `/version` - Manage semantic versioning
- `/mcp-setup` - Configure MCP API keys ✅ KEEP (setup/config only)
- `/mcp-manage` - Manage MCP server configs ✅ KEEP (add/remove servers)
- `/mcp-info` - List available MCP servers ✅ KEEP
- `/mcp-clear` - Clear MCP server configs ✅ KEEP
- `/memory-search` - Search project memory ✅ KEEP
- `/memory-store` - Store knowledge ✅ KEEP

**Agents:**
- project-detector (detect framework/stack)
- git-configurator (setup .gitignore, hooks, workflows)

**Skills:**
- Project state management
- Git workflow automation
- Memory management (SQLite/Chroma) ✅ KEEP

**MCP Servers:**
- memory-api (from multiagent-memory) ✅ KEEP

**Estimated Size:** 10 commands, 2 agents, 3 skills ⚠️ Larger but foundational

---

### 2. **planning** (Spec → Architecture)
**Purpose:** Create specs, plans, architecture, documentation

**Consolidates:**
- multiagent-docs → documentation generation
- multiagent-notes → note-taking and organization
- multiagent-idea → idea capture and refinement
- multiagent-cto → technical decision-making
- multiagent-supervisor → oversight and coordination

**Commands:**
- `/spec` - Create specifications (works with spec-kit)
- `/plan` - Generate development plans
- `/architecture` - Design system architecture
- `/roadmap` - Create project roadmap
- `/notes` - Capture technical notes
- `/decide` - Make technical decisions (CTO-level)

**Agents:**
- spec-creator (generates specs from conversation)
- architecture-designer (creates system diagrams)
- technical-advisor (CTO-level decisions)

**Skills:**
- Spec management
- Architecture pattern library
- Decision tracking

**Estimated Size:** 6 commands, 3 agents, 3 skills ⚠️ Larger but necessary

---

### 3. **develop** (Code Generation & Implementation)
**Purpose:** Build features, scaffold code, implement functionality, create MCP servers

**Consolidates:**
- multiagent-frontend → React/Vue/Svelte components
- multiagent-backend → API/server code
- multiagent-implementation → general implementation
- multiagent-ai-infrastructure → AI/LLM integration
- multiagent-mcp → MCP server BUILDING commands + skill (not setup/config)

**Commands:**
- `/feature` - Add new feature (reads specs)
- `/component` - Generate UI component
- `/api` - Create API endpoint
- `/scaffold` - Scaffold entire module
- `/ai-integration` - Add AI capabilities
- `/mcp-build` - Build complete FastMCP server ✅ (references .claude/commands/mcp/build-complete-fastmcp-server.md)
- `/mcp-test` - Test MCP servers ✅ (references .claude/commands/mcp/mcp-comprehensive-testing.md)

**Agents:**
- feature-builder (implements features from specs)
- frontend-generator (creates components for detected framework)
- backend-generator (creates APIs for detected stack)
- ai-integrator (adds LLM capabilities)

**Skills:**
- Code generation for 20+ frameworks
- Component library templates
- API pattern library
- **MCP Development** ✅ - FastMCP templates, patterns, testing (from multiagent-mcp)

**Estimated Size:** 7 commands, 4 agents, 4 skills ⚠️ Larger but comprehensive

**Note:** MCP building is development work, just like building APIs or components. Setup/config stays in core.

---

### 4. **iterate** (Refinement & Adjustment)
**Purpose:** Modify, refactor, enhance, sync during active development

**Consolidates:**
- multiagent-iterate → /adjust, /sync, /tasks + **task-layering agent**
- multiagent-supervisor → /start, /mid, /end (worktree management)
- multiagent-refactoring → code refactoring
- multiagent-enhancement → feature enhancements

**Commands:**
- `/tasks` - Task layering (invokes task-layering agent) ✅ KEEP
- `/start` - Setup worktrees for parallel work ✅ KEEP
- `/mid` - Check progress during development ✅ KEEP
- `/end` - Validate completion ✅ KEEP
- `/adjust` - Modify features mid-development ✅ KEEP
- `/sync` - Sync changes across agents ✅ KEEP
- `/refactor` - Refactor code
- `/enhance` - Enhance existing features

**Agents:**
- task-layering (reads spec tasks.md → creates layered-tasks.md) ✅ CRITICAL - KEEP
- refactoring-assistant (suggests and applies refactors)

**Skills:**
- Iteration tracking ✅ KEEP
- Worktree management scripts ✅ KEEP
- Task layering scripts ✅ KEEP
- Code refactoring patterns

**Estimated Size:** 8 commands, 2 agents, 4 skills ⚠️ Larger but necessary

---

### 5. **quality** (Testing & Validation)
**Purpose:** Test, validate, secure, optimize, ensure compliance

**Consolidates:**
- multiagent-validation → testing and validation
- multiagent-security → security scanning
- multiagent-reliability → reliability checks
- multiagent-performance → performance optimization
- multiagent-compliance → compliance checks

**Commands:**
- `/test` - Run tests (detects framework's test tools)
- `/test-generate` - Generate tests from specs
- `/security` - Security audit
- `/performance` - Performance profiling
- `/validate` - Validate against specs
- `/compliance` - Check compliance (GDPR, accessibility, etc.)

**Agents:**
- test-generator (creates tests from acceptance criteria)
- security-auditor (scans for vulnerabilities)
- performance-optimizer (identifies bottlenecks)

**Skills:**
- Test framework integration (Jest, Pytest, Go test, etc.)
- Security scanning
- Performance monitoring

**Estimated Size:** 6 commands, 3 agents, 3 skills ⚠️ Larger but necessary

---

### 6. **deploy** (Deployment & Monitoring)
**Purpose:** Deploy to production, monitor, observe

**Consolidates:**
- multiagent-deployment → deployment workflows (ALREADY GOOD!)
- multiagent-observability → monitoring and logging

**Commands:**
- `/deploy` - Deploy to production ✅
- `/deploy-prepare` - Prepare deployment ✅
- `/deploy-validate` - Validate deployment ✅
- `/monitor` - Set up monitoring
- `/logs` - View/analyze logs

**Agents:**
- deployment-orchestrator (handles deployment) ✅
- observability-setup (configures monitoring)

**Skills:**
- Platform detection (Vercel, AWS, Railway, etc.) ✅
- Monitoring integration (Sentry, DataDog, etc.)

**Estimated Size:** 5 commands, 2 agents, 2 skills ✅ Reasonable

---

## Plugins to KEEP SEPARATE:

### **multiagent-build-system**
**Why:** Builds other plugins - meta-tooling
**Keep as-is** with new `/lifecycle` master command

### **multiagent-website-builder**
**Why:** Specialized for landing pages/marketing sites
**Decision:** Keep separate - distinct workflow from app development

### **multiagent-deployment**
**Why:** Already has working /deploy commands
**Decision:** Keep as-is OR merge into deploy lifecycle plugin

---

## Unused/Unclear Plugins:

- **multiagent-profile** - What does this do? Archive?

---

## Size Analysis:

**Reasonable size (4-6 commands):**
- ✅ core (4 commands)
- ✅ iterate (6 commands)
- ✅ deploy (5 commands)

**Larger but necessary (6+ commands):**
- ⚠️ planning (6 commands) - architectural decisions are complex
- ⚠️ develop (6 commands) - consider splitting AI out
- ⚠️ quality (6 commands) - testing/security are broad domains

**Recommendation:**
- Start with 6 plugins as planned
- If `develop` gets unwieldy, split into:
  - `develop` (general features)
  - `ai` (AI/LLM-specific infrastructure)

---

## Build Order (Using /lifecycle command):

1. **develop** - Most needed for actual coding work
2. **iterate** - Task layering + refactoring (consolidates multiagent-iterate, multiagent-supervisor, multiagent-refactoring, multiagent-enhancement)
3. **quality** - Testing and validation
4. **deploy** - Deployment workflows (or keep multiagent-deployment as-is)
5. **planning** - Spec creation and architecture
6. **core** - Foundation, detection, memory, MCP setup (consolidates multiagent-core, multiagent-git, multiagent-memory, multiagent-mcp)

**Strategy:**
- Build from existing working code when possible
- multiagent-iterate already has task-layering agent ✅ → copy to new iterate plugin
- multiagent-supervisor already has worktree scripts ✅ → copy to new iterate plugin
- multiagent-memory already has memory system ✅ → copy to new core plugin
- multiagent-deployment already has deploy commands ✅ → copy to new deploy plugin OR keep separate

---

## Success Criteria:

Each plugin should:
- ✅ Have clear lifecycle purpose
- ✅ Read from `.claude/project.json` for framework detection
- ✅ Work with spec-kit OR standalone
- ✅ Use subagents for multi-step work
- ✅ Chain with other lifecycle plugins
- ✅ Be buildable via `/build-lifecycle-plugin`

**No more consolidation after this. We build, test, use.**
