# Advanced Usage Examples

This document covers complex scenarios and advanced use cases for the Environment Setup skill.

## Example 1: Multi-Language Project Setup

Projects using multiple programming languages require coordinated environment checks.

**Scenario**: Full-stack application with Node.js frontend, Python backend, Go microservices.

```bash
#!/usr/bin/env bash
# multi-lang-setup.sh

set -e

echo "=== Multi-Language Environment Setup ==="

# Check all required languages
required_tools=(node npm python3 pip3 go docker)

echo "Checking required tools..."
for tool in "${required_tools[@]}"; do
  if bash scripts/check-tools.sh "$tool" > /dev/null 2>&1; then
    echo "✓ $tool"
  else
    echo "✗ $tool missing"
    missing_tools+=("$tool")
  fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
  echo ""
  echo "Missing tools: ${missing_tools[*]}"
  echo "Install missing tools and try again."
  exit 1
fi

# Validate versions against requirements
echo ""
echo "Validating versions..."

# Frontend requirements
if [ -f "frontend/package.json" ]; then
  echo "Checking frontend (Node.js)..."
  (cd frontend && bash ../scripts/validate-versions.sh)
fi

# Backend requirements
if [ -f "backend/requirements.txt" ]; then
  echo "Checking backend (Python)..."
  (cd backend && bash ../scripts/validate-versions.sh)
fi

# Services requirements
if [ -f "services/go.mod" ]; then
  echo "Checking services (Go)..."
  # Check Go version manually since go.mod uses different format
  go_version=$(go version | awk '{print $3}' | sed 's/go//')
  required_go="1.21.0"

  if [ "$(printf '%s\n' "$required_go" "$go_version" | sort -V | head -n1)" != "$required_go" ]; then
    echo "✗ Go version $go_version is older than required $required_go"
    exit 1
  else
    echo "✓ Go version $go_version"
  fi
fi

echo ""
echo "=== All checks passed ==="
```

---

## Example 2: Custom Version Requirements File

Use a custom file to specify version requirements when not using standard formats.

**Create**: `.tool-versions` (asdf format):
```
nodejs 20.11.0
python 3.11.5
golang 1.21.5
rust 1.75.0
```

**Or create**: `tool-requirements.txt`:
```
# Format: tool:version_constraint
node:>=18.0.0
python3:>=3.9.0
go:>=1.20.0
rust:>=1.70.0
docker:>=20.0.0
```

**Run Validation**:
```bash
# Using .tool-versions
bash scripts/validate-versions.sh

# Using custom requirements file
bash scripts/validate-versions.sh --requirements tool-requirements.txt
```

---

## Example 3: Environment Validation with Exit Codes

Build a robust validation system that fails fast on errors.

```bash
#!/usr/bin/env bash
# validate-environment.sh

set -e

EXIT_CODE=0

echo "=== Comprehensive Environment Validation ==="

# 1. Check tools
echo "1. Checking development tools..."
if ! bash scripts/check-environment.sh --json > /tmp/env-check.json; then
  echo "✗ Tool check failed"
  EXIT_CODE=1
else
  echo "✓ All tools present"
fi

# 2. Validate versions
echo ""
echo "2. Validating versions..."
if ! bash scripts/validate-versions.sh --json > /tmp/version-check.json; then
  echo "✗ Version validation failed"
  EXIT_CODE=1
else
  echo "✓ All versions meet requirements"
fi

# 3. Check PATH
echo ""
echo "3. Validating PATH..."
if ! bash scripts/validate-path.sh --json > /tmp/path-check.json; then
  echo "⚠ PATH has warnings (non-critical)"
  # Don't fail on PATH warnings
else
  echo "✓ PATH is valid"
fi

# 4. Check environment variables
echo ""
echo "4. Checking environment variables..."
if ! bash scripts/check-env-vars.sh --json > /tmp/env-vars-check.json; then
  echo "✗ Environment variables not properly configured"
  EXIT_CODE=1
else
  echo "✓ All environment variables set"
fi

# 5. Generate comprehensive report
if command -v jq > /dev/null; then
  echo ""
  echo "5. Generating JSON report..."

  jq -n \
    --slurpfile tools /tmp/env-check.json \
    --slurpfile versions /tmp/version-check.json \
    --slurpfile path /tmp/path-check.json \
    --slurpfile envvars /tmp/env-vars-check.json \
    '{
      tools: $tools[0],
      versions: $versions[0],
      path: $path[0],
      env_vars: $envvars[0],
      overall_status: (if '$EXIT_CODE' == 0 then "success" else "error" end)
    }' > environment-report.json

  echo "Report saved to: environment-report.json"
fi

# Cleanup
rm -f /tmp/env-check.json /tmp/version-check.json /tmp/path-check.json /tmp/env-vars-check.json

if [ $EXIT_CODE -ne 0 ]; then
  echo ""
  echo "=== Validation Failed ==="
  echo "Fix the errors above and try again."
  exit $EXIT_CODE
fi

echo ""
echo "=== All Validations Passed ==="
exit 0
```

