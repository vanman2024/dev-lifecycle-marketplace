# Advanced Detection - Complex Multi-Framework Projects

This example demonstrates detection in complex scenarios including monorepos, multi-framework projects, and custom configurations.

## Scenario 1: Monorepo with Multiple Frameworks

### Project Structure

```
my-monorepo/
├── apps/
│   ├── web/          # Next.js app
│   ├── mobile/       # React Native
│   └── api/          # FastAPI backend
├── packages/
│   ├── ui/           # Shared UI components
│   └── utils/        # Shared utilities
├── turbo.json
└── package.json
```

### Detection Strategy

Detect each workspace separately:

```bash
# Detect root (monorepo configuration)
bash scripts/generate-project-json.sh .

# Detect individual apps
bash scripts/generate-project-json.sh ./apps/web
bash scripts/generate-project-json.sh ./apps/mobile
bash scripts/generate-project-json.sh ./apps/api

# Detect shared packages
bash scripts/generate-project-json.sh ./packages/ui
bash scripts/generate-project-json.sh ./packages/utils
```

### Aggregate Results

Create a master detection script for monorepos:

```bash
#!/bin/bash
# detect-monorepo.sh

ROOT_PATH="${1:-.}"
OUTPUT_DIR="$ROOT_PATH/.claude"
mkdir -p "$OUTPUT_DIR"

# Detect root
bash scripts/generate-project-json.sh "$ROOT_PATH"

# Detect all apps
for app in "$ROOT_PATH/apps"/*; do
    if [ -d "$app" ]; then
        echo "Detecting: $app"
        bash scripts/generate-project-json.sh "$app"

        # Copy to centralized location
        APP_NAME=$(basename "$app")
        cp "$app/.claude/project.json" "$OUTPUT_DIR/project-${APP_NAME}.json"
    fi
done

# Detect all packages
for pkg in "$ROOT_PATH/packages"/*; do
    if [ -d "$pkg" ]; then
        echo "Detecting: $pkg"
        bash scripts/generate-project-json.sh "$pkg"

        PKG_NAME=$(basename "$pkg")
        cp "$pkg/.claude/project.json" "$OUTPUT_DIR/project-${PKG_NAME}.json"
    fi
done

echo "Monorepo detection complete!"
echo "Results in: $OUTPUT_DIR/"
```

### Result

```
.claude/
├── project.json           # Root configuration
├── project-web.json       # Next.js app
├── project-mobile.json    # React Native app
├── project-api.json       # FastAPI backend
├── project-ui.json        # UI package
└── project-utils.json     # Utils package
```

## Scenario 2: Multi-Language Project

### Project Structure

```
fullstack-app/
├── frontend/       # TypeScript + React
├── backend/        # Python + FastAPI
├── workers/        # Go + Fiber
└── scripts/        # Shell scripts
```

### Detection Approach

```bash
# Detect each language stack
bash scripts/generate-project-json.sh ./frontend
bash scripts/generate-project-json.sh ./backend
bash scripts/generate-project-json.sh ./workers

# View all detected languages
cat frontend/.claude/project.json | jq '.language'    # typescript
cat backend/.claude/project.json | jq '.language'     # python
cat workers/.claude/project.json | jq '.language'     # go
```

### Consolidate Results

```bash
#!/bin/bash
# consolidate-multi-language.sh

jq -s '{
  name: "fullstack-app",
  type: "multi-language",
  stacks: [
    {
      name: "frontend",
      config: .[0]
    },
    {
      name: "backend",
      config: .[1]
    },
    {
      name: "workers",
      config: .[2]
    }
  ]
}' frontend/.claude/project.json \
   backend/.claude/project.json \
   workers/.claude/project.json > .claude/project-consolidated.json
```

## Scenario 3: Custom Framework Detection

### Problem

You're using a custom internal framework not detected automatically.

### Solution 1: Manual Addition

Edit `.claude/project.json` after generation:

```json
{
  "frameworks": [
    {
      "name": "Custom Internal Framework",
      "version": "2.0.0",
      "confidence": "manual",
      "evidence": "manually added"
    }
  ]
}
```

### Solution 2: Extend Detection Script

Create custom detection rules:

```bash
# custom-detect.sh

# Add to detect-frameworks.sh
detect_custom_framework() {
    if [[ -f "$PROJECT_PATH/internal-framework.config.js" ]]; then
        local version=$(grep "version" "$PROJECT_PATH/internal-framework.config.js" | sed 's/.*: "\(.*\)".*/\1/')
        add_detection "Internal Framework" "$version" "high" "internal-framework.config.js"
    fi
}

# Run custom detection
detect_custom_framework
```

## Scenario 4: Polyglot Microservices

### Project Structure

```
microservices/
├── auth-service/       # Node.js + Express
├── payment-service/    # Python + Django
├── notification-svc/   # Go + Gin
├── analytics-service/  # Rust + Actix
└── docker-compose.yml
```

### Batch Detection

