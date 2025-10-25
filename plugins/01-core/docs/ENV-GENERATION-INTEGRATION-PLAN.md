# Environment Generation Integration Plan

## Overview

Integrate environment file creation patterns from `multiagent-core` into the `01-core` plugin initialization workflow to ensure proper `.env`, `.toml`, and `.json` configuration files are created when initializing projects.

---

## Key Patterns from multiagent-core

### 1. Two-Tier Key Management

**Global MCP Keys** (in `~/.bashrc`):
- MCP server authentication keys
- Shared development tool keys
- Platform CLI tokens
- Format: `export MCP_GITHUB_TOKEN="..."`
- **Never** committed to project repos
- Set once, used across all projects

**Project-Specific Keys** (in `.env`):
- Runtime API keys for application features
- Database connection strings
- Service integrations (Stripe, SendGrid, etc.)
- Project URLs and secrets
- Format: Standard `.env` key-value pairs
- **Never** use MCP_* prefix (those are in ~/.bashrc)

### 2. .env.template Structure

```bash
# ==============================================================================
# PROJECT API KEYS & CONFIGURATION
# ==============================================================================
# Copy this file to .env and fill in your project-specific values
# .env is gitignored - never commit real API keys!
#
# For shared/global keys (MCP servers, development tools):
#   See ~/.bashrc for MCP_* and platform keys
# ==============================================================================

# ------------------------------------------------------------------------------
# PROJECT IDENTITY
# ------------------------------------------------------------------------------
PROJECT_NAME=
NODE_ENV=development

# ------------------------------------------------------------------------------
# DATABASES
# ------------------------------------------------------------------------------
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

MONGODB_URI=mongodb://localhost:27017/dbname
REDIS_URL=redis://localhost:6379

# ------------------------------------------------------------------------------
# PROJECT-SPECIFIC API KEYS
# ------------------------------------------------------------------------------
# These are ONLY for this project's runtime code
# Do NOT use MCP_* prefix (those are in ~/.bashrc)

OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GOOGLE_AI_API_KEY=

# ------------------------------------------------------------------------------
# THIRD-PARTY SERVICES (Project-Specific)
# ------------------------------------------------------------------------------
STRIPE_PUBLIC_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

SENDGRID_API_KEY=

# ------------------------------------------------------------------------------
# APPLICATION URLS
# ------------------------------------------------------------------------------
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:8000
API_URL=http://localhost:8000/api

# ------------------------------------------------------------------------------
# AUTHENTICATION
# ------------------------------------------------------------------------------
JWT_SECRET=
SESSION_SECRET=
NEXTAUTH_SECRET=
NEXTAUTH_URL=http://localhost:3000

# ------------------------------------------------------------------------------
# FEATURE FLAGS
# ------------------------------------------------------------------------------
ENABLE_ANALYTICS=false
ENABLE_DEBUG_LOGGING=false

# ==============================================================================
# NOTES
# ==============================================================================
# Global MCP Keys: Located in ~/.bashrc with MCP_* prefix
# Platform Keys: Set via platform CLI (vercel env, railway vars, etc.)
# Never commit .env file - it's gitignored by default
# ==============================================================================
```

### 3. Intelligent Environment Generation Agent

**Agent**: `env-generator.md` (from multiagent-core)

**Process**:
1. Analyzes project files (specs, docs, dependencies, .mcp.json)
2. Categorizes services by type:
   - AI/LLM API Keys (anthropic, openai, cohere, etc.)
   - Memory Systems (mem0, pinecone, weaviate, etc.)
   - Communication Services (sendgrid, twilio, slack, etc.)
   - Data & Storage (airtable, supabase, redis, postgresql, etc.)
   - Business Services (stripe, calendly, salesforce, etc.)
   - Infrastructure & Platform (vercel, aws, digitalocean, etc.)
   - MCP Servers (production only - dev uses ~/.bashrc)
3. Fills template with detected services
4. Includes dashboard URLs for obtaining keys
5. Annotates source files where each key was found
6. Separates secrets (empty values) from config (defaults)

**Output**: Comprehensive `.env` file with categorized keys and helpful comments

---

## Integration into 01-core:init

### Current Implementation (multiagent-core/cli.py:1570-1590)

```python
# Copy .env.template for project-specific API keys
console.print("Setting up .env.template...")
try:
    resource = templates_root.joinpath('.env.template')
    with importlib_resources.as_file(resource) as env_template_src:
        env_template_src = Path(env_template_src)
        dest_env_template = cwd / '.env.template'
        if not dest_env_template.exists():
            shutil.copy(env_template_src, dest_env_template)
            console.print("[green]Created .env.template (copy to .env and fill in your keys)[/green]")
        else:
            console.print("[dim]Skipped existing .env.template[/dim]")
except FileNotFoundError:
    console.print("[yellow]Warning: .env.template not found in package resources[/yellow]")
except Exception as e:
    console.print(f"[yellow]Warning: Could not copy .env.template: {e}[/yellow]")
```

