---
description: Prepare project for deployment with pre-flight checks (dependencies, build tools, authentication, environment variables)
argument-hint: [project-path]
allowed-tools: Read(*), Bash(*), Glob(*), Grep(*)
---

**Arguments**: $ARGUMENTS

Goal: Run comprehensive pre-flight checks to ensure project is ready for deployment

Core Principles:
- Verify before deploy - catch issues early
- Check all prerequisites systematically
- Provide actionable feedback
- Support all project types

Phase 1: Discovery
Goal: Understand project structure

Actions:
- Parse $ARGUMENTS for project path (default to current directory)
- Detect project type by checking for indicator files:
  - !{bash ls -1 package.json requirements.txt pyproject.toml go.mod Cargo.toml .mcp.json 2>/dev/null}
- Load configuration files for context:
  - @package.json (if exists)
  - @requirements.txt (if exists)
  - @.env.example (if exists)
- Identify project language and framework

Phase 2: Dependency Verification
Goal: Ensure all dependencies are installed

Actions:
- For Node.js projects (package.json):
  - !{bash [ -d "node_modules" ] && echo "✅ node_modules exists" || echo "❌ Run npm install"}
  - !{bash npm list --depth=0 2>&1 | head -20}
- For Python projects (requirements.txt/pyproject.toml):
  - !{bash python3 --version}
  - !{bash pip list | wc -l}
- For Go projects (go.mod):
  - !{bash go version}
  - !{bash go list -m all | head -10}
- Report missing dependencies

Phase 3: Build Tool Validation
Goal: Verify required build tools are available

Actions:
- Check platform-specific CLIs based on expected deployment:
  - FastMCP: !{bash which fastmcp || echo "❌ fastmcp CLI not found"}
  - DigitalOcean: !{bash which doctl || echo "❌ doctl not found"}
  - Vercel: !{bash which vercel || echo "❌ vercel CLI not found"}
  - Netlify: !{bash which netlify || echo "❌ netlify CLI not found"}
- Check build tools:
  - !{bash which npm node python3 go cargo 2>/dev/null}
- Report missing tools with installation instructions

Phase 4: Authentication Check
Goal: Verify deployment authentication is configured

Actions:
- Check environment variables for credentials:
  - !{bash [ -n "$DIGITALOCEAN_ACCESS_TOKEN" ] && echo "✅ DIGITALOCEAN_ACCESS_TOKEN set" || echo "⚠️  DIGITALOCEAN_ACCESS_TOKEN not set"}
  - !{bash [ -n "$VERCEL_TOKEN" ] && echo "✅ VERCEL_TOKEN set" || echo "⚠️  VERCEL_TOKEN not set"}
- Check CLI authentication status:
  - !{bash vercel whoami 2>/dev/null || echo "⚠️  Not logged into Vercel"}
  - !{bash netlify status 2>/dev/null || echo "⚠️  Not logged into Netlify"}
- Report authentication issues

Phase 5: Environment Variables
Goal: Verify required environment variables are documented and available

Actions:
- If .env.example exists:
  - @.env.example
  - List required variables from file
- Check if .env file exists:
  - !{bash [ -f ".env" ] && echo "✅ .env file exists" || echo "⚠️  .env file missing"}
- Warn about missing critical variables
- Remind to never commit .env to git

Phase 6: Git Status
Goal: Check git repository status

Actions:
- Verify git repository:
  - !{bash git rev-parse --is-inside-work-tree 2>/dev/null && echo "✅ Git repository" || echo "⚠️  Not a git repository"}
- Check for uncommitted changes:
  - !{bash git status --porcelain | wc -l}
- Check current branch:
  - !{bash git branch --show-current}
- Warn if working directory is dirty

Phase 7: Summary
Goal: Report readiness status

Actions:
- Display pre-flight check results:
  - **Project Type:** Detected language/framework
  - **Dependencies:** Installed status
  - **Build Tools:** Available tools
  - **Authentication:** Platform auth status
  - **Environment:** Required variables status
  - **Git Status:** Clean/dirty, current branch
  - **Overall Status:** Ready/Not Ready for deployment
- If not ready:
  - List specific issues to fix
  - Provide commands to resolve each issue
- If ready:
  - Confirm deployment can proceed
  - Suggest running: /deployment:deploy
