# Migration Guide: v1.x to v2.0

**Date**: October 29, 2025

This guide helps you migrate from the old numbered plugin structure (v1.x) to the new clean naming structure (v2.0).

---

## TL;DR - Quick Migration

### Command Name Changes

| Old Command (v1.x) | New Command (v2.0) | Notes |
|-------------------|-------------------|-------|
| `/01-core:*` or `/core:*` | `/foundation:*` | Renamed for clarity |
| `/02-develop:*` or `/develop:*` | Removed | Functionality distributed |
| `/03-planning:*` or `/planning:*` | `/planning:*` | Unchanged |
| `/04-iterate:*` or `/iterate:*` | `/iterate:*` | Unchanged |
| `/05-quality:*` or `/quality:*` | `/quality:*` | Unchanged |
| `/06-deployment:*` or `/deployment:*` | `/deployment:*` | Unchanged |

### Plugin Name Changes

```
01-core       → foundation
02-develop    → (removed)
03-planning   → planning
04-iterate    → iterate
05-quality    → quality
06-deployment → deployment
```

---

## What Changed

### 1. Plugin Naming

**Old Structure (v1.x):**
```
plugins/
├── 01-core/
├── 02-develop/
├── 03-planning/
├── 04-iterate/
├── 05-quality/
└── 06-deployment/
```

**New Structure (v2.0):**
```
plugins/
├── foundation/
├── planning/
├── iterate/
├── quality/
└── deployment/
```

### 2. Removed 02-develop Plugin

The `02-develop` plugin has been removed. Its functionality has been:
- **Distributed** to other plugins (foundation, iterate)
- **Replaced** by external tech-specific plugins (nextjs-frontend, fastmcp, vercel-ai-sdk, etc.)
- **Simplified** to follow the tech-agnostic philosophy more strictly

**Migration Path:**
- Use `/foundation:init` for project initialization
- Use external plugins for code generation (e.g., `/nextjs-frontend:*`, `/fastmcp:*`)
- Use `/iterate:adjust` for code modifications

### 3. Renamed 01-core to foundation

The `core` name was ambiguous. `foundation` better reflects its purpose: foundational project setup.

**Migration:**
- Replace all `/core:*` or `/01-core:*` with `/foundation:*`
- Example: `/core:init` → `/foundation:init`

### 4. Standardized Testing (quality plugin)

**Old Approach (v1.x):**
- Generic test framework detection
- Minimal test automation
- No standardized patterns

**New Approach (v2.0):**
- **Newman/Postman**: Standardized API testing
- **Playwright**: Standardized E2E testing
- **DigitalOcean Webhooks**: Cost-effective webhook testing ($4-6/month)
- **Security Scanning**: Comprehensive vulnerability detection

**Migration:**
- Adopt Newman for API tests (Postman collections)
- Adopt Playwright for E2E browser tests
- Use `/quality:test` for comprehensive testing
- Use `/quality:security` for security scans
- Use `/quality:performance` for performance analysis

### 5. Standardized Deployment (deployment plugin)

**Old Approach (v1.x):**
- Manual deployment configuration
- Limited platform support
- No auto-detection

**New Approach (v2.0):**
- **Auto-detection**: Detects project type and routes to platform
- **Multi-platform**: FastMCP Cloud, Vercel, Railway, DigitalOcean, Netlify
- **Cost-optimized**: DigitalOcean option at $4-6/month

**Migration:**
- Use `/deployment:deploy` with auto-detection
- Configure platform-specific settings in `.claude/project.json`
- Let the deployment plugin handle platform selection

---

## Step-by-Step Migration

### Step 1: Backup Current Setup

```bash
# Backup your current .claude directory
cp -r ~/.claude ~/.claude.backup

# Backup current plugins
cp -r ~/.claude/plugins ~/.claude/plugins.backup
```

### Step 2: Update Marketplace Configuration

The marketplace.json has been updated automatically. If you need to verify:

```json
{
  "name": "dev-lifecycle-marketplace",
  "metadata": {
    "version": "2.0.0"
  },
  "plugins": [
    {"name": "foundation", "source": "./plugins/foundation"},
    {"name": "planning", "source": "./plugins/planning"},
    {"name": "iterate", "source": "./plugins/iterate"},
    {"name": "quality", "source": "./plugins/quality"},
    {"name": "deployment", "source": "./plugins/deployment"}
  ]
}
```

### Step 3: Update Your Workflows

