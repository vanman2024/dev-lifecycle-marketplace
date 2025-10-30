# Common Patterns

This document describes typical patterns and workflows for using the Environment Setup skill in real-world scenarios.

## Pattern 1: Pre-commit Hook for Environment Validation

Ensure developers have the correct environment before committing code.

**Setup**: Create `.git/hooks/pre-commit`

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

# Check if environment meets requirements
if ! bash scripts/validate-versions.sh > /dev/null 2>&1; then
  echo "ERROR: Environment validation failed"
  echo "Your tool versions don't meet project requirements."
  echo ""
  echo "Run this to see details:"
  echo "  bash scripts/validate-versions.sh"
  echo ""
  exit 1
fi

# Continue with other pre-commit checks
# ... linting, formatting, etc.
```

**Make executable**:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Pattern 2: Project Initialization Script

Create a single script that sets up a new developer's environment completely.

**Create**: `scripts/init-dev-environment.sh`

```bash
#!/usr/bin/env bash
# init-dev-environment.sh - Complete development environment setup

set -e

PROJECT_NAME="My Project"
REPO_URL="https://github.com/username/project.git"

echo "==================================="
echo "$PROJECT_NAME - Development Setup"
echo "==================================="
echo ""

# Step 1: Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "go.mod" ]; then
  echo "This doesn't appear to be the project root directory."
  echo "Please run this script from the project root."
  exit 1
fi

# Step 2: Check basic tools
echo "Step 1/6: Checking basic tools..."
required_basic=(git)

for tool in "${required_basic[@]}"; do
  if ! command -v "$tool" > /dev/null; then
    echo "✗ $tool is not installed"
    echo "Please install $tool first."
    exit 1
  fi
done
echo "✓ Basic tools present"
echo ""

# Step 3: Run comprehensive environment check
echo "Step 2/6: Checking development environment..."
if bash scripts/check-environment.sh > /dev/null 2>&1; then
  echo "✓ All required tools installed"
else
  echo "✗ Some required tools are missing"
  echo ""
  bash scripts/check-environment.sh
  echo ""
  echo "Please install missing tools and run this script again."
  exit 1
fi
echo ""

# Step 4: Validate versions
echo "Step 3/6: Validating tool versions..."
if bash scripts/validate-versions.sh > /dev/null 2>&1; then
  echo "✓ All versions meet requirements"
else
  echo "⚠ Version warnings detected"
  bash scripts/validate-versions.sh
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
echo ""

# Step 5: Setup environment variables
echo "Step 4/6: Setting up environment variables..."
if [ ! -f ".env" ]; then
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "✓ Created .env from .env.example"
    echo "⚠ Please edit .env with your configuration"
  else
    echo "⚠ No .env.example found, skipping"
  fi
else
  echo "✓ .env already exists"
fi
echo ""

# Step 6: Install dependencies
echo "Step 5/6: Installing dependencies..."

if [ -f "package.json" ]; then
  echo "Installing Node.js dependencies..."
  if command -v pnpm > /dev/null; then
    pnpm install
  elif command -v yarn > /dev/null; then
    yarn install
  else
    npm install
  fi
fi

if [ -f "requirements.txt" ]; then
  echo "Installing Python dependencies..."
  if [ ! -d "venv" ]; then
    python3 -m venv venv
  fi
  source venv/bin/activate
  pip install -r requirements.txt
fi

if [ -f "go.mod" ]; then
  echo "Installing Go dependencies..."
  go mod download
fi

if [ -f "Cargo.toml" ]; then
  echo "Installing Rust dependencies..."
  cargo fetch
fi

echo "✓ Dependencies installed"
echo ""

# Step 7: Run verification
echo "Step 6/6: Running verification tests..."
if [ -f "package.json" ]; then
  if npm run test:quick > /dev/null 2>&1; then
    echo "✓ Quick tests passed"
  else
    echo "⚠ Tests failed (may be expected for first setup)"
  fi
fi
echo ""

# Summary
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "  1. Review and edit .env file with your configuration"
echo "  2. Read the documentation in docs/"
echo "  3. Run 'npm start' (or equivalent) to start development"
echo ""
echo "Need help? Check:"
echo "  - README.md"
echo "  - docs/getting-started.md"
echo "  - Project wiki: $REPO_URL/wiki"
echo ""
```

---

## Pattern 3: CI/CD Pipeline Integration

Integrate environment checks into CI/CD workflows.

**GitHub Actions**: `.github/workflows/ci.yml`

```yaml
name: CI

