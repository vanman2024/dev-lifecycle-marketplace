# Deployment Scripts Skill

Platform-specific deployment scripts and configurations for automating deployments across various cloud platforms.

## Overview

This skill provides reusable deployment utilities that can be used by deployment commands, agents, and CI/CD pipelines. It supports multiple platforms including Vercel, Netlify, Fly.io, AWS, Google Cloud, and more.

## Structure

```
deployment-scripts/
├── SKILL.md                          # Skill manifest with usage instructions
├── README.md                         # This file
├── scripts/                          # Functional deployment scripts (8 total)
│   ├── check-auth.sh                # Verify platform authentication
│   ├── validate-env.sh              # Validate environment variables
│   ├── validate-build.sh            # Pre-deployment build checks
│   ├── deploy-helper.sh             # Universal deployment wrapper
│   ├── rollback-deployment.sh       # Rollback to previous version
│   ├── health-check.sh              # Post-deployment health checks
│   ├── vercel-deploy.sh             # Vercel-specific deployment
│   └── netlify-deploy.sh            # Netlify-specific deployment
├── templates/                        # Platform configurations (10 total)
│   ├── vercel.json                  # Vercel platform config
│   ├── netlify.toml                 # Netlify platform config
│   ├── fly.toml                     # Fly.io platform config
│   ├── render.yaml                  # Render platform config
│   ├── Dockerfile.node              # Node.js optimized Dockerfile
│   ├── Dockerfile.python            # Python optimized Dockerfile
│   ├── .dockerignore                # Docker ignore patterns
│   ├── github-actions-deploy.yml    # GitHub Actions workflow
│   ├── gitlab-ci-deploy.yml         # GitLab CI workflow
│   └── .env.example                 # Environment variables template
└── examples/                         # Usage examples (5 total)
    ├── basic-deployment.md          # Simple deployment workflow
    ├── multi-environment.md         # Multi-environment strategy
    ├── docker-deployment.md         # Container deployments
    ├── cicd-integration.md          # CI/CD integration patterns
    └── troubleshooting.md           # Common issues and solutions
```

## Quick Start

### 1. Check Authentication

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh vercel
```

### 2. Validate Environment

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
```

### 3. Deploy

```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
  --platform vercel \
  --env production
```

## Supported Platforms

### Cloud Platforms
- **Vercel** - Frontend deployment platform
- **Netlify** - JAMstack deployment platform
- **Fly.io** - Global application platform
- **Render** - Unified cloud platform
- **AWS** - Amazon Web Services
- **Google Cloud** - Google Cloud Platform

### Container Platforms
- **Docker** - Container runtime
- **Docker Hub** - Container registry
- **GitHub Container Registry** - GHCR
- **AWS ECS** - Elastic Container Service
- **Google Cloud Run** - Serverless containers

### CI/CD Platforms
- **GitHub Actions** - GitHub's CI/CD
- **GitLab CI/CD** - GitLab's CI/CD
- **CircleCI** - Cloud CI/CD platform
- **Jenkins** - Self-hosted automation server
- **Bitbucket Pipelines** - Bitbucket's CI/CD
- **Travis CI** - Continuous integration service

## Script Usage

### Authentication Check

```bash
# Check Vercel authentication
bash scripts/check-auth.sh vercel

# Check multiple platforms
for platform in vercel netlify aws; do
  bash scripts/check-auth.sh $platform
done
```

### Environment Validation

```bash
# Validate production environment
bash scripts/validate-env.sh .env.production

# Validate with custom required variables
bash scripts/validate-env.sh .env.production required-vars.txt
```

### Build Validation

```bash
# Validate current directory
bash scripts/validate-build.sh .

# Validate specific project
bash scripts/validate-build.sh /path/to/project
```

### Universal Deployment Helper

```bash
# Deploy to Vercel production
bash scripts/deploy-helper.sh --platform vercel --env production

# Dry run (show what would be deployed)
bash scripts/deploy-helper.sh --platform vercel --env production --dry-run

# Skip tests and build validation
bash scripts/deploy-helper.sh --platform vercel --env staging --skip-tests --skip-build
```

### Platform-Specific Deployment

```bash
# Deploy to Vercel
bash scripts/vercel-deploy.sh production

# Deploy to Netlify
bash scripts/netlify-deploy.sh staging
```

### Health Check

```bash
# Basic health check
bash scripts/health-check.sh https://my-app.com

# With custom timeout
bash scripts/health-check.sh https://my-app.com 60
```

### Rollback

