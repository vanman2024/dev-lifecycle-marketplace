---
name: code-generation
description: Framework-agnostic code generation templates for 20+ frameworks. Use when generating code for any detected framework or stack.
---

# Code Generation Skill

## Instructions

1. **Detect Project Framework**:
   - Read `.claude/project.json` to identify framework and stack
   - Check package.json, requirements.txt, go.mod, Cargo.toml, etc.
   - Identify language version and dependencies

2. **Select Appropriate Template**:
   - Match detected framework to template library
   - Choose template based on code type (component, API, model, etc.)
   - Adapt template to project conventions

3. **Generate Code**:
   - Load template from templates/ directory
   - Replace placeholders with actual values
   - Apply project-specific conventions (naming, structure)
   - Include proper imports and dependencies
   - Add type annotations if using TypeScript/typed languages

4. **Validate Generated Code**:
   - Check syntax correctness
   - Verify imports are valid
   - Ensure follows project patterns
   - Add linting fixes if needed

## Supported Frameworks

### Frontend
- React (JS/TS) - JSX components, hooks, context
- Vue (2/3) - SFC templates, composition API
- Svelte - Svelte components, stores
- Angular - Components, services, modules
- Solid.js - JSX components, signals
- Qwik - Qwik components, resumability

### Backend
- Node.js (Express, Fastify, Koa, NestJS)
- Python (Django, Flask, FastAPI, Pyramid)
- Go (Gin, Echo, Chi, Fiber)
- Rust (Actix, Rocket, Axum)
- Ruby (Rails, Sinatra)
- PHP (Laravel, Symfony)
- Java (Spring Boot)
- C# (.NET, ASP.NET Core)

### Databases/ORMs
- Prisma, TypeORM, Sequelize (Node.js)
- SQLAlchemy, Django ORM, Tortoise (Python)
- GORM (Go)
- Diesel (Rust)
- ActiveRecord (Ruby)
- Eloquent (PHP)

## Examples

**Example 1: React Component Generation**
```
Framework: React + TypeScript
Template: templates/react-ts-component.template
Output: Button.tsx with props, TypeScript types, and styles
```

**Example 2: FastAPI Endpoint**
```
Framework: Python + FastAPI
Template: templates/fastapi-endpoint.template
Output: router with Pydantic models and async handlers
```

**Example 3: Go API Handler**
```
Framework: Go + Gin
Template: templates/go-gin-handler.template
Output: handler function with request/response structs
```

## Template Variables

All templates support these variables:
- `{{NAME}}` - Component/function/class name
- `{{DESCRIPTION}}` - Purpose description
- `{{PROPS}}` - Properties/parameters
- `{{IMPORTS}}` - Required imports
- `{{TYPES}}` - Type definitions
- `{{METHODS}}` - Methods/functions
- `{{TESTS}}` - Test cases

## Best Practices

- **Never hardcode frameworks** - Always detect from project.json
- **Match existing patterns** - Analyze similar files in project
- **Use project conventions** - Follow naming, structure, imports
- **Include types** - Add TypeScript/type hints when applicable
- **Generate tests** - Include test file alongside implementation
- **Add documentation** - Include JSDoc/docstrings

## Template Locations

- Frontend components: `templates/frontend/`
- Backend APIs: `templates/backend/`
- Database models: `templates/database/`
- Tests: `templates/tests/`
- Configuration: `templates/config/`

---

**Purpose**: Universal code generation for any framework
**Used by**: feature-builder, frontend-generator, backend-generator agents
