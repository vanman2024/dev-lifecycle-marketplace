---
description: Rollback to previous deployment version with platform-specific rollback procedures
argument-hint: [deployment-id-or-version]
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
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Safely rollback to a previous deployment version using platform-specific rollback mechanisms

Core Principles:
- Safety first - verify rollback target before executing
- Platform-aware - use correct rollback method for each platform
- Validate after rollback - ensure rolled-back version works
- Preserve deployment history

Phase 1: Discovery
Goal: Identify deployment to rollback and current state

Actions:
- Parse $ARGUMENTS for deployment ID or version to rollback to
- If not provided, use AskUserQuestion to gather:
  - Which deployment/version to rollback to?
  - Which platform? (FastMCP Cloud, DigitalOcean, Vercel, etc.)
- Check deployment history:
  - !{bash ls -la .deployment-history 2>/dev/null || echo "No deployment history found"}
- If history file exists:
  - @.deployment-history/latest.json
- Identify current deployment version and platform

Phase 2: Rollback Planning
Goal: Determine rollback strategy

Actions:
- Verify rollback target exists and is valid
- Check platform-specific requirements:
  - FastMCP Cloud: Previous deployment must exist
  - DigitalOcean: Previous droplet snapshot or code version
  - Vercel: Previous deployment ID from vercel deployments
  - Netlify: Previous deploy ID from netlify api
- Confirm rollback with user if not explicitly specified
- Use AskUserQuestion if confirmation needed:
  - Rollback from [current] to [target]?
  - This will replace the current live deployment

Phase 3: Execute Rollback
Goal: Perform platform-specific rollback

Actions:

Launch the deployment-deployer agent to execute the rollback.

Provide the agent with:
- Context: Current deployment state, target version/ID
- Target: $ARGUMENTS (version to rollback to)
- Platform: Detected from deployment history
- Requirements:
  - Use platform-specific rollback command
  - For FastMCP Cloud: fastmcp rollback --version $ARGUMENTS
  - For DigitalOcean: Redeploy previous code version or restore snapshot
  - For Vercel: vercel rollback $ARGUMENTS
  - For Netlify: netlify api restoreSiteDeploy --deploy-id $ARGUMENTS
  - Monitor rollback progress
  - Capture rollback status
- Expected output: Rollback confirmation and new deployment URL

Phase 4: Post-Rollback Validation
Goal: Verify rolled-back deployment works

Actions:
- After rollback completes, validate deployment health
- Use bash to check deployment URL:
  - !{bash curl -s -o /dev/null -w "%{http_code}" "$DEPLOYMENT_URL"}
- If validation fails:
  - Report failure to user
  - Suggest investigating logs
  - Consider rolling forward instead
- If validation succeeds:
  - Update deployment history
  - Confirm rollback successful

Phase 5: Summary
Goal: Report rollback results

Actions:
- Display rollback summary:
  - **Previous Version:** What was running before
  - **Rolled Back To:** Target version/deployment ID
  - **Platform:** Where rollback occurred
  - **Status:** Success or failure
  - **Deployment URL:** Rolled-back endpoint
  - **Validation:** Pass/fail status
- Provide next steps:
  - Monitor application for issues
  - Consider fixing root cause in code
  - Document why rollback was needed
