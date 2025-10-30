# Error Handling and Troubleshooting

This document covers common errors, edge cases, and how to handle them when using the Environment Setup skill.

## Common Errors

### Error 1: "command not found"

**Symptom**:
```bash
$ bash scripts/check-environment.sh
bash: scripts/check-environment.sh: No such file or directory
```

**Cause**: Script not found or wrong directory

**Solutions**:

```bash
# Solution 1: Ensure you're in the project root
cd /path/to/project
bash scripts/check-environment.sh

# Solution 2: Use absolute path
bash /absolute/path/to/scripts/check-environment.sh

# Solution 3: Check if scripts directory exists
ls -la scripts/

# Solution 4: Check if skill is properly installed
ls -la .claude/plugins/foundation/skills/environment-setup/scripts/
```

---

### Error 2: Tool Not Found in PATH

**Symptom**:
```
✗ node
  Status: Not found
```

**Cause**: Tool is installed but not in PATH

**Solutions**:

```bash
# Check if tool is actually installed
which node
whereis node

# If found, add to PATH
export PATH="/path/to/node/bin:$PATH"

# Make permanent by adding to shell config
echo 'export PATH="/path/to/node/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
bash scripts/check-tools.sh node
```

**For version managers**:

```bash
# nvm not loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Add to ~/.bashrc to persist
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
```

---

### Error 3: Version Mismatch

**Symptom**:
```
✗ node
  Required: >=18.0.0
  Installed: 16.20.0 (too old)
```

**Cause**: Installed version doesn't meet requirements

**Solutions**:

**Option 1: Upgrade using version manager (recommended)**

```bash
# Using nvm for Node.js
nvm install 18
nvm use 18
nvm alias default 18

# Using pyenv for Python
pyenv install 3.11.5
pyenv global 3.11.5
```

**Option 2: Upgrade system package**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nodejs

# macOS
brew upgrade node

# Verify
node --version
```

**Option 3: Install from official source**

Visit official websites:
- Node.js: https://nodejs.org/
- Python: https://www.python.org/
- Go: https://golang.org/

---

### Error 4: Permission Denied

**Symptom**:
```bash
$ bash scripts/check-environment.sh
bash: scripts/check-environment.sh: Permission denied
```

**Cause**: Script not executable

**Solution**:

```bash
# Make script executable
chmod +x scripts/check-environment.sh

# Or run with bash explicitly
bash scripts/check-environment.sh

