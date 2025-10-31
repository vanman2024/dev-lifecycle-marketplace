---
name: Project Detection
description: Comprehensive tech stack detection, framework identification, dependency analysis, and project.json generation. Use when analyzing project structure, detecting frameworks, identifying dependencies, discovering AI stack components, detecting databases, or when user mentions project detection, tech stack analysis, framework discovery, or project.json generation.
allowed-tools: 
---

# Project Detection Skill

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides comprehensive project analysis capabilities including framework detection, dependency analysis, AI stack identification, database detection, and automatic `.claude/project.json` generation.

## Instructions

### Framework Detection

1. Use `scripts/detect-frameworks.sh <project-path>` to identify all frameworks
2. Detects frontend frameworks: Next.js, React, Vue, Svelte, Angular, Solid.js
3. Detects backend frameworks: FastAPI, Django, Flask, Express, NestJS, Go frameworks, Rust frameworks
4. Identifies meta-frameworks and build tools
5. Returns structured JSON output with versions and confidence scores

### Dependency Analysis

1. Use `scripts/detect-dependencies.sh <project-path>` to analyze all dependencies
2. Scans package.json, requirements.txt, go.mod, Cargo.toml, Gemfile, composer.json
3. Categorizes dependencies: production, development, peer
4. Identifies version ranges and exact versions
5. Detects dependency conflicts and outdated packages

### AI Stack Identification

1. Use `scripts/detect-ai-stack.sh <project-path>` to discover AI components
2. Detects: Vercel AI SDK, Claude Agent SDK, LangChain, Mem0, OpenAI SDK
3. Identifies AI model providers and API integrations
4. Discovers RAG systems and vector databases
5. Finds agent frameworks and orchestration tools

### Database Detection

1. Use `scripts/detect-database.sh <project-path>` to identify databases
2. Detects: Supabase, PostgreSQL, MongoDB, Redis, MySQL, SQLite
3. Identifies ORMs: Prisma, TypeORM, SQLAlchemy, GORM, Diesel
4. Finds connection strings and configuration files
5. Discovers database migration tools

### Project.json Generation

1. Use `scripts/generate-project-json.sh <project-path>` to create complete project.json
2. Aggregates all detection results into structured format
3. Generates `.claude/project.json` with complete tech stack information
4. Includes framework versions, dependencies, AI stack, databases
5. Adds metadata: language, build tools, test frameworks, deployment targets

## Available Scripts

- **detect-frameworks.sh**: Comprehensive framework detection across all languages
- **detect-dependencies.sh**: Dependency analysis from all package managers
- **detect-ai-stack.sh**: AI/ML stack component identification
- **detect-database.sh**: Database and ORM detection
- **generate-project-json.sh**: Master script that generates complete project.json
- **validate-detection.sh**: Validates detection accuracy and completeness

## Templates

- **project.json.template**: Complete project.json structure with all fields
- **framework-patterns.json**: Detection patterns for 30+ frameworks
- **dependency-patterns.json**: Dependency identification patterns
- **ai-stack-patterns.json**: AI/ML component detection patterns
- **database-patterns.json**: Database detection patterns
- **detection-report.md**: Human-readable detection report template

## Examples

See `examples/` directory for detailed usage examples:
- `basic-usage.md` - Simple project detection workflow
- `advanced-detection.md` - Complex multi-framework projects
- `ai-stack-discovery.md` - AI stack identification patterns
- `database-analysis.md` - Database and ORM detection
- `project-json-generation.md` - Complete project.json generation

## Detection Strategies

### Frontend Detection
- Check for framework-specific config files (next.config.js, vite.config.ts)
- Scan package.json for framework dependencies
- Identify build tool configurations
- Detect UI component libraries (shadcn, Material-UI, Tailwind UI)

### Backend Detection
- Identify web framework imports and decorators
- Scan for framework-specific file structures
- Detect API route patterns
- Find server configuration files

### AI Stack Detection
- Search for AI SDK imports and usage
- Identify model provider API keys in env files
- Detect vector database configurations
- Find agent and tool definitions

### Database Detection
- Scan for database client imports
- Find ORM schema definitions
- Identify connection string patterns
- Detect migration directories

## Output Format

All detection scripts output JSON in this format:
```json
{
  "detected": true,
  "confidence": "high|medium|low",
  "type": "framework|database|ai-stack",
  "name": "Framework Name",
  "version": "1.0.0",
  "files": ["list", "of", "evidence", "files"],
  "metadata": {}
}
```

## Requirements

- Support 30+ frameworks across 8+ languages
- Provide confidence scores for all detections
- Include file paths as evidence
- Generate valid project.json schema
- Handle monorepos and multi-framework projects
- Detect framework versions accurately
- Identify both direct and transitive dependencies

## Integration

This skill is used by:
- `foundation:init` command - Initial project analysis
- `foundation:analyze` command - Deep project structure analysis
- All code generation skills - Framework-specific code templates
- All deployment commands - Framework-specific deployment configs

---

**Purpose**: Comprehensive project analysis and tech stack detection
**Used by**: All agents requiring project context and framework information
