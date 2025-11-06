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

Phase 6: Alert Configuration
Goal: Set up basic alerting rules

Actions:
- Create monitoring-alerts.yml with basic alert rules
- Define thresholds: error rate, response time, availability, resource usage
- Document alert configuration in platform dashboard
- Provide webhook setup guide for Slack/Discord/PagerDuty

Phase 7: Deployment Integration
Goal: Configure monitoring for CI/CD

Actions:
- Check for workflows: !{bash ls -1 .github/workflows/*.yml 2>/dev/null}
- Add monitoring steps: release creation, source maps upload, deployment markers
- Document required CI/CD secrets: monitoring API keys, DSN values
- Add post-deploy health check step

Phase 8: Summary
Goal: Report setup status and next steps

Actions:
- Display monitoring setup summary:
  - Platform: Selected monitoring platform
  - Dependencies: Installed packages
  - Configuration: Created config files
  - Integration: Modified application files
  - Alerts: Configured alert rules
  - CI/CD: Deployment tracking setup
- List required environment variables (DSN, API keys, environment identifiers)
- Provide next steps:
  - Set environment variables in deployment platform
  - Create monitoring platform account and project
  - Configure alert notification channels
  - Deploy and test monitoring integration
  - Review dashboard for errors and performance data
