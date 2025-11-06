# Deployment Plugin

Automated deployment orchestration for AI applications with intelligent platform routing and comprehensive validation.

## Overview

The Deployment plugin provides automated deployment workflows that detect your project type and route to the appropriate hosting platform. It handles authentication, builds, deployment, and post-deployment validation for multiple platforms.

## Features

### Intelligent Platform Detection
- **Auto-detects project types**: MCP servers, APIs/backends, frontends, static websites
- **Framework recognition**: FastMCP, Next.js, React, Astro, FastAPI, Flask, Django, Express, and more
- **Smart platform routing**:
  - MCP servers → FastMCP Cloud
  - APIs/Callbacks → DigitalOcean droplets
  - Frontends → Vercel
  - Static sites → Hostinger, Netlify, Cloudflare Pages

### Supported Platforms
- **FastMCP Cloud** - Native MCP server hosting
- **DigitalOcean** - VPS and App Platform for APIs
- **Vercel** - Frontend and full-stack deployments
- **Netlify** - Static sites and Jamstack apps
- **Cloudflare Pages** - Edge-deployed static sites
- **Hostinger** - Traditional web hosting

### Multi-Language Support
- **TypeScript/JavaScript** - Node.js projects (npm, pnpm, yarn)
- **Python** - Python projects (pip, poetry, pipenv)
- **Go** - Go applications (go build)
- **Language-agnostic** - Detects and adapts to any project structure

## Commands

### `/deployment:deploy [project-path]`
Main deployment command with full automation.

**Features:**
- Automatic project type detection
- Platform selection and routing
- Build execution with validation
- Environment variable configuration
- Deployment with progress monitoring
- Post-deployment health checks
- Rollback information preservation

**Usage:**
```bash
# Deploy current directory
/deployment:deploy

# Deploy specific project
/deployment:deploy /path/to/project
```

**Workflow:**
1. **Detection** - Analyzes project structure and determines type
2. **Validation** - Checks prerequisites and authentication
3. **Build** - Executes production build
4. **Deploy** - Deploys to recommended platform
5. **Verify** - Validates deployment health
6. **Summary** - Reports results and provides next steps

### `/deployment:validate <deployment-url>`
Validate deployment health with comprehensive checks.

**Features:**
- HTTP accessibility testing
- Health endpoint verification
- SSL certificate validation
- Performance testing
- CORS and security header checks
- Platform-specific validation

**Usage:**
```bash
# Validate deployed application
/deployment:validate https://myapp.vercel.app

# Validate with specific endpoint
/deployment:validate https://api.example.com/health
```

### `/deployment:rollback [deployment-id-or-version]`
Rollback to previous deployment version.

**Features:**
- Platform-specific rollback mechanisms
- Deployment history tracking
- Post-rollback validation
- Safety confirmations

**Usage:**
```bash
# Interactive rollback (prompts for version)
/deployment:rollback

# Rollback to specific version
/deployment:rollback v1.2.3

# Rollback to deployment ID
/deployment:rollback dep_abc123
```

### `/deployment:prepare [project-path]`
Pre-flight checks before deployment.

**Features:**
- Dependency verification
- Build tool validation
- Authentication status
- Environment variable checks
- Git repository status
- Readiness report

**Usage:**
```bash
# Check current project
/deployment:prepare

# Check specific project
/deployment:prepare /path/to/project
```

## Agents

### deployment-detector
Analyzes project structure and determines optimal deployment platform.

**Capabilities:**
- Multi-criteria project type detection
- Framework identification
- Platform recommendation with confidence scoring
- Deployment requirements analysis

### deployment-deployer
Executes platform-specific deployments with proper authentication.

**Capabilities:**
- Platform-specific deployment execution
- Build process management
- Environment configuration
- Authentication handling
- Progress monitoring

### deployment-validator
Validates deployment health and functionality.

**Capabilities:**
- HTTP/HTTPS endpoint testing
- Health check execution
- SSL/TLS validation
- Performance metrics
- Security header verification

## Skills

### platform-detection
Project type detection and platform recommendation logic.

**Provides:**
- Detection scripts for identifying project types
- Framework signature matching
- Platform routing rules
- Validation requirements
- Configuration analysis

### health-checks
Post-deployment validation and health checking.

**Provides:**
- HTTP health check scripts
- API endpoint testing
- MCP server validation
- SSL/TLS certificate checking
- Performance testing
- Monitoring dashboard templates

## Authentication Setup

### DigitalOcean
```bash
# Set access token in environment
export DIGITALOCEAN_ACCESS_TOKEN="your_token_here"

# Or authenticate with doctl
doctl auth init
```

### Vercel
```bash
# Login to Vercel CLI
vercel login

# Or set token
export VERCEL_TOKEN="your_token_here"
```

### Netlify
```bash
# Login to Netlify CLI
netlify login

# Or set token
export NETLIFY_AUTH_TOKEN="your_token_here"
```

### FastMCP Cloud
```bash
# Login to FastMCP CLI
fastmcp login

# Configure authentication
fastmcp auth setup
```

## Environment Variables

### Required for DigitalOcean
```bash
DIGITALOCEAN_ACCESS_TOKEN  # DigitalOcean API token
```

