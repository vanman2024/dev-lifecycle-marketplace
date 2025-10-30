# Basic Usage Examples

This document demonstrates simple, common use cases for the Environment Setup skill.

## Example 1: Quick Environment Check

Check if all required development tools are installed and accessible.

```bash
# Run comprehensive environment check
bash scripts/check-environment.sh
```

**Expected Output**:
```
Checking development tools...
✓ Git version control: 2.39.2
✓ Node.js runtime: 20.11.0
✓ Python 3 interpreter: 3.11.5
✗ Go language: not found
✓ Docker container runtime: 24.0.7

Checking package managers...
✓ npm package manager: 10.2.4
✗ Yarn package manager: not found (optional)

================================
Environment Check Summary
================================

Overall Status: error

Issues Found:
  - go is not installed

Recommendations:
  - Install Go language
```

**Action**: Install missing tools based on recommendations.

---

## Example 2: Check Specific Tools

Verify if specific tools are installed without checking everything.

```bash
# Check only Node.js and Python
bash scripts/check-tools.sh node python3

# Check all supported tools
bash scripts/check-tools.sh --all

# Get JSON output for programmatic use
bash scripts/check-tools.sh --json node python3 go
```

**Example Output**:
```
✓ node
  Version: 20.11.0
  Location: /home/user/.nvm/versions/node/v20.11.0/bin/node

✓ python3
  Version: 3.11.5
  Location: /usr/bin/python3

✗ go
  Status: Not found
  Install: Install Go: https://golang.org/dl/ or use package manager
```

---

## Example 3: Validate Tool Versions

Check if installed tool versions meet project requirements defined in package.json.

**Setup**: Create a package.json with engines field:
```json
{
  "name": "my-project",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

**Run Validation**:
```bash
# Validate against package.json
bash scripts/validate-versions.sh

# Validate with verbose output
bash scripts/validate-versions.sh --json
```

**Example Output**:
```
Collecting version requirements...

Found requirements in: package.json

✓ node
  Required: >=18.0.0
  Installed: 20.11.0

✓ npm
  Required: >=9.0.0
  Installed: 10.2.4
```

---

## Example 4: Check PATH Configuration

Verify that your PATH environment variable is correctly configured.

```bash
# Basic PATH check
bash scripts/validate-path.sh

# Verbose output with all PATH entries
bash scripts/validate-path.sh --verbose
```

**Example Output**:
```
PATH Validation Results
================================

Duplicate Paths:
  - /usr/local/bin

Missing Paths:
  - /home/user/.local/bin (recommended)

Recommendations:
  - Remove duplicate PATH entries to simplify configuration
  - Add missing directories to PATH in shell configuration

Shell configuration: /home/user/.bashrc

! PATH configuration has warnings
```

---

## Example 5: Check Environment Variables

Validate that required environment variables are set.

**Setup**: Create .env.example file:
```bash
NODE_ENV=development
DATABASE_URL=
API_KEY=
```

**Run Check**:
```bash
# Check environment variables from .env files
bash scripts/check-env-vars.sh

# Check specific required variables
bash scripts/check-env-vars.sh --required NODE_ENV,DATABASE_URL,API_KEY
```

**Example Output**:
```
Validating environment variables...

✓ NODE_ENV: development
! DATABASE_URL: set but empty
✗ API_KEY: not set

================================
Environment Variables Summary
================================

Environment files found: .env .env.example

Valid: 1
Empty: 1
Missing: 1

Missing Variables:
  - API_KEY

Recommendations:
  - Create or update .env file with missing variables
```

---

## Example 6: Combined Workflow

Typical workflow when setting up a new project or onboarding a team member.

```bash
# Step 1: Clone the repository
git clone https://github.com/username/project.git
cd project

# Step 2: Run comprehensive environment check
bash .claude/plugins/foundation/skills/environment-setup/scripts/check-environment.sh --verbose

# Step 3: If issues found, check specific areas
bash .claude/plugins/foundation/skills/environment-setup/scripts/validate-path.sh
bash .claude/plugins/foundation/skills/environment-setup/scripts/validate-versions.sh

# Step 4: Check environment variables
cp .env.example .env
# Edit .env with your values
bash .claude/plugins/foundation/skills/environment-setup/scripts/check-env-vars.sh

# Step 5: Install project dependencies
npm install

# Step 6: Verify everything is working
npm test
npm start
```

---

## Common Patterns

### Pattern 1: Pre-installation Check

Before installing dependencies, verify environment is ready:

```bash
#!/usr/bin/env bash
# setup.sh

echo "Checking environment..."
if ! bash scripts/check-environment.sh; then
  echo "Environment check failed. Please fix issues before continuing."
  exit 1
fi

echo "Installing dependencies..."
npm install
```

### Pattern 2: CI/CD Pipeline Check

Use in CI/CD to verify runner environment:

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Check Environment
        run: |
          bash .claude/plugins/foundation/skills/environment-setup/scripts/check-environment.sh --json

      - name: Install Dependencies
        run: npm install

      - name: Run Tests
        run: npm test
```

### Pattern 3: Development Setup Script

Automate new developer onboarding:

```bash
#!/usr/bin/env bash
# dev-setup.sh

echo "=== Development Environment Setup ==="
echo ""

# Check tools
echo "1. Checking development tools..."
bash scripts/check-tools.sh node python3 git docker

# Validate versions
echo ""
echo "2. Validating tool versions..."
bash scripts/validate-versions.sh

# Setup environment
echo ""
echo "3. Setting up environment variables..."
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env file. Please update with your values."
fi

# Install dependencies
echo ""
echo "4. Installing dependencies..."
npm install

echo ""
echo "=== Setup Complete ==="
echo "Run 'npm start' to start development server"
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Check all tools | `bash scripts/check-environment.sh` |
| Check specific tool | `bash scripts/check-tools.sh <tool>` |
| Validate versions | `bash scripts/validate-versions.sh` |
| Check PATH | `bash scripts/validate-path.sh` |
| Check env vars | `bash scripts/check-env-vars.sh` |
| JSON output | Add `--json` flag to any command |
| Verbose output | Add `--verbose` flag to any command |

---

## Next Steps

- See [advanced-usage.md](./advanced-usage.md) for complex scenarios
- See [common-patterns.md](./common-patterns.md) for workflow patterns
- See [error-handling.md](./error-handling.md) for troubleshooting
- See [integration.md](./integration.md) for using with other skills
