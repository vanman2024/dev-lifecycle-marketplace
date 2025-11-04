---
description: Validate deployment health with comprehensive checks (URL accessibility, health endpoints, environment variables)
argument-hint: <deployment-url>
allowed-tools: Task, Read, Bash, AskUserQuestion
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

Goal: Validate that a deployed application is running correctly with health checks and endpoint testing

Core Principles:
- Verify deployment is accessible and functional
- Test key endpoints and responses
- Validate environment configuration
- Provide actionable feedback on issues

Phase 1: Discovery
Goal: Gather deployment information

Actions:
- Parse $ARGUMENTS for deployment URL
- If URL not provided, use AskUserQuestion to gather:
  - What's the deployment URL to validate?
  - What type of deployment? (MCP server, API, Frontend, Static)
  - Any specific endpoints to test?
- Attempt to detect deployment type from URL structure:
  - !{bash curl -s -o /dev/null -w "%{http_code}" "$ARGUMENTS" 2>/dev/null}

Phase 2: Validation Planning
Goal: Determine validation strategy

Actions:
- Based on deployment type, identify checks needed:
  - All: HTTP accessibility (200 OK response)
  - APIs: Health check endpoint, key routes
  - MCP servers: MCP protocol response
  - Frontends: Assets loaded, no console errors
  - Static sites: All pages accessible

Phase 3: Execute Validation
Goal: Run comprehensive health checks

Actions:

Launch the deployment-validator agent to perform thorough validation.

Provide the agent with:
- Context: Deployment URL and type from Phase 1
- Target: $ARGUMENTS (deployment URL)
- Requirements:
  - Test URL accessibility and response codes
  - Verify health check endpoints if applicable
  - For APIs: Test critical endpoints with sample requests
  - For MCP servers: Validate MCP protocol responses
  - For frontends: Check asset loading and render
  - Check SSL certificate validity
  - Test response times and performance
  - Validate CORS and security headers
- Expected output: Comprehensive validation report with pass/fail status

Phase 4: Summary
Goal: Report validation results

Actions:
- Display validation summary:
  - **Deployment URL:** From $ARGUMENTS
  - **Status:** Overall pass/fail
  - **Accessibility:** URL response code and time
  - **Health Checks:** Pass/fail with details
  - **Performance:** Response times
  - **Issues Found:** List of any problems
  - **Recommendations:** Suggested fixes
- If validation failed:
  - Highlight critical issues
  - Provide troubleshooting steps
  - Suggest rollback if deployment is broken
- If validation passed:
  - Confirm deployment is healthy
  - Show monitoring recommendations
