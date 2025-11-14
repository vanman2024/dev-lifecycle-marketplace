# Doppler Plugin/Skill Design Document

**Purpose:** Systematize Doppler setup for reuse across projects
**Created:** 2025-11-12
**Target:** Claude Code plugin marketplace

---

## Problem Statement

Currently, setting up Doppler requires:
1. Manual project creation
2. Environment configuration
3. Script generation (migration, run-wrapper, GitHub setup)
4. Documentation creation
5. GitHub integration
6. Workflow templates

**Goal:** Create a reusable plugin/skill that automates this entire process for any project.

---

## Proposed Solution: Doppler Plugin

### Option 1: Full Plugin (Recommended)

**Structure:**
```
.claude/plugins/marketplaces/secret-management/doppler/
├── manifest.json                    # Plugin metadata
├── agents/
│   ├── doppler-setup.md            # Main setup agent
│   ├── doppler-migrator.md         # Migration agent
│   └── github-integrator.md        # GitHub setup agent
├── commands/
│   ├── doppler-init.md             # /doppler:init
│   ├── doppler-migrate.md          # /doppler:migrate
│   ├── doppler-github.md           # /doppler:github
│   └── doppler-sync.md             # /doppler:sync
├── skills/
│   └── doppler-templates.md        # Script/doc templates
├── templates/
│   ├── scripts/
│   │   ├── migrate-to-doppler.sh.template
│   │   ├── run-with-doppler.sh.template
│   │   └── setup-doppler-github.sh.template
│   ├── docs/
│   │   ├── README.md.template
│   │   ├── integration-guide.md.template
│   │   ├── github-integration.md.template
│   │   └── environment-setup.md.template
│   └── workflows/
│       └── test-doppler-secrets.yml.template
└── README.md                        # Plugin documentation
```

**Slash Commands:**
```bash
/doppler:init [project-name]         # Complete setup
/doppler:migrate                     # Generate migration script
/doppler:github                      # Setup GitHub integration
/doppler:sync [environment]          # Sync secrets to Doppler
```

---

### Option 2: Skill Only (Lighter Weight)

**Structure:**
```
.claude/skills/doppler-setup/
├── skill.md                         # Main skill definition
├── scripts/
│   ├── migrate-template.sh
│   ├── run-template.sh
│   └── github-setup-template.sh
└── docs/
    └── templates/
```

**Usage:**
```bash
# Invoke skill
Skill: doppler-setup

# Skill generates everything based on project context
```

---

## Recommended Approach: Full Plugin

### Why Plugin Over Skill?

**Plugins provide:**
- ✅ Multiple specialized agents (setup, migration, GitHub integration)
- ✅ Slash commands for specific tasks
- ✅ Better organization for complex workflows
- ✅ Template system for scripts/docs
- ✅ Reusable across projects
- ✅ Marketplace distribution

**Skills are better for:**
- ❌ Single-purpose tasks
- ❌ Simple templating
- ❌ No multi-step workflows

---

## Plugin Architecture

### 1. Manifest (`manifest.json`)

```json
{
  "name": "doppler",
  "display_name": "Doppler Secret Management",
  "version": "1.0.0",
  "description": "Automated Doppler setup for centralized secret management",
  "author": "Claude Code",
  "category": "secret-management",
  "tags": ["secrets", "environment", "deployment", "github", "ci-cd"],
  "requires": {
    "doppler_cli": ">=3.0.0"
  },
  "commands": [
    "/doppler:init",
    "/doppler:migrate",
    "/doppler:github",
    "/doppler:sync"
  ],
  "agents": [
    "doppler-setup",
    "doppler-migrator",
    "github-integrator"
  ],
  "skills": [
    "doppler-templates"
  ]
}
```

---

### 2. Main Command: `/doppler:init`

**File:** `commands/doppler-init.md`

```markdown
**Arguments**: [project-name] [--github-repo=owner/repo]

Goal: Complete Doppler setup for a project

Phase 1: Discovery
- Detect project name (from directory or argument)
- Check if .claude/project.json exists (read tech stack)
- Check for existing .env files
- Detect GitHub repository (from git remote or argument)
- Check Doppler CLI installation

Phase 2: Doppler Project Setup
- Launch doppler-setup agent:
  - Create Doppler project
  - Create environments (dev, stg, prd)
  - Configure local setup

Phase 3: Generate Scripts
- Launch doppler-templates skill:
  - Generate migrate-to-doppler.sh (with placeholders)
  - Generate run-with-doppler.sh
  - Generate setup-doppler-github.sh
  - Place in scripts/doppler/

Phase 4: Generate Documentation
- Launch doppler-templates skill:
  - Generate docs/doppler/README.md
  - Generate docs/doppler/integration-guide.md
  - Generate docs/doppler/github-integration.md
  - Generate docs/doppler/environment-setup.md

Phase 5: GitHub Integration (Optional)
- Ask user: "Setup GitHub integration now?"
- If yes, launch github-integrator agent

Phase 6: Summary
- Display setup completion
- Show next steps
- List generated files
```

