---
description: Setup automated rollback triggers on error thresholds
argument-hint: $ARGUMENTS
---

**Arguments**: $ARGUMENTS

Goal: Configure automated rollback triggers that monitor deployment health and rollback on error thresholds

Core Principles:
- Proactive monitoring - detect issues before users report them
- Automatic recovery - rollback without manual intervention
- Configurable thresholds - adapt to different application needs
- Platform-aware - use native monitoring where available

Phase 1: Discovery
Goal: Identify deployment platform and monitoring requirements

Actions:
- Parse $ARGUMENTS for thresholds (error rate, response time, consecutive failures)
- Detect platform: !{bash ls -1 .vercel/project.json .do/app.yaml railway.json 2>/dev/null | head -1}
- Check existing monitoring: !{bash ls -la .github/workflows/*monitor*.yml 2>/dev/null || echo "None"}
- If $ARGUMENTS not provided, use AskUserQuestion for:
  - Error rate threshold (default: 5%)
  - Response time threshold (default: 5000ms)
  - Consecutive failures before rollback (default: 3)

Phase 2: Configure Monitoring
Goal: Create health check configuration and scripts

Actions:
- Create directory: !{bash mkdir -p .deployment-monitoring}
- Write .deployment-monitoring/config.json with thresholds from Phase 1
- Write .deployment-monitoring/health-check.sh that monitors HTTP status, response times, error rates
- Write .deployment-monitoring/auto-rollback.sh that calls platform-specific rollback
- Make executable: !{bash chmod +x .deployment-monitoring/*.sh}

Phase 3: Configure Platform Triggers
Goal: Setup automated rollback for detected platform

Actions:
- Create workflow directory: !{bash mkdir -p .github/workflows}
- Write .github/workflows/deployment-monitor.yml with:
  - Trigger: After deployment success OR on schedule (every 5 min)
  - Job: Run health-check.sh, if thresholds exceeded run auto-rollback.sh
- For platforms with native monitoring, update configs:
  - Vercel: Add monitoring to vercel.json
  - DigitalOcean: Update app spec with alerts
  - Railway: Configure webhook notifications
- Commit configuration: !{bash git add .deployment-monitoring/ .github/workflows/}

Phase 4: Test and Enable
Goal: Verify configuration and enable monitoring

Actions:
- Test health check locally: !{bash bash .deployment-monitoring/health-check.sh}
- Verify workflow syntax: !{bash cat .github/workflows/deployment-monitor.yml | grep -E "on:|jobs:|steps:"}
- Commit: !{bash git commit -m "feat: Add automated rollback monitoring"}
- Push to enable: !{bash git push origin $(git branch --show-current)}
- Explain test procedure: Deploy broken version to trigger automatic rollback, monitor via GitHub Actions

Phase 5: Summary
Goal: Report configuration and usage

Actions:
- Display summary:
  - **Platform:** Detected platform
  - **Monitoring:** Enabled via GitHub Actions
  - **Thresholds:** Error rate, response time, consecutive failures
  - **Check Interval:** 5 minutes
  - **Files Created:**
    - .deployment-monitoring/config.json
    - .deployment-monitoring/health-check.sh
    - .deployment-monitoring/auto-rollback.sh
    - .github/workflows/deployment-monitor.yml
- How it works:
  - Post-deployment health checks run automatically
  - Continuous monitoring every 5 minutes
  - Automatic rollback when thresholds exceeded
  - GitHub Actions logs track all activity
- Next steps:
  - Test with intentional failure
  - Monitor: gh run list --workflow=deployment-monitor.yml
  - Adjust thresholds in config.json as needed
  - View dashboards: GitHub Actions, Vercel/DigitalOcean/Railway platform
