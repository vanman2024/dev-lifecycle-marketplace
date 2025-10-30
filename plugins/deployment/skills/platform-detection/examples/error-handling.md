# Error Handling and Edge Cases

This document covers common errors, edge cases, and troubleshooting strategies for platform detection.

## Common Errors

### Error 1: "unknown" Project Type

**Symptoms**:
```bash
$ bash detect-project-type.sh .
unknown
```

**Causes**:
1. No recognizable configuration files
2. Project in initial setup phase
3. Unusual project structure
4. Required files in non-standard locations

**Solutions**:

**Solution 1: Add Configuration Files**
```bash
# For MCP server
cat > .mcp.json <<EOF
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["dist/index.js"]
    }
  }
}
EOF

# Rerun detection
bash detect-project-type.sh .
# Should now return: mcp-server
```

**Solution 2: Add Dependencies**
```bash
# For Node.js project
npm init -y
npm install express

# Rerun detection
bash detect-project-type.sh .
# Should now return: api
```

**Solution 3: Manual Override**
```bash
# Force project type
PROJECT_TYPE="api"
PLATFORM=$(bash recommend-platform.sh .)
```

---

### Error 2: Wrong Framework Detected

**Symptoms**:
```bash
$ bash detect-framework.sh .
React 18.2.0
# Expected: Next.js 14.2.0
```

**Cause**: Next.js includes React, but detection prioritizes less specific framework

**Solution**: Check detection priority in `framework-signatures.json`

**Debug**:
```bash
# Verify Next.js config exists
ls -la next.config.*

# If missing, create it
cat > next.config.js <<EOF
/** @type {import('next').NextConfig} */
const nextConfig = {};
module.exports = nextConfig;
EOF

# Rerun detection
bash detect-framework.sh .
# Should now return: Next.js
```

---

### Error 3: Validation Fails for Recommended Platform

**Symptoms**:
```bash
$ bash validate-platform-requirements.sh . vercel
ERROR: No package.json found - Vercel requires Node.js project
RESULT: FAILED - Fix errors before deploying
```

**Cause**: Platform requirements not met

**Solution**: Fix missing requirements

**For Vercel**:
```bash
# Create package.json
npm init -y

# Add build script
npm pkg set scripts.build="next build"

# Revalidate
bash validate-platform-requirements.sh . vercel
# Should now pass
```

**For DigitalOcean**:
```bash
# Option 1: Add Dockerfile
cat > Dockerfile <<EOF
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
CMD ["npm", "start"]
EOF

# Option 2: Add buildpack compatibility
npm pkg set scripts.start="node server.js"

# Revalidate
bash validate-platform-requirements.sh . digitalocean
```

---

### Error 4: Multiple Platforms Score Equally

**Symptoms**:
```bash
# Debug mode shows tie
DEBUG=1 bash recommend-platform.sh .
# Vercel: 175
# Netlify: 175
```

**Cause**: Both platforms equally suitable

**Resolution**: Tiebreaker uses priority (Vercel wins as Priority 1)

**Manual Selection**:
```bash
# Review both options
echo "Vercel: Priority 1, excellent Next.js support"
echo "Netlify: Priority 2, great build tools"

# Choose based on needs
PLATFORM="vercel"  # or "netlify"
```

---

## Edge Cases

### Edge Case 1: Partial Configuration

**Scenario**: Project has some config files but incomplete

**Example**:
```bash
# Has package.json but no dependencies
cat package.json
{
  "name": "my-app",
  "version": "1.0.0"
}
```

**Detection Result**: `unknown`

**Fix**:
```bash
# Install framework
npm install next react react-dom

# Or specify manually in package.json
npm pkg set dependencies.next="14.2.0"
npm pkg set dependencies.react="18.2.0"

# Rerun detection
bash detect-framework.sh .
```

---

### Edge Case 2: Mixed Project (Frontend + API)

**Scenario**: Single repo with both frontend and backend

