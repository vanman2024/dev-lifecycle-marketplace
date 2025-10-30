# Basic Detection Examples

This document demonstrates basic platform detection workflows for common single-service projects.

## Example 1: FastMCP Server Detection

### Project Structure
```
my-mcp-server/
├── .mcp.json
├── package.json
├── src/
│   ├── index.ts
│   └── tools/
│       └── calculator.ts
└── README.md
```

### package.json
```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "dependencies": {
    "fastmcp": "^1.0.0"
  }
}
```

### Detection Workflow
```bash
# Step 1: Detect project type
cd my-mcp-server
PROJECT_TYPE=$(bash /path/to/detect-project-type.sh .)
echo "Project Type: $PROJECT_TYPE"
# Output: mcp-server

# Step 2: Detect framework
FRAMEWORK=$(bash /path/to/detect-framework.sh .)
echo "Framework: $FRAMEWORK"
# Output: FastMCP (TypeScript) 1.0.0

# Step 3: Recommend platform
PLATFORM=$(bash /path/to/recommend-platform.sh .)
echo "Recommended Platform: $PLATFORM"
# Output: fastmcp-cloud
```

### Expected Results
- **Project Type**: `mcp-server`
- **Framework**: `FastMCP (TypeScript)`
- **Recommended Platform**: `fastmcp-cloud`
- **Reasoning**: FastMCP Cloud is optimized for FastMCP servers

---

## Example 2: Next.js Frontend Detection

### Project Structure
```
my-nextjs-app/
├── next.config.js
├── package.json
├── app/
│   ├── layout.tsx
│   └── page.tsx
├── public/
└── README.md
```

### package.json
```json
{
  "name": "my-nextjs-app",
  "version": "0.1.0",
  "dependencies": {
    "next": "14.2.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "scripts": {
    "build": "next build",
    "start": "next start"
  }
}
```

### Detection Workflow
```bash
# Complete detection
cd my-nextjs-app
PROJECT_TYPE=$(bash /path/to/detect-project-type.sh .)
FRAMEWORK=$(bash /path/to/detect-framework.sh .)
PLATFORM=$(bash /path/to/recommend-platform.sh .)

echo "Results:"
echo "  Type: $PROJECT_TYPE"
echo "  Framework: $FRAMEWORK"
echo "  Platform: $PLATFORM"
```

### Expected Results
- **Project Type**: `frontend`
- **Framework**: `Next.js 14.2.0`
- **Recommended Platform**: `vercel`
- **Reasoning**: Vercel is built by the Next.js team

---

## Example 3: FastAPI Backend Detection

### Project Structure
```
my-api/
├── requirements.txt
├── main.py
├── routers/
│   ├── __init__.py
│   ├── users.py
│   └── items.py
└── README.md
```

### requirements.txt
```
fastapi==0.110.0
uvicorn==0.27.0
pydantic==2.6.0
```

### main.py
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello World"}
```

### Detection Workflow
```bash
cd my-api

# Run detection
PROJECT_TYPE=$(bash /path/to/detect-project-type.sh .)
FRAMEWORK=$(bash /path/to/detect-framework.sh .)
PLATFORM=$(bash /path/to/recommend-platform.sh .)

# Validate for recommended platform
bash /path/to/validate-platform-requirements.sh . "$PLATFORM"
```

### Expected Results
- **Project Type**: `api`
- **Framework**: `FastAPI 0.110.0`
- **Recommended Platform**: `digitalocean`
- **Validation**: Should pass with warnings about optional files

---

## Example 4: Static Site Detection

### Project Structure
```
my-static-site/
├── index.html
├── css/
│   └── styles.css
├── js/
│   └── app.js
└── images/
    └── logo.png
```

### Detection Workflow
```bash
cd my-static-site

# Detection
PROJECT_TYPE=$(bash /path/to/detect-project-type.sh .)
FRAMEWORK=$(bash /path/to/detect-framework.sh .)
PLATFORM=$(bash /path/to/recommend-platform.sh .)

echo "Type: $PROJECT_TYPE"
echo "Framework: $FRAMEWORK"
echo "Platform: $PLATFORM"
```

### Expected Results
- **Project Type**: `static-site`
- **Framework**: `unknown` (no framework)
- **Recommended Platform**: `cloudflare-pages`
- **Reasoning**: Simple static site benefits from global CDN

---

## Example 5: Astro Site Detection

### Project Structure
```
my-astro-site/
├── astro.config.mjs
├── package.json
├── src/
│   ├── pages/
│   │   └── index.astro
│   └── components/
│       └── Header.astro
└── public/
```

### astro.config.mjs
```javascript
import { defineConfig } from 'astro/config';

export default defineConfig({
  output: 'static'
});
```

### Detection Workflow
```bash
cd my-astro-site

# Full workflow with debug output
DEBUG=1 PROJECT_TYPE=$(bash /path/to/detect-project-type.sh .)
DEBUG=1 FRAMEWORK=$(bash /path/to/detect-framework.sh .)
PLATFORM=$(bash /path/to/recommend-platform.sh .)
```

### Expected Results
- **Project Type**: `frontend`
- **Framework**: `Astro` (with version from package.json)
- **Recommended Platform**: `vercel`
- **Alternative Platforms**: `netlify`, `cloudflare-pages`

---

## Common Patterns

### Pattern 1: Quick Type Detection
```bash
# Just get the project type
bash detect-project-type.sh /path/to/project
```

### Pattern 2: Full Detection Pipeline
```bash
#!/bin/bash
PROJECT_DIR="$1"

TYPE=$(bash detect-project-type.sh "$PROJECT_DIR")
FRAMEWORK=$(bash detect-framework.sh "$PROJECT_DIR")
PLATFORM=$(bash recommend-platform.sh "$PROJECT_DIR")

echo "Project Analysis:"
echo "  Type: $TYPE"
echo "  Framework: $FRAMEWORK"
echo "  Recommended: $PLATFORM"
```

### Pattern 3: Conditional Deployment
```bash
#!/bin/bash
PLATFORM=$(bash recommend-platform.sh .)

case "$PLATFORM" in
  fastmcp-cloud)
    echo "Deploying to FastMCP Cloud..."
    # Deploy to FastMCP Cloud
    ;;
  vercel)
    echo "Deploying to Vercel..."
    vercel deploy --prod
    ;;
  digitalocean)
    echo "Deploying to DigitalOcean..."
    doctl apps create --spec app.yaml
    ;;
esac
```

---

## Troubleshooting

### Issue: "unknown" Project Type
**Cause**: No clear indicators found
**Solution**: Add configuration files (.mcp.json for MCP, package.json for Node, etc.)

### Issue: Wrong Framework Detected
**Cause**: Multiple frameworks present
**Solution**: Detection prioritizes more specific frameworks (e.g., Next.js over React)

### Issue: Validation Fails
**Cause**: Missing required files for platform
**Solution**: Review validation output and add missing files

---

## Next Steps

- See `advanced-monorepo-detection.md` for complex multi-service projects
- See `platform-recommendation-flow.md` for detailed recommendation logic
- See `integration-with-deploy-commands.md` for automated deployment workflows
