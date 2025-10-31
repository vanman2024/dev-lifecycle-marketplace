# Integration with Deployment Commands

This document demonstrates how to integrate platform detection with automated deployment workflows and commands.

## Overview

Platform detection integrates with:
- `/deployment:deploy` - Automatic platform selection
- `/deployment:validate` - Pre-deployment validation
- `/deployment:configure` - Platform-specific configuration generation
- CI/CD pipelines - Automated deployment workflows

## Integration Pattern 1: Deploy Command

### Basic Integration

```markdown
<!-- /deployment:deploy command -->
---
allowed-tools: Task, Bash, Read, Write
description: Deploy project to recommended platform
---

# Deployment Command

## Goal
Automatically detect project type and deploy to optimal platform.

## Actions

### Phase 1: Detection
Use platform-detection skill to analyze project.

```bash
# Load platform-detection skill
cd plugins/deployment/skills/platform-detection

# Detect project characteristics
PROJECT_TYPE=$(bash scripts/detect-project-type.sh $PROJECT_PATH)
FRAMEWORK=$(bash scripts/detect-framework.sh $PROJECT_PATH)
PLATFORM=$(bash scripts/recommend-platform.sh $PROJECT_PATH)

echo "Detected Configuration:"
echo "  Type: $PROJECT_TYPE"
echo "  Framework: $FRAMEWORK"
echo "  Recommended Platform: $PLATFORM"
```

### Phase 2: Validation
Validate project meets platform requirements.

```bash
# Validate platform requirements
if ! bash scripts/validate-platform-requirements.sh $PROJECT_PATH $PLATFORM; then
    echo "ERROR: Project does not meet requirements for $PLATFORM"
    exit 1
fi
```

### Phase 3: Deploy
Deploy to selected platform.

```bash
# Deploy based on platform
case $PLATFORM in
    fastmcp-cloud)
        # Deploy to FastMCP Cloud
        fastmcp deploy
        ;;
    digitalocean)
        # Deploy to DigitalOcean
        doctl apps create --spec app.yaml
        ;;
    vercel)
        # Deploy to Vercel
        vercel deploy --prod
        ;;
    netlify)
        # Deploy to Netlify
        netlify deploy --prod
        ;;
    cloudflare-pages)
        # Deploy to Cloudflare Pages
        wrangler pages publish dist
        ;;
esac
```
```

---

## Integration Pattern 2: Validate Command

```markdown
<!-- /deployment:validate command -->
---
allowed-tools: Bash, Read
description: Validate project for deployment
---

# Validate Deployment

## Goal
Verify project is ready for deployment to target platform.

## Actions

```bash
# Detect recommended platform
PLATFORM=$(bash plugins/deployment/skills/platform-detection/scripts/recommend-platform.sh .)

# Run validation
echo "Validating for $PLATFORM..."
bash plugins/deployment/skills/platform-detection/scripts/validate-platform-requirements.sh . $PLATFORM

# Analyze deployment configuration
echo ""
echo "Configuration Analysis:"
bash plugins/deployment/skills/platform-detection/scripts/analyze-deployment-config.sh .
```
```

---

## Integration Pattern 3: Configure Command

```markdown
<!-- /deployment:configure command -->
---
allowed-tools: Task, Bash, Read, Write
description: Generate platform-specific configuration
---

# Configure Deployment

## Goal
Generate deployment configuration for detected platform.

## Actions

### Phase 1: Detect Platform

```bash
PLATFORM=$(bash plugins/deployment/skills/platform-detection/scripts/recommend-platform.sh .)
echo "Generating configuration for: $PLATFORM"
```

### Phase 2: Generate Configuration

```bash
# Load appropriate template
TEMPLATE="plugins/deployment/skills/platform-detection/templates/platform-config/${PLATFORM}.json"

