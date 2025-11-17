---
description: Complete Doppler secret management setup with scripts, docs, and GitHub integration
argument-hint: [project-name]
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---


## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Complete Doppler setup with scripts, documentation, and GitHub integration

This command uses the `doppler-management` skill to generate all necessary files.

---

## Phase 1: Discovery & Validation

Goal: Detect project context and check prerequisites

Actions:
- Parse $ARGUMENTS for project name or detect from directory:
  !{bash basename $(pwd)}
- Detect GitHub repository:
  !{bash git remote -v 2>&1 | grep origin | head -1 | sed 's/.*github.com[:/]\(.*\)\.git.*/\1/' || echo "not-detected"}
- Check Doppler CLI installation:
  !{bash which doppler && doppler --version || echo "not-installed"}
- Check authentication:
  !{bash doppler me 2>&1 | grep -q "email" && echo "authenticated" || echo "not-authenticated"}
- Load project configuration:
  @.claude/project.json
- Check for existing .env files:
  !{bash ls -la .env* 2>/dev/null | grep -v .example || echo "no-env-files"}

If Doppler not installed:
- Display: "Install Doppler CLI: curl -Ls https://cli.doppler.com/install.sh | sh"
- Exit with instructions

If not authenticated:
- Display: "Run 'doppler login' to authenticate"
- Exit with instructions

---

## Phase 2: Doppler Project Setup

Goal: Create Doppler project and environments

Actions:
- Create Doppler project:
  !{bash doppler projects create $PROJECT_NAME --description "$PROJECT_NAME - AI-powered application" 2>&1}

- Create environments with proper names and slugs:
  !{bash doppler environments create dev dev --project $PROJECT_NAME 2>&1 || echo "dev exists"}
  !{bash doppler environments create staging stg --project $PROJECT_NAME 2>&1 || echo "stg exists"}
  !{bash doppler environments create production prd --project $PROJECT_NAME 2>&1 || echo "prd exists"}

- Configure local development:
  !{bash doppler setup --project $PROJECT_NAME --config dev --no-interactive 2>&1}

- Verify environments created:
  !{bash doppler environments --project $PROJECT_NAME 2>&1}

---

## Phase 3: Generate Scripts

Goal: Create all Doppler utility scripts from templates

Use doppler-management skill templates:

**Create scripts/doppler/ directory:**
!{bash mkdir -p scripts/doppler}

**Generate migrate-to-doppler.sh:**
- Copy from: `skills/doppler-management/scripts/migrate-to-doppler.sh`
- Replace variables:
  - `{{PROJECT_NAME}}` → $PROJECT_NAME
  - `{{GITHUB_REPO}}` → $GITHUB_REPO (detected)
  - `{{GENERATION_DATE}}` → $(date +%Y-%m-%d)
- Output to: `scripts/doppler/migrate-to-doppler.sh`
- Make executable: !{bash chmod +x scripts/doppler/migrate-to-doppler.sh}

**Generate run-with-doppler.sh:**
- Copy from: `skills/doppler-management/scripts/run-with-doppler.sh`
- Replace `{{PROJECT_NAME}}` → $PROJECT_NAME
- Output to: `scripts/doppler/run-with-doppler.sh`
- Make executable: !{bash chmod +x scripts/doppler/run-with-doppler.sh}

**Generate setup-doppler-github.sh:**
- Copy from: `skills/doppler-management/scripts/setup-doppler-github.sh`
- Replace variables:
  - `{{PROJECT_NAME}}` → $PROJECT_NAME
  - `{{GITHUB_REPO}}` → $GITHUB_REPO
- Output to: `scripts/doppler/setup-doppler-github.sh`
- Make executable: !{bash chmod +x scripts/doppler/setup-doppler-github.sh}

---

## Phase 4: Generate Documentation

Goal: Create comprehensive Doppler documentation

Use doppler-management skill templates:

**Create docs/doppler/ directory:**
!{bash mkdir -p docs/doppler}

**Generate README.md:**
- Copy from: `skills/doppler-management/templates/docs/README.md`
- Replace variables:
  - `{{PROJECT_NAME}}` → $PROJECT_NAME
  - `{{GITHUB_REPO}}` → $GITHUB_REPO
- Output to: `docs/doppler/README.md`

**Generate integration-guide.md:**
- Copy from: `skills/doppler-management/templates/docs/integration-guide.md`
- Replace variables as needed
- Output to: `docs/doppler/integration-guide.md`

**Generate github-integration.md:**
- Copy from: `skills/doppler-management/templates/docs/github-integration.md`
- Replace `{{GITHUB_REPO}}` → $GITHUB_REPO
- Output to: `docs/doppler/github-integration.md`

