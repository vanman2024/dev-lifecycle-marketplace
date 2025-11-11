# Project Structure Standardization

**Description**: Standardized project structure patterns with backend/frontend separation templates

**Use this skill when**: Projects need clean organization with proper backend/frontend separation, test isolation, and documentation structure

## Core Principles

1. **Backend/Frontend Separation**: Clear boundaries between backend and frontend code
2. **Test Isolation**: Tests live with their respective codebases (backend/tests/, frontend/__tests__/)
3. **Dependency Isolation**: Separate dependency files, no mixed node_modules
4. **Documentation Organization**: Centralized docs/ with architecture/ subdirectory
5. **Script Centralization**: Deployment and setup scripts in scripts/ directory

## Standard Structure Templates

### Full-Stack Monorepo Structure

**Template Location**: `@templates/full-stack-monorepo-structure.txt`

This is the standardized structure for full-stack projects with backend and frontend:

```
Reference: plugins/foundation/skills/project-structure/templates/full-stack-monorepo-structure.txt
```

Key features:
- backend/ contains all server-side code
- frontend/ contains all client-side code
- docs/ centralized documentation
- scripts/ deployment and automation
- tests/e2e/ for end-to-end Playwright tests

### Backend-Only Structure

**Template Location**: `@templates/backend-only-structure.txt`

For API-only or backend services:

```
Reference: plugins/foundation/skills/project-structure/templates/backend-only-structure.txt
```

### Frontend-Only Structure

**Template Location**: `@templates/frontend-only-structure.txt`

For frontend applications or static sites:

```
Reference: plugins/foundation/skills/project-structure/templates/frontend-only-structure.txt
```

### Microservices Structure

**Template Location**: `@templates/microservices-structure.txt`

For distributed microservices architecture:

```
Reference: plugins/foundation/skills/project-structure/templates/microservices-structure.txt
```

## Scripts

### Create Structure Script (Primary)

**Location**: `scripts/create-structure.sh`

**Purpose**: Creates standardized project structure automatically

**Usage**:
```bash
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh <type> [path]
```

**Project Types**:
- `full-stack` - Backend + Frontend monorepo
- `backend-only` - API/Service only
- `frontend-only` - Web app/static site
- `microservices` - Multiple services architecture

**What it creates**:
- All necessary directories (backend/, frontend/, docs/, scripts/, tests/)
- .env.example files with placeholders
- README.md stubs
- .gitignore with proper exclusions
- Empty files in correct locations

**Example**:
```bash
# Create full-stack structure in current directory
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh full-stack .

# Create backend-only structure in new project
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh backend-only my-api

# Create microservices structure
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh microservices my-services
```

**Output**: Displays created structure with tree view and next steps

## Examples

### Example 1: Full-Stack Next.js + FastAPI

**Location**: `examples/nextjs-fastapi-example.md`

Real-world example showing:
- Next.js 15 App Router in frontend/
- FastAPI backend in backend/
- Supabase integration
- Separate testing setup
- CI/CD configuration

Reference: `@examples/nextjs-fastapi-example.md`

### Example 2: Microservices with Shared Packages

**Location**: `examples/microservices-example.md`

Shows:
- Multiple service directories
- Shared packages/
- Independent deployments
- Service-specific tests

Reference: `@examples/microservices-example.md`

### Example 3: Migration from Mixed Structure

**Location**: `examples/migration-example.md`

Step-by-step migration showing:
- Before: Mixed structure (all files in root)
- After: Standardized structure
- Import path updates
- Configuration changes

Reference: `@examples/migration-example.md`

## Usage Patterns

### Pattern 1: New Project Initialization

```bash
# Use create-structure script directly
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh full-stack my-project

# Or use /foundation:init-structure command (which calls this script)
SlashCommand(/foundation:init-structure my-project)
```

### Pattern 2: Create Structure in Current Directory

```bash
# Create full-stack structure
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh full-stack .

# Create backend-only structure
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh backend-only .

# Create microservices structure
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh microservices .
```

### Pattern 3: Validate Existing Structure

```bash
# Validate current structure (uses /foundation:validate-structure)
SlashCommand(/foundation:validate-structure)

# Review compliance report and fix issues
```

## Integration with Other Commands

### Works with:
- `/foundation:init-structure` - Uses templates from this skill
- `/foundation:validate-structure` - Uses validation logic from this skill
- `/testing:generate-tests` - Follows structure patterns from this skill
- `/deployment:deploy` - Recognizes standardized structure

### Invoked by:
- structure-organizer agent
- test-suite-generator agent
- deployment agents

## Validation Checklist

Use this checklist when validating or creating structure:

**Required Directories**:
- ✅ backend/ or api/ or server/
- ✅ frontend/ or web/ or client/
- ✅ docs/
- ✅ scripts/

**Separation**:
- ✅ No backend files in frontend/
- ✅ No frontend files in backend/
- ✅ Tests in correct locations (backend/tests/, frontend/__tests__/)

**Dependencies**:
- ✅ backend/requirements.txt or backend/package.json
- ✅ frontend/package.json
- ✅ No shared node_modules at root (unless monorepo with workspaces)

**Documentation**:
- ✅ Root README.md explains structure
- ✅ backend/README.md with setup instructions
- ✅ frontend/README.md with development guide
- ✅ docs/architecture/ exists

**Configuration**:
- ✅ .gitignore includes .env, node_modules, __pycache__
- ✅ .env.example templates exist (not .env)
- ✅ CI/CD workflows test backend/frontend separately

## Anti-Patterns to Avoid

❌ **Root tests/ directory** - Tests should be in backend/tests/ or frontend/__tests__/
❌ **Mixed dependencies** - Keep backend and frontend dependencies separate
❌ **Scattered configs** - Configuration files should be in appropriate directories
❌ **No separation** - Backend and frontend code must be in separate directories
❌ **Hardcoded secrets** - Use .env.example with placeholders only

## References

- PROJECT-STRUCTURE-STANDARD.md (source document)
- /foundation:init-structure command
- /foundation:validate-structure command
- structure-organizer agent
