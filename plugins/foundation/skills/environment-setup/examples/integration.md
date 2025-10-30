# Integration with Other Skills and Tools

This document demonstrates how to integrate the Environment Setup skill with other skills, tools, and workflows.

## Integration 1: Project Initialization Skill

Combine environment setup with project initialization workflows.

**Example**: Integrate with project scaffolding

```bash
#!/usr/bin/env bash
# integrated-project-init.sh

project_name=$1

if [ -z "$project_name" ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

echo "=== Creating Project: $project_name ==="
echo ""

# Step 1: Check environment first
echo "Step 1: Checking environment..."
if ! bash scripts/check-environment.sh > /dev/null 2>&1; then
  echo "✗ Environment check failed"
  echo "Please fix environment issues before creating project."
  bash scripts/check-environment.sh
  exit 1
fi
echo "✓ Environment ready"
echo ""

# Step 2: Create project structure
echo "Step 2: Creating project structure..."
mkdir -p "$project_name"/{src,tests,docs,scripts}
cd "$project_name"

# Step 3: Initialize package.json with required engines
cat > package.json <<EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

# Step 4: Copy environment setup scripts
mkdir -p scripts
cp -r ../scripts/{check-environment.sh,check-tools.sh,validate-versions.sh,validate-path.sh,check-env-vars.sh} scripts/

# Step 5: Create .env.example
cat > .env.example <<EOF
NODE_ENV=development
PORT=3000
DATABASE_URL=
API_KEY=
EOF

# Step 6: Create setup documentation
cat > docs/SETUP.md <<EOF
# $project_name - Setup Guide

## Prerequisites

Run environment check:
\`\`\`bash
bash scripts/check-environment.sh
\`\`\`

## Installation

\`\`\`bash
npm install
\`\`\`

## Configuration

\`\`\`bash
cp .env.example .env
# Edit .env with your values
\`\`\`
EOF

echo "✓ Project created: $project_name"
echo ""
echo "Next steps:"
echo "  cd $project_name"
echo "  npm init -y"
echo "  bash scripts/check-environment.sh"
```

---

## Integration 2: Testing Frameworks

Integrate environment checks with test suites.

**Jest**: `jest.config.js`

```javascript
module.exports = {
  globalSetup: './test/global-setup.js',
  // ... other config
};
```

**test/global-setup.js**:

```javascript
const { execSync } = require('child_process');

module.exports = async () => {
  console.log('Checking test environment...');

  try {
    // Check environment before running tests
    execSync('bash scripts/check-environment.sh --json', {
      stdio: 'inherit'
    });

    // Verify required test tools
    execSync('bash scripts/check-tools.sh node npm docker', {
      stdio: 'inherit'
    });

    console.log('✓ Environment ready for testing');
  } catch (error) {
    console.error('✗ Environment check failed');
    console.error('Fix environment issues before running tests');
    process.exit(1);
  }
};
```

**Pytest**: `conftest.py`

```python
import subprocess
import sys
import pytest

def pytest_configure(config):
    """Check environment before running tests"""
    print("Checking test environment...")

    try:
        # Run environment check
        subprocess.run(
            ['bash', 'scripts/check-environment.sh', '--json'],
            check=True,
            capture_output=True
        )
        print("✓ Environment ready for testing")
    except subprocess.CalledProcessError as e:
        print("✗ Environment check failed")
        print("Fix environment issues before running tests")
        sys.exit(1)
```

---

## Integration 3: Build Systems

Integrate with build tools and bundlers.

**Webpack**: `webpack.config.js`

```javascript
const { execSync } = require('child_process');

// Check environment before building
try {
  execSync('bash scripts/validate-versions.sh', { stdio: 'inherit' });
} catch (error) {
  console.error('Environment validation failed');
  process.exit(1);
}

module.exports = {
  // ... webpack config
};
```

**Vite**: `vite.config.js`

```javascript
import { defineConfig } from 'vite';
import { execSync } from 'child_process';

// Check environment
try {
  execSync('bash scripts/check-environment.sh', { stdio: 'pipe' });
} catch (error) {
  console.warn('⚠ Environment check failed (continuing anyway)');
}

export default defineConfig({
  // ... vite config
});
```