**Generate environment-setup.md:**
- Copy from: `skills/doppler-management/templates/docs/environment-setup.md`
- Replace variables as needed
- Output to: `docs/doppler/environment-setup.md`

**Copy PLUGIN-DESIGN.md:**
- Copy from: `skills/doppler-management/templates/docs/PLUGIN-DESIGN.md`
- Output to: `docs/doppler/PLUGIN-DESIGN.md`

---

## Phase 5: GitHub Actions Workflow

Goal: Create test workflow for verifying Doppler integration

Actions:
- Create .github/workflows/ directory if not exists:
  !{bash mkdir -p .github/workflows}

- Generate test-doppler-secrets.yml:
  - Copy from: `skills/doppler-management/templates/workflows/test-doppler-secrets.yml`
  - Replace variables as needed
  - Output to: `.github/workflows/test-doppler-secrets.yml`

---

## Phase 6: Update .gitignore

Goal: Protect Doppler configuration files

Actions:
- Check if .gitignore exists
- Add Doppler entries if not present:
  ```
  # Doppler (secret management)
  .doppler.env
  doppler.yaml
  .doppler/
  ```

- Add to .gitignore:
  !{bash grep -q "doppler" .gitignore 2>/dev/null || echo -e "\n# Doppler (secret management)\n.doppler.env\ndoppler.yaml\n.doppler/" >> .gitignore}

---

## Phase 7: Generate Summary Document

Goal: Create quick reference guide

Actions:
- Generate DOPPLER-SETUP-SUMMARY.md in project root
- Include:
  - Setup status
  - File locations
  - Next steps checklist
  - Common commands
  - Dashboard links
  - Migration checklist

---

## Phase 8: Summary & Next Steps

Goal: Display completion status and guide user

Display:
```
╔════════════════════════════════════════════════════╗
║  Doppler Setup Complete!                           ║
╚════════════════════════════════════════════════════╝

Project: $PROJECT_NAME
Repository: $GITHUB_REPO
Environments: dev, stg, prd

Files Created:
✓ scripts/doppler/
  ├── migrate-to-doppler.sh       (8.4K)
  ├── run-with-doppler.sh         (1.3K)
  └── setup-doppler-github.sh     (8.2K)

✓ docs/doppler/
  ├── README.md                    (9.7K)
  ├── integration-guide.md         (15K)
  ├── github-integration.md        (12K)
  ├── environment-setup.md         (17K)
  └── PLUGIN-DESIGN.md            (Design docs)

✓ .github/workflows/
  └── test-doppler-secrets.yml    (6.8K)

✓ DOPPLER-SETUP-SUMMARY.md        (11K)

✓ .gitignore updated

═══════════════════════════════════════════════════

Next Steps:

1. EDIT MIGRATION SCRIPT (Required)
   nano scripts/doppler/migrate-to-doppler.sh

   Replace placeholders with real values:
   - GOOGLE_API_KEY
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
   - SUPABASE_SERVICE_KEY

2. RUN MIGRATION
   scripts/doppler/migrate-to-doppler.sh

3. SETUP GITHUB INTEGRATION
   scripts/doppler/setup-doppler-github.sh

4. TEST LOCAL DEVELOPMENT
   scripts/doppler/run-with-doppler.sh uvicorn api.main:app --reload

5. VERIFY SECRETS
   doppler secrets --project $PROJECT_NAME --config dev

6. CLEAN UP OLD .env FILES (After verification)
   trash-put .env.development .env.staging .env.production

═══════════════════════════════════════════════════

Documentation:
- Quick Start: docs/doppler/README.md
- Full Guide:  docs/doppler/integration-guide.md
- GitHub Setup: docs/doppler/github-integration.md
- Summary:     DOPPLER-SETUP-SUMMARY.md

Dashboards:
- Doppler:  https://dashboard.doppler.com/workplace/projects/$PROJECT_NAME
- GitHub:   https://github.com/$GITHUB_REPO

═══════════════════════════════════════════════════

SECURITY REMINDER:
⚠️ migrate-to-doppler.sh contains PLACEHOLDERS only
⚠️ You MUST edit with real secrets before running
⚠️ Never commit this file after adding real secrets
```

---

## Available Skills

This command has access to foundation plugin skills:

- **doppler-management**: Complete Doppler setup with all scripts and templates
- **environment-setup**: Tool verification and system checks
- **mcp-configuration**: MCP server configuration management
- **project-detection**: Tech stack and dependency detection

To use a skill: `!{skill skill-name}`
