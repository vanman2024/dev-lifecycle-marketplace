# Basic Usage - Project Detection Skill

This example demonstrates the most common usage pattern for the project-detection skill.

## Scenario

You have a project and want to automatically detect its tech stack and generate a `.claude/project.json` file.

## Step 1: Navigate to Your Project

```bash
cd /path/to/your/project
```

## Step 2: Run the Master Detection Script

```bash
bash /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/scripts/generate-project-json.sh .
```

Or with an absolute path:

```bash
bash /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/scripts/generate-project-json.sh /path/to/your/project
```

## Step 3: Review the Output

The script will output progress:

```
=== Project Detection & Analysis ===
Project Path: /path/to/your/project

[1/5] Detecting frameworks...
  Found 3 frameworks

[2/5] Analyzing dependencies...
  Found 45 dependencies

[3/5] Discovering AI stack...
  Found 2 AI components

[4/5] Detecting databases...
  Found 3 database components

[5/5] Detecting primary language...
  Primary language: typescript

=== Generating .claude/project.json ===
Successfully generated: /path/to/your/project/.claude/project.json

=== Summary ===
  Language:         typescript
  Package Manager:  pnpm
  Frameworks:       3
  Dependencies:     45
  AI Stack:         2 components
  Databases:        3 components
  Build Tools:      1
  Test Frameworks:  2

✓ Generated JSON is valid
Project detection complete!
```

## Step 4: View the Generated project.json

```bash
cat .claude/project.json
```

Example output:

```json
{
  "name": "my-awesome-app",
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
    "project_path": "/path/to/your/project"
  }
}
```

## Step 5: Validate the Detection (Optional)

```bash
bash /home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-detection/scripts/validate-detection.sh .
```

Output:

```
=== Project Detection Validation ===
Project: /path/to/your/project
Config: /path/to/your/project/.claude/project.json

✓ project.json exists
✓ Valid JSON syntax

Checking required fields...
  ✓ name
  ✓ language
  ✓ frameworks
  ✓ dependencies
  ✓ ai_stack
  ✓ databases
  ✓ metadata

Checking detection completeness...
  ✓ Frameworks: 3
  ✓ Dependencies: 45
  ✓ AI Stack: 2 components
  ✓ Databases: 3 components

Cross-validating with project files...
  ✓ Language matches project files
  ✓ Next.js detection validated
  ✓ Prisma detection validated

=== Validation Summary ===
✓ All validations passed!
  No errors, no warnings
```

## Common Use Cases

### Use Case 1: First Time Project Analysis

When joining a new project or exploring a codebase:

```bash
cd /path/to/new-project
bash ~/.claude/plugins/.../generate-project-json.sh .
cat .claude/project.json
```

### Use Case 2: Tech Stack Documentation

Generate project.json to document your tech stack:

```bash
# Generate detection
bash ~/.claude/plugins/.../generate-project-json.sh .

# Commit to repository
git add .claude/project.json
git commit -m "Add auto-generated tech stack documentation"
```

### Use Case 3: CI/CD Integration

Add detection to your CI pipeline:

```yaml
# .github/workflows/tech-stack-audit.yml
name: Tech Stack Audit
on: [push]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Detect tech stack
        run: bash scripts/generate-project-json.sh .
      - name: Validate detection
        run: bash scripts/validate-detection.sh .
```

## Troubleshooting

### Issue: "jq not found"

Install jq for JSON validation:

```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

### Issue: "Permission denied"

Make scripts executable:

```bash
chmod +x ~/.claude/plugins/.../scripts/*.sh
```

### Issue: "No frameworks detected"

The project might use an unsupported framework. Check manually:

```bash
# View individual detection results
bash scripts/detect-frameworks.sh .
bash scripts/detect-dependencies.sh .
```

## Next Steps

- Read [advanced-detection.md](./advanced-detection.md) for complex scenarios
- Read [ai-stack-discovery.md](./ai-stack-discovery.md) for AI-specific detection
- Read [database-analysis.md](./database-analysis.md) for database detection