if [ -f "$TEMPLATE" ]; then
    # Detect project details
    FRAMEWORK=$(bash plugins/deployment/skills/platform-detection/scripts/detect-framework.sh .)

    # Generate config from template
    # (Use template substitution logic here)
    cat "$TEMPLATE" | \
        sed "s/{{PROJECT_NAME}}/$(basename $PWD)/g" | \
        sed "s/{{FRAMEWORK}}/$FRAMEWORK/g" > "${PLATFORM}-config.json"

    echo "Created ${PLATFORM}-config.json"
else
    echo "No template found for $PLATFORM"
fi
```
```

---

## Integration Pattern 4: CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Auto-Deploy

on:
  push:
    branches: [main]

jobs:
  detect-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup detection tools
        run: |
          chmod +x deployment/skills/platform-detection/scripts/*.sh

      - name: Detect platform
        id: detect
        run: |
          PLATFORM=$(bash deployment/skills/platform-detection/scripts/recommend-platform.sh .)
          echo "platform=$PLATFORM" >> $GITHUB_OUTPUT
          echo "Detected platform: $PLATFORM"

      - name: Validate requirements
        run: |
          bash deployment/skills/platform-detection/scripts/validate-platform-requirements.sh . ${{ steps.detect.outputs.platform }}

      - name: Deploy to FastMCP Cloud
        if: steps.detect.outputs.platform == 'fastmcp-cloud'
        env:
          FASTMCP_TOKEN: ${{ secrets.FASTMCP_TOKEN }}
        run: |
          fastmcp deploy

      - name: Deploy to Vercel
        if: steps.detect.outputs.platform == 'vercel'
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
        run: |
          npx vercel deploy --prod --token=$VERCEL_TOKEN

      - name: Deploy to DigitalOcean
        if: steps.detect.outputs.platform == 'digitalocean'
        env:
          DO_TOKEN: ${{ secrets.DO_TOKEN }}
        run: |
          doctl auth init --access-token $DO_TOKEN
          doctl apps create --spec app.yaml

      - name: Deploy to Netlify
        if: steps.detect.outputs.platform == 'netlify'
        env:
          NETLIFY_TOKEN: ${{ secrets.NETLIFY_TOKEN }}
        run: |
          npx netlify deploy --prod --auth=$NETLIFY_TOKEN

      - name: Deploy to Cloudflare Pages
        if: steps.detect.outputs.platform == 'cloudflare-pages'
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        run: |
          npx wrangler pages publish dist
```

---

## Integration Pattern 5: Monorepo Deployment

### Multi-Service Detection and Deployment

```yaml
# .github/workflows/deploy-monorepo.yml
name: Deploy Monorepo

on:
  push:
    branches: [main]

jobs:
  detect-services:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}

    steps:
      - uses: actions/checkout@v3

      - name: Detect services
        id: set-matrix
        run: |
          # Create deployment matrix
          SERVICES=$(bash .github/scripts/detect-monorepo-services.sh)
          echo "matrix=$SERVICES" >> $GITHUB_OUTPUT

  deploy-services:
    needs: detect-services
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJson(needs.detect-services.outputs.matrix) }}

    steps:
      - uses: actions/checkout@v3

      - name: Deploy ${{ matrix.service }}
        run: |
          cd ${{ matrix.path }}

          # Detect platform for this service
          PLATFORM=$(bash ../../deployment/skills/platform-detection/scripts/recommend-platform.sh .)

          # Deploy to detected platform
          bash ../../deployment/scripts/deploy-to-platform.sh $PLATFORM
```

### Monorepo Detection Script

```bash
#!/bin/bash
# .github/scripts/detect-monorepo-services.sh

# Find all services in monorepo
SERVICES_JSON='{"include":['

for service_dir in apps/*/; do
    service_name=$(basename "$service_dir")

    # Detect platform for service
    platform=$(bash deployment/skills/platform-detection/scripts/recommend-platform.sh "$service_dir")

    # Add to matrix
    SERVICES_JSON+="{\"service\":\"$service_name\",\"path\":\"$service_dir\",\"platform\":\"$platform\"},"
done

# Close JSON
SERVICES_JSON="${SERVICES_JSON%,}]}"

