---
description: Manage environment variables for project configuration
argument-hint: <action> [key] [value]
allowed-tools: Read, Write, Edit, Bash, Grep, AskUserQuestion
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Scan codebase to detect ALL environment variables used, generate .env file, and manage environment configuration

Core Principles:
- **Scan actual codebase** to detect environment variable usage (no .claude/project.json)
- Secure handling - never log sensitive values
- Support .env files and system environment
- **Launch agents for large codebases** to comprehensively search code
- Generate complete .env template from detected variables

## Phase 1: Discovery - Multi-Source Detection

Goal: Detect required environment variables from ALL available sources (priority order)

Actions:
- Parse $ARGUMENTS for action (scan, generate, setup-multi-env, add, remove, list, check)
- Load .env file if exists: @.env
- **Launch env-detector agent with multi-source analysis:**

  **Priority 1: Check specs/ directory (HIGHEST PRIORITY)**
  - Look for specs/*.md files
  - Analyze specs for mentioned services, APIs, databases
  - Extract service requirements from spec documents
  - Example: Spec mentions "Supabase for database" → detect SUPABASE_* vars needed

  **Priority 2: Check manifest files (MEDIUM PRIORITY)**
  - Read package.json dependencies (Node.js/TypeScript)
  - Read pyproject.toml/requirements.txt (Python)
  - Detect installed SDKs: @anthropic-ai/sdk, @supabase/supabase-js, openai, etc.

  **Priority 3: Scan codebase (FALLBACK)**
  - Search code for environment variable usage patterns
  - JavaScript: process.env.VAR_NAME, import.meta.env.VAR_NAME
  - Python: os.getenv("VAR_NAME"), os.environ["VAR_NAME"]
  - Find actual variable references in code

- Merge results from all sources (deduplicate)
- Map detected services/variables to required environment variables

## Phase 2: Validation

Goal: Verify action and gather information if needed

Actions:
- If action unclear, use AskUserQuestion to ask:
  - What would you like to do? (scan, generate, setup-multi-env, add, remove, list, check)
  - For add: Which key and value?
  - For remove: Which key to remove?
  - For setup-multi-env: Which project name and environments?
- For 'add' action:
  - Validate key format (UPPERCASE_SNAKE_CASE)
  - Check if key already exists
  - Warn if overwriting
- For 'setup-multi-env' action:
  - Use AskUserQuestion to gather:
    - Project name (e.g., "staffhive")
    - Environments needed (development, staging, production or custom)
    - Services detected from Phase 1 agent analysis

## Phase 3: Execution

Goal: Perform environment variable management

Actions based on action:

**For 'scan' action (DRY-RUN):**
- Use detected services from Phase 1 agent analysis
- Display what would be generated WITHOUT creating files
- Show preview of .env structure with all detected variables
- Report detection sources (specs, manifests, code)
- List all services detected and their required keys
- Format output similar to final .env but as a preview
- Report: "Found {count} required variables for {services}"
- Suggest: "Run '/foundation:env-vars generate' to create .env files"

**For 'generate' action (CREATE FILES):**
- Use detected services from Phase 1 agent analysis
- Generate .env file based on detected services with placeholder values:

  **Example Template Format:**
  ```
  # ============================================
  # Anthropic Claude API (detected: @anthropic-ai/sdk)
  # ============================================
  ANTHROPIC_API_KEY=your_anthropic_api_key_here

  # ============================================
  # Supabase (detected: @supabase/supabase-js)
  # ============================================
  SUPABASE_URL=https://your-project.supabase.co
  SUPABASE_ANON_KEY=your_supabase_anon_key_here

  # ============================================
  # OpenAI (detected: openai package)
  # ============================================
  OPENAI_API_KEY=your_openai_api_key_here

  # ============================================
  # Application Configuration
  # ============================================
  NODE_ENV=development
  PORT=3000
  ```

- Also generate .env.example (safe to commit with same structure)
- Report: "Created .env with {count} required variables for {services}"
- List all services detected and their required keys
- Show file locations: ".env and .env.example created"

**For 'add' action:**
- Add/update variable in .env file
- Example: Edit .env to add KEY=value
- Never log the value
- Report: "Added {key} to .env"

**For 'remove' action:**
- Remove variable from .env
- Example: Edit .env to remove line
- Report: "Removed {key} from .env"

**For 'list' action:**
- Display all variables (mask sensitive values)
- Example: @.env
- Format: KEY=masked_value (show *** for sensitive keys)

**For 'check' action:**
- Compare .env against detected variables from codebase scan
- Report missing variables that code expects
- Report unused variables in .env (cleanup candidates)
- Example: "Missing: SUPABASE_URL (used in src/lib/supabase.ts:12)"

**For 'setup-multi-env' action (COMPREHENSIVE MULTI-ENVIRONMENT SETUP):**

This creates a production-ready multi-environment structure with proper API key organization.

**Step 1: Gather Project Information**
- Use AskUserQuestion to collect:
  - Project name (e.g., "staffhive")
  - Environments to create (default: development, staging, production)
  - Confirm services detected from Phase 1 analysis

**Step 2: Create Environment Files**

Create separate .env files for each environment with detected services:

**`.env.development`:**
```bash
# ============================================
# {PROJECT_NAME} - Development Environment
# ============================================

# Anthropic Claude API (detected: {detection_source})
# Get key: https://console.anthropic.com/settings/keys
# Project: {project-name}-development
ANTHROPIC_API_KEY={project-name}_dev_your_key_here

# Supabase (detected: {detection_source})
# Get keys: https://supabase.com/dashboard/project/{project}/settings/api
SUPABASE_URL=https://{project}-dev.supabase.co
SUPABASE_ANON_KEY={project}_dev_anon_key_here

# Application Configuration
NODE_ENV=development
PORT=3000
DEBUG=true
LOG_LEVEL=debug
```

**`.env.staging`:**
```bash
# ============================================
# {PROJECT_NAME} - Staging Environment
# ============================================

ANTHROPIC_API_KEY={project-name}_staging_your_key_here
SUPABASE_URL=https://{project}-staging.supabase.co
SUPABASE_ANON_KEY={project}_staging_anon_key_here

NODE_ENV=staging
PORT=3000
DEBUG=false
LOG_LEVEL=info
```

**`.env.production`:**
```bash
# ============================================
# {PROJECT_NAME} - Production Environment
# ============================================

ANTHROPIC_API_KEY={project-name}_prod_your_key_here
SUPABASE_URL=https://{project}-prod.supabase.co
SUPABASE_ANON_KEY={project}_prod_anon_key_here

NODE_ENV=production
PORT=3000
DEBUG=false
LOG_LEVEL=warn
```

**`.env.example`** (safe to commit):
```bash
# Template - Copy to .env.development, .env.staging, or .env.production
ANTHROPIC_API_KEY=your_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
NODE_ENV=development
```

**`.env`** (symlink):
```bash
# Create symlink to active environment
ln -sf .env.development .env
```

**Step 3: Create Environment Switcher Script**

**`switch-env.sh`:**
```bash
#!/usr/bin/env bash
# Switch between environments by updating .env symlink

set -euo pipefail

ENVIRONMENT="${1:-}"

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: ./switch-env.sh [development|staging|production]"
    echo ""
    echo "Current environment:"
    if [ -L .env ]; then
        readlink .env | sed 's/\.env\.//'
    else
        echo "No environment active (symlink not found)"
    fi
    exit 1
fi

ENV_FILE=".env.$ENVIRONMENT"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file not found: $ENV_FILE"
    echo "Available environments:"
    ls -1 .env.* 2>/dev/null | sed 's/\.env\./  - /'
    exit 1
fi

ln -sf "$ENV_FILE" .env
echo "✓ Switched to $ENVIRONMENT environment"
echo "Active file: $ENV_FILE"
```

Make executable:
```bash
chmod +x switch-env.sh
```

**Step 4: Update .gitignore**

Add to .gitignore (create if doesn't exist):
```
# Environment files (NEVER commit these!)
.env
.env.development
.env.staging
.env.production

# Keep example files
!.env.example
```

**Step 5: Generate Anthropic Console Setup Guide**

Create `ANTHROPIC_SETUP.md` with instructions:
```markdown
# Anthropic Console Setup for {PROJECT_NAME}

## Create Projects in Anthropic Console

Visit: https://console.anthropic.com

### 1. Create Development Project

1. Click "Create Project"
2. Name: `{project-name}-development`
3. Description: "Development environment for {project-name}"
4. Click "Create API Key"
5. Name: "{project-name} Dev - YYYY-MM-DD"
6. Copy key → Paste into `.env.development` as `ANTHROPIC_API_KEY`

### 2. Create Staging Project

1. Click "Create Project"
2. Name: `{project-name}-staging`
3. Description: "Staging environment for {project-name}"
4. Click "Create API Key"
5. Name: "{project-name} Staging - YYYY-MM-DD"
6. Copy key → Paste into `.env.staging` as `ANTHROPIC_API_KEY`

### 3. Create Production Project

1. Click "Create Project"
2. Name: `{project-name}-production`
3. Description: "Production environment for {project-name}"
4. Click "Create API Key"
5. Name: "{project-name} Production - YYYY-MM-DD"
6. Copy key → Paste into `.env.production` as `ANTHROPIC_API_KEY`

## Key Naming Convention

Follow this pattern for all API keys:
- **Development**: `{project-name}-dev-YYYY-MM-DD`
- **Staging**: `{project-name}-staging-YYYY-MM-DD`
- **Production**: `{project-name}-prod-YYYY-MM-DD`

## Usage Tracking

Each Anthropic project has separate usage tracking:
- Development usage won't affect production quotas
- Easy to rotate keys per environment
- Clear cost attribution per environment

## Next Steps

1. ✓ Create Anthropic projects (instructions above)
2. ✓ Copy API keys to respective .env files
3. ✓ Set up Supabase projects (if detected)
4. ✓ Run `./switch-env.sh development` to activate dev environment
5. ✓ Validate: `/foundation:env-vars check`
```

**Step 6: Generate Service-Specific Guides**

For each detected service, create setup instructions:

**If Supabase detected:**
Create `SUPABASE_SETUP.md` with multi-project setup instructions.

**If FastMCP detected:**
Create `FASTMCP_SETUP.md` with multi-environment server configuration.

**Step 7: Report Created Files**

Display comprehensive summary:
```
✓ Multi-Environment Setup Complete for {PROJECT_NAME}

Files Created:
├── .env.development (development configuration)
├── .env.staging (staging configuration)
├── .env.production (production configuration)
├── .env.example (template for git)
├── .env → .env.development (active environment symlink)
├── switch-env.sh (environment switcher)
├── ANTHROPIC_SETUP.md (Anthropic Console instructions)
├── SUPABASE_SETUP.md (Supabase multi-project guide)
└── .gitignore (updated with env file rules)

Detected Services:
- Anthropic Claude API (from {source})
- Supabase (from {source})
- [Additional services...]

Next Steps:

1. Create Anthropic Console Projects:
   Read ANTHROPIC_SETUP.md for detailed instructions
   https://console.anthropic.com

2. Set up service accounts for each environment:
   - Development: Testing and development
   - Staging: Pre-production validation
   - Production: Live application

3. Fill in API keys:
   Edit each .env.{environment} file with actual keys

4. Switch to development:
   ./switch-env.sh development

5. Validate setup:
   /foundation:env-vars check

6. Start development:
   npm run dev (or equivalent)
```

## Phase 4: Summary

Goal: Report results

Actions:
- Display summary:
  - For scan: "Found {count} required variables for {services}" (preview only, no files created)
  - For generate: "Created .env and .env.example with {count} variables"
  - For setup-multi-env: "Multi-environment setup complete with {N} environments"
  - For add: "Environment variable added: {key}"
  - For remove: "Environment variable removed: {key}"
  - For list: "{count} environment variables configured"
  - For check: "✓ All required variables present" or "Missing: {list}"
- Show next steps:
  - For scan: "Run '/foundation:env-vars generate' to create .env files"
  - For generate: "Fill in your actual API keys and secrets in .env"
  - For setup-multi-env: "Read ANTHROPIC_SETUP.md and follow setup instructions"
  - For add/remove: "Restart development server to apply changes"
  - "Add .env to .gitignore if not already present"
  - For check: "Fill in missing variables"
