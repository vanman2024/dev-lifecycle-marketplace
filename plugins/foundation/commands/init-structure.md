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
Goal: Invoke structure-organizer agent for intelligent migration

DO NOT START WITHOUT USER APPROVAL

Actions:

Launch the structure-organizer agent to handle intelligent analysis and migration.

Provide the agent with context:
- Project path: $ARGUMENTS
- Project type from Phase 2: [full-stack/backend-only/frontend-only/microservices]
- User preferences from Phase 3: [backend vs api, frontend vs web, migrate files yes/no]
- Current structure issues identified

The agent will:
1. Verify analysis and ask any additional questions
2. Create detailed migration plan
3. Get final approval
4. Create backup automatically
5. Run create-structure.sh script with correct type
6. Move files if needed
7. Update configurations
8. Validate compliance
9. Return results

Phase 6: Summary
Goal: Display results from structure-organizer agent

Actions:
- Show agent's migration results
- Display compliance score improvement
- Show backup location
- List what was created/moved
- Suggest next steps:
  - Review generated READMEs
  - Configure .env.example files
  - Run tests to verify functionality
  - Update CI/CD workflows for new structure
  - Use /foundation:validate-structure to verify final compliance
