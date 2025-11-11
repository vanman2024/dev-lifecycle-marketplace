---
description: Create standardized monorepo structure with backend/frontend/docs/scripts separation
argument-hint: [project-path]
allowed-tools: Task, Read, Write, Edit, Bash(*), Glob, Grep, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Initialize or restructure a project with standardized directory layout for clean backend/frontend separation, following PROJECT-STRUCTURE-STANDARD guidelines.

Core Principles:
- Detect existing structure before proposing changes
- Ask for confirmation before moving files
- Maintain backward compatibility with imports
- Create comprehensive migration plan
- Backup existing structure

Phase 1: Discovery
Goal: Understand current project structure and tech stack

Actions:
- Parse $ARGUMENTS for target directory (default: current directory)
- Check if project exists and has initialization markers
- Example: !{bash test -f package.json || test -f requirements.txt && echo "Found" || echo "Not found"}
- Detect project type (monorepo, microservices, single app)
- Load tech stack information
- Example: @.claude/project.json

Phase 2: Structure Analysis
Goal: Analyze current structure and identify issues

Actions:
- Scan directory tree to understand current layout
- Example: !{bash find . -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | head -20}
- Identify mixed concerns (backend/frontend files intermingled)
- Check for existing backend/ or frontend/ directories
- Detect test location patterns
- Generate current structure report

Phase 3: Clarifying Questions
Goal: Understand user's preferences and requirements

Actions:
- Use AskUserQuestion to confirm:
  - Is this a full-stack project (backend + frontend)?
  - Should existing files be migrated automatically?
  - Are there any files/directories to exclude from migration?
  - Preferred backend directory name (backend/ api/ server/)?
  - Preferred frontend directory name (frontend/ web/ client/)?
- Confirm structure type:
  - Monorepo (single repo, separate backend/frontend)
  - Microservices (separate services)
  - Hybrid monorepo (shared packages + services)

Phase 4: Migration Planning
Goal: Design comprehensive migration strategy

Actions:
- Based on analysis and user input, create migration plan
- Identify files to move: backend (Python/Go/Java/Node APIs), frontend (React/Next.js/Vue), shared utilities, docs, scripts, configs
- Plan directory structure: backend/src, backend/tests, frontend/src, frontend/__tests__, docs/architecture, scripts/
- Present plan to user for approval
- DO NOT proceed without explicit user approval

Phase 5: Implementation
Goal: Execute structure creation using standardized script

DO NOT START WITHOUT USER APPROVAL

Actions:
- Create backup of current structure (if migrating existing project)
- Example: !{bash tar -czf project-backup-$(date +%Y%m%d-%H%M%S).tar.gz . --exclude=node_modules --exclude=.git --exclude=__pycache__}
- Use create-structure script from project-structure skill:
- Example: !{bash bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/foundation/skills/project-structure/scripts/create-structure.sh full-stack .}
- Script automatically creates: backend/, frontend/, docs/, scripts/, tests/e2e/, .gitignore, README stubs, .env.example files
- If migrating existing files, move them to new locations:
  - Backend files → backend/src/
  - Frontend files → frontend/src/ or frontend/app/
  - Tests → backend/tests/ or frontend/__tests__/
- Update import paths if needed (Python, TypeScript)

Phase 6: Validation
Goal: Verify migration succeeded and project still works

Actions:
- Check all files were moved correctly
- Example: !{bash ls -la backend/ frontend/ docs/ scripts/}
- Verify no orphaned files remain
- Test backend still works (if applicable)
- Example: !{bash cd backend && npm run typecheck 2>/dev/null || python -m py_compile src/*.py 2>/dev/null || echo "No validation available"}
- Test frontend still works (if applicable)
- Example: !{bash cd frontend && npm run typecheck 2>/dev/null || echo "No validation available"}
- Report any issues found

Phase 7: Documentation
Goal: Document new structure and update guides

Actions:
- Create docs/PROJECT-STRUCTURE.md explaining:
  - Directory layout
  - Where to add new files
  - Testing conventions
  - Deployment process
- Update root README.md with:
  - Getting started for backend
  - Getting started for frontend
  - Development workflow
  - Structure overview
- Create scripts/README.md explaining available scripts

Phase 8: Summary
Goal: Report results and next steps

Actions:
- Display migration summary:
  - Files moved: backend, frontend, docs, scripts
  - Structure validated: ✅
  - Import paths updated: ✅
  - Documentation created: ✅
- Show new structure tree
- Backup location: project-backup-YYYYMMDD-HHMMSS.tar.gz
- Suggest next steps:
  - Review generated READMEs
  - Run tests to verify functionality
  - Update CI/CD workflows for new structure
  - Use /foundation:validate-structure to check compliance
