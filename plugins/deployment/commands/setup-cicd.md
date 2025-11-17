---
description: Automatically configure CI/CD pipeline with GitHub Actions and secrets for any deployment platform (Vercel, DigitalOcean, Railway). Uses gh CLI to auto-configure repository secrets and generates platform-specific workflows.
argument-hint: "[platform] [project-path]"
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

## Available Skills

This commands has access to the following skills from the deployment plugin:

- **cicd-setup**: Automated CI/CD pipeline setup using GitHub Actions with automatic secret configuration via GitHub CLI. Generates platform-specific workflows (Vercel, DigitalOcean, Railway) and configures repository secrets automatically. Use when setting up continuous deployment, configuring GitHub Actions, automating deployments, or when user mentions CI/CD, GitHub Actions, automated deployment, or pipeline setup.
- **deployment-scripts**: Platform-specific deployment scripts and configurations. Use when deploying applications, configuring cloud platforms, validating deployment environments, setting up CI/CD pipelines, or when user mentions Vercel, Netlify, AWS, Docker, deployment config, build scripts, or environment validation.
- **digitalocean-app-deployment**: DigitalOcean App Platform deployment using doctl CLI for containerized applications, web services, static sites, and databases. Includes app spec generation, deployment orchestration, environment management, domain configuration, and health monitoring. Use when deploying to App Platform, managing app specs, configuring databases, or when user mentions App Platform, app spec, managed deployment, or PaaS deployment.
- **digitalocean-droplet-deployment**: Generic DigitalOcean droplet deployment using doctl CLI for any application type (APIs, web servers, background workers). Includes validation, deployment scripts, systemd service management, secret handling, health checks, and deployment tracking. Use when deploying Python/Node.js/any apps to droplets, managing systemd services, handling secrets securely, or when user mentions droplet deployment, doctl, systemd, or server deployment.
- **health-checks**: Post-deployment validation and health check scripts for validating HTTP endpoints, APIs, MCP servers, SSL/TLS certificates, and performance metrics. Use when deploying applications, validating deployments, testing endpoints, checking SSL certificates, running performance tests, or when user mentions health checks, deployment validation, endpoint testing, performance testing, or uptime monitoring.
- **platform-detection**: Detect project type and recommend deployment platform. Use when deploying projects, choosing hosting platforms, analyzing project structure, or when user mentions deployment, platform selection, MCP servers, APIs, frontend apps, static sites, FastMCP Cloud, DigitalOcean, Vercel, Hostinger, Netlify, or Cloudflare.
- **vercel-deployment**: Vercel deployment using Vercel CLI for Next.js, React, Vue, static sites, and serverless functions. Includes project validation, deployment orchestration, environment management, domain configuration, and analytics integration. Use when deploying frontend applications, static sites, or serverless APIs, or when user mentions Vercel, Next.js deployment, serverless functions, or edge network.

**To use a skill:**
```
!{skill skill-name}
```

Use skills when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---



## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- GitHub secrets configured via gh CLI (not hardcoded)
- All tokens read from environment variables
- Placeholders only in generated files

**Arguments**: $ARGUMENTS

Goal: Automatically set up complete CI/CD pipeline with GitHub Actions and repository secrets using one command

Phase 1: Discovery & Setup
Goal: Parse arguments and prepare for CI/CD setup

Actions:
- Create comprehensive todo list using TodoWrite for all phases
- Parse $ARGUMENTS to extract platform and project-path (default to current directory)
- Check current directory: !{bash pwd}
- Check git repository status: !{bash git rev-parse --is-inside-work-tree && echo "✓ Git repository" || echo "✗ Not a git repository"}
- Get repository info: !{bash gh repo view --json owner,name 2>/dev/null || echo "No GitHub repository detected"}
- Update todos

Phase 2: Prerequisites Verification
Goal: Ensure all required tools and authentication are in place

Actions:
- Check GitHub CLI: !{bash gh auth status && echo "✓ gh authenticated" || echo "✗ gh not authenticated"}
- If gh not authenticated, inform user to run: gh auth login
- Check git repository exists
- Determine platform from $ARGUMENTS or detect automatically:
  - !{bash ls -1 vercel.json .vercel next.config.js next.config.mjs app-spec.yml .do/app.yaml railway.json 2>/dev/null}