**Structure**:
```
project/
├── package.json (Next.js dependencies)
├── app/
│   └── page.tsx
└── pages/api/
    └── hello.ts
```

**Detection Result**:
- Type: `frontend`
- Framework: `Next.js`
- Platform: `vercel`

**Reasoning**: Vercel handles both Next.js frontend and API routes

**Alternative**: Separate backend

```
project/
├── frontend/
│   ├── package.json (Next.js)
│   └── app/
└── backend/
    ├── package.json (Express)
    └── src/
```

**Detection**: Run separately for each
```bash
bash detect-project-type.sh frontend  # frontend
bash detect-project-type.sh backend   # api
```

---

### Edge Case 3: Legacy Framework Versions

**Scenario**: Old framework version not in signatures

**Example**:
```json
{
  "dependencies": {
    "next": "9.0.0"  // Very old version
  }
}
```

**Detection**: Still detects as Next.js (version-agnostic)

**Platform Recommendation**: May still recommend Vercel

**Consideration**: Check platform compatibility
```bash
# Vercel may not support Next.js 9
# Consider upgrading or using DigitalOcean with Docker
```

---

### Edge Case 4: Custom MCP Implementation

**Scenario**: MCP server without FastMCP

**Structure**:
```
custom-mcp/
├── .mcp.json
├── package.json (no fastmcp)
└── src/
    └── server.ts (custom MCP implementation)
```

**Detection**:
- Type: `mcp-server` (has .mcp.json)
- Framework: `unknown` (no fastmcp)
- Platform: `digitalocean` (fallback for custom MCP)

**Validation**:
```bash
bash validate-platform-requirements.sh . digitalocean
# Recommend adding Dockerfile for custom implementation
```

---

### Edge Case 5: Monorepo with Inconsistent Structure

**Scenario**: Services in different locations

**Structure**:
```
monorepo/
├── pnpm-workspace.yaml
├── apps/
│   └── web/
├── services/
│   └── api/
└── packages/
    └── shared/
```

**Detection**:
- Root: `monorepo`
- Recommendation: `multiple-platforms`

**Solution**: Analyze each service path
```bash
# Create service map
declare -A SERVICES
SERVICES[web]="apps/web"
SERVICES[api]="services/api"

for name in "${!SERVICES[@]}"; do
    path="${SERVICES[$name]}"
    platform=$(bash recommend-platform.sh "$path")
    echo "$name ($path) -> $platform"
done
```

---

### Edge Case 6: No Build Script

**Scenario**: Frontend project without build script

**package.json**:
```json
{
  "name": "my-app",
  "dependencies": {
    "react": "18.2.0"
  }
  // No "scripts" field
}
```

**Detection**: Works (detects React)

**Validation Issue**: Platforms may fail without build script

**Fix**:
```bash
# Add build script
npm pkg set scripts.build="vite build"
npm pkg set scripts.dev="vite"
npm pkg set scripts.preview="vite preview"

# Install build tool if missing
npm install -D vite @vitejs/plugin-react
```

---

## Ambiguous Scenarios

### Scenario 1: Static Site with Build Process

**Question**: Is it `static-site` or `frontend`?

**Detection Logic**:
- Has package.json + framework → `frontend`
- No package.json + HTML → `static-site`

**Example**:
```bash
# Gatsby site
# Has package.json + gatsby
# Type: frontend (not static-site)

# Pure HTML site
# No package.json
# Type: static-site
```

---

### Scenario 2: API with Frontend Features

**Question**: Express serving React - API or Frontend?

**Detection Logic**: Prioritizes primary purpose

**Example**:
```javascript
// Express serving static React build
app.use(express.static('build'));
app.get('/api/*', apiRoutes);
```

**If**:
- API routes dominate → Type: `api`
- React routes dominate → Type: `frontend`

**Detection**: Checks `routes/` vs `app/pages/` directories

---

## Debugging Tools

### Debug Mode

Enable detailed logging:

