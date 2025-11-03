---
name: vercel-deployment
description: Vercel deployment using Vercel CLI for Next.js, React, Vue, static sites, and serverless functions. Includes project validation, deployment orchestration, environment management, domain configuration, and analytics integration. Use when deploying frontend applications, static sites, or serverless APIs, or when user mentions Vercel, Next.js deployment, serverless functions, or edge network.
allowed-tools: Bash, Read, Write, Edit
---

# Vercel Deployment Skill

This skill provides comprehensive deployment lifecycle management for applications deployed to Vercel using the Vercel CLI.

## Overview

The deployment lifecycle consists of five phases:
1. **Pre-Deployment Validation** - Application readiness, framework detection, build validation
2. **Project Configuration** - vercel.json generation, build settings, environment variables
3. **Deployment** - Deploy to preview or production, manage builds
4. **Domain & Environment Management** - Custom domains, environment variables, aliases
5. **Post-Deployment Verification** - Health checks, deployment status, analytics

## Supported Application Types

- **Next.js**: App Router, Pages Router, API Routes, Middleware
- **React**: Create React App, Vite, custom builds
- **Vue**: Vue 3, Nuxt, Vite
- **Static Sites**: HTML/CSS/JS, Gatsby, Astro, Hugo, Jekyll
- **Serverless Functions**: Node.js, Python, Go, Ruby serverless APIs
- **Monorepos**: Turborepo, Nx, pnpm workspaces

## Available Scripts

### 1. Application Validation

**Script**: `scripts/validate-app.sh <app-path>`

**Purpose**: Validates application is ready for Vercel deployment

**Checks**:
- Framework detection (Next.js, React, Vue, static)
- package.json or build configuration present
- Build command specified or detectable
- Output directory configured
- No hardcoded secrets in code
- Environment configuration present
- Node.js version compatibility

**Usage**:
```bash
# Validate Next.js app
./scripts/validate-app.sh /path/to/nextjs-app

# Validate React app
./scripts/validate-app.sh /path/to/react-app

# Validate static site
STATIC_SITE=true ./scripts/validate-app.sh /path/to/static-site

# Verbose mode
VERBOSE=1 ./scripts/validate-app.sh .
```

**Exit Codes**:
- `0`: Validation passed
- `1`: Validation failed (must fix before deployment)

### 2. Deploy to Vercel

**Script**: `scripts/deploy-to-vercel.sh <app-path> [environment]`

**Purpose**: Deploys application to Vercel

**Actions**:
- Validates Vercel CLI authentication
- Detects project framework and settings
- Links project to Vercel (if first deployment)
- Builds and deploys application
- Configures environment variables
- Captures deployment URL
- Monitors deployment status

**Usage**:
```bash
# Deploy to preview (automatic for branches)
./scripts/deploy-to-vercel.sh /path/to/app

# Deploy to production
./scripts/deploy-to-vercel.sh /path/to/app production

# Deploy with custom name
PROJECT_NAME=my-app ./scripts/deploy-to-vercel.sh /path/to/app

# Deploy and wait for completion
WAIT=true ./scripts/deploy-to-vercel.sh /path/to/app production

# Deploy with specific build command
BUILD_CMD="npm run build:prod" ./scripts/deploy-to-vercel.sh /path/to/app
```

**Environment Variables**:
- `VERCEL_TOKEN`: Vercel authentication token
- `VERCEL_ORG_ID`: Organization ID (for team projects)
- `VERCEL_PROJECT_ID`: Project ID (for existing projects)
- `PROJECT_NAME`: Custom project name
- `BUILD_CMD`: Custom build command
- `OUTPUT_DIR`: Custom output directory
- `WAIT`: Set to `true` to wait for deployment completion
- `PROD`: Set to `true` for production deployment

**Exit Codes**:
- `0`: Deployment successful
- `1`: Deployment failed

### 3. Update Environment Variables

**Script**: `scripts/update-env-vars.sh <project-name> <environment>`

**Purpose**: Updates environment variables for Vercel project

**Actions**:
- Retrieves current environment variables
- Prompts for updated variables
- Supports development, preview, production scopes
- Triggers redeployment if needed
- Verifies variables applied