### Proposed 01-core:init Steps

#### Step 1: Copy .env.template (Mechanical)

**Script**: `plugins/01-core/skills/environment-setup/scripts/copy-env-template.sh`

```bash
#!/usr/bin/env bash
# Script: copy-env-template.sh
# Purpose: Copy .env.template to project directory
# Plugin: 01-core
# Skill: environment-setup

set -euo pipefail

TEMPLATE_SOURCE="plugins/01-core/skills/environment-setup/templates/.env.template"
TEMPLATE_DEST=".env.template"

if [[ -f "$TEMPLATE_DEST" ]]; then
    echo "✓ .env.template already exists"
    exit 0
fi

if [[ ! -f "$TEMPLATE_SOURCE" ]]; then
    echo "❌ ERROR: Template not found at $TEMPLATE_SOURCE"
    exit 1
fi

cp "$TEMPLATE_SOURCE" "$TEMPLATE_DEST"
echo "✅ Created .env.template"
echo "   Copy to .env and fill in your project-specific keys"
```

#### Step 2: Intelligent Analysis (Optional, Agent-based)

**Agent**: `plugins/01-core/skills/environment-setup/agent/env-generator.md`

**Trigger**: User explicitly requests intelligent env generation
**Command**: `/core:env-generate` (separate slash command)

**Process**:
1. Scan project files for service dependencies
2. Categorize by service type
3. Generate comprehensive .env with:
   - Detected services
   - Dashboard URLs
   - Source annotations
   - Empty values for secrets
   - Defaults for config

**Do NOT auto-invoke**: Too expensive for tokens, opt-in only

#### Step 3: Create .gitignore Entry (Mechanical)

**Script**: `plugins/01-core/skills/environment-setup/scripts/update-gitignore.sh`

```bash
#!/usr/bin/env bash
# Script: update-gitignore.sh
# Purpose: Ensure .env is gitignored
# Plugin: 01-core
# Skill: environment-setup

set -euo pipefail

GITIGNORE_FILE=".gitignore"

# Create .gitignore if missing
if [[ ! -f "$GITIGNORE_FILE" ]]; then
    touch "$GITIGNORE_FILE"
fi

# Check if .env is already ignored
if grep -q "^\.env$" "$GITIGNORE_FILE"; then
    echo "✓ .env already in .gitignore"
    exit 0
fi

# Add .env to .gitignore
echo "" >> "$GITIGNORE_FILE"
echo "# Environment variables (never commit)" >> "$GITIGNORE_FILE"
echo ".env" >> "$GITIGNORE_FILE"
echo ".env.local" >> "$GITIGNORE_FILE"
echo "" >> "$GITIGNORE_FILE"

echo "✅ Added .env to .gitignore"
```

#### Step 4: Display Key Management Guidance (Output)

**Output to user** (part of init command completion):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Environment Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Two-Tier Key Management:

1. Global MCP Keys (in ~/.bashrc)
   - MCP server authentication (MCP_GITHUB_TOKEN, etc.)
   - Shared development tools
   - Set once, used across all projects

   Add to ~/.bashrc:
     export MCP_GITHUB_TOKEN="ghp_xxxxx"
     export MCP_POSTMAN_KEY="PMAK-xxxxx"

2. Project Keys (in .env - THIS PROJECT ONLY)
   - Database credentials
   - Project-specific API keys
   - Service integrations

   Copy .env.template to .env and add project-specific keys

Next steps:
  1. Copy .env.template to .env
  2. Fill in project-specific API keys
  3. For MCP servers: Add MCP_* keys to ~/.bashrc once
  4. Optional: Run /core:env-generate for intelligent analysis
```

---

## TOML and JSON Config Files

### When to Create

**TOML Files** (e.g., `config.toml`, `pyproject.toml`):
- **Trigger**: Python project detected (`pyproject.toml` exists or `setup.py` exists)
- **Action**: Ensure `pyproject.toml` exists with basic structure
- **Script**: `plugins/01-core/skills/environment-setup/scripts/create-toml-config.sh`

**JSON Files** (e.g., `config.json`, `package.json`):
- **Trigger**: Node.js project detected (`package.json` exists)
- **Action**: Ensure `package.json` exists with basic structure
- **Script**: `plugins/01-core/skills/environment-setup/scripts/create-json-config.sh`

### Example: create-toml-config.sh

```bash
#!/usr/bin/env bash
# Script: create-toml-config.sh
# Purpose: Create pyproject.toml if Python project detected
# Plugin: 01-core
# Skill: environment-setup

set -euo pipefail

# Check if Python project
if [[ ! -f "setup.py" ]] && [[ ! -f "requirements.txt" ]] && [[ ! -d "src" ]]; then
    echo "✓ Not a Python project, skipping pyproject.toml"
    exit 0