**Old Workflow (v1.x):**
```bash
/core:init my-project
/develop:feature "authentication"
/planning:spec "authentication"
/quality:test
/deployment:deploy
```

**New Workflow (v2.0):**
```bash
/foundation:init my-project
/planning:spec "authentication"
# Use external tech-specific plugins for implementation
/iterate:tasks  # Manage tasks with agent assignments
/quality:test
/deployment:deploy
```

### Step 4: Update Scripts and Automation

If you have scripts that call Claude Code commands:

**Old:**
```bash
claude "/core:init my-project"
claude "/develop:feature auth"
```

**New:**
```bash
claude "/foundation:init my-project"
# Use tech-specific plugins for implementation
```

### Step 5: Update Documentation References

Search your project documentation for:
- `/core:` → Replace with `/foundation:`
- `/01-core:` → Replace with `/foundation:`
- `/develop:` → Remove or replace with tech-specific plugin commands
- `/02-develop:` → Remove or replace with tech-specific plugin commands

---

## Plugin-Specific Migration

### foundation (formerly 01-core)

**Command Mapping:**

| Old | New | Changes |
|-----|-----|---------|
| `/core:init` | `/foundation:init` | Renamed |
| `/core:detect` | `/foundation:detect-stack` | Renamed for clarity |
| `/core:project-setup` | `/foundation:setup-env` + `/foundation:verify-setup` | Split into focused commands |
| `/core:upgrade-to` | Removed | Use package manager directly |

**What to Update:**
- All command references from `/core:*` to `/foundation:*`
- Project initialization scripts
- CI/CD pipelines using core commands

### planning (formerly 03-planning)

**No Changes Required** ✅

Commands remain the same:
- `/planning:plan`
- `/planning:spec`
- `/planning:architecture`
- `/planning:roadmap`
- `/planning:decisions`

### iterate (formerly 04-iterate)

**No Changes Required** ✅

Commands remain the same:
- `/iterate:adjust`
- `/iterate:sync`
- `/iterate:tasks`

**Enhanced:**
- Preserved critical task-layering agent
- Improved task management with agent assignments

### quality (formerly 05-quality)

**Command Mapping:**

| Old | New | Changes |
|-----|-----|---------|
| `/quality:test` | `/quality:test` | Enhanced with Newman/Playwright |
| `/quality:security` | `/quality:security` | Enhanced with comprehensive scanning |
| `/quality:performance` | `/quality:performance` | New command |

**What to Update:**
- **Adopt Newman**: Migrate API tests to Postman collections
- **Adopt Playwright**: Migrate E2E tests to Playwright
- Update test scripts to use standardized frameworks
- Configure DigitalOcean for webhook testing (optional, $4-6/month)

**Migration Example - API Tests:**

Old (Jest/Supertest):
```javascript
describe('API Tests', () => {
  it('should return users', async () => {
    const res = await request(app).get('/api/users');
    expect(res.status).toBe(200);
  });
});
```

New (Newman/Postman):
```json
{
  "name": "Get Users",
  "request": {
    "method": "GET",
    "url": "{{baseUrl}}/api/users"
  },
  "tests": [
    "pm.test('Status is 200', () => pm.response.to.have.status(200));"
  ]
}
```

Use `/quality:test api` to run Newman tests.

**Migration Example - E2E Tests:**

Old (Custom E2E):
```javascript
it('should login', async () => {
  await page.goto('/login');
  await page.fill('#email', 'test@example.com');
  await page.click('button[type=submit]');
});
```

New (Playwright):
```typescript
test('should login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('#email', 'test@example.com');
  await page.click('button[type=submit]');
  await expect(page).toHaveURL('/dashboard');
});
```

Use `/quality:test e2e` to run Playwright tests.

### deployment (formerly 06-deployment)

**Command Mapping:**

| Old | New | Changes |
|-----|-----|---------|
| `/deployment:deploy` | `/deployment:deploy` | Enhanced with auto-detection |
| `/deployment:prepare` | `/deployment:prepare` | New command |
| `/deployment:validate` | `/deployment:validate` | New command |
| `/deployment:rollback` | `/deployment:rollback` | New command |

**What to Update:**
- **Platform Detection**: Remove manual platform configuration
- **Auto-routing**: Let deployment plugin detect and route to platform
- **Multi-platform**: Configure fallback platforms in `.claude/project.json`

**Old Config:**
```json
{
  "deployment": {
    "platform": "vercel",
    "config": { ... }
  }
}
```

