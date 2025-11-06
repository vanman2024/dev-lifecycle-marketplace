---
description: Observability integration (Sentry, DataDog, alerts)
argument-hint: [monitoring-platform]
allowed-tools: Read, Write, Bash, Glob, AskUserQuestion
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

Phase 1: Discovery
Goal: Understand project structure and monitoring needs

Actions:
- Detect project type:
  - !{bash ls -1 package.json requirements.txt pyproject.toml go.mod 2>/dev/null}
- Check if monitoring is already configured:
  - !{bash grep -r "sentry\|datadog\|newrelic" . --include="*.json" --include="*.py" --include="*.js" --include="*.ts" 2>/dev/null | head -5}
- Load existing configuration files:
  - @package.json (if exists)
  - @requirements.txt (if exists)
- Determine project language and framework

Phase 2: Platform Selection
Goal: Choose appropriate monitoring platform

Actions:
- If $ARGUMENTS provided, use specified platform
- Otherwise, use AskUserQuestion to gather:
  - Which monitoring platform? (Sentry, DataDog, New Relic, Custom)
  - What to monitor? (Errors, Performance, Logs, All)
  - Environment to monitor? (Production, Staging, All)
- Verify platform CLI is available:
  - !{bash which sentry-cli datadog-ci 2>/dev/null}

Phase 3: Install Dependencies
Goal: Add monitoring SDK to project

Actions:
- Install based on platform and language:
  - Sentry + Node.js: !{bash npm install --save @sentry/node @sentry/profiling-node}
  - Sentry + Python: !{bash pip install sentry-sdk}
  - DataDog + Node.js: !{bash npm install --save dd-trace}
  - DataDog + Python: !{bash pip install ddtrace}
- Report installation status

Phase 4: Configuration
Goal: Create monitoring configuration files

Actions:
- Create .env.example with placeholders (SENTRY_DSN, DD_API_KEY, MONITORING_ENVIRONMENT)
- Ensure .env in .gitignore: !{bash grep -q "^.env$" .gitignore || echo ".env" >> .gitignore}
- Create platform-specific config files with placeholders only
- Add initialization code to application entry point
- Document required environment variables in README

Phase 5: Integration
Goal: Integrate monitoring into application code

Actions:
- Detect entry point: !{bash ls -1 index.js server.js app.js main.py app.py 2>/dev/null | head -1}
- Add monitoring initialization at application startup
- Configure error handlers and performance tracking
- Set up release tracking if CI/CD configured
- Add source map upload for Node.js projects

Phase 6: Sentry CLI Setup (Sentry Only)
Goal: Install and configure Sentry CLI for release tracking

Actions:
- If platform is Sentry:
  - Check if sentry-cli installed: !{bash which sentry-cli || echo "not-installed"}
  - If not installed, provide installation:
    - npm: !{bash npm install -g @sentry/cli}
    - Or curl: curl -sL https://sentry.io/get-cli/ | bash
  - Verify installation: !{bash sentry-cli --version}
  - Create .sentryclirc with auth token reference:
    ```
    [auth]
    token=${SENTRY_AUTH_TOKEN}

    [defaults]
    org=${SENTRY_ORG_SLUG}
    project=${SENTRY_PROJECT_SLUG}
    ```
  - Add .sentryclirc to .gitignore
  - Document Doppler variables: SENTRY_AUTH_TOKEN, SENTRY_ORG_SLUG, SENTRY_PROJECT_SLUG
- Display: "✓ Sentry CLI configured for release tracking"

Phase 7: Alert Configuration
Goal: Set up basic alerting rules

Actions:
- Create monitoring-alerts.yml with basic alert rules
- Define thresholds: error rate, response time, availability, resource usage
- Document alert configuration in platform dashboard
- Provide webhook setup guide for Slack/Discord/PagerDuty

Phase 8: Deployment Integration
Goal: Configure monitoring for CI/CD

Actions:
- Check for workflows: !{bash ls -1 .github/workflows/*.yml 2>/dev/null}
- Add monitoring steps: release creation, source maps upload, deployment markers
- For Sentry: Add sentry-cli release commands to CI/CD:
  ```yaml
  - name: Create Sentry Release
    run: |
      sentry-cli releases new $VERSION
      sentry-cli releases set-commits $VERSION --auto
      sentry-cli releases files $VERSION upload-sourcemaps ./dist
      sentry-cli releases finalize $VERSION
      sentry-cli releases deploys $VERSION new -e production
  ```
- Document required CI/CD secrets: monitoring API keys, DSN values, Sentry auth token
- Add post-deploy health check step

Phase 9: Summary
Goal: Report setup status and next steps

Actions:
- Display monitoring setup summary:
  ```
  ✅ Monitoring Setup Complete

  Platform: [Sentry|DataDog|etc]
  Dependencies: [Installed SDK packages]
  Configuration: [Config files created]
  Integration: [Modified entry points]
  Alerts: [Alert rules configured]

  Sentry CLI (if Sentry):
  - ✓ sentry-cli installed
  - ✓ .sentryclirc configured
  - ✓ Release tracking ready
  - ✓ CI/CD integration added

  CI/CD: [Deployment tracking setup]
  ```

- List required environment variables:
  - For Sentry: SENTRY_DSN, SENTRY_AUTH_TOKEN, SENTRY_ORG_SLUG, SENTRY_PROJECT_SLUG
  - For DataDog: DD_API_KEY, DD_APP_KEY, DD_SITE
  - All: MONITORING_ENVIRONMENT (production/staging)

- Provide next steps:
  1. Add secrets to Doppler:
     ```bash
     doppler secrets set SENTRY_DSN="your-sentry-dsn" --config production
     doppler secrets set SENTRY_AUTH_TOKEN="your-token" --config production
     doppler secrets set SENTRY_ORG_SLUG="your-org" --config production
     doppler secrets set SENTRY_PROJECT_SLUG="your-project" --config production
     ```
  2. Test locally with Doppler: `doppler run -- npm run dev`
  3. Deploy application to trigger monitoring
  4. Verify Sentry MCP: "Show me the latest errors"
  5. Test Sentry CLI: `sentry-cli releases list`
  6. Review monitoring dashboard for data

- Display integration summary:
  - **MCP Server**: Query issues, create alerts (via .mcp.json)
  - **Sentry CLI**: Create releases, upload source maps, track deploys
  - **SDK**: Capture errors and performance in application code
  - All three use same Doppler-managed credentials ✓
