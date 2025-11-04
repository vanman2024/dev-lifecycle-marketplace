---
description: Complete deployment orchestrator - prepares project, configures CI/CD with GitHub Actions and secrets, deploys, and validates. Runs prepare → setup-cicd → deploy → validate in sequence for full automation.
argument-hint: [project-path]
allowed-tools: Bash, Read, Write, Glob, Grep, TodoWrite
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
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Complete end-to-end deployment orchestration - prepare, configure CI/CD, deploy, and validate

**Orchestration Flow**:
1. Run `/deployment:prepare` → Link to platform, check prerequisites
2. Run `/deployment:setup-cicd` → Configure GitHub secrets and workflow
3. Execute deployment → Deploy to platform
4. Run `/deployment:validate` → Verify deployment health

Core Principles:
- Orchestrate don't duplicate - run existing commands in sequence
- Full automation - from zero to deployed with CI/CD
- Validate at each step - catch issues early
- Track progress - use TodoWrite for visibility

Phase 1: Project Preparation
Goal: Link project to platform and check prerequisites

Actions:
- Create comprehensive todo list with all orchestration phases using TodoWrite:
  - Phase 1: Prepare (link platform, check prerequisites)
  - Phase 2: Setup CI/CD (configure GitHub secrets + workflow)
  - Phase 3: Execute Deployment (deploy to platform)
  - Phase 4: Validate (verify deployment health)
- Parse $ARGUMENTS for project path (default to current directory if empty)
- Navigate to project: !{bash cd $PROJECT_PATH && pwd}
- Detect project type: !{bash ls -1 package.json next.config.js vercel.json .mcp.json 2>/dev/null}
- Check if already linked to platform:
  - Vercel: !{bash [ -f ".vercel/project.json" ] && echo "Already linked" || echo "Need to link"}
- If not linked, link now:
  - Vercel: !{bash vercel link --yes --token "$VERCEL_TOKEN"}
- Verify linkage: !{bash [ -f ".vercel/project.json" ] && cat .vercel/project.json | jq '.projectId,.orgId'}
- Check prerequisites:
  - Dependencies: !{bash [ -d "node_modules" ] && echo "✅ Dependencies installed" || echo "⚠️  Run npm install"}
  - Build tools: !{bash which vercel npm node}
  - Environment: !{bash [ -f ".env" ] && echo "✅ .env exists"}
- Update todos to mark preparation complete

Phase 2: CI/CD Configuration
Goal: Configure GitHub secrets and Actions workflow automatically using cicd-setup skill

Actions:
- Detect platform from Phase 1 (vercel, digitalocean-app, railway, etc.)
- Extract platform IDs using cicd-setup skill:
  - !{bash bash plugins/deployment/skills/cicd-setup/scripts/extract-platform-ids.sh <platform> .}
- Configure GitHub secrets using cicd-setup skill:
  - !{bash bash plugins/deployment/skills/cicd-setup/scripts/configure-github-secrets.sh <platform> .}
- This will use gh CLI to set:
  - Vercel: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID
  - DigitalOcean: DIGITALOCEAN_ACCESS_TOKEN, DO_APP_ID
- Generate GitHub Actions workflow:
  - !{bash mkdir -p .github/workflows}
  - !{bash bash plugins/deployment/skills/cicd-setup/scripts/generate-workflow.sh <platform> .github/workflows/deploy.yml}
- Verify workflow created: !{bash [ -f ".github/workflows/deploy.yml" ] && echo "✅ Workflow created"}
- Commit workflow to git:
  - !{bash git add .github/workflows/deploy.yml}
  - !{bash git commit -m "ci: Add automated deployment workflow"}
  - !{bash git push origin $(git branch --show-current)}
- Update todos to mark CI/CD configuration complete

Phase 3: Initial Deployment
Goal: Perform first deployment to platform (creates project if needed)

Actions:
- Inform user that CI/CD is now configured
- Explain that future deployments will be automatic via GitHub Actions
- Perform initial deployment using platform CLI:
  - Vercel: !{bash vercel --prod --yes --token "$VERCEL_TOKEN"}
  - DigitalOcean: !{bash doctl apps create-deployment $APP_ID}
- Capture deployment URL from output
- Update todos to mark initial deployment complete

Phase 4: Post-Deployment Validation
Goal: Verify deployment succeeded and is healthy

Actions:
- Wait for deployment to complete (30 seconds): !{bash sleep 30}
- Check deployment URL accessibility:
  - !{bash curl -f $DEPLOYMENT_URL || echo "Deployment not yet accessible"}
- Run health checks if available:
  - !{bash curl -f $DEPLOYMENT_URL/health || curl -f $DEPLOYMENT_URL/api/health || echo "No health endpoint"}
- Verify GitHub Actions workflow exists:
  - !{bash [ -f ".github/workflows/deploy.yml" ] && echo "✅ CI/CD active"}
- List configured GitHub secrets:
  - !{bash gh secret list}
- Update todos to mark validation complete

Phase 5: Summary and Next Steps
Goal: Report complete deployment setup and provide guidance

Actions:
- Mark all todos complete
- Display comprehensive summary:
  - **Project**: $PROJECT_NAME
  - **Platform**: Vercel/DigitalOcean/Railway
  - **Deployment URL**: $DEPLOYMENT_URL
  - **GitHub Repository**: $REPO_OWNER/$REPO_NAME
  - **CI/CD Status**: ✅ Fully Automated
  - **GitHub Secrets**: VERCEL_TOKEN, VERCEL_ORG_ID, VERCEL_PROJECT_ID (or platform-specific)
  - **GitHub Actions**: .github/workflows/deploy.yml

- Explain what happens now:
  - **Every push to main** → Automatic production deployment via GitHub Actions
  - **Every pull request** → Automatic preview deployment
  - **No manual deployments needed** → GitHub handles everything

- Provide next steps:
  1. Test automatic deployment: Make a change and push to GitHub
  2. Monitor deployment: gh run watch
  3. View deployment logs: gh run view
  4. Rollback if needed: /deployment:rollback

- Show example workflow:
  ```
  git add .
  git commit -m "feat: New feature"
  git push origin main
  # → GitHub Actions automatically deploys to production!
  ```

- If any step failed:
  - Show detailed error logs
  - Provide troubleshooting steps
  - Suggest manual fixes
