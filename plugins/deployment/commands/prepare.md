---
description: Prepare project for deployment with pre-flight checks (dependencies, build tools, authentication, environment variables)
argument-hint: [project-path]
allowed-tools: Read, Bash, Glob, Grep
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

Goal: Run comprehensive pre-flight checks to ensure project is ready for deployment

Core Principles:
- Verify before deploy - catch issues early
- Check all prerequisites systematically
- Provide actionable feedback
- Support all project types

Phase 1: Discovery
Goal: Understand project structure

Actions:
- Parse $ARGUMENTS for project path (default to current directory)
- Detect project type by checking for indicator files:
  - !{bash ls -1 package.json requirements.txt pyproject.toml go.mod Cargo.toml .mcp.json 2>/dev/null}
- Load configuration files for context:
  - @package.json (if exists)
  - @requirements.txt (if exists)
  - @.env.example (if exists)
- Identify project language and framework

Phase 2: Platform Project Initialization
Goal: Ensure project is linked to deployment platform

Actions:
- Detect target platform from project structure:
  - Vercel: next.config.js, vercel.json, or React/Vue in package.json
  - DigitalOcean: Dockerfile, app-spec.yml, or containerized app
  - Railway: railway.json or backend API project
  - Netlify: netlify.toml or static site

- For Vercel projects:
  - Check if linked: !{bash [ -f ".vercel/project.json" ] && echo "✅ Linked to Vercel" || echo "⚠️ Not linked"}
  - If not linked, run: !{bash vercel link --yes}
  - Verify linkage: !{bash [ -f ".vercel/project.json" ] && cat .vercel/project.json | jq -r '.projectId' || echo "Failed to link"}

- For DigitalOcean projects:
  - Check for app-spec.yml: !{bash [ -f "app-spec.yml" ] || [ -f ".do/app.yaml" ] && echo "✅ App spec exists" || echo "⚠️ No app spec"}
  - If missing app-spec.yml, create from template using deployment-scripts skill
  - Validate spec: !{bash doctl apps spec validate app-spec.yml 2>&1 || echo "Create app manually: doctl apps create"}

- For Railway projects:
  - Check if linked: !{bash [ -f "railway.json" ] && echo "✅ Linked to Railway" || echo "⚠️ Not linked"}
  - If not linked, run: !{bash railway link}
  - Verify linkage: !{bash railway status 2>&1 | head -5}

- Report platform linkage status

Phase 3: Dependency Verification
Goal: Ensure all dependencies are installed

Actions:
- For Node.js projects (package.json):
  - !{bash [ -d "node_modules" ] && echo "✅ node_modules exists" || echo "❌ Run npm install"}
  - !{bash npm list --depth=0 2>&1 | head -20}
- For Python projects (requirements.txt/pyproject.toml):
  - !{bash python3 --version}
  - !{bash pip list | wc -l}
- For Go projects (go.mod):
  - !{bash go version}
  - !{bash go list -m all | head -10}
- Report missing dependencies

Phase 4: Build Tool Validation
Goal: Verify required build tools are available

Actions:
- Check platform-specific CLIs based on expected deployment:
  - FastMCP: !{bash which fastmcp || echo "❌ fastmcp CLI not found"}
  - DigitalOcean: !{bash which doctl || echo "❌ doctl not found"}
  - Vercel: !{bash which vercel || echo "❌ vercel CLI not found"}
  - Netlify: !{bash which netlify || echo "❌ netlify CLI not found"}
- Check build tools:
  - !{bash which npm node python3 go cargo 2>/dev/null}
- Report missing tools with installation instructions

Phase 5: Authentication Check
Goal: Verify deployment authentication is configured

Actions:
- Check environment variables for credentials:
  - !{bash [ -n "$DIGITALOCEAN_ACCESS_TOKEN" ] && echo "✅ DIGITALOCEAN_ACCESS_TOKEN set" || echo "⚠️  DIGITALOCEAN_ACCESS_TOKEN not set"}
  - !{bash [ -n "$VERCEL_TOKEN" ] && echo "✅ VERCEL_TOKEN set" || echo "⚠️  VERCEL_TOKEN not set"}
- Check CLI authentication status:
  - !{bash vercel whoami 2>/dev/null || echo "⚠️  Not logged into Vercel"}
  - !{bash netlify status 2>/dev/null || echo "⚠️  Not logged into Netlify"}
- Report authentication issues

Phase 6: Environment Variables
Goal: Verify required environment variables are documented and available

Actions:
- If .env.example exists:
  - @.env.example
  - List required variables from file
- Check if .env file exists:
  - !{bash [ -f ".env" ] && echo "✅ .env file exists" || echo "⚠️  .env file missing"}
- Warn about missing critical variables
- Remind to never commit .env to git

Phase 7: Git Status
Goal: Check git repository status

Actions:
- Verify git repository:
  - !{bash git rev-parse --is-inside-work-tree 2>/dev/null && echo "✅ Git repository" || echo "⚠️  Not a git repository"}
- Check for uncommitted changes:
  - !{bash git status --porcelain | wc -l}
- Check current branch:
  - !{bash git branch --show-current}
- Warn if working directory is dirty

Phase 8: CI/CD Setup Check
Goal: Check if automated deployments are configured

Actions:
- Check for GitHub Actions workflow:
  - !{bash [ -f ".github/workflows/deploy.yml" ] && echo "✅ CI/CD workflow exists" || echo "⚠️  No CI/CD workflow found"}
- If workflow exists:
  - Display workflow path
  - Confirm automated deployments enabled
- If no workflow:
  - Suggest setting up CI/CD: /deployment:setup-cicd
  - Explain benefits of automated deployments

Phase 9: Summary
Goal: Report readiness status

Actions:
- Display pre-flight check results:
  - **Project Type:** Detected language/framework
  - **Platform Linkage:** Vercel/DigitalOcean/Railway linked status
  - **Dependencies:** Installed status
  - **Build Tools:** Available tools
  - **Authentication:** Platform auth status
  - **Environment:** Required variables status
  - **Git Status:** Clean/dirty, current branch
  - **CI/CD Status:** Configured/Not configured
  - **Overall Status:** Ready/Not Ready for deployment
- If not ready:
  - List specific issues to fix
  - Provide commands to resolve each issue
- If ready but no CI/CD:
  - Recommend: /deployment:setup-cicd [platform]
  - Then: /deployment:deploy
- If fully ready:
  - Confirm deployment can proceed
  - Suggest running: /deployment:deploy
