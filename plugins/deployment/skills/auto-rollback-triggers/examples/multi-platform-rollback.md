# Multi-Platform Rollback

Automated rollback orchestration across multiple deployment platforms.

## Overview

This example demonstrates rollback triggers for:
- Vercel (frontend deployments)
- DigitalOcean App Platform (full-stack apps)
- Railway (backend services)
- Netlify (static sites)
- Render (containerized apps)

## Platform Detection

### Automatic Platform Detection

The rollback script can auto-detect platforms based on deployment URLs:

```bash
#!/bin/bash
# auto-detect-platform.sh

DEPLOYMENT_URL="$1"

if [[ "$DEPLOYMENT_URL" =~ vercel\.app ]]; then
  echo "vercel"
elif [[ "$DEPLOYMENT_URL" =~ ondigitalocean\.app ]]; then
  echo "digitalocean"
elif [[ "$DEPLOYMENT_URL" =~ railway\.app ]]; then
  echo "railway"
elif [[ "$DEPLOYMENT_URL" =~ netlify\.app ]]; then
  echo "netlify"
elif [[ "$DEPLOYMENT_URL" =~ render\.com ]]; then
  echo "render"
else
  echo "unknown"
fi
```

Usage:

```bash
PLATFORM=$(bash auto-detect-platform.sh "https://myapp.vercel.app")
echo "Detected platform: $PLATFORM"
```

## Platform-Specific Rollback

### Vercel Rollback

```bash
# Monitor and rollback Vercel deployment
VERCEL_PROJECT="my-nextjs-app"
VERCEL_DEPLOYMENT="dpl_abc123xyz"
PREVIOUS_DEPLOYMENT="dpl_previous456xyz"

# Monitor error rate
bash scripts/monitor-error-rate.sh \
  "https://${VERCEL_PROJECT}.vercel.app/api/metrics" \
  5.0 \
  300 || {
    echo "Error rate exceeded - rolling back Vercel deployment"

    bash scripts/trigger-rollback.sh \
      vercel \
      "$VERCEL_PROJECT" \
      "$PREVIOUS_DEPLOYMENT" \
      "$VERCEL_TOKEN"
  }
```

### DigitalOcean App Platform Rollback

```bash
# Monitor and rollback DigitalOcean App
DO_APP_ID="abc123-def456-ghi789"
DO_DEPLOYMENT="deployment_12345"
PREVIOUS_DEPLOYMENT="deployment_12344"

# Check SLO
bash scripts/check-slo.sh \
  "https://myapp.ondigitalocean.app/health" \
  99.9 || {
    echo "SLO violated - rolling back DigitalOcean app"

    bash scripts/trigger-rollback.sh \
      digitalocean \
      "$DO_APP_ID" \
      "$PREVIOUS_DEPLOYMENT" \
      "$DIGITALOCEAN_TOKEN"
  }
```

### Railway Rollback

```bash
# Monitor and rollback Railway service
RAILWAY_PROJECT="my-api-service"
RAILWAY_DEPLOYMENT="deploy_abc123"
PREVIOUS_DEPLOYMENT="deploy_abc122"

# Monitor error rate
bash scripts/monitor-error-rate.sh \
  "https://my-api.railway.app/metrics" \
  5.0 \
  300 || {
    echo "Error rate exceeded - rolling back Railway service"

    bash scripts/trigger-rollback.sh \
      railway \
      "$RAILWAY_PROJECT" \
      "$PREVIOUS_DEPLOYMENT" \
      "$RAILWAY_TOKEN"
  }
```

### Netlify Rollback

```bash
# Monitor and rollback Netlify site
NETLIFY_SITE="my-static-site"
NETLIFY_DEPLOY="deploy_abc123"
PREVIOUS_DEPLOY="deploy_abc122"

# Check availability
bash scripts/check-slo.sh \
  "https://my-static-site.netlify.app/" \
  99.5 || {
    echo "Availability dropped - rolling back Netlify site"

    bash scripts/trigger-rollback.sh \
      netlify \
      "$NETLIFY_SITE" \
      "$PREVIOUS_DEPLOY" \
      "$NETLIFY_TOKEN"
  }
```

### Render Rollback

```bash
# Monitor and rollback Render service
RENDER_SERVICE="srv-abc123"
RENDER_DEPLOY="deploy_abc123"
PREVIOUS_DEPLOY="deploy_abc122"

# Monitor error rate
bash scripts/monitor-error-rate.sh \
  "https://my-service.onrender.com/metrics" \
  5.0 \
  300 || {
    echo "Error rate exceeded - rolling back Render service"

    bash scripts/trigger-rollback.sh \
      render \
      "$RENDER_SERVICE" \
      "$PREVIOUS_DEPLOY" \
      "$RENDER_TOKEN"
  }
```

