# Doppler Management Skill

**Purpose:** Complete Doppler secret management setup with scripts, templates, and GitHub integration

**Category:** Secret Management / DevOps

---

## Capabilities

This skill provides comprehensive Doppler setup for centralized secret management:

1. **Project Setup** - Create Doppler project and environments
2. **Script Generation** - Generate migration, run-wrapper, and GitHub setup scripts
3. **Documentation** - Generate complete integration guides
4. **GitHub Integration** - Setup automatic secret sync to GitHub Actions
5. **Multi-Environment** - Support for dev, staging, production configs

---

## Resources Available

### Scripts (`skills/doppler-management/scripts/`)

**migrate-to-doppler.sh** - Migration script template
- Detects environment variables from project
- Generates Doppler upload commands
- Uses placeholders (security compliant)
- Supports multi-environment (dev, stg, prd)

**run-with-doppler.sh** - Command wrapper template
- Injects Doppler secrets at runtime
- Supports environment switching
- Works with any command

**setup-doppler-github.sh** - Interactive GitHub integration wizard
- Guides through GitHub App installation
- Configures sync mappings
- Creates GitHub Environments
- Verifies secret sync

### Documentation Templates (`skills/doppler-management/templates/docs/`)

**README.md** - Main documentation index
- Quick start guide
- Command reference
- Troubleshooting

**integration-guide.md** - Complete integration guide
- Local development setup
- Framework integration (FastAPI, Next.js, etc.)
- CI/CD configuration
- Team workflows

**github-integration.md** - GitHub App setup guide
- Step-by-step installation
- Sync configuration
- Workflow examples
- Security best practices

**environment-setup.md** - Multi-environment configuration
- .env file management
- Environment-specific configs
- Service configuration guides
- Migration instructions

**PLUGIN-DESIGN.md** - Plugin architecture documentation
- Design decisions
- Template system
- Reusability patterns

### Workflow Templates (`skills/doppler-management/templates/workflows/`)

**test-doppler-secrets.yml** - GitHub Actions test workflow
- Verifies secret sync
- Tests all environments
- Validates configuration

---

## Usage Patterns

### Pattern 1: Complete Setup (Recommended)

Use when setting up Doppler for the first time:

```bash
# Command: /foundation:doppler-setup [project-name]

Steps executed:
1. Check Doppler CLI installation
2. Detect project name and GitHub repo
3. Create Doppler project and environments
4. Generate scripts in scripts/doppler/
5. Generate documentation in docs/doppler/
6. Create GitHub Actions workflow
7. Update .gitignore
8. Display setup summary
```

### Pattern 2: Script Generation Only

Use when you need to regenerate scripts:

```markdown
Invoke skill: doppler-management

Context: "Generate Doppler scripts for [project-name]"

Output:
- scripts/doppler/migrate-to-doppler.sh
- scripts/doppler/run-with-doppler.sh
- scripts/doppler/setup-doppler-github.sh
```

### Pattern 3: Documentation Generation

Use when you need fresh documentation:

```markdown
Invoke skill: doppler-management

Context: "Generate Doppler documentation for [project-name]"

Output:
- docs/doppler/README.md
- docs/doppler/integration-guide.md
- docs/doppler/github-integration.md
- docs/doppler/environment-setup.md
```

---

## Template Variables

### Automatic Detection

When invoked, this skill automatically detects:

**From `.claude/project.json`:**
- `{{PROJECT_NAME}}` - Project name
- `{{TECH_STACK}}` - Framework information
- `{{ENVIRONMENT_VARS}}` - List of environment variables

**From `git remote`:**
- `{{GITHUB_REPO}}` - Repository owner/name

**From environment:**
- `{{GENERATION_DATE}}` - Current date

### Environment Variable Detection

Scans these sources in order:
1. Existing `.env*` files
2. `specs/` directory (service requirements)
3. `.claude/project.json` (declared variables)
4. Code analysis (os.getenv, process.env patterns)

### Variable Categories

Automatically categorizes detected variables:

- **Google APIs** - GOOGLE_API_KEY, GOOGLE_FILE_SEARCH_STORE_ID
- **Supabase** - SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_KEY
- **Application** - ENVIRONMENT, PORT, DEBUG
- **AI Services** - OPENAI_API_KEY, ANTHROPIC_API_KEY
- **Payments** - STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY
- **Custom** - Any other detected variables

---

## Security Compliance

**CRITICAL:** All generated files follow security rules:

@~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/security/SECURITY-RULES.md

### Guaranteed Practices

✅ **All scripts use placeholders:**
```bash
# CORRECT - Always generated this way
GOOGLE_API_KEY=your_google_api_key_here
SUPABASE_URL=https://your-project.supabase.co
```

✅ **Never hardcodes secrets:**
- All values are placeholders
- User must manually add real credentials
- Scripts check for placeholder values before execution

✅ **Documentation includes acquisition guides:**
- Where to get each API key
- Step-by-step setup for each service
- Links to service dashboards

✅ **Protects sensitive files:**
- Auto-updates .gitignore
- Adds `.doppler.env`, `doppler.yaml`, `.doppler/`
- Protects all `.env.*` except `.env.example`

---

## Framework-Specific Customization

### FastAPI (Python)

**Detected patterns:**
- `os.getenv()`, `os.environ.get()`, `os.environ[]`
- `pydantic.BaseSettings`

**Generated code:**
```python
import os
api_key = os.getenv("GOOGLE_API_KEY")
```

**Run command:**
```bash
./run-with-doppler.sh uvicorn api.main:app --reload
```

### Next.js (TypeScript)

**Detected patterns:**
- `process.env.NEXT_PUBLIC_*`
- `process.env.*` in API routes

