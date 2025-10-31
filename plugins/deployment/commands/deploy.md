---
description: Deploy application to detected platform with automated routing (FastMCP Cloud, DigitalOcean, Vercel, Hostinger)
argument-hint: [project-path]
allowed-tools: Task, Read, Write, Bash, Glob, Grep, AskUserQuestion, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Automatically detect project type and deploy to the appropriate platform with full CI/CD automation

Core Principles:
- Detect don't assume - analyze project structure to determine type
- Platform-agnostic - work with any project (MCP, API, frontend, static)
- Validate before deploy - ensure build succeeds and prerequisites met
- Track progress - use TodoWrite for visibility

Phase 1: Discovery
Goal: Understand project structure and requirements

Actions:
- Create todo list with all deployment phases using TodoWrite
- Parse $ARGUMENTS for project path (default to current directory if empty)
- Detect project files to understand type:
  - !{bash ls -la | grep -E "\.mcp\.json|package\.json|requirements\.txt|pyproject\.toml|go\.mod|Cargo\.toml|astro\.config|next\.config|vercel\.json"}
- Load key configuration files for context:
  - @package.json (if exists)
  - @requirements.txt (if exists)
  - @.mcp.json (if exists)
- If project type is ambiguous, use AskUserQuestion to clarify:
  - What type of project is this?
  - Which platform should it deploy to?
  - Any specific deployment requirements?
- Update todos

Phase 2: Project Detection
Goal: Determine project type and target platform

Actions:

Launch the deployment-detector agent to analyze project and determine deployment platform.

Provide the agent with:
- Context: Project files and structure from Phase 1
- Target: $ARGUMENTS (project path)
- Requirements:
  - Classify as: MCP server | API/Backend | Frontend | Static website
  - Determine framework/language
  - Recommend platform: FastMCP Cloud | DigitalOcean | Vercel | Hostinger/Netlify/Cloudflare
  - Identify build command and output directory
  - List required environment variables
  - Provide confidence level and reasoning
- Expected output: JSON detection report with project classification and deployment config

Wait for detection to complete.
Update todos to mark detection phase complete.

Phase 3: Pre-Deployment Validation
Goal: Verify prerequisites and authentication

Actions:
- Review detection report from Phase 2
- Check authentication for target platform:
  - FastMCP Cloud: Verify fastmcp CLI installed and authenticated
  - DigitalOcean: Check DIGITALOCEAN_ACCESS_TOKEN environment variable
  - Vercel: Check vercel CLI installed and logged in
  - Netlify/Cloudflare: Check respective authentication
- If authentication missing, prompt user to authenticate first
- Verify build tools available (npm, python, go, etc.)
- Confirm deployment approach with user if confidence is not high
- Update todos

Phase 4: Build Execution
Goal: Build project for production

Actions:
- Execute build command from detection report
- Example: !{bash npm run build} or !{bash python -m build}
- Monitor build output for errors
- If build fails:
  - Capture error logs
  - Display to user with suggestions
  - Abort deployment
  - Mark todo as failed
- If build succeeds:
  - Verify output directory exists
  - Verify build artifacts generated
  - Update todos to mark build complete

Phase 5: Deployment
Goal: Deploy to target platform

Actions:

Launch the deployment-deployer agent to execute platform-specific deployment.

Provide the agent with:
- Context: Detection report, build status, authentication status
- Target: $ARGUMENTS (project path)
- Platform: From detection report
- Requirements:
  - Configure environment variables
  - Execute deployment command
  - Monitor deployment progress
  - Capture deployment URL/ID
  - Handle deployment errors
- Expected output: Deployment status, URL, and platform-specific metadata

Wait for deployment to complete.
Update todos to mark deployment phase complete.

Phase 6: Post-Deployment Validation
Goal: Verify deployment succeeded

Actions:

Launch the deployment-validator agent to verify deployment health.

Provide the agent with:
- Context: Deployment URL and metadata from Phase 5
- Target: Deployed application endpoint
- Requirements:
  - Check URL accessibility (HTTP 200 OK)
  - Test health check endpoint if applicable
  - Verify environment variables set correctly
  - For MCP servers: Test MCP protocol responses
  - For APIs: Test key endpoints
  - For frontends: Verify assets loaded
  - Provide validation report
- Expected output: Validation status with any issues found

Wait for validation to complete.
Update todos to mark validation complete.

Phase 7: Summary
Goal: Report deployment results

Actions:
- Mark all todos complete
- Display comprehensive deployment summary:
  - **Project Type:** From detection report
  - **Platform:** Deployment target
  - **Deployment URL:** Application endpoint
  - **Status:** Success or failure
  - **Build Time:** Duration
  - **Deploy Time:** Duration
  - **Validation:** Pass/fail with details
- If successful:
  - Show next steps (testing, monitoring, rollback if needed)
  - Provide rollback command: /deployment:rollback
- If failed:
  - Show detailed error logs
  - Suggest troubleshooting steps
  - Provide support resources
