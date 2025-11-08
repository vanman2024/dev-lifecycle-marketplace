---
description: Capture performance baselines (Lighthouse, API latency) for deployment monitoring
argument-hint: <deployment-url>
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

Skills provide pre-built resources including templates, scripts, examples, and best practices to accelerate your work.

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

Goal: Capture performance baselines for deployed applications to monitor regression and track improvements

Core Principles:
- Establish quantitative performance metrics
- Measure both frontend (Lighthouse) and backend (API latency) performance
- Create reusable baseline reports for comparison
- Enable automated performance monitoring

Phase 1: Discovery
Goal: Gather deployment information and determine baseline type

Actions:
- Parse $ARGUMENTS for deployment URL
- If URL not provided, use AskUserQuestion to gather:
  - What's the deployment URL to baseline?
  - What type of deployment? (Frontend/API/Full-stack)
  - Which metrics to capture? (Lighthouse only, API only, or both)
  - Should results be saved? (Yes/No and location)
- Detect deployment type from URL structure:
  - !{bash curl -I -s "$ARGUMENTS" 2>/dev/null | head -n 1}
- Check if Lighthouse CLI is available:
  - !{bash which lighthouse 2>/dev/null || echo "Not installed"}
- Identify project root for saving baseline data:
  - !{bash pwd}
  - @.claude/project.json (if exists for project context)

Phase 2: Baseline Planning
Goal: Determine what metrics to capture based on deployment type

Actions:
- Based on deployment type, plan metrics collection:
  - **Frontend/Full-stack**:
    - Lighthouse performance score
    - First Contentful Paint (FCP)
    - Largest Contentful Paint (LCP)
    - Time to Interactive (TTI)
    - Total Blocking Time (TBT)
    - Cumulative Layout Shift (CLS)
  - **API/Backend**:
    - Endpoint response times (p50, p95, p99)
    - Time to First Byte (TTFB)
    - Request throughput
    - Error rates
  - **All types**:
    - SSL/TLS handshake time
    - DNS resolution time
    - Connection establishment time
- Determine baseline storage location:
  - Default: `.claude/baselines/baseline-YYYY-MM-DD-HHMMSS.json`
  - User-specified location from Phase 1

Phase 3: Execute Baseline Capture
Goal: Run performance measurements and collect metrics

Actions:

Launch the deployment-validator agent to capture performance baselines.

Provide the agent with:
- Context: Deployment URL and type from Phase 1
- Target: $ARGUMENTS (deployment URL)
- Requirements:
  - Run Lighthouse audit if frontend/full-stack (capture all metrics)
  - Run API latency tests if API/backend (multiple requests for statistical accuracy)
  - Measure connection and SSL metrics for all types
  - Capture timestamp and deployment environment details
  - Format results as structured JSON
  - Save baseline report to specified location
- Expected output: Comprehensive baseline report with all captured metrics

Phase 4: Summary
Goal: Report baseline capture results and provide monitoring guidance

Actions:
- Display baseline summary:
  - **Deployment URL:** From $ARGUMENTS
  - **Baseline Date:** Timestamp of capture
  - **Deployment Type:** Frontend/API/Full-stack
  - **Performance Scores:** (if Lighthouse ran)
    - Overall performance score (0-100)
    - Key metrics: LCP, FCP, TTI, TBT, CLS
  - **API Latency:** (if API tests ran)
    - p50, p95, p99 response times
    - Average throughput
  - **Connection Metrics:**
    - DNS resolution time
    - SSL handshake time
    - Time to First Byte
  - **Baseline File:** Path to saved baseline report
- Provide monitoring recommendations:
  - Run baseline captures before/after major deployments
  - Compare new baselines against this one to detect regressions
  - Set up automated baseline captures in CI/CD
  - Monitor trends over time for gradual degradation
- Suggest next steps:
  - Integrate baseline checks into deployment pipeline
  - Set performance budgets based on baseline
  - Configure alerts for significant deviations
