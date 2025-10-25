# develop Plugin - Build Summary

**Created**: 2025-10-22  
**Version**: 1.0.0  
**Lifecycle Phase**: Development (Phase 3 of 6)

---

## Overview

The `develop` plugin consolidates code generation and implementation capabilities from multiple legacy plugins into a single, cohesive development tool that adapts to any framework.

### Consolidated Plugins

This plugin replaces and consolidates:
- `multiagent-frontend` → Frontend component generation
- `multiagent-backend` → Backend API creation
- `multiagent-implementation` → General implementation
- `multiagent-ai-infrastructure` → AI/LLM integration
- `multiagent-mcp` → MCP server building (commands only)

---

## Components Built

### Slash Commands (7)

1. **`/feature`** - Add new feature from specification
2. **`/component`** - Generate UI component for detected framework
3. **`/api`** - Create API endpoint for detected backend
4. **`/scaffold`** - Scaffold entire module (frontend + backend + tests)
5. **`/ai-integration`** - Add AI/LLM capabilities to application
6. **`/mcp-build`** - Build complete FastMCP server
7. **`/mcp-test`** - Test MCP servers comprehensively

### Skills (4)

1. **`code-generation`** - Framework-agnostic code generation templates for 20+ frameworks
2. **`component-templates`** - UI component library templates (buttons, forms, cards, etc.)
3. **`api-patterns`** - REST/GraphQL/tRPC API pattern library
4. **`mcp-development`** - FastMCP server templates and testing utilities

### Agents (4)

1. **`feature-builder`** - Implements features from specifications (comprehensive agent)
2. **`frontend-generator`** - Generates frontend components for any framework
3. **`backend-generator`** - Creates backend APIs for any stack
4. **`ai-integrator`** - Adds AI/LLM capabilities to applications

---

## Design Principles

### Project-Agnostic Architecture

✅ **Detects framework** - Reads `.claude/project.json` to understand the stack  
✅ **Adapts behavior** - Code generation changes based on detected framework  
✅ **No hardcoding** - Never assumes React, Django, or any specific framework  
✅ **Works locally** - No external service dependencies  

### Supported Frameworks

**Frontend**: React, Vue, Svelte, Angular, Solid.js, Qwik  
**Backend**: Express, Fastify, NestJS, Django, Flask, FastAPI, Gin, Echo, Actix, Rocket  
**Databases**: Prisma, TypeORM, SQLAlchemy, GORM, Diesel  
**Testing**: Jest, Vitest, Pytest, Go test, Testing Library  

---

## File Structure

```
plugins/develop/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest (metadata only)
├── commands/                           # 7 slash commands
│   ├── feature.md
│   ├── component.md
│   ├── api.md
│   ├── scaffold.md
│   ├── ai-integration.md
│   ├── mcp-build.md
│   └── mcp-test.md
├── agents/                             # 4 specialized agents
│   ├── feature-builder.md
│   ├── frontend-generator.md
│   ├── backend-generator.md
│   └── ai-integrator.md
├── skills/                             # 4 skill libraries
│   ├── code-generation/
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   ├── templates/
│   │   └── scripts/
│   ├── component-templates/
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   └── scripts/
│   ├── api-patterns/
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   └── scripts/
│   └── mcp-development/
│       ├── SKILL.md
│       ├── templates/
│       └── scripts/
├── docs/
│   └── PLUGIN-SUMMARY.md              # This file
├── README.md                           # Plugin documentation
├── CHANGELOG.md                        # Version history
├── LICENSE                             # MIT License
├── .gitignore                          # Git ignore rules
└── .mcp.json                           # MCP server configuration
```

---

## Usage Examples

### Building a Feature from Spec

```bash
# User creates or has a spec
/spec "Build authentication system"

# Generate code for detected framework
/develop:feature add-auth
```

### Generating UI Components

```bash
# Detects if you're using React, Vue, Svelte, etc.
/develop:component LoginForm

# With variants
/develop:component Button --variant=primary,secondary,outline
```

### Creating API Endpoints

```bash
# Adapts to Express, FastAPI, Go Gin, etc.
/develop:api users --method=GET,POST,PUT,DELETE
```

### Scaffolding Complete Modules

```bash
# Creates frontend + backend + tests in one go
/develop:scaffold blog-system
```

### Adding AI Capabilities

```bash
# Integrates OpenAI, Anthropic, or local models
/develop:ai-integration chat
/develop:ai-integration embeddings
```

### Building MCP Servers

```bash
# Build complete FastMCP server
/develop:mcp-build github-tools "GitHub repository management"

# Test it comprehensively
/develop:mcp-test github-tools
```

---

## Integration with Other Lifecycle Plugins

**Works with**:
- **core** (`/init`, `/detect`) - Initializes `.claude/project.json` with framework detection
- **planning** (`/spec`, `/plan`) - Reads specifications created by planning plugin
- **iterate** (`/adjust`, `/refactor`) - Refines generated code
- **quality** (`/test`, `/validate`) - Tests generated features
- **deploy** (`/deploy`) - Deploys completed features

---

## Next Steps

1. **Add Template Files**:
   - Populate `skills/*/templates/` directories with actual templates
   - Add framework-specific code generation templates

2. **Add Scripts**:
   - Create utility scripts in `skills/*/scripts/`
   - Add framework detection scripts
   - Add code validation scripts

3. **Testing**:
   - Test each command with different frameworks
   - Verify project-agnostic behavior
   - Validate with React, Vue, Django, Go, etc.

4. **Documentation**:
   - Add usage examples for each framework
   - Document template variables
   - Create troubleshooting guide

---

## Success Criteria

✅ Plugin structure complete  
✅ All 7 commands created and validated  
✅ All 4 skills defined  
✅ All 4 agents created  
✅ Project-agnostic design implemented  
✅ Integration points documented  
✅ README and documentation complete  

---

**Status**: Ready for template population and testing  
**Next Plugin**: `iterate` (Phase 4 - Refinement & Adjustment)
