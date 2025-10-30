# Project.json Generation - Complete Configuration Guide

This example demonstrates the complete workflow for generating and managing `.claude/project.json` files.

## Overview

The `project.json` file is the central configuration for Claude Code to understand your project's tech stack, dependencies, and structure.

## Basic Generation

### Single Command

```bash
bash scripts/generate-project-json.sh /path/to/project
```

This command:
1. Detects all frameworks
2. Analyzes all dependencies
3. Discovers AI stack components
4. Detects databases and ORMs
5. Determines build tools and test frameworks
6. Generates `.claude/project.json`

## Understanding project.json Structure

### Complete Example

```json
{
  "name": "my-fullstack-app",
  "version": "1.0.0",
  "description": "Auto-detected project configuration",
  "language": "typescript",
  "package_manager": "pnpm",
  "frameworks": [
    {
      "name": "Next.js",
      "version": "^14.0.0",
      "confidence": "high",
      "evidence": "next.config.js"
    },
    {
      "name": "React",
      "version": "^18.2.0",
      "confidence": "high",
      "evidence": "package.json"
    }
  ],
  "dependencies": {
    "production": [...],
    "development": [...],
    "all": [...]
  },
  "ai_stack": [
    {
      "name": "Vercel AI SDK",
      "type": "sdk",
      "version": "^3.0.0",
      "evidence": "package.json"
    },
    {
      "name": "Anthropic SDK (TypeScript)",
      "type": "sdk",
      "version": "unknown",
      "evidence": "source files"
    }
  ],
  "databases": [
    {
      "name": "Supabase",
      "type": "database-service",
      "version": "^2.38.0",
      "evidence": "package.json"
    },
    {
      "name": "Prisma",
      "type": "orm",
      "version": "^5.7.0",
      "evidence": "prisma/schema.prisma"
    }
  ],
  "build_tools": ["vite"],
  "test_frameworks": ["vitest", "playwright"],
  "metadata": {
    "detected_at": "2025-10-28T21:00:00Z",
    "detection_version": "1.0.0",
    "project_path": "/path/to/project"
  }
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Project name (from directory or package.json) |
| `version` | string | Project version |
| `description` | string | Project description |
| `language` | string | Primary programming language |
| `package_manager` | string | Package manager (npm, yarn, pnpm, bun) |
| `frameworks` | array | Detected frameworks with versions |
| `dependencies` | object | Categorized dependencies |
| `ai_stack` | array | AI/ML components |
| `databases` | array | Databases and ORMs |
| `build_tools` | array | Build tools and bundlers |
| `test_frameworks` | array | Testing frameworks |
| `metadata` | object | Detection metadata |

## Generation Workflows

### Workflow 1: New Project Setup

```bash
#!/bin/bash
# setup-new-project.sh

PROJECT_PATH="${1:-.}"

echo "=== Setting up project detection ==="

# Step 1: Initialize .claude directory
mkdir -p "$PROJECT_PATH/.claude"

# Step 2: Run detection
bash scripts/generate-project-json.sh "$PROJECT_PATH"

# Step 3: Validate
bash scripts/validate-detection.sh "$PROJECT_PATH"

# Step 4: Add to git
cd "$PROJECT_PATH"
git add .claude/project.json
git commit -m "Add project detection configuration"

echo "✓ Project detection configured!"
```

### Workflow 2: Update Existing Configuration

```bash
#!/bin/bash
# update-project-config.sh

PROJECT_PATH="${1:-.}"

if [ ! -f "$PROJECT_PATH/.claude/project.json" ]; then
    echo "No existing configuration found"
    exit 1
fi

# Backup existing
cp "$PROJECT_PATH/.claude/project.json" "$PROJECT_PATH/.claude/project.json.backup"

# Regenerate
bash scripts/generate-project-json.sh "$PROJECT_PATH"