## Multi-Service Deployment

### Full-Stack Application Rollback

Orchestrate rollback across frontend and backend:

```bash
#!/bin/bash
# rollback-fullstack.sh

set -e

FRONTEND_PLATFORM="vercel"
FRONTEND_PROJECT="my-frontend"
FRONTEND_PREVIOUS="dpl_frontend_prev"

BACKEND_PLATFORM="railway"
BACKEND_PROJECT="my-backend"
BACKEND_PREVIOUS="deploy_backend_prev"

echo "=== Full-Stack Rollback ==="

# Step 1: Rollback backend first (dependencies)
echo "1. Rolling back backend..."
bash scripts/trigger-rollback.sh \
  "$BACKEND_PLATFORM" \
  "$BACKEND_PROJECT" \
  "$BACKEND_PREVIOUS" \
  "$RAILWAY_TOKEN"

# Wait for backend rollback to complete
sleep 30

# Step 2: Verify backend health
echo "2. Verifying backend health..."
if ! bash scripts/check-slo.sh \
  "https://my-backend.railway.app/health" \
  99.0; then
  echo "Backend rollback failed health check"
  exit 1
fi

# Step 3: Rollback frontend
echo "3. Rolling back frontend..."
bash scripts/trigger-rollback.sh \
  "$FRONTEND_PLATFORM" \
  "$FRONTEND_PROJECT" \
  "$FRONTEND_PREVIOUS" \
  "$VERCEL_TOKEN"

echo "✓ Full-stack rollback completed"
```

### Microservices Rollback

Rollback multiple services in dependency order:

```bash
#!/bin/bash
# rollback-microservices.sh

declare -A SERVICES=(
  ["database"]="digitalocean:db-service:deploy_123"
  ["auth-api"]="railway:auth-service:deploy_234"
  ["user-api"]="railway:user-service:deploy_345"
  ["frontend"]="vercel:web-app:dpl_456"
)

declare -A DEPENDENCIES=(
  ["auth-api"]="database"
  ["user-api"]="database auth-api"
  ["frontend"]="user-api auth-api"
)

rollback_service() {
  local service="$1"
  local platform deployment_id

  IFS=':' read -r platform project_id deployment_id <<< "${SERVICES[$service]}"

  echo "Rolling back $service ($platform)..."

  # Get appropriate token
  local token
  case "$platform" in
    vercel)      token="$VERCEL_TOKEN" ;;
    digitalocean) token="$DIGITALOCEAN_TOKEN" ;;
    railway)     token="$RAILWAY_TOKEN" ;;
  esac

  bash scripts/trigger-rollback.sh \
    "$platform" \
    "$project_id" \
    "$deployment_id" \
    "$token"
}

# Rollback in reverse dependency order
echo "=== Microservices Rollback ==="

# 1. Frontend (depends on all)
rollback_service "frontend"
sleep 20

# 2. APIs (depend on database)
rollback_service "user-api"
rollback_service "auth-api"
sleep 20

# 3. Database (no dependencies)
rollback_service "database"

echo "✓ All services rolled back"
```

## GitHub Actions Multi-Platform

### Unified Rollback Workflow

