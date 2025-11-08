---
description: Setup Doppler secret management for scalable environment variable handling
argument-hint: [project-name]
---

**Arguments**: $ARGUMENTS

Goal: Configure Doppler CLI and project structure for centralized secret management across all environments.

Core Principles:
- Detect project context before setup
- Use placeholders only (never real secrets)
- Support multi-environment workflows
- Provide migration path from .env files

Phase 1: Discovery
Goal: Understand project and check prerequisites

Actions:
- Parse $ARGUMENTS for project name or use directory name:
  !{bash basename $(pwd)}
- Check Doppler CLI installation:
  !{bash which doppler || echo "not-installed"}
- Check for existing .env files:
  !{bash ls -la .env* 2>/dev/null | grep -v .example || echo "no-env-files"}
- Load project configuration:
  @.claude/project.json

Phase 2: Doppler CLI Setup
Goal: Install and authenticate with Doppler

Actions:
- If Doppler not installed, display: "Install Doppler CLI: curl -Ls https://cli.doppler.com/install.sh | sh"
- Verify installation: !{bash doppler --version}
- Check authentication: !{bash doppler me 2>&1 | grep -q "email" && echo "authenticated" || echo "not-authenticated"}
- If not authenticated, guide user to: doppler login

Phase 3: Project Initialization
Goal: Create Doppler project and environments

Actions:
- Create Doppler project:
  !{bash doppler projects create $PROJECT_NAME --description "Managed by Claude Code" 2>&1 || echo "exists"}
- Create environments (dev, staging, production):
  !{bash doppler environments create dev --project $PROJECT_NAME 2>&1 || true}
  !{bash doppler environments create staging --project $PROJECT_NAME 2>&1 || true}
  !{bash doppler environments create production --project $PROJECT_NAME 2>&1 || true}
- List environments: !{bash doppler environments list --project $PROJECT_NAME}

Phase 4: Migration Script Generation
Goal: Create placeholder migration script

Actions:
- Create migrate-to-doppler.sh with placeholder examples
- Script shows HOW to migrate secrets (with placeholders only)
- Include examples for: ANTHROPIC_API_KEY, SUPABASE_URL, DATABASE_URL
- All values use format: your_service_key_here
- Add security warning comments

Phase 5: Local Configuration
Goal: Configure Doppler for local development

Actions:
- Setup Doppler: !{bash doppler setup --project $PROJECT_NAME --config dev}
- Add to .gitignore: .doppler.env and doppler.yaml
- Verify setup: !{bash doppler configure get}
- Create run-with-doppler.sh wrapper script

Phase 6: Framework Integration
Goal: Configure framework-specific usage

Actions:
- Detect framework from project.json
- Provide framework-specific instructions
- For Next.js: doppler run -- npm run dev
- For FastAPI: doppler run -- uvicorn main:app --reload
- For generic: Use run-with-doppler.sh wrapper

Phase 7: Summary
Goal: Report setup completion

Actions:
Display:
✅ Doppler Setup Complete
Project: $PROJECT_NAME
Environments: dev, staging, production

Files Created:
- migrate-to-doppler.sh (EDIT with real secrets!)
- run-with-doppler.sh

Next Steps:
1. Edit migrate-to-doppler.sh with actual secrets
2. Run: bash migrate-to-doppler.sh
3. Clean old .env: trash-put .env.development .env.staging
4. Test: doppler run -- [your-command]
5. Setup CI/CD tokens from dashboard

Dashboard: https://dashboard.doppler.com/workplace/projects/$PROJECT_NAME