```bash
#!/bin/bash
# detect-all-services.sh

SERVICES=(
    "auth-service"
    "payment-service"
    "notification-svc"
    "analytics-service"
)

for service in "${SERVICES[@]}"; do
    echo "=== Detecting: $service ==="
    bash scripts/generate-project-json.sh "./$service"

    # Extract key info
    echo "Language: $(cat $service/.claude/project.json | jq -r '.language')"
    echo "Frameworks: $(cat $service/.claude/project.json | jq -r '.frameworks[].name' | tr '\n' ', ')"
    echo ""
done

# Create service catalog
jq -n --slurpfile auth auth-service/.claude/project.json \
      --slurpfile payment payment-service/.claude/project.json \
      --slurpfile notification notification-svc/.claude/project.json \
      --slurpfile analytics analytics-service/.claude/project.json \
'{
  microservices: {
    auth: $auth[0],
    payment: $payment[0],
    notification: $notification[0],
    analytics: $analytics[0]
  }
}' > .claude/microservices-catalog.json
```

## Scenario 5: Incremental Detection

### Use Case

Detect only what changed since last detection.

### Implementation

```bash
#!/bin/bash
# incremental-detect.sh

PREVIOUS=".claude/project.json.prev"
CURRENT=".claude/project.json"

# Backup previous detection
if [ -f "$CURRENT" ]; then
    cp "$CURRENT" "$PREVIOUS"
fi

# Run new detection
bash scripts/generate-project-json.sh .

# Compare results
if [ -f "$PREVIOUS" ]; then
    echo "=== Changes Detected ==="

    # Compare frameworks
    echo "New frameworks:"
    comm -13 \
        <(jq -r '.frameworks[].name' "$PREVIOUS" | sort) \
        <(jq -r '.frameworks[].name' "$CURRENT" | sort)

    # Compare dependencies count
    PREV_COUNT=$(jq '.dependencies.all | length' "$PREVIOUS")
    CURR_COUNT=$(jq '.dependencies.all | length' "$CURRENT")
    echo "Dependency change: $PREV_COUNT → $CURR_COUNT"

    # Compare AI stack
    echo "New AI components:"
    comm -13 \
        <(jq -r '.ai_stack[].name' "$PREVIOUS" | sort) \
        <(jq -r '.ai_stack[].name' "$CURRENT" | sort)
fi
```

## Scenario 6: Detection with Custom Filters

### Filter by Framework Type

```bash
# Get only frontend frameworks
cat .claude/project.json | jq '.frameworks[] | select(.name | test("React|Vue|Svelte|Angular"))'

# Get only backend frameworks
cat .claude/project.json | jq '.frameworks[] | select(.name | test("Express|FastAPI|Django|Flask"))'

# Get only databases
cat .claude/project.json | jq '.databases[] | select(.type == "database")'

# Get only ORMs
cat .claude/project.json | jq '.databases[] | select(.type == "orm")'
```

### Filter by Confidence

```bash
# Get high confidence detections only
cat .claude/project.json | jq '.frameworks[] | select(.confidence == "high")'

# Get all low confidence detections (needs review)
cat .claude/project.json | jq '.frameworks[] | select(.confidence == "low")'
```

## Performance Optimization

### Parallel Detection

```bash
#!/bin/bash
# parallel-detect.sh

# Run all detections in parallel
bash scripts/detect-frameworks.sh . > /tmp/frameworks.json &
bash scripts/detect-dependencies.sh . > /tmp/dependencies.json &
bash scripts/detect-ai-stack.sh . > /tmp/ai-stack.json &
bash scripts/detect-database.sh . > /tmp/databases.json &

# Wait for all to complete
wait

# Merge results
jq -s '.[0] * .[1] * .[2] * .[3]' \
    /tmp/frameworks.json \
    /tmp/dependencies.json \
    /tmp/ai-stack.json \
    /tmp/databases.json > .claude/project.json

echo "Parallel detection complete!"
```

### Cached Detection

```bash
#!/bin/bash
# cached-detect.sh

CACHE_FILE=".claude/.detection-cache"
CACHE_DURATION=3600  # 1 hour

if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))

    if [ $CACHE_AGE -lt $CACHE_DURATION ]; then
        echo "Using cached detection (${CACHE_AGE}s old)"
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Run fresh detection
bash scripts/generate-project-json.sh .
cp .claude/project.json "$CACHE_FILE"
```

## Best Practices

1. **Version Control**: Commit `.claude/project.json` to git
2. **CI Integration**: Run detection on every push
3. **Documentation**: Keep README in sync with detected stack
4. **Validation**: Always validate after manual edits
5. **Monorepo**: Detect each workspace separately
6. **Multi-language**: Consolidate results into catalog

## Troubleshooting Complex Projects

### Issue: Multiple versions of same framework

```bash
# Find conflicting versions
cat .claude/project.json | jq '.dependencies.all[] | select(.name == "react")'
```

### Issue: Incorrect primary language

Manually override in project.json:

```json
{
  "language": "typescript",
  "language_override": true
}
```

### Issue: Missing framework detection

Check detection patterns:

```bash
cat templates/framework-patterns.json | jq '.framework_detection_patterns.backend."YourFramework"'
```