on: [push, pull_request]

jobs:
  environment-check:
    name: Validate Environment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version-file: '.nvmrc'

      - name: Validate Environment
        run: |
          bash scripts/check-environment.sh --json | tee env-check.json

      - name: Validate Versions
        run: |
          bash scripts/validate-versions.sh --json | tee version-check.json

      - name: Upload Environment Report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: environment-report
          path: |
            env-check.json
            version-check.json

  build:
    name: Build and Test
    needs: environment-check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm ci
      - name: Build
        run: npm run build
      - name: Test
        run: npm test
```

**GitLab CI**: `.gitlab-ci.yml`

```yaml
stages:
  - validate
  - build
  - test

validate-environment:
  stage: validate
  script:
    - bash scripts/check-environment.sh --json | tee env-check.json
    - bash scripts/validate-versions.sh --json | tee version-check.json
  artifacts:
    paths:
      - env-check.json
      - version-check.json
    expire_in: 1 week

build:
  stage: build
  dependencies:
    - validate-environment
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
```

---

## Pattern 4: Makefile Integration

Integrate environment checks into Make-based workflows.

**Makefile**:

```makefile
.PHONY: check-env check-tools check-versions check-path check-env-vars install setup clean

# Default target
all: check-env install build

# Check entire environment
check-env:
	@echo "Checking environment..."
	@bash scripts/check-environment.sh

# Check specific tools
check-tools:
	@echo "Checking required tools..."
	@bash scripts/check-tools.sh node python3 go docker

# Validate versions
check-versions:
	@echo "Validating tool versions..."
	@bash scripts/validate-versions.sh

# Check PATH configuration
check-path:
	@echo "Validating PATH..."
	@bash scripts/validate-path.sh

# Check environment variables
check-env-vars:
	@echo "Checking environment variables..."
	@bash scripts/check-env-vars.sh

# Full setup (run once)
setup: check-env
	@echo "Setting up development environment..."
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@$(MAKE) install

# Install dependencies (requires valid environment)
install: check-versions
	@echo "Installing dependencies..."
	@npm install

# Build (requires installation)
build: install
	@echo "Building project..."
	@npm run build

# Test (requires build)
test: build
	@echo "Running tests..."
	@npm test

# Start development server
dev: check-env
	@echo "Starting development server..."
	@npm run dev

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@rm -rf node_modules dist build

# Force reinstall everything
reset: clean setup
```

**Usage**:
```bash
make setup          # First-time setup
make check-env      # Quick environment check
make dev            # Start development
make test           # Run tests
make reset          # Clean and reinstall
```

---

## Pattern 5: Docker Development Environment

Use environment checks in Docker-based development workflows.

**docker-compose.yml**:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "bash", "scripts/check-tools.sh", "node"]
      interval: 30s
      timeout: 10s
      retries: 3

  environment-check:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
    command: bash scripts/check-environment.sh --verbose
```

**Dockerfile.dev**:

```dockerfile
FROM node:20-alpine

# Install bash and other utilities
RUN apk add --no-cache bash curl git

WORKDIR /app

# Copy environment scripts
COPY scripts/ ./scripts/
RUN chmod +x scripts/*.sh

# Validate base environment
RUN ./scripts/check-tools.sh node npm git

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy rest of application
COPY . .

CMD ["npm", "run", "dev"]
```

**Usage**:
```bash
# Check environment
docker-compose run environment-check

# Start development
docker-compose up app
```

---

## Pattern 6: Team Onboarding Checklist

Create an interactive onboarding experience.

**scripts/onboard.sh**:

```bash
#!/usr/bin/env bash
# onboard.sh - Interactive developer onboarding

set -e

echo "======================================"
echo "  Welcome to Project Name!"
echo "======================================"
echo ""
echo "This script will guide you through setting up"
echo "your development environment."
echo ""

# Progress tracking
completed=0
total=6

# Function to show progress
show_progress() {
  completed=$((completed + 1))
  echo ""
  echo "Progress: [$completed/$total] ━━━━━━━━━━"
  echo ""
}

# 1. Clone repository (if needed)
if [ ! -d ".git" ]; then
  echo "Step 1: Clone repository"
  echo "It looks like you haven't cloned the repository yet."
  echo "Please clone it first:"
  echo "  git clone https://github.com/username/project.git"
  exit 1
fi
echo "✓ Repository cloned"
show_progress

# 2. Check tools
echo "Step 2: Checking development tools..."
if bash scripts/check-environment.sh > /tmp/env-check.log 2>&1; then
  echo "✓ All tools installed"
else
  echo "✗ Missing tools detected"
  echo ""
  cat /tmp/env-check.log
  echo ""
  echo "Please install missing tools and run this script again."
  echo "See docs/installation.md for help."
  exit 1
fi
show_progress

# 3. Validate versions
echo "Step 3: Checking tool versions..."
if bash scripts/validate-versions.sh > /tmp/version-check.log 2>&1; then
  echo "✓ Versions are correct"
else
  echo "⚠ Version issues detected"
  cat /tmp/version-check.log
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi
show_progress

# 4. Setup environment
echo "Step 4: Environment configuration..."
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "✓ Created .env file"
  echo ""
  echo "IMPORTANT: Edit .env and add your configuration:"
  echo "  - Database connection"
  echo "  - API keys"
  echo "  - Authentication secrets"
  echo ""
  read -p "Press Enter when you've configured .env..."
fi
show_progress

# 5. Install dependencies
echo "Step 5: Installing dependencies..."
npm install
echo "✓ Dependencies installed"
show_progress

# 6. Run tests
echo "Step 6: Verifying installation..."
if npm test > /tmp/test.log 2>&1; then
  echo "✓ Tests passed"
else
  echo "⚠ Some tests failed (this may be expected)"
fi
show_progress

# Success!
echo ""
echo "======================================"
echo "  🎉 Setup Complete!"
echo "======================================"
echo ""
echo "You're ready to start developing!"
echo ""
echo "Quick commands:"
echo "  npm start       - Start development server"
echo "  npm test        - Run tests"
echo "  npm run lint    - Check code quality"
echo ""
echo "Documentation:"
echo "  README.md               - Project overview"
echo "  docs/getting-started.md - Development guide"
echo "  docs/architecture.md    - System architecture"
echo ""
echo "Need help?"
echo "  - Ask in #engineering Slack channel"
echo "  - Check the wiki: https://github.com/username/project/wiki"
echo "  - Email: team@example.com"
echo ""
```

---

## Pattern 7: Environment Monitoring Dashboard

Create a simple dashboard to monitor team environments.

**scripts/report-environment.sh**:

```bash
#!/usr/bin/env bash
# report-environment.sh - Generate HTML environment report

output_file="environment-report.html"

# Collect data
bash scripts/check-environment.sh --json > /tmp/env.json
bash scripts/validate-versions.sh --json > /tmp/versions.json 2>/dev/null || echo '{}' > /tmp/versions.json
bash scripts/validate-path.sh --json > /tmp/path.json
bash scripts/check-env-vars.sh --json > /tmp/envvars.json 2>/dev/null || echo '{}' > /tmp/envvars.json

# Generate HTML report
cat > "$output_file" <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <title>Environment Report</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 1200px; margin: 40px auto; padding: 20px; }
    .status-success { color: green; }
    .status-warning { color: orange; }
    .status-error { color: red; }
    .card { border: 1px solid #ddd; padding: 20px; margin: 20px 0; border-radius: 5px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background-color: #f5f5f5; }
  </style>
</head>
<body>
  <h1>Environment Report</h1>
  <p>Generated: <span id="timestamp"></span></p>

  <div class="card">
    <h2>Development Tools</h2>
    <div id="tools"></div>
  </div>

  <div class="card">
    <h2>Version Validation</h2>
    <div id="versions"></div>
  </div>

  <div class="card">
    <h2>PATH Configuration</h2>
    <div id="path"></div>
  </div>

  <div class="card">
    <h2>Environment Variables</h2>
    <div id="envvars"></div>
  </div>

  <script>
    document.getElementById('timestamp').textContent = new Date().toLocaleString();

    // Load and display data
    // (In production, you'd fetch this via API)
  </script>
</body>
</html>
HTML

echo "Report generated: $output_file"
echo "Open in browser: file://$(pwd)/$output_file"
```

---

## Next Steps

- See [basic-usage.md](./basic-usage.md) for simple examples
- See [advanced-usage.md](./advanced-usage.md) for complex scenarios
- See [error-handling.md](./error-handling.md) for troubleshooting
- See [integration.md](./integration.md) for using with other skills