echo "$SERVICES_JSON"
```

---

## Integration Pattern 6: Pre-commit Hook

### Validate Before Commit

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running deployment validation..."

# Detect platform
PLATFORM=$(bash deployment/skills/platform-detection/scripts/recommend-platform.sh .)

# Validate requirements
if ! bash deployment/skills/platform-detection/scripts/validate-platform-requirements.sh . "$PLATFORM" >/dev/null 2>&1; then
    echo "ERROR: Deployment validation failed for $PLATFORM"
    echo ""
    echo "Run the following to see details:"
    echo "  bash deployment/skills/platform-detection/scripts/validate-platform-requirements.sh . $PLATFORM"
    echo ""
    exit 1
fi

echo "✓ Deployment validation passed for $PLATFORM"
```

---

## Integration Pattern 7: Custom Deploy Script

### Comprehensive Deployment Wrapper

```bash
#!/bin/bash
# scripts/deploy.sh - Smart deployment script

set -euo pipefail

PROJECT_PATH="${1:-.}"
FORCE_PLATFORM="${2:-}"

# Change to project directory
cd "$PROJECT_PATH"

echo "╔════════════════════════════════════════╗"
echo "║     Smart Deployment Script            ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Step 1: Detection
echo "Step 1: Detecting project characteristics..."
PROJECT_TYPE=$(bash ../deployment/skills/platform-detection/scripts/detect-project-type.sh .)
FRAMEWORK=$(bash ../deployment/skills/platform-detection/scripts/detect-framework.sh .)

echo "  Type: $PROJECT_TYPE"
echo "  Framework: $FRAMEWORK"
echo ""

# Step 2: Platform Recommendation
echo "Step 2: Recommending platform..."
if [ -n "$FORCE_PLATFORM" ]; then
    PLATFORM="$FORCE_PLATFORM"
    echo "  Using forced platform: $PLATFORM"
else
    PLATFORM=$(bash ../deployment/skills/platform-detection/scripts/recommend-platform.sh .)
    echo "  Recommended platform: $PLATFORM"
fi
echo ""

# Step 3: Validation
echo "Step 3: Validating requirements..."
if bash ../deployment/skills/platform-detection/scripts/validate-platform-requirements.sh . "$PLATFORM"; then
    echo "  ✓ Validation passed"
else
    echo "  ✗ Validation failed"
    exit 1
fi
echo ""

# Step 4: Configuration Analysis
echo "Step 4: Analyzing configuration..."
CONFIG_ANALYSIS=$(bash ../deployment/skills/platform-detection/scripts/analyze-deployment-config.sh . 2>/dev/null)

HAS_DOCKER=$(echo "$CONFIG_ANALYSIS" | jq -r '.has_docker')
HAS_CI_CD=$(echo "$CONFIG_ANALYSIS" | jq -r '.has_ci_cd')

echo "  Docker: $HAS_DOCKER"
echo "  CI/CD: $HAS_CI_CD"
echo ""

# Step 5: Deploy
echo "Step 5: Deploying to $PLATFORM..."

case "$PLATFORM" in
    fastmcp-cloud)
        echo "  Running: fastmcp deploy"
        fastmcp deploy
        ;;

    digitalocean)
        if [ "$HAS_DOCKER" = "true" ]; then
            echo "  Using Docker deployment"
            doctl apps create --spec app.yaml
        else
            echo "  Using buildpack deployment"
            # Generate app.yaml from template
            bash ../deployment/scripts/generate-do-config.sh > app.yaml
            doctl apps create --spec app.yaml
        fi
        ;;

    vercel)
        echo "  Running: vercel deploy --prod"
        vercel deploy --prod
        ;;

    netlify)
        echo "  Running: netlify deploy --prod"
        netlify deploy --prod
        ;;

    cloudflare-pages)
        echo "  Running: wrangler pages publish"
        # Determine output directory
        if [ -d "dist" ]; then
            OUTPUT_DIR="dist"
        elif [ -d "build" ]; then
            OUTPUT_DIR="build"
        elif [ -d ".next" ]; then
            OUTPUT_DIR=".next"
        else
            echo "ERROR: Cannot determine output directory"
            exit 1
        fi
        wrangler pages publish "$OUTPUT_DIR"
        ;;

    multiple-platforms)
        echo "ERROR: Monorepo detected"
        echo "Deploy each service independently:"
        for service_dir in apps/*/; do
            service_name=$(basename "$service_dir")
            service_platform=$(bash ../deployment/skills/platform-detection/scripts/recommend-platform.sh "$service_dir")
            echo "  $service_name -> $service_platform"
        done
        exit 1
        ;;

    *)
        echo "ERROR: Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

echo ""
echo "╔════════════════════════════════════════╗"
echo "║     Deployment Successful!             ║"
echo "╚════════════════════════════════════════╝"
```

