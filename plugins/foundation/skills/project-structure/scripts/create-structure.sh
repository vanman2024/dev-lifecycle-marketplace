#!/bin/bash
# create-structure.sh - Create standardized project structure
# Usage: bash create-structure.sh <project-type> [project-path]
# Types: full-stack, backend-only, frontend-only, microservices

set -e

PROJECT_TYPE="${1:-full-stack}"
PROJECT_PATH="${2:-.}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating ${PROJECT_TYPE} project structure at ${PROJECT_PATH}${NC}"

cd "$PROJECT_PATH" || exit 1

case "$PROJECT_TYPE" in
  "full-stack")
    echo -e "${YELLOW}Creating full-stack monorepo structure...${NC}"

    # Backend structure
    mkdir -p backend/src/{routes,models,services,utils}
    mkdir -p backend/tests/{unit,integration,__mocks__}
    touch backend/src/__init__.py
    touch backend/.env.example
    touch backend/README.md
    touch backend/.gitignore

    # Frontend structure
    mkdir -p frontend/{app,src}/{components,pages,hooks,utils,styles}
    mkdir -p frontend/__tests__/{components,hooks,utils,__mocks__}
    mkdir -p frontend/public
    touch frontend/.env.example
    touch frontend/README.md
    touch frontend/.gitignore

    # Docs structure
    mkdir -p docs/{architecture/{diagrams,decisions},guides,api}
    touch docs/architecture/README.md
    touch docs/guides/setup.md
    touch docs/guides/development.md
    touch docs/guides/deployment.md

    # Scripts
    mkdir -p scripts
    touch scripts/{setup.sh,deploy.sh,test-all.sh,README.md}
    chmod +x scripts/*.sh

    # E2E tests
    mkdir -p tests/e2e/{specs,fixtures}

    # Root files
    touch README.md
    touch .gitignore

    echo -e "${GREEN}✅ Full-stack structure created${NC}"
    echo "Backend: backend/"
    echo "Frontend: frontend/"
    echo "Docs: docs/"
    echo "Scripts: scripts/"
    echo "E2E Tests: tests/e2e/"
    ;;

  "backend-only")
    echo -e "${YELLOW}Creating backend-only structure...${NC}"

    # Source structure
    mkdir -p src/{routes,models,services,middleware,utils}
    touch src/__init__.py

    # Tests
    mkdir -p tests/{unit,integration,__mocks__,fixtures}

    # Docs
    mkdir -p docs/{api,architecture}
    touch docs/api/endpoints.md
    touch docs/architecture/README.md

    # Scripts
    mkdir -p scripts
    touch scripts/{setup.sh,deploy.sh,migrate.sh}
    chmod +x scripts/*.sh

    # Root files
    touch .env.example
    touch README.md
    touch .gitignore

    echo -e "${GREEN}✅ Backend-only structure created${NC}"
    echo "Source: src/"
    echo "Tests: tests/"
    echo "Docs: docs/"
    echo "Scripts: scripts/"
    ;;

  "frontend-only")
    echo -e "${YELLOW}Creating frontend-only structure...${NC}"

    # Source structure
    mkdir -p {app,src}/{components,pages,hooks,utils,styles,types}

    # Tests
    mkdir -p __tests__/{components,hooks,utils,__mocks__}
    mkdir -p tests/e2e/{specs,fixtures}

    # Public assets
    mkdir -p public/{images,fonts}

    # Docs
    mkdir -p docs/{components,guides}

    # Scripts
    mkdir -p scripts
    touch scripts/{build.sh,deploy.sh}
    chmod +x scripts/*.sh

    # Root files
    touch .env.example
    touch README.md
    touch .gitignore

    echo -e "${GREEN}✅ Frontend-only structure created${NC}"
    echo "Source: app/ or src/"
    echo "Tests: __tests__/, tests/e2e/"
    echo "Public: public/"
    echo "Docs: docs/"
    echo "Scripts: scripts/"
    ;;

  "microservices")
    echo -e "${YELLOW}Creating microservices structure...${NC}"

    # Services
    mkdir -p services/{auth,api,worker}/{src,tests,docs}
    mkdir -p services/{auth,api,worker}/src/{routes,models,utils}
    touch services/auth/.env.example
    touch services/api/.env.example
    touch services/worker/.env.example

    # Shared packages
    mkdir -p packages/{common,types}/{src,tests}

    # Docs
    mkdir -p docs/{architecture,services,deployment}
    touch docs/architecture/README.md
    touch docs/services/communication.md
    touch docs/deployment/README.md

    # Scripts
    mkdir -p scripts/{deploy,test}
    touch scripts/deploy/{auth.sh,api.sh,worker.sh}
    touch scripts/test/all-services.sh
    chmod +x scripts/**/*.sh

    # E2E tests
    mkdir -p tests/{e2e,integration}

    # Root files
    touch README.md
    touch .gitignore
    touch docker-compose.yml

    echo -e "${GREEN}✅ Microservices structure created${NC}"
    echo "Services: services/{auth,api,worker}/"
    echo "Shared: packages/{common,types}/"
    echo "Docs: docs/"
    echo "Scripts: scripts/"
    echo "Tests: tests/{e2e,integration}/"
    ;;

  *)
    echo -e "${YELLOW}Unknown project type: $PROJECT_TYPE${NC}"
    echo "Valid types: full-stack, backend-only, frontend-only, microservices"
    exit 1
    ;;
esac

# Create common .gitignore content
cat > .gitignore <<'EOF'
# Environment variables
.env
.env.local
.env.development
.env.staging
.env.production
!.env.example

# Dependencies
node_modules/
__pycache__/
*.pyc
.Python
venv/
ENV/

# Build outputs
dist/
build/
.next/
out/
*.egg-info/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.nyc_output/
*.coverage
htmlcov/

# Misc
*.pid
*.seed
*.pid.lock
EOF

echo -e "${GREEN}✅ .gitignore created${NC}"

# Display tree structure
echo ""
echo -e "${BLUE}Project structure:${NC}"
tree -L 3 -I 'node_modules|__pycache__|.git' || find . -type d -not -path '*/node_modules/*' -not -path '*/__pycache__/*' -not -path '*/.git/*' | head -30

echo ""
echo -e "${GREEN}✅ Structure creation complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review generated structure"
echo "2. Update README files with project-specific info"
echo "3. Configure .env.example files"
echo "4. Run: /foundation:validate-structure to verify compliance"