---

## Integration 4: Code Quality Tools

Combine with linters and formatters.

**ESLint**: Create a pre-lint check

```json
{
  "scripts": {
    "prelint": "bash scripts/check-tools.sh node npm",
    "lint": "eslint .",
    "preformat": "bash scripts/check-tools.sh node npm",
    "format": "prettier --write ."
  }
}
```

**Husky**: `.husky/pre-commit`

```bash
#!/usr/bin/env bash
. "$(dirname -- "$0")/_/husky.sh"

# Check environment
if ! bash scripts/validate-versions.sh > /dev/null 2>&1; then
  echo "⚠ Warning: Environment version mismatch detected"
  echo "Run: bash scripts/validate-versions.sh"
fi

# Continue with lint-staged
npx lint-staged
```

---

## Integration 5: Dependency Management

Integrate with package managers and dependency tools.

**npm**: `package.json` scripts

```json
{
  "scripts": {
    "preinstall": "bash scripts/validate-versions.sh",
    "postinstall": "bash scripts/check-env-vars.sh || echo 'Remember to configure .env'",
    "env:check": "bash scripts/check-environment.sh --verbose",
    "env:validate": "bash scripts/validate-versions.sh && bash scripts/check-env-vars.sh"
  }
}
```

**pnpm**: `.npmrc`

```ini
# Require environment check before install
preinstall=bash scripts/validate-versions.sh
```

**Poetry** (Python): `pyproject.toml`

```toml
[tool.poetry.scripts]
env-check = "bash scripts/check-environment.sh"
env-validate = "bash scripts/validate-versions.sh"
```

---

## Integration 6: Container Orchestration

Integrate with Docker Compose and Kubernetes.

**Docker Compose**: `docker-compose.yml`

```yaml
version: '3.8'

services:
  # Environment validation service
  env-check:
    image: alpine:latest
    volumes:
      - ./scripts:/scripts
    command: sh -c "apk add --no-cache bash && bash /scripts/check-environment.sh"
    profiles: ["check"]

  app:
    build: .
    depends_on:
      - env-check
    environment:
      - NODE_ENV=${NODE_ENV:-development}
```

**Usage**:
```bash
# Run environment check
docker-compose --profile check run env-check

# Start application
docker-compose up app
```

**Kubernetes**: `job-env-check.yaml`

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: env-check
spec:
  template:
    spec:
      containers:
      - name: env-check
        image: your-app:latest
        command: ["bash", "scripts/check-environment.sh"]
      restartPolicy: Never
```

---

## Integration 7: Monitoring and Observability

Send environment metrics to monitoring systems.

**Example**: Send to custom endpoint

```bash
#!/usr/bin/env bash
# report-to-monitoring.sh

# Get environment status
env_status=$(bash scripts/check-environment.sh --json)

# Extract key metrics
node_version=$(echo "$env_status" | jq -r '.tools.node.version')
python_version=$(echo "$env_status" | jq -r '.tools.python.version')
overall_status=$(echo "$env_status" | jq -r '.status')

# Send to monitoring endpoint
curl -X POST https://monitoring.example.com/api/metrics \
  -H "Content-Type: application/json" \
  -d "{
    \"host\": \"$(hostname)\",
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"status\": \"$overall_status\",
    \"versions\": {
      \"node\": \"$node_version\",
      \"python\": \"$python_version\"
    }
  }"
```

**Datadog Integration**:

```bash
#!/usr/bin/env bash
# send-to-datadog.sh

env_status=$(bash scripts/check-environment.sh --json)

# Send custom metrics
echo "environment.status:1|g|#status:$overall_status,host:$(hostname)" | \
  nc -u -w1 localhost 8125

# Send service check
if [ "$overall_status" = "success" ]; then
  echo "environment.check:0|c" | nc -u -w1 localhost 8125
else
  echo "environment.check:2|c" | nc -u -w1 localhost 8125
fi
```

---

## Integration 8: Documentation Generation

Auto-generate environment documentation.

```bash
#!/usr/bin/env bash
# generate-env-docs.sh