---

## Example 4: Docker Container Environment Check

Validate environment inside Docker containers during build or runtime.

**Dockerfile**:
```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy environment check scripts
COPY scripts/ ./scripts/
RUN chmod +x scripts/*.sh

# Validate build environment
RUN apk add --no-cache bash curl && \
    ./scripts/check-tools.sh node npm && \
    ./scripts/validate-versions.sh

COPY package*.json ./
RUN npm ci --production

COPY . .

# Runtime environment check (optional)
RUN ./scripts/check-environment.sh

CMD ["node", "server.js"]
```

**Or as healthcheck**:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD bash scripts/check-tools.sh node || exit 1
```

---

## Example 5: Version Manager Integration

Automatically use version managers when available.

```bash
#!/usr/bin/env bash
# smart-version-check.sh

# Function to get Node version via nvm if available
get_node_version() {
  if [ -n "${NVM_DIR:-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
    nvm current
  elif command -v node > /dev/null; then
    node --version | sed 's/v//'
  else
    echo "not_installed"
  fi
}

# Function to get Python version via pyenv if available
get_python_version() {
  if command -v pyenv > /dev/null; then
    pyenv version | awk '{print $1}'
  elif command -v python3 > /dev/null; then
    python3 --version | awk '{print $2}'
  else
    echo "not_installed"
  fi
}

# Check and auto-switch Node version
required_node="20.11.0"
current_node=$(get_node_version)

if [ "$current_node" != "$required_node" ]; then
  if [ -n "${NVM_DIR:-}" ]; then
    echo "Switching to Node.js $required_node via nvm..."
    source "$NVM_DIR/nvm.sh"

    if ! nvm ls "$required_node" > /dev/null 2>&1; then
      echo "Installing Node.js $required_node..."
      nvm install "$required_node"
    fi

    nvm use "$required_node"
  else
    echo "Node.js version mismatch: have $current_node, need $required_node"
    echo "Install nvm for automatic version switching: https://github.com/nvm-sh/nvm"
    exit 1
  fi
fi

# Check and auto-switch Python version
required_python="3.11.5"
current_python=$(get_python_version)

if [ "$current_python" != "$required_python" ]; then
  if command -v pyenv > /dev/null; then
    echo "Switching to Python $required_python via pyenv..."

    if ! pyenv versions | grep -q "$required_python"; then
      echo "Installing Python $required_python..."
      pyenv install "$required_python"
    fi

    pyenv local "$required_python"
  else
    echo "Python version mismatch: have $current_python, need $required_python"
    echo "Install pyenv for automatic version switching: https://github.com/pyenv/pyenv"
    exit 1
  fi
fi

echo "✓ All versions configured correctly"
```

---

## Example 6: Conditional Tool Requirements

Different environments may require different tools.

```bash
#!/usr/bin/env bash
# conditional-check.sh

# Detect environment
ENV=${NODE_ENV:-development}

case $ENV in
  production)
    required_tools=(node docker git)
    ;;
  development)
    required_tools=(node python3 go docker git make)
    ;;
  test)
    required_tools=(node docker)
    ;;
  *)
    echo "Unknown environment: $ENV"
    exit 1
    ;;
esac