fi

# Check if pyproject.toml already exists
if [[ -f "pyproject.toml" ]]; then
    echo "✓ pyproject.toml already exists"
    exit 0
fi

# Get project name (default to current directory name)
PROJECT_NAME=$(basename "$PWD")

# Create basic pyproject.toml
cat > pyproject.toml << EOF
[project]
name = "${PROJECT_NAME}"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.9"
dependencies = []

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"

[tool.black]
line-length = 100
target-version = ['py39']

[tool.isort]
profile = "black"
line_length = 100
EOF

echo "✅ Created pyproject.toml"
```

---

## bashrc Management

### Current Status

**From multiagent-core/cli.py:462-464**:
```python
# TODO: Re-enable after fixing bashrc_organizer.py issues
#     ... bashrc organization code ...
```

**Conclusion**: bashrc automation was **disabled** due to issues.

### Recommended Approach

**Do NOT automate bashrc management** - too fragile, varies by user setup.

**Instead**: Provide clear **manual instructions** in init output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Global MCP Keys Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Add MCP server keys to ~/.bashrc:

  nano ~/.bashrc

Add these lines at the end:

  # MCP Server Authentication (Global)
  export MCP_GITHUB_TOKEN="ghp_xxxxx"
  export MCP_POSTMAN_KEY="PMAK-xxxxx"
  export MCP_FIGMA_TOKEN="figd_xxxxx"

Reload bashrc:

  source ~/.bashrc

These keys will be available across all projects.
```

---

## Updated 01-core:init Workflow

### Step-by-Step Integration

**File**: `plugins/01-core/commands/init.md`

Add these steps:

```markdown
## Step 5: Environment Configuration

### 5.1 Copy .env.template
!{bash plugins/01-core/skills/environment-setup/scripts/copy-env-template.sh}

### 5.2 Update .gitignore
!{bash plugins/01-core/skills/environment-setup/scripts/update-gitignore.sh}

### 5.3 Create Config Files (if needed)
!{bash plugins/01-core/skills/environment-setup/scripts/create-toml-config.sh}
!{bash plugins/01-core/skills/environment-setup/scripts/create-json-config.sh}

### 5.4 Display Key Management Guidance
!{cat plugins/01-core/skills/environment-setup/templates/key-management-guide.txt}
```

---

## Files to Create

### Directory Structure

```
plugins/01-core/skills/environment-setup/
├── scripts/
│   ├── copy-env-template.sh
│   ├── update-gitignore.sh
│   ├── create-toml-config.sh
│   └── create-json-config.sh
├── templates/
│   ├── .env.template
│   ├── key-management-guide.txt
│   └── pyproject.toml.template
└── agent/
    └── env-generator.md (copied from multiagent-core)
```

### Optional: Slash Command for Intelligent Generation

**File**: `plugins/01-core/commands/env-generate.md`

```markdown
---
description: Intelligently generate .env file by analyzing project dependencies
---

# /core:env-generate

Analyzes your project to detect service dependencies and generates a comprehensive .env file with:
- Categorized API keys (AI/LLM, Communication, Data, Business, Infrastructure)
- Dashboard URLs for obtaining keys
- Source annotations showing where each key was found
- Empty values for secrets, defaults for config

## Usage

Run this command in your project directory:

```bash
/core:env-generate
```

## Process

This command will:
1. Analyze project files (specs, docs, dependencies, .mcp.json)
2. Detect service integrations
3. Categorize by service type
4. Generate .env with helpful comments and dashboard URLs

## Agent Invocation

!{AGENT: env-generator}
```

---

## Summary

### What to Include in 01-core:init

1. ✅ **Copy .env.template** (mechanical script)
2. ✅ **Update .gitignore** (mechanical script)
3. ✅ **Create TOML/JSON config** (mechanical scripts, conditional)
4. ✅ **Display key management guidance** (output text)
5. ❌ **Do NOT automate bashrc** (manual instructions only)
6. ❌ **Do NOT auto-invoke env-generator** (opt-in via /core:env-generate)

### Separation of Concerns

**Mechanical (init)**:
- Copy template
- Update gitignore
- Create config scaffolds
- Display guidance

**Intelligent (optional slash command)**:
- Analyze project
- Detect services
- Generate comprehensive .env
- Token-expensive, opt-in only

---

## Next Steps

1. Create `plugins/01-core/skills/environment-setup/` structure
2. Copy `.env.template` from multiagent-core
3. Create mechanical scripts (copy, gitignore, toml, json)
4. Create key-management-guide.txt template
5. Copy env-generator.md agent from multiagent-core
6. Update `plugins/01-core/commands/init.md` to include env setup steps
7. Create `/core:env-generate` slash command (optional)
8. Add permission for `/core:env-generate` to settings.local.json
9. Test the full workflow

---

**End of Integration Plan**