output="docs/ENVIRONMENT.md"

cat > "$output" <<'EOF'
# Environment Documentation

This document was auto-generated from current environment configuration.

EOF

# Add current tool versions
echo "## Installed Tools" >> "$output"
echo "" >> "$output"

bash scripts/check-environment.sh --json | \
  jq -r '.tools | to_entries[] | select(.value.installed == true) | "- **\(.key)**: \(.value.version)"' >> "$output"

# Add requirements
echo "" >> "$output"
echo "## Version Requirements" >> "$output"
echo "" >> "$output"

if [ -f "package.json" ]; then
  echo "From package.json:" >> "$output"
  jq -r '.engines | to_entries[] | "- **\(.key)**: \(.value)"' package.json >> "$output"
fi

# Add PATH
echo "" >> "$output"
echo "## PATH Configuration" >> "$output"
echo "" >> "$output"
echo "\`\`\`" >> "$output"
echo "$PATH" | tr ':' '\n' >> "$output"
echo "\`\`\`" >> "$output"

echo "Documentation generated: $output"
```

---

## Integration 9: IDE/Editor Integration

Integrate with development environments.

**VSCode**: `.vscode/tasks.json`

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Check Environment",
      "type": "shell",
      "command": "bash scripts/check-environment.sh --verbose",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "problemMatcher": []
    },
    {
      "label": "Validate Versions",
      "type": "shell",
      "command": "bash scripts/validate-versions.sh",
      "problemMatcher": []
    },
    {
      "label": "Full Environment Check",
      "dependsOrder": "sequence",
      "dependsOn": ["Check Environment", "Validate Versions"],
      "problemMatcher": []
    }
  ]
}
```

**JetBrains IDEs**: `.idea/runConfigurations/Check_Environment.xml`

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Check Environment" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="bash scripts/check-environment.sh --verbose" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <method v="2" />
  </configuration>
</component>
```

---

## Integration 10: Continuous Deployment

Integrate with deployment pipelines.

**Terraform**: `main.tf`

```hcl
resource "null_resource" "env_check" {
  provisioner "local-exec" {
    command = "bash scripts/check-environment.sh"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_instance" "app" {
  # ... instance config

  depends_on = [null_resource.env_check]
}
```

**Ansible**: `playbook.yml`

```yaml
---
- name: Deploy Application
  hosts: all
  tasks:
    - name: Check local environment
      local_action:
        module: shell
        cmd: bash scripts/check-environment.sh
      delegate_to: localhost
      run_once: true

    - name: Deploy application
      # ... deployment tasks
```

---

## Integration 11: Custom Skills

Use environment-setup within other Claude Code skills.

**Example Skill**: `.claude/skills/my-skill/SKILL.md`

```markdown
---
name: My Custom Skill
description: Custom functionality requiring environment validation
---

# My Custom Skill

## Instructions

1. **Validate Environment First**:
   ```bash
   bash .claude/plugins/foundation/skills/environment-setup/scripts/check-environment.sh
   ```

2. **Check Required Tools**:
   ```bash
   bash .claude/plugins/foundation/skills/environment-setup/scripts/check-tools.sh node docker
   ```

3. **Proceed with skill operations** only if environment is valid

## Dependencies

- Requires Environment Setup skill
- Uses: check-environment.sh, check-tools.sh
```

---

## Best Practices for Integration

1. **Fail Fast**: Check environment at the earliest possible point
2. **Be Specific**: Check only what you need, not everything
3. **Cache Results**: Don't recheck unnecessarily within same session
4. **Provide Context**: Tell users why checks are running
5. **Allow Overrides**: Provide escape hatches for edge cases
6. **Log Appropriately**: Use verbose mode only when needed
7. **Handle Errors**: Provide clear error messages and recovery steps

---

## Next Steps

- See [basic-usage.md](./basic-usage.md) for simple examples
- See [advanced-usage.md](./advanced-usage.md) for complex scenarios
- See [common-patterns.md](./common-patterns.md) for workflow patterns
- See [error-handling.md](./error-handling.md) for troubleshooting