# Show diff
echo "=== Configuration Changes ==="
diff "$PROJECT_PATH/.claude/project.json.backup" "$PROJECT_PATH/.claude/project.json" || true

# Validate
bash scripts/validate-detection.sh "$PROJECT_PATH"
```

### Workflow 3: Monorepo Generation

```bash
#!/bin/bash
# generate-monorepo-configs.sh

ROOT_PATH="${1:-.}"

echo "=== Generating monorepo configurations ==="

# Generate root config
bash scripts/generate-project-json.sh "$ROOT_PATH"

# Generate for each app
for app in "$ROOT_PATH/apps"/*; do
    if [ -d "$app" ]; then
        echo "Generating config for: $(basename $app)"
        bash scripts/generate-project-json.sh "$app"
    fi
done

# Generate for each package
for pkg in "$ROOT_PATH/packages"/*; do
    if [ -d "$pkg" ]; then
        echo "Generating config for: $(basename $pkg)"
        bash scripts/generate-project-json.sh "$pkg"
    fi
done

echo "✓ Monorepo configurations generated!"
```

## Manual Customization

### Adding Custom Fields

```json
{
  "name": "my-app",
  "custom_fields": {
    "deployment_target": "vercel",
    "api_version": "v2",
    "features": ["auth", "payments", "ai-chat"]
  }
}
```

### Overriding Detections

```json
{
  "language": "typescript",
  "language_override": true,
  "frameworks": [
    {
      "name": "Custom Framework",
      "version": "2.0.0",
      "confidence": "manual",
      "evidence": "manually added"
    }
  ]
}
```

### Adding Documentation

```json
{
  "documentation": {
    "readme": "README.md",
    "api_docs": "docs/api.md",
    "architecture": "docs/architecture.md"
  },
  "contact": {
    "maintainer": "team@example.com",
    "repository": "https://github.com/org/repo"
  }
}
```

## Integration with Claude Code

### How Claude Uses project.json

1. **Framework Detection**: Knows which code templates to use
2. **Dependency Awareness**: Understands available packages
3. **AI Stack Integration**: Knows which AI SDKs are available
4. **Database Context**: Understands data layer architecture
5. **Build System**: Knows how to build and test

### Example: Claude Reading project.json

When you ask Claude to "add a new API endpoint", it:

1. Reads `.claude/project.json`
2. Sees you're using Next.js + TypeScript
3. Detects you have Prisma for database
4. Generates appropriate Next.js API route with Prisma queries
5. Uses correct TypeScript types

## Validation and Quality Checks

### Validate Configuration

```bash
bash scripts/validate-detection.sh .
```

### Check for Issues

```bash
#!/bin/bash
# check-config-quality.sh

CONFIG=".claude/project.json"

if [ ! -f "$CONFIG" ]; then
    echo "❌ No project.json found"
    exit 1
fi

echo "=== Configuration Quality Check ==="
echo ""

# Check if valid JSON
if jq empty "$CONFIG" 2>/dev/null; then
    echo "✓ Valid JSON"
else
    echo "❌ Invalid JSON"
    exit 1
fi

# Check for required fields
REQUIRED_FIELDS=("name" "language" "frameworks" "dependencies")

for field in "${REQUIRED_FIELDS[@]}"; do
    if jq -e ".$field" "$CONFIG" >/dev/null 2>&1; then
        echo "✓ Has '$field'"
    else
        echo "❌ Missing '$field'"
    fi
done

# Check for empty arrays
if [ $(jq '.frameworks | length' "$CONFIG") -eq 0 ]; then
    echo "⚠ No frameworks detected"
fi

if [ $(jq '.dependencies.all | length' "$CONFIG") -eq 0 ]; then
    echo "⚠ No dependencies detected"
fi

# Check metadata
if jq -e '.metadata.detected_at' "$CONFIG" >/dev/null 2>&1; then
    DETECTED_AT=$(jq -r '.metadata.detected_at' "$CONFIG")
    echo "✓ Last detected: $DETECTED_AT"
else
    echo "⚠ No detection timestamp"
fi
```

## Advanced Queries

### Query Framework Versions

```bash
# Get all framework versions
cat .claude/project.json | jq '.frameworks[] | "\(.name): \(.version)"'

# Get Next.js version
cat .claude/project.json | jq -r '.frameworks[] | select(.name == "Next.js") | .version'

# Check if using React 18+
cat .claude/project.json | jq '.frameworks[] | select(.name == "React" and (.version | test("^18|^19")))'
```

### Query Dependencies

```bash
# Count total dependencies
cat .claude/project.json | jq '.dependencies.all | length'

# List production dependencies
cat .claude/project.json | jq -r '.dependencies.production[] | .name'

# Find specific package version
cat .claude/project.json | jq '.dependencies.all[] | select(.name == "react")'
```

### Query AI Stack

```bash
# Check if using Vercel AI SDK
cat .claude/project.json | jq '.ai_stack[] | select(.name | contains("Vercel AI"))'

# List all AI SDKs
cat .claude/project.json | jq -r '.ai_stack[] | select(.type == "sdk") | .name'

# Check for vector database
cat .claude/project.json | jq '.ai_stack[] | select(.type == "vector-db")'
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/update-project-detection.yml
name: Update Project Detection

on:
  push:
    branches: [main]
    paths:
      - 'package.json'
      - 'requirements.txt'
      - 'go.mod'
      - 'Cargo.toml'

jobs:
  update-detection:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate project.json
        run: bash scripts/generate-project-json.sh .

      - name: Validate detection
        run: bash scripts/validate-detection.sh .

      - name: Commit changes
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add .claude/project.json
          git diff --staged --quiet || git commit -m "chore: update project detection [skip ci]"
          git push
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Regenerate project.json if dependencies changed
if git diff --cached --name-only | grep -qE "package.json|requirements.txt|go.mod|Cargo.toml"; then
    echo "Dependencies changed, regenerating project.json..."
    bash scripts/generate-project-json.sh .
    git add .claude/project.json
fi
```

## Troubleshooting

### Issue: Incorrect Language Detection

**Solution**: Manually override in project.json

```json
{
  "language": "typescript",
  "language_override": true
}
```

### Issue: Missing Framework

**Solution**: Check detection patterns

```bash
cat templates/framework-patterns.json | jq '.framework_detection_patterns'
```

### Issue: Outdated Configuration

**Solution**: Regenerate

```bash
bash scripts/generate-project-json.sh .
```

## Best Practices

1. **Version Control**: Always commit `.claude/project.json`
2. **Regular Updates**: Regenerate after adding dependencies
3. **Validation**: Always validate after manual edits
4. **Documentation**: Add custom fields for project-specific info
5. **CI Integration**: Automate detection updates
6. **Monorepo**: Generate separate configs for each package
7. **Manual Review**: Review auto-detected configurations

## Migration Guide

### From No Configuration

```bash
# Step 1: Generate initial config
bash scripts/generate-project-json.sh .

# Step 2: Review and customize
nano .claude/project.json

# Step 3: Validate
bash scripts/validate-detection.sh .

# Step 4: Commit
git add .claude/project.json
git commit -m "Add project detection configuration"
```

### From Manual Configuration

```bash
# Backup existing
cp .claude/project.json .claude/project.json.manual

# Generate auto-detected version
bash scripts/generate-project-json.sh .

# Merge custom fields from manual config
jq -s '.[0] * .[1]' .claude/project.json.manual .claude/project.json > .claude/project.json.merged
mv .claude/project.json.merged .claude/project.json
```

## Next Steps

- Read [basic-usage.md](./basic-usage.md) for simple detection
- Read [advanced-detection.md](./advanced-detection.md) for complex scenarios
- Read [ai-stack-discovery.md](./ai-stack-discovery.md) for AI detection
- Read [database-analysis.md](./database-analysis.md) for database detection