echo "Checking tools for environment: $ENV"
echo "Required: ${required_tools[*]}"
echo ""

missing=()
for tool in "${required_tools[@]}"; do
  if bash scripts/check-tools.sh "$tool" > /dev/null 2>&1; then
    echo "✓ $tool"
  else
    echo "✗ $tool"
    missing+=("$tool")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo ""
  echo "Missing required tools for $ENV: ${missing[*]}"
  exit 1
fi

echo ""
echo "✓ All required tools for $ENV are installed"
```

---

## Example 7: Generate Installation Script

Automatically generate installation instructions based on missing tools.

```bash
#!/usr/bin/env bash
# generate-install-script.sh

output_file="install-missing-tools.sh"

# Check environment and capture results
bash scripts/check-environment.sh --json > /tmp/env-status.json

# Parse missing tools
missing_tools=$(jq -r '.tools | to_entries[] | select(.value.installed == false) | .key' /tmp/env-status.json)

if [ -z "$missing_tools" ]; then
  echo "No missing tools - environment is complete!"
  exit 0
fi

# Generate installation script
cat > "$output_file" <<'EOF'
#!/usr/bin/env bash
# Auto-generated installation script

set -e

echo "Installing missing development tools..."

EOF

# Add installation commands for each missing tool
while IFS= read -r tool; do
  case $tool in
    node|npm)
      cat >> "$output_file" <<'EOF'
# Install Node.js via nvm
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
nvm install --lts

EOF
      ;;
    python3)
      cat >> "$output_file" <<'EOF'
# Install Python 3
if command -v apt-get > /dev/null; then
  sudo apt-get update && sudo apt-get install -y python3 python3-pip
elif command -v brew > /dev/null; then
  brew install python3
fi

EOF
      ;;
    go)
      cat >> "$output_file" <<'EOF'
# Install Go
GO_VERSION="1.21.5"
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

EOF
      ;;
    docker)
      cat >> "$output_file" <<'EOF'
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
echo "Note: Log out and back in for Docker permissions to take effect"

EOF
      ;;
  esac
done <<< "$missing_tools"

cat >> "$output_file" <<'EOF'
echo ""
echo "Installation complete!"
echo "Please restart your shell or run: source ~/.bashrc"
EOF

chmod +x "$output_file"

echo "Installation script generated: $output_file"
echo "Review the script and run: ./$output_file"
```

---

## Example 8: Monitoring Environment Drift

Track environment changes over time to detect drift.

```bash
#!/usr/bin/env bash
# track-environment.sh

snapshot_dir=".env-snapshots"
mkdir -p "$snapshot_dir"

timestamp=$(date +%Y%m%d_%H%M%S)
snapshot_file="$snapshot_dir/env-$timestamp.json"

# Capture current environment state
bash scripts/check-environment.sh --json > "$snapshot_file"

echo "Environment snapshot saved: $snapshot_file"

# Compare with previous snapshot if it exists
previous=$(ls -t "$snapshot_dir"/env-*.json 2>/dev/null | sed -n 2p)

if [ -n "$previous" ] && command -v jq > /dev/null; then
  echo ""
  echo "Comparing with previous snapshot..."

  # Compare tool versions
  jq -r '.tools | to_entries[] | "\(.key):\(.value.version)"' "$snapshot_file" | sort > /tmp/current.txt
  jq -r '.tools | to_entries[] | "\(.key):\(.value.version)"' "$previous" | sort > /tmp/previous.txt

  if ! diff -q /tmp/current.txt /tmp/previous.txt > /dev/null; then
    echo "Environment changes detected:"
    diff -u /tmp/previous.txt /tmp/current.txt || true
  else
    echo "No changes detected"
  fi

  rm /tmp/current.txt /tmp/previous.txt
fi

# Cleanup old snapshots (keep last 10)
ls -t "$snapshot_dir"/env-*.json | tail -n +11 | xargs -r rm
```

---

## Next Steps

- See [basic-usage.md](./basic-usage.md) for simple examples
- See [common-patterns.md](./common-patterns.md) for workflow patterns
- See [error-handling.md](./error-handling.md) for troubleshooting
- See [integration.md](./integration.md) for using with other skills