---

### 3. Agent: `doppler-setup`

**File:** `agents/doppler-setup.md`

```markdown
You are the Doppler setup agent.

Your role:
1. Create Doppler project via CLI
2. Create environments (dev, stg, prd)
3. Configure local development setup
4. Verify configuration

Tools available:
- Bash (doppler commands)
- Read (project.json)
- Write (config files if needed)

Process:
1. Check Doppler authentication (doppler me)
2. Create project: doppler projects create [name]
3. Create environments (handle errors if exists)
4. Setup local: doppler setup --project [name] --config dev
5. Verify: doppler configure get
6. Return: Project details and status
```

---

### 4. Skill: `doppler-templates`

**File:** `skills/doppler-templates.md`

```markdown
# Doppler Templates Skill

Purpose: Generate Doppler scripts and documentation from templates

**Capabilities:**
1. Detect project context (.claude/project.json)
2. Extract environment variables
3. Generate migration scripts with detected vars
4. Generate documentation with project-specific info
5. Customize for different tech stacks

**Templates Available:**
- scripts/migrate-to-doppler.sh.template
- scripts/run-with-doppler.sh.template
- scripts/setup-doppler-github.sh.template
- docs/README.md.template
- docs/integration-guide.md.template
- docs/github-integration.md.template
- workflows/test-doppler-secrets.yml.template

**Template Variables:**
- {{PROJECT_NAME}}
- {{GITHUB_REPO}}
- {{ENVIRONMENT_VARS}}
- {{TECH_STACK}}
- {{DETECTED_FRAMEWORKS}}

**Usage:**
When invoked, this skill:
1. Reads project.json for context
2. Scans for environment variables
3. Replaces template variables
4. Outputs customized files
```

---

### 5. Template Example: Migration Script

**File:** `templates/scripts/migrate-to-doppler.sh.template`

```bash
#!/bin/bash
# {{PROJECT_NAME}} - Doppler Migration Script
# Generated by Claude Code Doppler Plugin
# Last Updated: {{GENERATION_DATE}}

PROJECT="{{PROJECT_NAME}}"

# Detected environment variables:
{{#ENVIRONMENT_VARS}}
# {{CATEGORY}}
doppler secrets set {{KEY}}="{{PLACEHOLDER}}" \
  --project "$PROJECT" --config {{ENVIRONMENT}}
{{/ENVIRONMENT_VARS}}
```

---

## Plugin Commands Breakdown

### `/doppler:init [project-name]`

**Purpose:** Complete Doppler setup from scratch

**What it does:**
1. Create Doppler project and environments
2. Generate all scripts (scripts/doppler/)
3. Generate all documentation (docs/doppler/)
4. Create GitHub Actions test workflow
5. Update .gitignore
6. Display next steps

**When to use:** First-time Doppler setup for a project

---

### `/doppler:migrate`

**Purpose:** Generate migration script only

**What it does:**
1. Scan project for environment variables
2. Detect from: .env files, specs/, code
3. Generate migrate-to-doppler.sh with placeholders
4. Place in scripts/doppler/

**When to use:**
- Already have Doppler project
- Just need migration script
- Environment variables changed

---

### `/doppler:github`

**Purpose:** Setup GitHub integration

**What it does:**
1. Detect GitHub repository
2. Generate setup-doppler-github.sh wizard
3. Create GitHub Actions test workflow
4. Create sync mapping documentation
5. Guide through browser-based setup

**When to use:**
- After Doppler project exists
- Ready to sync to GitHub Actions
- Setting up CI/CD

---

### `/doppler:sync [environment]`

**Purpose:** Sync current .env to Doppler

**What it does:**
1. Read current .env file
2. Parse variables
3. Upload to specified Doppler config
4. Verify upload
5. Display synced secrets

**When to use:**
- Quick sync without full migration
- Update specific environment
- Development workflow

---

## Implementation Checklist

### Phase 1: Plugin Structure
- [ ] Create plugin directory structure
- [ ] Write manifest.json
- [ ] Create README.md
- [ ] Define all slash commands
- [ ] Define all agents

### Phase 2: Templates
- [ ] Create script templates
  - [ ] migrate-to-doppler.sh.template
  - [ ] run-with-doppler.sh.template
  - [ ] setup-doppler-github.sh.template
- [ ] Create doc templates
  - [ ] README.md.template
  - [ ] integration-guide.md.template
  - [ ] github-integration.md.template
  - [ ] environment-setup.md.template
- [ ] Create workflow templates
  - [ ] test-doppler-secrets.yml.template

### Phase 3: Agents
- [ ] doppler-setup agent
- [ ] doppler-migrator agent
- [ ] github-integrator agent

### Phase 4: Skills
- [ ] doppler-templates skill
  - [ ] Template rendering engine
  - [ ] Variable detection
  - [ ] Context extraction

### Phase 5: Commands
- [ ] /doppler:init
- [ ] /doppler:migrate
- [ ] /doppler:github
- [ ] /doppler:sync