```bash
# Enable debug output
DEBUG=1 bash detect-project-type.sh .

# Output shows scoring:
# === Detection Scores ===
# mcp-server: 18
# api: 7
# frontend: 0
# static-site: 0
# monorepo: 0
# Selected: mcp-server (score: 18)
```

### Manual Inspection Script

```bash
#!/bin/bash
# inspect-project.sh - Manual project inspection

echo "=== Project Inspection ==="
echo ""

echo "Configuration Files:"
ls -la | grep -E "\.json|\.yaml|\.toml|\.config\." | awk '{print "  " $9}'

echo ""
echo "Package Managers:"
[ -f "package.json" ] && echo "  ✓ npm/yarn/pnpm (package.json)"
[ -f "requirements.txt" ] && echo "  ✓ pip (requirements.txt)"
[ -f "pyproject.toml" ] && echo "  ✓ poetry (pyproject.toml)"
[ -f "Gemfile" ] && echo "  ✓ bundler (Gemfile)"

echo ""
echo "Frameworks (from package.json):"
if [ -f "package.json" ]; then
    grep -E "next|react|vue|astro|express|fastify" package.json | \
        sed 's/^[[:space:]]*/  /'
fi

echo ""
echo "Frameworks (from requirements.txt):"
if [ -f "requirements.txt" ]; then
    grep -E "fastapi|flask|django|fastmcp" requirements.txt | \
        sed 's/^/  /'
fi

echo ""
echo "Directory Structure:"
ls -d */ 2>/dev/null | sed 's/^/  /'

echo ""
echo "Containerization:"
[ -f "Dockerfile" ] && echo "  ✓ Dockerfile"
[ -f "docker-compose.yml" ] && echo "  ✓ docker-compose.yml"
[ -f ".dockerignore" ] && echo "  ✓ .dockerignore"
```

---

## Fallback Strategies

### Strategy 1: Default to DigitalOcean

When detection fails completely:

```bash
PROJECT_TYPE=$(bash detect-project-type.sh .)

if [ "$PROJECT_TYPE" = "unknown" ]; then
    echo "Detection failed, defaulting to DigitalOcean"
    PLATFORM="digitalocean"
    echo "Reason: DigitalOcean supports containerized apps (add Dockerfile)"
fi
```

### Strategy 2: Ask User

Interactive selection:

```bash
#!/bin/bash
# interactive-platform-selection.sh

AUTO=$(bash recommend-platform.sh .)

if [ "$AUTO" = "unknown" ] || [ "$AUTO" = "multiple-platforms" ]; then
    echo "Automatic detection inconclusive"
    echo "Please select platform:"
    echo "1) FastMCP Cloud"
    echo "2) DigitalOcean"
    echo "3) Vercel"
    echo "4) Netlify"
    echo "5) Cloudflare Pages"

    read -p "Selection: " choice

    case $choice in
        1) PLATFORM="fastmcp-cloud" ;;
        2) PLATFORM="digitalocean" ;;
        3) PLATFORM="vercel" ;;
        4) PLATFORM="netlify" ;;
        5) PLATFORM="cloudflare-pages" ;;
        *) echo "Invalid selection"; exit 1 ;;
    esac
else
    PLATFORM="$AUTO"
fi

echo "Selected platform: $PLATFORM"
```

### Strategy 3: Multi-Platform Support

Deploy to multiple platforms:

```bash
#!/bin/bash
# multi-platform-deploy.sh

# Try primary recommendation
PRIMARY=$(bash recommend-platform.sh .)

# Define fallback
FALLBACK="digitalocean"

echo "Deploying to $PRIMARY"
if ! deploy_to_platform "$PRIMARY"; then
    echo "Primary deployment failed, trying $FALLBACK"
    deploy_to_platform "$FALLBACK"
fi
```

---

## Next Steps

- See `basic-detection.md` for successful detection examples
- See `platform-recommendation-flow.md` for scoring details
- See `integration-with-deploy-commands.md` for handling errors in automation