**Usage**:
```bash
# Update production env vars
./scripts/update-env-vars.sh my-app production

# Update from .env file
ENV_FILE=.env.production ./scripts/update-env-vars.sh my-app production

# Update specific variables
API_KEY=new_key DATABASE_URL=new_url ./scripts/update-env-vars.sh my-app production

# Update for all environments
ENV_SCOPE=all ./scripts/update-env-vars.sh my-app
```

**Exit Codes**:
- `0`: Environment variables updated successfully
- `1`: Update failed

### 4. Configure Domain

**Script**: `scripts/configure-domain.sh <project-name> <domain>`

**Purpose**: Configures custom domain for Vercel project

**Actions**:
- Adds domain to Vercel project
- Configures SSL/TLS certificate (automatic)
- Sets up DNS records
- Configures redirects (www, apex)
- Verifies domain is accessible

**Usage**:
```bash
# Add custom domain
./scripts/configure-domain.sh my-app myapp.com

# Add with www redirect
WWW_REDIRECT=true ./scripts/configure-domain.sh my-app myapp.com

# Add subdomain
./scripts/configure-domain.sh my-app api.myapp.com

# Force HTTPS redirect
FORCE_HTTPS=true ./scripts/configure-domain.sh my-app myapp.com
```

**Exit Codes**:
- `0`: Domain configured successfully
- `1`: Configuration failed

### 5. Manage Deployments

**Script**: `scripts/manage-deployment.sh <action> <project-name>`

**Purpose**: Manage Vercel deployments and project

**Actions**:
- `list`: List recent deployments
- `inspect`: Show deployment details
- `logs`: View deployment logs
- `rollback`: Rollback to previous deployment
- `promote`: Promote preview to production
- `remove`: Remove deployment
- `alias`: Manage aliases

**Usage**:
```bash
# List deployments
./scripts/manage-deployment.sh list my-app

# Inspect specific deployment
./scripts/manage-deployment.sh inspect my-app <deployment-url>

# View logs
./scripts/manage-deployment.sh logs my-app <deployment-url>

# Rollback to previous
./scripts/manage-deployment.sh rollback my-app

# Promote preview to production
./scripts/manage-deployment.sh promote my-app <preview-url>

# Remove deployment
./scripts/manage-deployment.sh remove my-app <deployment-url>
```

### 6. Health Check

**Script**: `scripts/health-check.sh <deployment-url>`

**Purpose**: Validates Vercel deployment health

**Checks**:
- Deployment status (ready/building/error)
- HTTP endpoint accessibility
- SSL certificate validity
- Build logs for errors
- Performance metrics
- Edge network propagation
- DNS resolution

**Usage**:
```bash
# Check deployment health
./scripts/health-check.sh https://my-app.vercel.app

# Continuous monitoring (runs every 30s)
MONITOR=true ./scripts/health-check.sh https://my-app.vercel.app

# Detailed health report
DETAILED=true ./scripts/health-check.sh https://my-app.vercel.app
```

**Exit Codes**:
- `0`: All health checks passed
- `1`: One or more health checks failed

### 7. Project Setup

**Script**: `scripts/setup-project.sh <app-path> <project-name>`

**Purpose**: Initialize Vercel project configuration

**Actions**:
- Creates vercel.json configuration
- Links project to Vercel
- Sets up environment variables
- Configures build settings
- Sets up Git integration

**Usage**:
```bash
# Setup new project
./scripts/setup-project.sh /path/to/app my-app

# Setup with custom settings
FRAMEWORK=nextjs ./scripts/setup-project.sh /path/to/app my-app

# Setup for team
TEAM=my-team ./scripts/setup-project.sh /path/to/app my-app
```

## Available Templates

### 1. Next.js Configuration

**File**: `templates/vercel-nextjs.json`

**Purpose**: vercel.json for Next.js applications

**Example**:
```json
{
  "version": 2,
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "installCommand": "npm install",
  "devCommand": "npm run dev",
  "env": {
    "NEXT_PUBLIC_API_URL": "your_api_url_here"
  },
  "build": {
    "env": {
      "DATABASE_URL": "@database-url"
    }
  }
}
```