**Generated code:**
```typescript
// Client-side
const url = process.env.NEXT_PUBLIC_SUPABASE_URL

// Server-side
const key = process.env.SUPABASE_SERVICE_KEY
```

**Run command:**
```bash
./run-with-doppler.sh npm run dev
```

### Generic Projects

Works with any tech stack that uses environment variables.

---

## Integration with Foundation Commands

### `/foundation:doppler-setup`

**Primary command** that orchestrates complete Doppler setup:

```markdown
**Arguments**: [project-name]

Process:
1. Invoke doppler-management skill for detection
2. Create Doppler project via CLI
3. Generate all scripts from templates
4. Generate all documentation from templates
5. Create GitHub Actions workflow
6. Update .gitignore
7. Display summary and next steps
```

### `/foundation:env-vars`

**Complementary command** for environment variable management:

```markdown
Integration:
- Detects vars → Provides to doppler-management skill
- Generates .env files → Used by migration script
- Multi-environment support → Matches Doppler configs
```

---

## File Organization

### Generated Structure

```
project/
├── scripts/
│   └── doppler/
│       ├── migrate-to-doppler.sh       # Migration script
│       ├── run-with-doppler.sh         # Run wrapper
│       └── setup-doppler-github.sh     # GitHub setup wizard
├── docs/
│   └── doppler/
│       ├── README.md                    # Documentation index
│       ├── integration-guide.md         # Integration guide
│       ├── github-integration.md        # GitHub setup
│       ├── environment-setup.md         # Environment guide
│       └── PLUGIN-DESIGN.md            # Architecture docs
├── .github/
│   └── workflows/
│       └── test-doppler-secrets.yml    # Test workflow
└── DOPPLER-SETUP-SUMMARY.md           # Quick reference
```

### Benefits of Organization

✅ **Scripts in `scripts/doppler/`**
- Not cluttering project root
- Easy to find and maintain
- Grouped by purpose

✅ **Docs in `docs/doppler/`**
- Organized documentation
- Easy navigation
- Searchable

✅ **Workflows in `.github/workflows/`**
- Standard GitHub location
- Auto-discovered by Actions
- Version controlled

---

## Examples

### Example 1: New Project Setup

**Scenario:** Fresh project, never used Doppler

```bash
# User runs:
/foundation:doppler-setup my-saas-app

# Skill detects:
- Project name: my-saas-app
- GitHub repo: username/my-saas-app (from git remote)
- Tech stack: FastAPI + Next.js (from project.json)
- Environment vars: 12 detected

# Skill generates:
✓ scripts/doppler/migrate-to-doppler.sh (with 12 vars)
✓ scripts/doppler/run-with-doppler.sh
✓ scripts/doppler/setup-doppler-github.sh
✓ docs/doppler/ (all 4 guides)
✓ .github/workflows/test-doppler-secrets.yml
✓ DOPPLER-SETUP-SUMMARY.md

# User next steps:
1. Edit scripts/doppler/migrate-to-doppler.sh (add real secrets)
2. Run: scripts/doppler/migrate-to-doppler.sh
3. Run: scripts/doppler/setup-doppler-github.sh
4. Test: scripts/doppler/run-with-doppler.sh uvicorn api.main:app
```

### Example 2: Regenerate After Adding Services

**Scenario:** Added Stripe, need updated scripts

```bash
# User adds to project.json:
"environment_variables": {
  "stripe": ["STRIPE_SECRET_KEY", "STRIPE_PUBLISHABLE_KEY"]
}

# User runs:
/foundation:doppler-setup  # Detects existing setup

# Skill detects:
- Existing Doppler project
- New variables: STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY
- Existing migration script

# Skill offers:
"Detected existing Doppler setup. Options:"
1. Regenerate migration script (includes new Stripe vars)
2. Update documentation
3. Both

# User selects: Both

# Skill updates:
✓ scripts/doppler/migrate-to-doppler.sh (now includes Stripe)
✓ docs/doppler/environment-setup.md (Stripe section added)
```

---

## Troubleshooting Guide

### Issue: Scripts not executable

**Fix:**
```bash
chmod +x scripts/doppler/*.sh
```

### Issue: Variables not detected

**Causes:**
1. Not in standard .env location
2. Not declared in project.json
3. Using non-standard naming

**Fix:**
Manually add to migration script or declare in project.json:
```json
"environment_variables": {
  "custom": ["MY_CUSTOM_VAR"]
}
```

### Issue: GitHub integration fails

**Fix:**
See `docs/doppler/github-integration.md` troubleshooting section

---

## Skill Invocation

### Direct Invocation

```markdown
Skill: doppler-management

Context: "Setup Doppler for [project-name]"

The skill will:
1. Detect project context
2. Generate all scripts and docs
3. Provide next steps
```

### Via Command

```bash
/foundation:doppler-setup [project-name]
```

The command internally invokes this skill.

---

## Maintenance

### Updating Templates

Templates are in `skills/doppler-management/templates/`

To update:
1. Edit template files
2. Test with sample project
3. Commit changes
4. Regenerate documentation if needed

### Adding New Services

To add support for a new service:

1. Add to variable categories (in detection logic)
2. Update migration script template
3. Add service section to environment-setup.md
4. Test detection and generation

---

## Related Skills

- **environment-setup** - General environment configuration
- **mcp-configuration** - MCP server setup
- **project-detection** - Tech stack detection

---

## Version History

**v1.0.0** (2025-11-12)
- Initial release
- Complete script generation
- Multi-environment support
- GitHub integration
- Comprehensive documentation

---

**Maintained by:** Foundation Plugin Team
**Category:** Secret Management
**Tags:** doppler, secrets, environment, github, ci-cd, deployment
