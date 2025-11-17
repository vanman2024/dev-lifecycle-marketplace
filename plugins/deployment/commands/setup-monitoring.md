---
description: Observability integration (Sentry, DataDog, alerts)
argument-hint: [monitoring-platform]
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

CRITICAL: All generated files must follow docs/security/SECURITY-RULES.md
Never hardcode API keys. Use placeholders: your_service_key_here

**Arguments**: $ARGUMENTS

Goal: Set up production monitoring and observability for deployed applications

Core Principles:
- Capture errors and exceptions automatically
- Monitor performance and availability
- Set up alerts for critical issues
- Support multiple monitoring platforms

## Phase 1: Discovery

Goal: Understand project structure and detect framework

Actions:
- Get project name from directory or package.json:
  - !{bash basename $(pwd)}
  - @package.json (extract name field if exists)
- Detect project type and framework:
  - !{bash ls -1 package.json requirements.txt pyproject.toml go.mod 2>/dev/null}
  - Check for Next.js: !{bash grep -q "next" package.json 2>/dev/null && echo "nextjs" || echo ""}
  - Check for React: !{bash grep -q "react" package.json 2>/dev/null && echo "react" || echo ""}
  - Check for Python: !{bash test -f requirements.txt && echo "python" || echo ""}
  - Check for FastAPI: !{bash grep -q "fastapi" requirements.txt 2>/dev/null && echo "fastapi" || echo ""}
  - Check for Django: !{bash grep -q "django" requirements.txt 2>/dev/null && echo "django" || echo ""}
- Store detected platform for later use
- Display: "Detected platform: [Next.js|React|Python|etc]"

## Phase 2: Platform Selection

Goal: Choose monitoring platform and verify setup

Actions:
- If $ARGUMENTS is "sentry", proceed with Sentry setup
- If $ARGUMENTS is "datadog", proceed with DataDog setup
- Otherwise, use AskUserQuestion:
  - Which platform? (Sentry recommended, DataDog, New Relic)
  - Note: Sentry has MCP integration for automatic setup

## Phase 3: Sentry Project Setup via MCP (Sentry Only)

Goal: Use Sentry MCP to find or create project

Actions:
**CRITICAL: Use MCP tools to automate Sentry setup**

1. List Sentry organizations via MCP:
   - Use mcp__plugin_deployment_sentry__find_organizations
   - If multiple orgs, ask user to select one
   - If only one org, use it automatically

2. Check if project already exists via MCP:
   - Use mcp__plugin_deployment_sentry__find_projects with org slug
   - Search for project matching current project name
   - If found: Display "✓ Project exists: [project-name]"
   - If not found: Proceed to create project

3. Map detected framework to Sentry platform:
   - Next.js → "javascript-nextjs"
   - React → "javascript-react"
   - Python + FastAPI → "python-fastapi"
   - Python + Django → "python-django"
   - Python (generic) → "python"
   - Node.js → "node"
   - Go → "go"
   - Default → Ask user for platform

4. Create Sentry project via MCP (if doesn't exist):
   - Use mcp__plugin_deployment_sentry__create_project
   - Parameters: organizationSlug, name, platform
   - Display: "✓ Sentry project created: [project-name]"

5. Get project DSN via MCP:
   - Use mcp__plugin_deployment_sentry__find_dsns
   - Parameters: organizationSlug, projectSlug
   - Store DSN for Phase 4
   - Display: "✓ DSN retrieved"

## Phase 4: Execute Monitoring Setup via Agent

Goal: Install dependencies, configure Doppler, integrate code, setup Sentry CLI

Actions:
- Invoke monitoring-setup-executor agent with parameters:
  - project_name: from Phase 1
  - project_platform: from Phase 1
  - monitoring_platform: from Phase 2
  - sentry_org_slug: from Phase 3 (if Sentry)
  - sentry_project_slug: from Phase 3 (if Sentry)
  - sentry_dsn: from Phase 3 (if Sentry)
- Agent will:
  - Install monitoring SDK dependencies
  - Configure Doppler storage for secrets
  - Create .env.example with placeholders
  - Integrate monitoring into application code
  - Install and configure Sentry CLI
  - Create alert configuration
  - Add CI/CD integration steps

Use Task() to invoke agent:
```
Task(agent="monitoring-setup-executor", parameters={
  "project_name": "<project_name>", "project_platform": "<platform>", "monitoring_platform": "<sentry|datadog>", "sentry_org_slug": "<org_slug>", "sentry_project_slug": "<project_slug>", "sentry_dsn": "<dsn>"
})
```

## Phase 5: Summary

Goal: Report setup status and next steps

Actions:
- Parse agent response JSON
- Display monitoring setup summary:
  ```
  ✅ Monitoring Setup Complete

  Platform: <Sentry|DataDog|etc>
  Dependencies: <Installed SDK packages>
  Doppler Secrets: <List of secrets configured>
  Integration: <Modified entry points>
  Sentry CLI: <Installed|Not applicable>
  CI/CD: <Integration added|Not configured>
  ```

- List required environment variables:
  - For Sentry: SENTRY_DSN, SENTRY_AUTH_TOKEN, SENTRY_ORG_SLUG, SENTRY_PROJECT_SLUG
  - For DataDog: DD_API_KEY, DD_APP_KEY, DD_SITE
  - All: MONITORING_ENVIRONMENT (production/staging)

- Provide next steps:
  1. Generate auth token (if Sentry):
     - Visit: https://sentry.io/settings/account/api/auth-tokens/
     - Create token with: project:releases, project:write

  2. Add secrets to Doppler:
     ```bash
     doppler secrets set SENTRY_AUTH_TOKEN="<your-token>" --config production
     doppler secrets set SENTRY_DSN="<dsn>" --config production
     doppler secrets set SENTRY_ORG_SLUG="<org>" --config production
     doppler secrets set SENTRY_PROJECT_SLUG="<project>" --config production
     ```

  3. Test locally with Doppler: `doppler run -- npm run dev`

  4. Deploy application to trigger monitoring

  5. Verify Sentry MCP: "Show me the latest errors"

  6. Test Sentry CLI: `sentry-cli releases list`

- Display integration summary:
  - **MCP Server**: Query issues, create alerts (via .mcp.json)
  - **Sentry CLI**: Create releases, upload source maps, track deploys
  - **SDK**: Capture errors and performance in application code
  - All three use same Doppler-managed credentials ✓

- If agent returned errors:
  - Display error details
  - Provide troubleshooting steps
  - Suggest manual setup if automation failed