### Optional Platform Tokens
```bash
VERCEL_TOKEN               # Vercel API token (optional if using CLI login)
NETLIFY_AUTH_TOKEN         # Netlify API token (optional if using CLI login)
```

## Example Workflows

### Complete Deployment Flow
```bash
# 1. Prepare project for deployment
/deployment:prepare

# 2. Deploy application
/deployment:deploy

# 3. Validate deployment
/deployment:validate https://myapp.vercel.app
```

### Deployment with Rollback
```bash
# Deploy new version
/deployment:deploy

# If issues found, rollback
/deployment:rollback

# Validate rolled-back version
/deployment:validate https://myapp.vercel.app
```

### Pre-Deployment Validation
```bash
# Check readiness
/deployment:prepare

# Fix any issues reported
# ...

# Deploy when ready
/deployment:deploy
```

## Platform-Specific Notes

### FastMCP Cloud
- Best for: MCP servers (FastMCP or custom MCP implementations)
- Requires: FastMCP CLI installed and authenticated
- Supports: Python and TypeScript MCP servers

### DigitalOcean
- Best for: APIs, callback servers, containerized applications
- Requires: doctl CLI and DIGITALOCEAN_ACCESS_TOKEN
- Supports: Docker, Node.js, Python, Go, and more

### Vercel
- Best for: Next.js, React, Vue, and modern frontend frameworks
- Requires: Vercel CLI or VERCEL_TOKEN
- Supports: Serverless functions, edge middleware

### Netlify/Cloudflare Pages/Hostinger
- Best for: Static sites, documentation, marketing pages
- Requires: Platform-specific CLI or tokens
- Supports: Static HTML, Jamstack, static site generators

## Troubleshooting

### Authentication Failures
```bash
# Check authentication status
/deployment:prepare

# Re-authenticate
vercel login  # or netlify login, doctl auth init, etc.
```

### Build Failures
```bash
# Run build locally first
npm run build  # or python -m build, go build, etc.

# Check build output directory exists
ls dist/  # or build/, public/, etc.
```

### Deployment Timeouts
- Check network connectivity
- Verify platform status pages
- Try deploying manually with CLI first

### Validation Failures
```bash
# Get detailed validation report
/deployment:validate https://myapp.example.com

# Check deployment logs on platform
```

## Development

### Installing Plugin Locally
```bash
# From ai-dev-marketplace root
./plugins/domain-plugin-builder/skills/build-assistant/scripts/install-plugin-locally.sh plugins/deployment
```

### Validation
```bash
# Validate entire plugin
./plugins/domain-plugin-builder/skills/build-assistant/scripts/validate-plugin.sh plugins/deployment

# Validate specific components
./plugins/domain-plugin-builder/skills/build-assistant/scripts/validate-command.sh plugins/deployment/commands/deploy.md
./plugins/domain-plugin-builder/skills/build-assistant/scripts/validate-agent.sh plugins/deployment/agents/deployment-detector.md
```

## License

MIT

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/ai-dev-marketplace/plugins/tree/master/deployment).

## MCP Server Integration

This plugin includes pre-configured MCP servers for enhanced observability capabilities.

### Sentry MCP Server

The Sentry MCP server enables direct integration with Sentry error tracking:

**Configuration:** `.mcp.json`

**Capabilities:**
- Query issues and error trends
- Create and manage alerts
- Analyze error patterns across deployments
- Track deployment impact on error rates

**Setup:**
1. Get Sentry auth token: https://sentry.io/settings/account/api/auth-tokens/
2. Add credentials to Doppler (recommended) or environment:

   **Option A: Using Doppler (Recommended)**
   ```bash
   # After /foundation:doppler-setup
   doppler secrets set SENTRY_ORG_SLUG="your-org-slug" --config dev
   doppler secrets set SENTRY_PROJECT_SLUG="your-project-slug" --config dev
   doppler secrets set SENTRY_AUTH_TOKEN="your-sentry-auth-token" --config dev

   # Repeat for staging and production configs
   ```

   **Option B: Direct Environment Variables**
   ```bash
   export SENTRY_ORG_SLUG=your-org-slug
   export SENTRY_PROJECT_SLUG=your-project-slug
   export SENTRY_AUTH_TOKEN=your-sentry-auth-token
   ```

3. The MCP server auto-loads when deployment plugin is active
4. Variables are injected from Doppler when using `doppler run --`

**Usage:**
- `/deployment:setup-monitoring sentry` - Configures Sentry integration
- Query issues via MCP: "Show me the top 10 errors in production"
- Create alerts: "Set up alert for error rate >1% in 5 minutes"

**Documentation:** https://github.com/modelcontextprotocol/servers/tree/main/src/sentry

## Related Plugins

- **fastmcp** - Build FastMCP servers for deployment to FastMCP Cloud
- **vercel-ai-sdk** - Build AI applications for deployment to Vercel
- **supabase** - Database and backend services often deployed alongside frontends
- **nextjs-frontend** - Next.js applications that deploy to Vercel

---

**Version**: 1.1.0
**Last Updated**: November 5, 2025
