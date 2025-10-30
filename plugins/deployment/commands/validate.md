---
description: Validate deployment health with comprehensive checks (URL accessibility, health endpoints, environment variables)
argument-hint: <deployment-url>
allowed-tools: Task(*), Read(*), Bash(*), AskUserQuestion(*)
---

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
