---
description: Validate project structure compliance with standardization checklist
argument-hint: [project-path]
allowed-tools: Read, Write, Bash(*), Glob, Grep
---

**Arguments**: $ARGUMENTS

Goal: Validate project structure against PROJECT-STRUCTURE-STANDARD checklist and provide actionable recommendations for achieving compliance.

Core Principles:
- Check against standardization checklist
- Provide clear pass/fail status
- Generate actionable fix recommendations
- Report both issues and compliance
- Suggest improvement commands

Phase 1: Discovery
Goal: Locate project and understand structure

Actions:
- Parse $ARGUMENTS for target directory (default: current directory)
- Check if directory exists
- Example: !{bash test -d "${ARGUMENTS:-.}" && echo "Found" || echo "Not found"}
- Load project metadata if available
- Example: @.claude/project.json
- Detect project type (full-stack, backend-only, frontend-only)

Phase 2: Structure Validation
Goal: Check directory structure compliance

Actions:
- Check required directories: backend/, frontend/, docs/, scripts/
- Check proper separation: no backend files in frontend/, no frontend in backend/, no mixed tests
- Check anti-patterns: root tests/, mixed node_modules, scattered configs
- Example: !{bash find . -maxdepth 2 -type d | grep -E "(backend|frontend|docs|scripts)" | sort}

Phase 3: File Organization Validation
Goal: Verify files are in correct locations

Actions:
- Backend: src/ or app/, tests/ at backend/tests/, dependency file, .env.example, README.md
- Frontend: src/ or app/, __tests__/ at frontend/, package.json, .env.example, README.md
- Docs: architecture/ directory, guides/, README.md or index
- Scripts: deployment/setup scripts, README.md explaining scripts

Phase 4: Dependency & Testing Validation
Goal: Ensure isolation and proper test organization

Actions:
- Check separate dependency files: backend/requirements.txt or package.json, frontend/package.json
- Verify no shared node_modules at root (unless monorepo with workspaces)
- Check .gitignore contains: .env, __pycache__/, node_modules/, build artifacts
- Example: !{bash test -f .gitignore && grep -E "(\.env$|node_modules|__pycache__)" .gitignore || echo ".gitignore incomplete"}
- Check backend tests at backend/tests/, frontend tests at frontend/__tests__/, NOT in root tests/
- Example: !{bash find . -name "tests" -o -name "__tests__" | head -10}

Phase 5: Documentation & CI/CD Validation
Goal: Verify documentation and deployment configs

Actions:
- Root README.md: structure explanation, getting started for both sides, development workflow
- Backend/frontend README.md: side-specific setup, documentation, testing instructions
- docs/architecture/: architecture docs, component diagrams
- CI/CD workflows: GitHub Actions .github/workflows/, GitLab .gitlab-ci.yml
- Verify workflows test backend/frontend separately with separate build jobs
- Example: !{bash test -d .github/workflows && ls .github/workflows/*.yml 2>/dev/null || echo "No workflows found"}

Phase 6: Compliance Report & Summary
Goal: Generate validation report and present status

Actions:
- Calculate compliance score: Structure (X/Y), File org (X/Y), Dependencies (X/Y), Testing (X/Y), Docs (X/Y), CI/CD (X/Y)
- Display report with PASSED/FAILED/WARNINGS sections
- Example format: "Overall Compliance: XX% | PASSED: backend/frontend separation, .gitignore | FAILED: tests mixed, missing docs/ | WARNINGS: root README.md incomplete"
- Provide actionable commands for each issue: mv tests/ frontend/__tests__/, mkdir docs/architecture/, /planning:architecture design, touch backend/README.md, /foundation:init-structure for auto-fix
- Display compliance with color coding: 90-100% Excellent, 80-89% Good (minor issues), 60-79% Needs improvement, <60% Major restructuring needed
- List quick wins: Create README files, add .env.example, update .gitignore
- List major work: Restructure tests, separate mixed files, create documentation
- Suggest next steps: Use /foundation:init-structure for auto-fix, manually address issues, run validation again
