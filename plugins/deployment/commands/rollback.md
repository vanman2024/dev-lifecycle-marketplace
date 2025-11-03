---
description: Rollback to previous deployment version with platform-specific rollback procedures
argument-hint: [deployment-id-or-version]
allowed-tools: Task, Read, Bash, AskUserQuestion
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