---

## Integration with Deployment Agents

### Using Detection in Agents

```markdown
<!-- deployment-agent.md -->
You are the deployment agent.

When deploying projects:

1. **Always use platform-detection skill first**:
   ```bash
   bash plugins/deployment/skills/platform-detection/scripts/recommend-platform.sh <path>
   ```

2. **Validate before deploying**:
   ```bash
   bash plugins/deployment/skills/platform-detection/scripts/validate-platform-requirements.sh <path> <platform>
   ```

3. **Analyze configuration**:
   ```bash
   bash plugins/deployment/skills/platform-detection/scripts/analyze-deployment-config.sh <path>
   ```

4. **Use detection results to inform deployment strategy**
```

---

## Environment Variable Management

### Detection-Based Environment Setup

```bash
#!/bin/bash
# scripts/setup-env.sh

PLATFORM=$(bash deployment/skills/platform-detection/scripts/recommend-platform.sh .)

# Platform-specific environment variables
case "$PLATFORM" in
    vercel)
        cat > .env.production <<EOF
NEXT_PUBLIC_API_URL=\${VERCEL_URL}
NEXT_PUBLIC_ENV=production
EOF
        ;;

    digitalocean)
        cat > .env.production <<EOF
API_URL=\${APP_URL}
PORT=8080
EOF
        ;;

    netlify)
        cat > .env.production <<EOF
URL=\${URL}
DEPLOY_URL=\${DEPLOY_URL}
EOF
        ;;
esac

echo "Created .env.production for $PLATFORM"
```

---

## Testing Integration

### Integration Tests

```bash
#!/bin/bash
# tests/test-deployment-integration.sh

test_fastmcp_deployment() {
    cd fixtures/fastmcp-server

    # Should detect MCP server
    TYPE=$(bash ../../scripts/detect-project-type.sh .)
    [ "$TYPE" = "mcp-server" ] || exit 1

    # Should recommend FastMCP Cloud
    PLATFORM=$(bash ../../scripts/recommend-platform.sh .)
    [ "$PLATFORM" = "fastmcp-cloud" ] || exit 1

    # Should pass validation
    bash ../../scripts/validate-platform-requirements.sh . "$PLATFORM" || exit 1

    echo "✓ FastMCP deployment test passed"
}

test_nextjs_deployment() {
    cd fixtures/nextjs-app

    TYPE=$(bash ../../scripts/detect-project-type.sh .)
    [ "$TYPE" = "frontend" ] || exit 1

    PLATFORM=$(bash ../../scripts/recommend-platform.sh .)
    [ "$PLATFORM" = "vercel" ] || exit 1

    bash ../../scripts/validate-platform-requirements.sh . "$PLATFORM" || exit 1

    echo "✓ Next.js deployment test passed"
}

# Run all tests
test_fastmcp_deployment
test_nextjs_deployment

echo ""
echo "All integration tests passed!"
```

---

## Next Steps

- See `basic-detection.md` for detection examples
- See `platform-recommendation-flow.md` for recommendation logic
- See `error-handling.md` for troubleshooting integration issues
- See `/deployment:deploy` command for live integration
