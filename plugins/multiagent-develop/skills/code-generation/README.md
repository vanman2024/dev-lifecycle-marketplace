# Code Generation Skill

Framework-agnostic code generation templates for 20+ frameworks.

## Purpose

Provides universal code generation capabilities that adapt to any detected framework or stack. Used by agents to generate components, APIs, models, and tests.

## Templates

Organized by technology stack:

### Frontend Templates
- `templates/frontend/react/` - React components (JS/TS)
- `templates/frontend/vue/` - Vue SFCs
- `templates/frontend/svelte/` - Svelte components
- `templates/frontend/angular/` - Angular components

### Backend Templates
- `templates/backend/node/` - Express, Fastify, NestJS
- `templates/backend/python/` - Django, Flask, FastAPI
- `templates/backend/go/` - Gin, Echo handlers
- `templates/backend/rust/` - Actix, Rocket routes

### Database Templates
- `templates/database/models/` - ORM models
- `templates/database/migrations/` - Migration files
- `templates/database/seeds/` - Seed data

### Test Templates
- `templates/tests/unit/` - Unit tests
- `templates/tests/integration/` - Integration tests
- `templates/tests/e2e/` - End-to-end tests

## Scripts

- `scripts/detect-framework.sh` - Detect project framework
- `scripts/generate-from-template.sh` - Template rendering
- `scripts/validate-syntax.sh` - Syntax validation

## Usage

Called automatically by:
- `/multiagent-develop:feature`
- `/multiagent-develop:component`
- `/multiagent-develop:api`
- Agents: feature-builder, frontend-generator, backend-generator