- Based on detected files, set platform (vercel, digitalocean-app, railway)
- Check platform CLI:
  - Vercel: !{bash which vercel && echo "✓ vercel CLI" || echo "✗ vercel CLI not installed"}
  - DigitalOcean: !{bash which doctl && echo "✓ doctl CLI" || echo "✗ doctl not installed"}
  - Railway: !{bash which railway && echo "✓ railway CLI" || echo "✗ railway not installed"}
- Check platform token in environment:
  - !{bash [ -n "$VERCEL_TOKEN" ] && echo "✓ VERCEL_TOKEN set" || echo "⚠ VERCEL_TOKEN not set"}
  - !{bash [ -n "$DIGITALOCEAN_ACCESS_TOKEN" ] && echo "✓ DIGITALOCEAN_ACCESS_TOKEN set" || echo "⚠ DIGITALOCEAN_ACCESS_TOKEN not set"}
- If any prerequisites missing, provide installation/setup instructions and exit
- Update todos

Phase 3: Extract Platform IDs
Goal: Automatically extract platform-specific project IDs

Actions:
- Run platform ID extraction script from cicd-setup skill:
  - !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/cicd-setup/scripts/extract-platform-ids.sh <platform> .}
- Script will:
  - Link project to platform if not already linked (e.g., vercel link)
  - Extract IDs from config files (.vercel/project.json, railway.json, etc.)
  - Output JSON with orgId, projectId, etc.
- Capture and display extracted IDs
- If extraction fails, provide troubleshooting steps
- Update todos

Phase 4: Configure GitHub Secrets
Goal: Automatically set GitHub repository secrets via gh CLI

Actions:
- Run GitHub secrets configuration script from cicd-setup skill:
  - !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/cicd-setup/scripts/configure-github-secrets.sh <platform> .}
- Script will use gh CLI to set:
  - Vercel: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID
  - DigitalOcean: DIGITALOCEAN_ACCESS_TOKEN, DO_APP_ID
  - Railway: RAILWAY_TOKEN, RAILWAY_PROJECT_ID
- Verify secrets were configured: !{bash gh secret list}
- Display configured secrets
- Update todos

Phase 5: Generate GitHub Actions Workflow
Goal: Create platform-specific deployment workflow

Actions:
- Ensure .github/workflows directory exists: !{bash mkdir -p .github/workflows}
- Run workflow generation script from cicd-setup skill:
  - !{bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/cicd-setup/scripts/generate-workflow.sh <platform> .github/workflows/deploy.yml}
- Script will copy platform-specific template (vercel-workflow.yml, digitalocean-app-workflow.yml, etc.)
- Verify workflow file created: !{bash [ -f .github/workflows/deploy.yml ] && echo "✓ Workflow created" || echo "✗ Workflow creation failed"}
- Display workflow path
- Update todos

Phase 6: Commit and Push Workflow
Goal: Add workflow to git and push to GitHub

Actions:
- Check if workflow already committed: !{bash git diff --quiet .github/workflows/deploy.yml && echo "Already committed" || echo "New changes"}
- If new changes, stage and commit:
  - !{bash git add .github/workflows/deploy.yml && git commit -m "ci: Add deployment workflow"}
- Push to remote: !{bash git push origin $(git branch --show-current)}
- If push fails, provide manual push instructions
- Update todos

Phase 7: Summary & Next Steps
Goal: Provide comprehensive setup summary and usage instructions

Actions:
- Mark all todos complete
- Display CI/CD setup summary:
  - **Platform:** <detected-platform>
  - **Repository:** <owner>/<name>
  - **Workflow File:** .github/workflows/deploy.yml
  - **GitHub Secrets Configured:**
    - List all secrets that were set
  - **Status:** ✅ CI/CD fully configured and automated

- Explain what happens next:
  - **Every push to main** → Automatic production deployment
  - **Every pull request** → Automatic preview deployment
  - **PR comments** → Preview URLs posted automatically

- Provide next steps:
  1. Test deployment: git push origin main
  2. Monitor deployment: gh run watch
  3. View deployment logs: gh run view
  4. Create PR for preview: gh pr create --fill

- Show platform-specific features:
  - Vercel: Preview URLs, production deployments, health checks
  - DigitalOcean: App Platform deployments, health checks
  - Railway: Automatic deployments, environment management

- Provide troubleshooting resources:
  - View workflow: .github/workflows/deploy.yml
  - List secrets: gh secret list
  - View runs: gh run list --workflow=deploy.yml