# Make all scripts executable
chmod +x scripts/*.sh
```

---

### Error 5: Environment Variables Not Set

**Symptom**:
```
✗ DATABASE_URL: not set
✗ API_KEY: not set
```

**Cause**: .env file missing or not loaded

**Solutions**:

**Solution 1: Create .env file**

```bash
# Copy from example
cp .env.example .env

# Edit with your values
nano .env  # or vim, code, etc.

# Verify
bash scripts/check-env-vars.sh
```

**Solution 2: Load .env manually**

```bash
# Load into current shell
export $(cat .env | xargs)

# Or use source (for bash/zsh)
source .env

# Verify
echo $DATABASE_URL
```

**Solution 3: Use dotenv loader**

```javascript
// In Node.js
require('dotenv').config();
```

```python
# In Python
from dotenv import load_dotenv
load_dotenv()
```

---

### Error 6: jq Not Installed

**Symptom**:
```
Warning: jq not installed, cannot parse package.json
```

**Cause**: jq utility not available

**Impact**: JSON parsing features won't work

**Solution**:

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Verify
jq --version
```

---

### Error 7: Version Manager Conflicts

**Symptom**:
```
node: command not found
# But:
nvm which node
/home/user/.nvm/versions/node/v20.11.0/bin/node
```

**Cause**: Version manager not initialized in current shell

**Solution**:

```bash
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify
node --version

# Ensure it's in your shell config (~/.bashrc or ~/.zshrc)
if ! grep -q "NVM_DIR" ~/.bashrc; then
  cat >> ~/.bashrc <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
EOF
fi
```

---

### Error 8: PATH Duplicates

**Symptom**:
```
Duplicate Paths:
  - /usr/local/bin
  - /usr/local/bin
  - /usr/local/bin
```

**Cause**: PATH modified multiple times in shell config

**Solution**:

```bash
# Check where duplicates are coming from
grep -n "PATH.*usr/local/bin" ~/.bashrc ~/.bash_profile ~/.zshrc

# Remove duplicates from shell config
# Edit ~/.bashrc and remove duplicate PATH exports

# Or use deduplication script
if [ -n "$PATH" ]; then
  old_PATH=$PATH:; PATH=
  while [ -n "$old_PATH" ]; do
    x=${old_PATH%%:*}
    case $PATH: in
      *:"$x":*) ;;
      *) PATH=$PATH:$x;;
    esac
    old_PATH=${old_PATH#*:}
  done
  PATH=${PATH#:}
  export PATH
fi
```

---

## Edge Cases

### Edge Case 1: WSL-Specific Issues

**Problem**: Tools installed in Windows not accessible in WSL

**Solution**:

```bash
# Don't mix Windows and WSL tools
# Install everything within WSL

# For WSL-specific PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Access Windows tools if needed
export PATH="$PATH:/mnt/c/Program Files/nodejs"
```

---

### Edge Case 2: Multiple Python Versions

**Problem**: `python` vs `python3` confusion

**Solution**:

```bash
# Always use python3 explicitly
alias python=python3

# Or create symlink
sudo ln -s /usr/bin/python3 /usr/bin/python

# Verify
python --version
python3 --version
```

---

### Edge Case 3: Docker-in-Docker

**Problem**: Running environment checks inside containers

**Solution**:

```dockerfile
# Install bash in Alpine-based images
RUN apk add --no-cache bash

# Skip Docker check inside containers
ENV SKIP_DOCKER_CHECK=true
```

```bash
# Modified check script
if [ "${SKIP_DOCKER_CHECK}" != "true" ]; then
  check_docker
fi
```

---

### Edge Case 4: Offline Environments

**Problem**: Cannot download version managers or tools

**Solution**:

```bash
# Pre-cache tools
mkdir -p ~/offline-tools

# Download installers
wget -P ~/offline-tools https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz

# Install from cache
tar -xJf ~/offline-tools/node-v20.11.0-linux-x64.tar.xz -C /usr/local --strip-components=1
```

---

### Edge Case 5: Corporate Proxy

**Problem**: Cannot download tools due to proxy

**Solution**:

```bash
# Set proxy environment variables
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.company.com"

# For npm
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080

# For pip
pip config set global.proxy http://proxy.company.com:8080

# Add to shell config
cat >> ~/.bashrc <<'EOF'
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.company.com"
EOF
```

---

## Debugging Strategies

### Strategy 1: Verbose Mode

Enable verbose output to see detailed information.

```bash
# Use --verbose flag
bash scripts/check-environment.sh --verbose
bash scripts/validate-path.sh --verbose

# Or enable bash debug mode
bash -x scripts/check-environment.sh
```

---

### Strategy 2: JSON Output for Parsing

Use JSON output for programmatic analysis.

```bash
# Get JSON output
bash scripts/check-environment.sh --json > env-status.json

# Parse with jq
jq '.tools' env-status.json
jq '.issues[]' env-status.json
jq '.recommendations[]' env-status.json

# Find specific tool status
jq '.tools.node' env-status.json
```

---

### Strategy 3: Incremental Testing

Test one component at a time.

```bash
# Test scripts individually
bash scripts/check-tools.sh node
bash scripts/check-tools.sh python3
bash scripts/check-tools.sh go

# Test specific checks
bash scripts/validate-path.sh
bash scripts/check-env-vars.sh --required NODE_ENV,PORT
```

---

### Strategy 4: Manual Verification

When scripts fail, verify manually.

```bash
# Check tool existence
command -v node
which node
whereis node

# Check version
node --version

# Check PATH
echo $PATH | tr ':' '\n'

# Check environment variables
env | grep -i node
printenv NODE_ENV
```

---

### Strategy 5: Log Collection

Collect logs for debugging or support.

```bash
# Create debug log
{
  echo "=== System Information ==="
  uname -a
  echo ""

  echo "=== Shell ==="
  echo $SHELL
  echo ""

  echo "=== PATH ==="
  echo $PATH | tr ':' '\n'
  echo ""

  echo "=== Environment Check ==="
  bash scripts/check-environment.sh --verbose 2>&1
  echo ""

  echo "=== Tool Locations ==="
  which -a node python3 go docker
  echo ""

  echo "=== Environment Variables ==="
  env | sort
} > debug-log.txt

echo "Debug log saved to: debug-log.txt"
```

---

## Recovery Procedures

### Procedure 1: Complete Reset

When environment is completely broken:

```bash
#!/usr/bin/env bash
# reset-environment.sh

set -e

echo "=== Resetting Development Environment ==="
echo ""

# Backup current config
mkdir -p ~/.env-backup
cp ~/.bashrc ~/.env-backup/bashrc.backup
cp ~/.zshrc ~/.env-backup/zshrc.backup 2>/dev/null || true

# Clean PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Reinstall version managers
echo "Reinstalling nvm..."
rm -rf ~/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

echo "Reinstalling pyenv..."
rm -rf ~/.pyenv
curl https://pyenv.run | bash

# Restore shell config
source ~/.bashrc

# Install required versions
echo "Installing Node.js..."
nvm install --lts

echo "Installing Python..."
pyenv install 3.11.5
pyenv global 3.11.5

# Verify
echo ""
echo "=== Verification ==="
bash scripts/check-environment.sh

echo ""
echo "=== Reset Complete ==="
```

---

### Procedure 2: PATH Cleanup

When PATH is completely messed up:

```bash
#!/usr/bin/env bash
# clean-path.sh

# Reset to minimal PATH
export PATH="/usr/local/bin:/usr/bin:/bin"

# Add essential directories
[ -d "/usr/local/sbin" ] && export PATH="/usr/local/sbin:$PATH"
[ -d "/usr/sbin" ] && export PATH="/usr/sbin:$PATH"
[ -d "/sbin" ] && export PATH="/sbin:$PATH"

# Add user local
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Add version managers
[ -d "$HOME/.nvm" ] && export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

[ -d "$HOME/.pyenv" ] && export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

[ -d "$HOME/.cargo" ] && export PATH="$HOME/.cargo/bin:$PATH"

# Verify
echo "Cleaned PATH:"
echo $PATH | tr ':' '\n'
```

---

## Getting Help

If issues persist:

1. **Check documentation**: Review skill docs and project README
2. **Run diagnostics**: Use `--verbose` and `--json` flags
3. **Collect logs**: Save output to a file for review
4. **Search issues**: Check GitHub issues for similar problems
5. **Ask for help**: Contact team with collected information

**When asking for help, include**:

```bash
# Generate support bundle
{
  echo "=== Environment Info ==="
  bash scripts/check-environment.sh --verbose
  echo ""
  echo "=== System Info ==="
  uname -a
  echo ""
  echo "=== Shell Config ==="
  cat ~/.bashrc
} > support-bundle.txt
```

---

## Next Steps

- See [basic-usage.md](./basic-usage.md) for simple examples
- See [advanced-usage.md](./advanced-usage.md) for complex scenarios
- See [common-patterns.md](./common-patterns.md) for workflow patterns
- See [integration.md](./integration.md) for using with other skills
