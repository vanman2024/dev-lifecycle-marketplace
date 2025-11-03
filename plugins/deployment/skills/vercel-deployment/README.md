# Vercel Deployment Skill

Comprehensive deployment lifecycle management for applications deployed to Vercel.

## Quick Start

### 1. Validate Your Application

```bash
./scripts/validate-app.sh /path/to/app
```

### 2. Deploy to Vercel

```bash
# Deploy to preview
./scripts/deploy-to-vercel.sh /path/to/app

# Deploy to production
./scripts/deploy-to-vercel.sh /path/to/app production
```

## Supported Frameworks

- **Next.js**: App Router, Pages Router, API Routes
- **React**: Vite, Create React App
- **Vue**: Vue 3, Nuxt
- **Static Sites**: HTML/CSS/JS, Gatsby, Astro

## Use Cases

### Use Vercel When:
- ✅ Deploying Next.js, React, Vue applications
- ✅ Need edge network and serverless functions
- ✅ Want Git-based continuous deployment
- ✅ Need preview deployments for PRs
- ✅ Want automatic SSL and global CDN
- ✅ Building frontend or full-stack apps

### Use Other Platforms When:
- Docker-based backend → DigitalOcean App Platform
- Custom server configuration → DigitalOcean Droplets
- Simple static hosting → Netlify, Cloudflare Pages

## Available Templates

All templates use placeholder values for secrets:
- `vercel-nextjs.json` - Next.js configuration
- `vercel-react.json` - React/Vite configuration
- `vercel-static.json` - Static site configuration
- `.env.example` - Environment variable template

## Documentation

See [SKILL.md](./SKILL.md) for complete documentation including:
- All available scripts and usage
- Framework-specific features
- Security best practices
- Troubleshooting guide
- Cost optimization tips
- Integration with dev lifecycle

## Security

**CRITICAL**: Never hardcode API keys or secrets:
- ❌ NEVER use real API keys in templates or code
- ✅ ALWAYS use placeholders: `your_api_key_here`
- ✅ Use `NEXT_PUBLIC_` prefix for browser-exposed variables
- ✅ Store secrets in Vercel dashboard or use `vercel secrets`

## Prerequisites

- [Vercel CLI](https://vercel.com/cli) installed: `npm install -g vercel`
- Vercel account (free tier available)
- Node.js 18+ for most frameworks

## Cost Estimates

### Free Tier (Hobby)
- **Bandwidth**: 100GB/month
- **Build Time**: 100 hours/month
- **Serverless**: 100GB-hours
- Perfect for: Personal projects, prototypes

### Pro Tier ($20/month)
- **Bandwidth**: 1TB/month
- **Build Time**: Unlimited
- **Teams**: Collaboration support
- Perfect for: Production apps, team projects