```bash
# Rollback to previous deployment
bash scripts/rollback-deployment.sh vercel

# Rollback to specific version
bash scripts/rollback-deployment.sh vercel <version-id>
```

## Template Usage

### Copy Platform Configuration

```bash
# Vercel
cp templates/vercel.json .

# Netlify
cp templates/netlify.toml .

# Fly.io
cp templates/fly.toml .

# Render
cp templates/render.yaml .
```

### Copy Docker Templates

```bash
# Node.js Dockerfile
cp templates/Dockerfile.node Dockerfile

# Python Dockerfile
cp templates/Dockerfile.python Dockerfile

# Docker ignore
cp templates/.dockerignore .
```

### Copy CI/CD Templates

```bash
# GitHub Actions
mkdir -p .github/workflows
cp templates/github-actions-deploy.yml .github/workflows/deploy.yml

# GitLab CI
cp templates/gitlab-ci-deploy.yml .gitlab-ci.yml
```

### Copy Environment Template

```bash
# Copy and customize
cp templates/.env.example .env.production
nano .env.production
```

## Integration with Commands

Deployment commands should use these scripts via the Bash tool:

```markdown
# In a /deploy command

Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh vercel
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/vercel-deploy.sh production
Bash: bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh https://my-app.com
```

## Best Practices

1. **Always validate before deploying**
   - Check authentication status
   - Validate environment variables
   - Run build validation

2. **Use environment-specific configurations**
   - Maintain separate `.env.production`, `.env.staging` files
   - Never commit secrets to version control

3. **Test in staging first**
   - Deploy to staging environment before production
   - Run health checks on staging

4. **Monitor deployments**
   - Always run health checks after deployment
   - Set up monitoring and alerting

5. **Keep rollback ready**
   - Know how to rollback before deploying
   - Test rollback procedures in staging

6. **Automate with CI/CD**
   - Use the provided CI/CD templates
   - Implement automated testing and deployment

## Examples

See the `examples/` directory for detailed guides:

- **basic-deployment.md** - Simple deployment workflow for beginners
- **multi-environment.md** - Managing multiple environments (dev, staging, prod)
- **docker-deployment.md** - Containerized deployment patterns
- **cicd-integration.md** - Setting up automated CI/CD pipelines
- **troubleshooting.md** - Common issues and their solutions

## Script Reference

### check-auth.sh
Verifies authentication for deployment platforms.

**Platforms:** vercel, netlify, aws, gcloud, fly, render

**Exit codes:**
- 0: Authenticated successfully
- 1: Authentication failed or CLI not installed

### validate-env.sh
Validates environment variables before deployment.

**Features:**
- Checks required variables are set
- Validates URL formats
- Detects insecure values
- Environment-specific validations

**Exit codes:**
- 0: All validations passed
- 1: Validation errors found

### validate-build.sh
Runs pre-deployment build validation checks.

**Checks:**
- Project type detection
- Dependencies installed
- Linting and type checking
- Security vulnerabilities
- File size checks
- Configuration validation

**Exit codes:**
- 0: Build validation passed
- 1: Build validation failed

### deploy-helper.sh
Universal deployment wrapper with platform detection.

**Options:**
- `--platform <platform>` - Target platform (required)
- `--env <environment>` - Environment (default: production)
- `--dir <path>` - Project directory (default: .)
- `--dry-run` - Show what would be deployed
- `--skip-tests` - Skip test execution
- `--skip-build` - Skip build validation

### health-check.sh
Post-deployment health and smoke testing.

**Checks:**
- Basic connectivity (HTTP status)
- Response time
- SSL certificate validation
- Health endpoints
- Content validation
- Static assets
- Security headers

**Exit codes:**
- 0: All health checks passed
- 1: Health checks failed

## Requirements

### Platform CLIs
- Vercel: `npm i -g vercel`
- Netlify: `npm i -g netlify-cli`
- Fly.io: Install from https://fly.io/docs/hands-on/install-flyctl/
- AWS: Install from https://aws.amazon.com/cli/
- Google Cloud: Install from https://cloud.google.com/sdk/docs/install

### System Tools
- bash (4.0+)
- curl
- git
- jq (optional, for JSON parsing)
- openssl (for SSL checks)

## Contributing

When extending this skill:

1. Add new scripts to `scripts/` directory
2. Make scripts executable: `chmod +x scripts/*.sh`
3. Add comprehensive error handling
4. Update SKILL.md to reference new scripts
5. Add templates to `templates/` directory
6. Document usage in examples

## License

Part of the ai-dev-marketplace deployment plugin.

## Version

1.0.0 - Initial release with comprehensive deployment automation