**New Config (Auto-detected):**
```json
{
  "deployment": {
    "platforms": {
      "primary": "auto",
      "fallback": ["vercel", "railway", "digitalocean"]
    }
  }
}
```

---

## Handling 02-develop Removal

The `02-develop` plugin has been removed to maintain strict tech-agnosticism. Here's how to replace its functionality:

### For Code Generation

**Old:**
```bash
/develop:feature "authentication"
/develop:component "UserProfile"
/develop:api "GET /users"
```

**New (Use Tech-Specific Plugins):**
```bash
# For Next.js projects
/nextjs-frontend:add-page "/users"
/nextjs-frontend:add-component "UserProfile"

# For FastMCP projects
/fastmcp:add-components tools

# For Vercel AI SDK projects
/vercel-ai-sdk:add-streaming
```

### For Implementation Adjustments

**Old:**
```bash
/develop:adjust "add error handling"
```

**New:**
```bash
/iterate:adjust "add error handling"
```

### For Code Refactoring

**Old:**
```bash
/develop:refactor "extract utility functions"
```

**New:**
```bash
/iterate:refactor "extract utility functions"
```

---

## Breaking Changes

### 1. Command Paths

- All `/core:*` and `/01-core:*` commands → `/foundation:*`
- All `/develop:*` and `/02-develop:*` commands → Use tech-specific plugins or `/iterate:*`

### 2. Plugin References

- Plugin references in documentation, scripts, CI/CD must be updated
- Numbered plugin references (01-, 02-, etc.) no longer work

### 3. Test Framework

- No more generic test framework detection
- Must use Newman for API tests or Playwright for E2E tests
- Old test commands may not work as expected

### 4. Deployment Configuration

- Manual platform configuration deprecated
- Must use auto-detection or specify platforms in `.claude/project.json`

---

## Non-Breaking Changes

### 1. Existing Project Files

- `.claude/project.json` format remains compatible
- Existing specifications, plans, and documentation continue to work
- Git repositories and version control unaffected

### 2. Agent Behavior

- All agents remain functionally equivalent
- task-layering agent preserved and enhanced
- Agent outputs and patterns unchanged

### 3. Skill Structure

- Skill patterns remain the same
- Progressive disclosure still works
- Scripts, templates, examples structure unchanged

---

## Troubleshooting

### Issue: Command not found after migration

**Problem:**
```bash
$ /core:init my-project
Error: Command not found
```

**Solution:**
```bash
$ /foundation:init my-project
```

Update all `/core:*` references to `/foundation:*`.

---

### Issue: /develop commands don't work

**Problem:**
```bash
$ /develop:feature "auth"
Error: Plugin not found
```

**Solution:**

Use tech-specific plugins:
```bash
# For Next.js
$ /nextjs-frontend:add-page "/auth"

# For general iteration
$ /iterate:adjust "implement auth feature"
```

---

### Issue: Tests failing after migration

**Problem:**
```bash
$ /quality:test
Error: No Newman collections found
```

**Solution:**

Migrate tests to Newman/Postman:
1. Export existing API tests as Postman collection
2. Place in `tests/` directory
3. Run `/quality:test api`

Or use external test frameworks with generic `/quality:test` command.

---

### Issue: Deployment fails with auto-detection

**Problem:**
```bash
$ /deployment:deploy
Error: Could not detect deployment platform
```

**Solution:**

Manually specify platform in `.claude/project.json`:
```json
{
  "deployment": {
    "platforms": {
      "primary": "vercel",
      "fallback": ["railway"]
    }
  }
}
```

---

## Rollback Instructions

If you need to rollback to v1.x:

```bash
# Restore from backup
rm -rf ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace
cp -r ~/.claude/plugins.backup/marketplaces/dev-lifecycle-marketplace ~/.claude/plugins/marketplaces/

# Or restore from legacy backup
cp -r /tmp/dev-lifecycle-legacy/* ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/
```

---

## Getting Help

- **Issues**: Report migration issues at repository
- **Questions**: Check plugin-specific README files
- **Legacy Backup**: Full v1.x backup at `/tmp/dev-lifecycle-legacy/`

---

## Timeline

- **v1.0.0**: Initial release with numbered plugins (01- through 06-)
- **v2.0.0**: Complete rebuild with clean naming (October 2025)
- **v2.1.0** (Planned): Full quality plugin skill implementation

---

**Migration Completed**: October 29, 2025
**Backup Location**: `/tmp/dev-lifecycle-legacy/`
