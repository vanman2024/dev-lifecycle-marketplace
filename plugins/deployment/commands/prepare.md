---
description: Prepare project for deployment with pre-flight checks (dependencies, build tools, authentication, environment variables)
argument-hint: [project-path]
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

## Phase 1: Parse Arguments

Parse project path:

Actions:
- Extract project path from $ARGUMENTS (default to current directory)
- Verify path exists: !{bash test -d "<path>" && echo "exists" || echo "missing"}
- Change to project directory if needed

## Phase 2: Execute Pre-Flight Checks via Agent

Goal: Run comprehensive deployment readiness checks

Actions:
- Invoke deployment-preparer agent with parameters:
  - project_path: from Phase 1
- Agent will check:
  - Project type detection (Node.js, Python, Go, Rust, MCP)
  - Platform linkage (Vercel, DigitalOcean, Railway, Netlify, FastMCP Cloud)
  - Dependency installation status
  - Build tool availability (CLIs, compilers)
  - Authentication status (platform CLIs, environment variables)
  - Environment variable configuration
  - Git repository status
  - CI/CD workflow presence

Use Task() to invoke agent:
```
Task(agent="deployment-preparer", parameters={
  "project_path": "<project_path>"
})
```

## Phase 3: Display Results and Recommendations

Show readiness status and next steps:

Actions:
- Parse agent response JSON
- Display pre-flight check results:
  ```
  📋 Pre-Flight Check Results

  **Project Type:** <detected language/framework>
  **Platform:** <detected deployment platform>

  ✅ Dependencies: Installed
  ✅ Build Tools: Available
  ✅ Authentication: Configured
  ✅ Environment: .env exists
  ✅ Git: Clean working tree on <branch>
  ⚠️  CI/CD: Not configured

  **Overall Status:** Ready for deployment
  ```

- If issues found, list with severity and resolution commands
- If fully ready: Suggest /deployment:deploy
- If ready but no CI/CD: Recommend /deployment:setup-cicd first
- If not ready: List specific fixes needed
- Display required environment variables from .env.example
- Summarize overall readiness with issue counts