```yaml
name: Multi-Platform Auto-Rollback

on:
  workflow_dispatch:
    inputs:
      platform:
        description: 'Platform to rollback'
        required: true
        type: choice
        options:
          - vercel
          - digitalocean
          - railway
          - netlify
          - all
      deployment_url:
        description: 'Deployment URL to monitor'
        required: true

jobs:
  monitor-and-rollback:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Monitor deployment
        id: monitor
        run: |
          bash scripts/monitor-error-rate.sh \
            "${{ inputs.deployment_url }}/metrics" \
            5.0 \
            300 || echo "ROLLBACK_NEEDED=true" >> $GITHUB_OUTPUT

      - name: Rollback Vercel
        if: |
          steps.monitor.outputs.ROLLBACK_NEEDED == 'true' &&
          (inputs.platform == 'vercel' || inputs.platform == 'all')
        run: |
          bash scripts/trigger-rollback.sh \
            vercel \
            "${{ secrets.VERCEL_PROJECT }}" \
            "${{ secrets.VERCEL_PREVIOUS_DEPLOYMENT }}" \
            "${{ secrets.VERCEL_TOKEN }}"

      - name: Rollback DigitalOcean
        if: |
          steps.monitor.outputs.ROLLBACK_NEEDED == 'true' &&
          (inputs.platform == 'digitalocean' || inputs.platform == 'all')
        run: |
          bash scripts/trigger-rollback.sh \
            digitalocean \
            "${{ secrets.DO_APP_ID }}" \
            "${{ secrets.DO_PREVIOUS_DEPLOYMENT }}" \
            "${{ secrets.DIGITALOCEAN_TOKEN }}"

      - name: Rollback Railway
        if: |
          steps.monitor.outputs.ROLLBACK_NEEDED == 'true' &&
          (inputs.platform == 'railway' || inputs.platform == 'all')
        run: |
          bash scripts/trigger-rollback.sh \
            railway \
            "${{ secrets.RAILWAY_PROJECT }}" \
            "${{ secrets.RAILWAY_PREVIOUS_DEPLOYMENT }}" \
            "${{ secrets.RAILWAY_TOKEN }}"
```

## Platform Configuration

### Centralized Platform Config

```json
{
  "platforms": {
    "vercel": {
      "enabled": true,
      "projects": {
        "frontend": {
          "project_id": "my-frontend",
          "monitoring_url": "https://my-frontend.vercel.app/metrics",
          "error_threshold": 5.0,
          "slo_target": 99.9
        }
      },
      "api_token_env": "VERCEL_TOKEN"
    },
    "digitalocean": {
      "enabled": true,
      "apps": {
        "api": {
          "app_id": "abc123-def456",
          "monitoring_url": "https://myapp.ondigitalocean.app/metrics",
          "error_threshold": 5.0,
          "slo_target": 99.9
        }
      },
      "api_token_env": "DIGITALOCEAN_TOKEN"
    },
    "railway": {
      "enabled": true,
      "services": {
        "backend": {
          "project_id": "my-backend",
          "monitoring_url": "https://my-backend.railway.app/metrics",
          "error_threshold": 5.0,
          "slo_target": 99.9
        }
      },
      "api_token_env": "RAILWAY_TOKEN"
    }
  }
}
```

### Platform Manager Script

```bash
#!/bin/bash
# platform-manager.sh

CONFIG_FILE="config/platforms.json"

get_platform_projects() {
  local platform="$1"
  jq -r ".platforms.$platform.projects | keys[]" "$CONFIG_FILE"
}

get_monitoring_url() {
  local platform="$1"
  local project="$2"
  jq -r ".platforms.$platform.projects.$project.monitoring_url" "$CONFIG_FILE"
}

monitor_all_platforms() {
  echo "=== Monitoring All Platforms ==="

  for platform in vercel digitalocean railway; do
    if [ "$(jq -r ".platforms.$platform.enabled" "$CONFIG_FILE")" = "true" ]; then
      echo "Monitoring $platform..."

      for project in $(get_platform_projects "$platform"); do
        local url=$(get_monitoring_url "$platform" "$project")
        echo "  Checking $project at $url"

        bash scripts/monitor-error-rate.sh "$url" 5.0 60 || {
          echo "  ⚠️ $project failed monitoring"
        }
      done
    fi
  done
}

monitor_all_platforms
```

## Best Practices

1. **Rollback Order Matters**: Always rollback in reverse dependency order (frontend → backend → database)
2. **Verify Between Steps**: Check health after each rollback before proceeding
3. **Platform-Specific Timeouts**: Different platforms have different rollback speeds
4. **Store Previous Deployment IDs**: Keep track of last-known-good deployments
5. **Test Rollback Process**: Regularly test rollback in staging
6. **Monitor Post-Rollback**: Continue monitoring after rollback to ensure stability
7. **Document Platform APIs**: Keep API documentation for each platform handy

## Troubleshooting

### Rollback Failed on One Platform

**Problem**: Multi-service rollback partially failed

**Solutions**:
- Continue with remaining services
- Document failed platform
- Trigger manual rollback for failed platform
- Investigate platform-specific issues

### Token Permission Issues

**Problem**: API token lacks rollback permissions

**Solutions**:
- Verify token has deployment management permissions
- Check token hasn't expired
- Ensure correct token for each platform
- Rotate tokens if compromised

## Next Steps

- Implement canary deployment protection
- Add automated testing post-rollback
- Set up cross-platform monitoring dashboard
- Configure graduated rollback strategies
