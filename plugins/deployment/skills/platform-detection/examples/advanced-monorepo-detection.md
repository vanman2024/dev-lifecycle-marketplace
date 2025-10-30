# Advanced Monorepo Detection

This document demonstrates platform detection for complex monorepo projects with multiple services requiring different deployment strategies.

## Example 1: Full-Stack Monorepo (API + Frontend)

### Project Structure
```
my-fullstack-app/
├── pnpm-workspace.yaml
├── package.json
├── apps/
│   ├── api/
│   │   ├── package.json
│   │   ├── src/
│   │   └── Dockerfile
│   └── web/
│       ├── package.json
│       ├── next.config.js
│       └── app/
├── packages/
│   ├── shared/
│   └── ui/
└── README.md
```

### pnpm-workspace.yaml
```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### apps/api/package.json
```json
{
  "name": "@myapp/api",
  "dependencies": {
    "express": "^4.18.0",
    "@myapp/shared": "workspace:*"
  }
}
```

### apps/web/package.json
```json
{
  "name": "@myapp/web",
  "dependencies": {
    "next": "14.2.0",
    "react": "18.2.0",
    "@myapp/shared": "workspace:*"
  }
}
```

### Detection Workflow

```bash
# Step 1: Detect root project type
cd my-fullstack-app
ROOT_TYPE=$(bash /path/to/detect-project-type.sh .)
echo "Root Type: $ROOT_TYPE"
# Output: monorepo

# Step 2: Analyze each service independently
echo "Analyzing API service..."
API_TYPE=$(bash /path/to/detect-project-type.sh apps/api)
API_FRAMEWORK=$(bash /path/to/detect-framework.sh apps/api)
API_PLATFORM=$(bash /path/to/recommend-platform.sh apps/api)

echo "API Results:"
echo "  Type: $API_TYPE"
echo "  Framework: $API_FRAMEWORK"
echo "  Platform: $API_PLATFORM"

echo ""
echo "Analyzing Web service..."
WEB_TYPE=$(bash /path/to/detect-project-type.sh apps/web)
WEB_FRAMEWORK=$(bash /path/to/detect-framework.sh apps/web)
WEB_PLATFORM=$(bash /path/to/recommend-platform.sh apps/web)

echo "Web Results:"
echo "  Type: $WEB_TYPE"
echo "  Framework: $WEB_FRAMEWORK"
echo "  Platform: $WEB_PLATFORM"
```

### Expected Results

**Root Level**:
- Type: `monorepo`
- Recommendation: `multiple-platforms`

**API Service**:
- Type: `api`
- Framework: `Express`
- Platform: `digitalocean` (has Dockerfile)

**Web Service**:
- Type: `frontend`
- Framework: `Next.js 14.2.0`
- Platform: `vercel`

### Deployment Strategy
```bash
#!/bin/bash
# deploy-monorepo.sh - Deploy all services

# Deploy API to DigitalOcean
cd apps/api
doctl apps create --spec digitalocean-app.yaml

# Deploy Web to Vercel
cd ../web
vercel deploy --prod

echo "Deployment complete!"
echo "API: https://api.myapp.com"
echo "Web: https://myapp.com"
```

---

## Example 2: Multi-MCP Server Monorepo

### Project Structure
```
mcp-servers/
├── pnpm-workspace.yaml
├── servers/
│   ├── calculator/
│   │   ├── .mcp.json
│   │   ├── package.json
│   │   └── src/
│   ├── database/
│   │   ├── .mcp.json
│   │   ├── package.json
│   │   └── src/
│   └── filesystem/
│       ├── .mcp.json
│       ├── package.json
│       └── src/
└── shared/
    └── types/
```

### Detection Script
```bash
#!/bin/bash
# analyze-mcp-monorepo.sh

SERVERS_DIR="servers"

echo "=== MCP Monorepo Analysis ==="
echo ""

