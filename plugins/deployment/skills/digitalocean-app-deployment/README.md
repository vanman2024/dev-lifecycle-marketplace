# DigitalOcean App Platform Deployment Skill

Comprehensive deployment lifecycle management for applications deployed to DigitalOcean App Platform.

## Quick Start

### 1. Validate Your Application

```bash
./scripts/validate-app.sh /path/to/app
```

### 2. Generate App Spec

```bash
# For Docker apps
./scripts/generate-app-spec.sh /path/to/app myapp

# For static sites
STATIC_SITE=true ./scripts/generate-app-spec.sh /path/to/app myapp

# With database
DATABASE=postgres ./scripts/generate-app-spec.sh /path/to/app myapp
```

### 3. Deploy to App Platform

```bash
# Deploy new app
./scripts/deploy-to-app-platform.sh .do/app.yaml

# Update existing app
./scripts/deploy-to-app-platform.sh .do/app.yaml <app-id>
```

## App Platform vs Droplets

| Feature | App Platform | Droplets |
|---------|-------------|----------|
| **Setup** | Low complexity | Medium-High |
| **Management** | Fully Managed | Self-Managed |
| **Scaling** | Automatic | Manual |
| **SSL/TLS** | Automatic | Manual |
| **Cost (Small App)** | ~$5-12/mo | ~$4-6/mo |
| **Best For** | Web apps, APIs, Static sites | Custom configs, Legacy apps |

## Use Cases

### Use App Platform When:
- ✅ Need managed infrastructure (auto-scaling, load balancing)
- ✅ Want zero-downtime deployments
- ✅ Need managed databases
- ✅ Want automatic SSL/TLS
- ✅ Deploy from Git (GitHub, GitLab)
- ✅ Need CDN for static sites
- ✅ Want simplified deployment workflow

### Use Droplets When:
- ✅ Need full server control
- ✅ Custom system configurations required
- ✅ Non-standard ports or networking
- ✅ Legacy applications
- ✅ Cost optimization for stable workloads
- ✅ Custom security requirements

## Available Templates

All templates include placeholder values for secrets:
- `app-spec-docker.yaml` - Docker-based applications
- `app-spec-nodejs.yaml` - Node.js runtime deployments
- `app-spec-python.yaml` - Python runtime deployments
- `app-spec-static.yaml` - Static site deployments
- `app-spec-with-database.yaml` - Apps with managed PostgreSQL

## Documentation

See [SKILL.md](./SKILL.md) for complete documentation including:
- All available scripts and usage
- Environment variables
- Security best practices
- Troubleshooting guide
- Cost optimization tips
- Integration with dev lifecycle

## Security

**CRITICAL**: Never hardcode API keys or secrets:
- ❌ NEVER use real API keys in templates or code
- ✅ ALWAYS use placeholders: `your_api_key_here`
- ✅ Mark sensitive env vars as `type: SECRET` in app specs
- ✅ Use appropriate scope (RUN_TIME, BUILD_TIME, RUN_AND_BUILD_TIME)

## Prerequisites

- [doctl](https://docs.digitalocean.com/reference/doctl/) installed and authenticated
- DigitalOcean account with App Platform access
- Application validated for App Platform deployment

## Cost Estimates

### Instance Sizing
- **basic-xxs**: $5/month - Small apps, testing
- **basic-xs**: $12/month - Low-traffic apps
- **professional-xs**: $24/month - Production apps

### Database Costs
- **Dev Database**: $7/month - Development/testing
- **Basic Database**: $15/month - Small production
- **Production Database**: $60+/month - High availability

Scale down during off-hours to optimize costs.