### Phase 6: Testing
- [ ] Test with FastAPI backend
- [ ] Test with Next.js frontend
- [ ] Test with monorepo
- [ ] Test GitHub integration flow

### Phase 7: Documentation
- [ ] Plugin usage guide
- [ ] Template customization guide
- [ ] Troubleshooting guide
- [ ] Examples for common stacks

---

## Usage Examples

### Example 1: New Project Setup

```bash
# User runs:
/doppler:init my-saas-app --github-repo=username/my-saas-app

# Plugin:
1. Creates Doppler project "my-saas-app"
2. Creates dev, stg, prd environments
3. Scans project for environment variables
4. Generates scripts/doppler/ with all scripts
5. Generates docs/doppler/ with all docs
6. Creates .github/workflows/test-doppler-secrets.yml
7. Updates .gitignore
8. Displays summary and next steps
```

---

### Example 2: Migrate Existing Project

```bash
# User runs:
/doppler:migrate

# Plugin:
1. Scans .env files in project
2. Detects environment variables from:
   - .env, .env.development, .env.production
   - specs/ directory
   - backend/frontend code
3. Generates migrate-to-doppler.sh with:
   - All detected variables
   - Proper categorization
   - Placeholder values
   - Comments for acquisition
4. Places in scripts/doppler/
5. Shows command to run migration
```

---

### Example 3: GitHub Integration

```bash
# User runs:
/doppler:github

# Plugin:
1. Detects GitHub repo from git remote
2. Generates setup-doppler-github.sh wizard
3. Creates GitHub Actions test workflow
4. Provides step-by-step instructions
5. Opens browser to Doppler dashboard
6. Guides through:
   - Installing GitHub App
   - Configuring sync mappings
   - Creating GitHub Environments
   - Verifying secret sync
```

---

## Tech Stack Support

### Supported Frameworks

**Backend:**
- FastAPI (Python)
- Express (Node.js)
- Django (Python)
- NestJS (TypeScript)
- Rails (Ruby)

**Frontend:**
- Next.js (React)
- Nuxt (Vue)
- SvelteKit
- Remix
- Astro

**Database:**
- Supabase
- PostgreSQL
- MongoDB
- MySQL

**AI:**
- Google AI SDK
- OpenAI SDK
- Anthropic SDK
- Vercel AI SDK

---

## Template Customization

### Framework-Specific Variables

**Next.js:**
```bash
# Frontend needs NEXT_PUBLIC_ prefix
NEXT_PUBLIC_SUPABASE_URL={{SUPABASE_URL}}
NEXT_PUBLIC_SUPABASE_ANON_KEY={{SUPABASE_ANON_KEY}}

# Backend only (no prefix)
SUPABASE_SERVICE_KEY={{SUPABASE_SERVICE_KEY}}
```

**FastAPI:**
```python
# Python uses os.getenv
GOOGLE_API_KEY={{GOOGLE_API_KEY}}
SUPABASE_URL={{SUPABASE_URL}}
```

---

## Future Enhancements

### V2 Features
- [ ] Support for other secret managers (Vault, AWS Secrets Manager)
- [ ] Automatic secret rotation scheduling
- [ ] Team onboarding workflows
- [ ] Multi-region support
- [ ] Compliance templates (SOC2, HIPAA)

### V3 Features
- [ ] Secret dependency graph
- [ ] Cost tracking per secret
- [ ] Secret usage analytics
- [ ] Auto-detection of unused secrets
- [ ] Integration with monitoring tools

---

## Comparison: Plugin vs Manual Setup

| Task | Manual | With Plugin | Time Saved |
|------|--------|-------------|-----------|
| Create Doppler project | 5 min | Automated | 5 min |
| Create environments | 3 min | Automated | 3 min |
| Generate migration script | 20 min | Automated | 20 min |
| Generate run wrapper | 5 min | Automated | 5 min |
| Generate GitHub setup | 15 min | Automated | 15 min |
| Create documentation | 30 min | Automated | 30 min |
| Create workflows | 10 min | Automated | 10 min |
| **Total** | **~90 min** | **~2 min** | **~88 min** |

---

## Next Steps to Build Plugin

1. **Create plugin structure** in Claude Code plugins directory
2. **Extract current implementation** as templates
3. **Generalize** for multiple tech stacks
4. **Test** with different project types
5. **Document** for marketplace
6. **Submit** to plugin marketplace (if exists)

---

## Questions to Answer

1. **Should this be a plugin or skill?**
   - **Answer:** Plugin (more powerful, better for complex workflows)

2. **Where should it live?**
   - Option A: `~/.claude/plugins/marketplace/secret-management/doppler/`
   - Option B: Project-specific in each repo
   - **Answer:** Option A (reusable across projects)

3. **How to handle project-specific customization?**
   - **Answer:** Template variables + project.json detection

4. **Should it support other secret managers?**
   - **Answer:** V2 feature (start with Doppler only)

5. **How to test plugin across different stacks?**
   - **Answer:** Create test projects for each supported stack

---

**Ready to build?** Let me know and I'll help create the plugin structure!