# Iterate over each server
for server_dir in $SERVERS_DIR/*/; do
    server_name=$(basename "$server_dir")
    echo "Analyzing: $server_name"

    type=$(bash detect-project-type.sh "$server_dir")
    framework=$(bash detect-framework.sh "$server_dir")
    platform=$(bash recommend-platform.sh "$server_dir")

    echo "  Type: $type"
    echo "  Framework: $framework"
    echo "  Platform: $platform"

    # Validate for FastMCP Cloud
    echo "  Validation:"
    bash validate-platform-requirements.sh "$server_dir" "$platform" 2>&1 | sed 's/^/    /'
    echo ""
done
```

### Expected Output
```
=== MCP Monorepo Analysis ===

Analyzing: calculator
  Type: mcp-server
  Framework: FastMCP (TypeScript) 1.0.0
  Platform: fastmcp-cloud
  Validation:
    === Validating for FastMCP Cloud ===
    ✓ Found: .mcp.json
    ✓ Found FastMCP dependency
    ✓ Found: README.md

    === Validation Summary ===
    Errors: 0
    Warnings: 0
    RESULT: PASSED - Ready for deployment

Analyzing: database
  Type: mcp-server
  Framework: FastMCP (TypeScript) 1.0.0
  Platform: fastmcp-cloud
  Validation:
    === Validating for FastMCP Cloud ===
    ✓ Found: .mcp.json
    ✓ Found FastMCP dependency
    ✓ Found: README.md

    === Validation Summary ===
    Errors: 0
    Warnings: 0
    RESULT: PASSED - Ready for deployment

Analyzing: filesystem
  Type: mcp-server
  Framework: FastMCP (TypeScript) 1.0.0
  Platform: fastmcp-cloud
  Validation:
    === Validating for FastMCP Cloud ===
    ✓ Found: .mcp.json
    ✓ Found FastMCP dependency
    WARNING: Missing optional file: .env.example

    === Validation Summary ===
    Errors: 0
    Warnings: 1
    RESULT: PASSED with warnings - Review warnings before deploying
```

---

## Example 3: Mixed Python/Node.js Monorepo

### Project Structure
```
mixed-services/
├── services/
│   ├── api-python/
│   │   ├── requirements.txt
│   │   ├── main.py
│   │   └── Dockerfile
│   ├── api-node/
│   │   ├── package.json
│   │   ├── src/
│   │   └── Dockerfile
│   └── frontend/
│       ├── package.json
│       ├── astro.config.mjs
│       └── src/
└── docker-compose.yml
```

### Comprehensive Analysis Script
```bash
#!/bin/bash
# comprehensive-analysis.sh

analyze_service() {
    local service_path="$1"
    local service_name=$(basename "$service_path")

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Service: $service_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Detection
    type=$(bash detect-project-type.sh "$service_path")
    framework=$(bash detect-framework.sh "$service_path")
    platform=$(bash recommend-platform.sh "$service_path")

    echo "Detection Results:"
    echo "  Type: $type"
    echo "  Framework: $framework"
    echo "  Platform: $platform"
    echo ""

    # Configuration analysis
    echo "Configuration Analysis:"
    bash analyze-deployment-config.sh "$service_path" 2>&1 | grep -E "^(✓|⚠|---)" | sed 's/^/  /'
    echo ""

    # Platform validation
    echo "Platform Validation for $platform:"
    if bash validate-platform-requirements.sh "$service_path" "$platform" >/dev/null 2>&1; then
        echo "  ✓ PASSED"
    else
        echo "  ✗ FAILED - Review requirements"
    fi
    echo ""
}

# Main execution
echo "╔════════════════════════════════════════╗"
echo "║   Mixed Services Monorepo Analysis    ║"
echo "╚════════════════════════════════════════╝"
echo ""

for service_dir in services/*/; do
    analyze_service "$service_dir"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Analysis Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Expected Results

**api-python**:
- Type: `api`
- Framework: `FastAPI`
- Platform: `digitalocean`
- Has Docker: ✓

**api-node**:
- Type: `api`
- Framework: `Express`
- Platform: `digitalocean`
- Has Docker: ✓

**frontend**:
- Type: `frontend`
- Framework: `Astro`
- Platform: `vercel`
- Has Docker: ✗

---

## Advanced Patterns

### Pattern 1: Parallel Service Analysis
```bash
#!/bin/bash
# parallel-analyze.sh

analyze_service() {
    local dir="$1"
    local name=$(basename "$dir")

    {
        echo "$name"
        bash detect-project-type.sh "$dir"
        bash detect-framework.sh "$dir"
        bash recommend-platform.sh "$dir"
    } | paste -sd '|'
}

export -f analyze_service

# Parallel execution
find services -maxdepth 1 -mindepth 1 -type d | \
    xargs -I {} -P 4 bash -c 'analyze_service "$@"' _ {} | \
    column -t -s '|' -N "Service,Type,Framework,Platform"
```

### Pattern 2: Deployment Matrix Generation
```bash
#!/bin/bash
# generate-deployment-matrix.sh

cat > deployment-matrix.json <<'EOF'
{
  "services": []
}
EOF

for service_dir in apps/*/; do
    name=$(basename "$service_dir")
    type=$(bash detect-project-type.sh "$service_dir")
    platform=$(bash recommend-platform.sh "$service_dir")

    # Add to matrix (simplified - use jq for production)
    cat >> deployment-matrix.json <<EOF
  {
    "name": "$name",
    "type": "$type",
    "platform": "$platform",
    "path": "$service_dir"
  },
EOF
done

# Use this matrix in CI/CD
echo "Deployment matrix generated: deployment-matrix.json"
```

### Pattern 3: Service Dependency Graph
```bash
#!/bin/bash
# analyze-dependencies.sh

# Map service dependencies and deployment order
echo "Service Deployment Order:"
echo ""
echo "1. Shared packages (build first)"
echo "2. Backend APIs (deploy second)"
echo "3. Frontend apps (deploy last)"
echo ""

echo "Dependencies detected:"
for service_dir in apps/*/; do
    name=$(basename "$service_dir")

    if [ -f "$service_dir/package.json" ]; then
        deps=$(grep "workspace:" "$service_dir/package.json" | wc -l)
        echo "  $name: $deps workspace dependencies"
    fi
done
```

---

## CI/CD Integration

### GitHub Actions Workflow
```yaml
name: Deploy Monorepo

on:
  push:
    branches: [main]

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      services: ${{ steps.detect.outputs.services }}
    steps:
      - uses: actions/checkout@v3

      - name: Detect changed services
        id: detect
        run: |
          # Use detection scripts to build deployment plan
          bash .github/scripts/detect-monorepo-changes.sh

  deploy:
    needs: detect-changes
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: ${{ fromJson(needs.detect-changes.outputs.services) }}
    steps:
      - name: Deploy ${{ matrix.service }}
        run: |
          platform=$(bash scripts/recommend-platform.sh "apps/${{ matrix.service }}")
          bash scripts/deploy-to-platform.sh "${{ matrix.service }}" "$platform"
```

---

## Best Practices

1. **Service Isolation**: Analyze each service independently
2. **Validation**: Always validate before deployment
3. **Documentation**: Keep deployment matrix updated
4. **Automation**: Use scripts for consistent analysis
5. **Monitoring**: Track deployment status per service

---

## Next Steps

- See `platform-recommendation-flow.md` for detailed recommendation logic
- See `integration-with-deploy-commands.md` for automated deployment
- See `error-handling.md` for troubleshooting complex scenarios