### 2. React/Vite Configuration

**File**: `templates/vercel-react.json`

**Purpose**: vercel.json for React applications

**Example**:
```json
{
  "version": 2,
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "devCommand": "npm run dev",
  "framework": "vite",
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

### 3. Static Site Configuration

**File**: `templates/vercel-static.json`

**Purpose**: vercel.json for static sites

**Example**:
```json
{
  "version": 2,
  "buildCommand": "npm run build",
  "outputDirectory": "public",
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

### 4. Serverless Functions Configuration

**File**: `templates/vercel-serverless.json`

**Purpose**: vercel.json for serverless API

**Example**:
```json
{
  "version": 2,
  "functions": {
    "api/**/*.js": {
      "runtime": "nodejs18.x",
      "memory": 1024,
      "maxDuration": 10
    }
  },
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "/api/$1"
    }
  ]
}
```

### 5. Environment Variables Template

**File**: `templates/.env.example`

**Purpose**: Environment variable template

**Example**:
```bash
# Public variables (exposed to browser)
NEXT_PUBLIC_API_URL=your_api_url_here
NEXT_PUBLIC_ANALYTICS_ID=your_analytics_id_here

# Server-only variables (not exposed)
DATABASE_URL=your_database_url_here
API_SECRET=your_api_secret_here
STRIPE_SECRET_KEY=your_stripe_key_here

# Vercel system variables (automatically provided)
# VERCEL=1
# VERCEL_URL=<deployment-url>
# VERCEL_ENV=production|preview|development
```

## Deployment Workflow

### Initial Deployment

1. **Validate Application**:
   ```bash
   ./scripts/validate-app.sh /path/to/app
   ```

2. **Setup Project**:
   ```bash
   ./scripts/setup-project.sh /path/to/app my-app
   ```

3. **Deploy to Preview**:
   ```bash
   ./scripts/deploy-to-vercel.sh /path/to/app
   ```

4. **Verify Deployment**:
   ```bash
   ./scripts/health-check.sh https://my-app-preview.vercel.app
   ```

5. **Deploy to Production**:
   ```bash
   ./scripts/deploy-to-vercel.sh /path/to/app production
   ```

### Update Deployment

1. **Deploy Updates**:
   ```bash
   ./scripts/deploy-to-vercel.sh /path/to/app production
   ```

2. **Verify Health**:
   ```bash
   ./scripts/health-check.sh https://my-app.com
   ```

### Update Environment Variables

1. **Update Variables**:
   ```bash
   ./scripts/update-env-vars.sh my-app production
   ```

2. **Redeploy** (automatic after env var changes)

### Configure Custom Domain

1. **Add Domain**:
   ```bash
   ./scripts/configure-domain.sh my-app myapp.com
   ```

2. **Update DNS** (follow Vercel instructions)

3. **Verify Domain**:
   ```bash
   ./scripts/health-check.sh https://myapp.com
   ```

## Security Best Practices

1. **Never Hardcode Secrets**: Always use environment variables
2. **Use Vercel Secrets**: Encrypt sensitive values with `vercel secrets add`
3. **Scope Variables**: Use appropriate target (development, preview, production)
4. **Prefix Public Variables**: Use `NEXT_PUBLIC_` for browser-exposed variables
5. **Rotate Secrets**: Regularly update API keys and tokens
6. **Enable Protection**: Use Vercel's deployment protection features
7. **Monitor Logs**: Regularly check deployment and runtime logs
8. **Use Teams**: Manage access with Vercel teams for collaboration

## Framework-Specific Features

### Next.js
- **App Router**: Full support for Next.js 13+ App Router
- **API Routes**: Serverless API endpoints
- **Middleware**: Edge middleware support
- **ISR**: Incremental Static Regeneration
- **Image Optimization**: Automatic image optimization
- **Font Optimization**: Automatic font optimization

### React/Vite
- **SPA Mode**: Single Page Application routing
- **API Proxying**: Proxy API requests to avoid CORS
- **Code Splitting**: Automatic code splitting
- **Fast Refresh**: Hot module replacement

### Static Sites
- **CDN**: Global edge network
- **Asset Optimization**: Automatic compression
- **Headers**: Custom header configuration
- **Redirects**: URL redirect management

### Serverless Functions
- **Edge Functions**: Ultra-low latency edge runtime
- **Node.js**: Full Node.js runtime support
- **Python**: Python serverless functions
- **Go**: Go serverless functions

## Vercel vs Other Platforms

| Feature | Vercel | App Platform | Droplets |
|---------|--------|--------------|----------|
| **Framework Focus** | Frontend/Fullstack | Any | Any |
| **Edge Network** | Global | CDN available | Manual |
| **Serverless** | Built-in | No | Manual |
| **Git Integration** | Native | Native | Manual |
| **Build Time** | Fast | Medium | N/A |
| **Cost (Small)** | Free-$20/mo | $5-12/mo | $4-6/mo |
| **Best For** | Next.js, React, Vue | Docker apps | Custom servers |

## Troubleshooting

### Build Failures

```bash
# View build logs
./scripts/manage-deployment.sh logs my-app <deployment-url>

# Common issues:
# - Missing dependencies in package.json
# - Incorrect build command
# - Node.js version mismatch
# - Environment variables missing at build time
```

### Deployment Failures

```bash
# Check deployment status
vercel inspect <deployment-url>

# View runtime logs
vercel logs <deployment-url>

# Common issues:
# - Serverless function timeout
# - Memory limit exceeded
# - Missing environment variables
# - API route errors
```

### Domain Issues

```bash
# Check domain configuration
vercel domains ls

# Verify DNS
dig myapp.com

# Common issues:
# - DNS not propagated (wait 24-48 hours)
# - Incorrect DNS records
# - SSL certificate provisioning (automatic, wait a few minutes)
```

## Cost Optimization

### Free Tier
- **Hobby Plan**: Free forever
- **Bandwidth**: 100GB/month
- **Build Time**: 100 hours/month
- **Serverless Executions**: 100GB-hours
- **Edge Requests**: Unlimited

### Pro Tier ($20/month)
- **Bandwidth**: 1TB/month
- **Build Time**: Unlimited
- **Team Collaboration**: Yes
- **Password Protection**: Yes
- **Analytics**: Advanced

### Tips
- Use ISR to reduce build times
- Optimize images with Next.js Image
- Cache static assets
- Use Edge Functions for low latency

## Integration with Dev Lifecycle

This skill integrates with:
- `/deployment:prepare` - Pre-deployment validation
- `/deployment:deploy` - Execute Vercel deployment
- `/deployment:validate` - Post-deployment verification
- `/deployment:rollback` - Rollback to previous deployment

## Vercel CLI Commands Reference

```bash
# Authentication
vercel login
vercel logout

# Deployment
vercel                    # Deploy to preview
vercel --prod            # Deploy to production
vercel --name my-app     # Deploy with custom name

# Project Management
vercel list              # List projects
vercel inspect <url>     # Inspect deployment
vercel logs <url>        # View logs
vercel remove <url>      # Remove deployment

# Environment Variables
vercel env ls            # List env vars
vercel env add           # Add env var
vercel env rm            # Remove env var

# Domains
vercel domains ls        # List domains
vercel domains add       # Add domain
vercel domains rm        # Remove domain

# Aliases
vercel alias ls          # List aliases
vercel alias set         # Set alias
vercel alias rm          # Remove alias
```

## Example Use Cases

### Next.js E-commerce Site
- Deploy with ISR for product pages
- Use Edge Functions for cart API
- Configure custom domain
- Set up analytics
- Cost: Free-$20/month

### React Dashboard
- Deploy with SPA routing
- Proxy API to backend
- Configure preview deployments
- Password protect staging
- Cost: Free-$20/month

### Serverless API
- Deploy API routes
- Configure rate limiting
- Set up monitoring
- Use Edge network
- Cost: Free (within limits)

### Multi-tenant SaaS
- Deploy with preview environments
- Configure per-tenant domains
- Use deployment protection
- Set up team access
- Cost: $20+/month
