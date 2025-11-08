---
description: Initialize feature flag infrastructure (LaunchDarkly/Flagsmith)
argument-hint: [launchdarkly|flagsmith|split]
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
Use the syntax: !{skill skill-name}

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

Goal: Set up feature flag infrastructure with provider integration and environment configuration

Core Principles:
- Detect project type and adapt integration patterns
- Use placeholders for all API keys and secrets
- Create environment examples without real credentials
- Provide clear documentation for setup

Phase 1: Discovery
Goal: Understand project structure and feature flag provider choice

Actions:
- Parse $ARGUMENTS for provider choice (launchdarkly, flagsmith, split)
- If no provider specified, use AskUserQuestion to gather:
  - Which feature flag provider? (LaunchDarkly, Flagsmith, Split.io)
  - Environment setup? (development, staging, production)
- Detect project type: !{bash ls -1 package.json requirements.txt pyproject.toml go.mod 2>/dev/null}
- Load relevant config: @package.json (if Node.js) or @requirements.txt (if Python)
- Determine frontend/backend architecture

Phase 2: Dependency Installation
Goal: Install feature flag SDK for detected project type

Actions:
- For Node.js/TypeScript projects:
  - LaunchDarkly: !{bash npm install launchdarkly-js-client-sdk @launchdarkly/node-server-sdk}
  - Flagsmith: !{bash npm install flagsmith flagsmith-nodejs}
  - Split: !{bash npm install @splitsoftware/splitio}
- For Python projects:
  - LaunchDarkly: !{bash pip install launchdarkly-server-sdk}
  - Flagsmith: !{bash pip install flagsmith}
  - Split: !{bash pip install splitio-client}
- Verify installation: !{bash npm list | grep -E "launchdarkly|flagsmith|split" || pip list | grep -E "launchdarkly|flagsmith|split"}

Phase 3: Environment Configuration
Goal: Create environment variable placeholders

Actions:
- Check if .env.example exists: !{bash [ -f ".env.example" ] && echo "exists" || echo "missing"}
- If missing, create new .env.example
- Add provider-specific environment variables with placeholders:
  - LaunchDarkly: LAUNCHDARKLY_SDK_KEY=your_launchdarkly_sdk_key_here
  - Flagsmith: FLAGSMITH_ENVIRONMENT_KEY=your_flagsmith_environment_key_here
  - Split: SPLIT_API_KEY=your_split_api_key_here
- Create .env file if missing (warn user to add real keys)
- Ensure .env is in .gitignore: !{bash grep -q "^\.env$" .gitignore || echo ".env" >> .gitignore}

Phase 4: Integration Code Generation
Goal: Create feature flag initialization and usage utilities

Actions:
- Detect framework for appropriate integration:
  - Next.js: Create lib/featureFlags.ts
  - React: Create src/utils/featureFlags.ts
  - Express/Node: Create src/services/featureFlags.ts
  - Python/FastAPI: Create app/services/feature_flags.py
- Generate initialization code with provider SDK
- Include example usage patterns:
  - Flag evaluation
  - User targeting
  - Error handling
  - Fallback values
- Use environment variable references (never hardcoded keys)

Phase 5: Documentation Creation
Goal: Document setup steps and usage

Actions:
- Create FEATURE_FLAGS.md with:
  - Provider selection rationale
  - API key acquisition instructions
  - Environment setup guide
  - Code usage examples
  - Testing and debugging tips
- Add inline code comments explaining integration
- Document flag naming conventions

Phase 6: Summary
Goal: Report setup completion and next steps

Actions:
- Display setup summary:
  - **Provider:** LaunchDarkly/Flagsmith/Split.io
  - **Project Type:** Detected framework
  - **Dependencies:** Installed packages
  - **Environment:** Variables configured
  - **Integration:** Files created
  - **Documentation:** FEATURE_FLAGS.md
- Show required actions:
  1. Obtain API key from provider dashboard
  2. Add real key to .env file
  3. Never commit .env to git
  4. Deploy with environment variables configured on platform
- Provide example flag usage code
- Suggest next steps:
  - Create first feature flag in provider dashboard
  - Test flag evaluation locally
  - Deploy with CI/CD environment variables configured
