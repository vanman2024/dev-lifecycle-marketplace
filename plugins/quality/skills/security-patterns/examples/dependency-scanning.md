# Dependency Scanning Example

Multi-language dependency vulnerability scanning across JavaScript, Python, Rust, and Go projects.

## Scenario

You maintain a monorepo with services in different languages and need to scan all dependencies for known CVEs.

## Project Structure

```
monorepo/
├── frontend/           # React (JavaScript)
│   ├── package.json
│   └── package-lock.json
├── backend/            # FastAPI (Python)
│   ├── requirements.txt
│   └── Pipfile.lock
├── api-gateway/        # Go
│   └── go.mod
├── data-processor/     # Rust
│   └── Cargo.toml
└── security-scans/     # Scan results directory
```

## Step 1: Scan All Dependencies

```bash
cd /path/to/monorepo
bash /path/to/scripts/scan-dependencies.sh . > security-scans/dependencies-scan.json
```

## Step 2: Review Multi-Language Results

### Example Output

```json
{
  "scan_timestamp": "2025-10-29T16:00:00Z",
  "project_directory": "./monorepo",
  "total_vulnerabilities": 8,
  "severity_breakdown": {
    "critical": 2,
    "high": 3,
    "medium": 2,
    "low": 1
  },
  "vulnerabilities": [
    {
      "package": "lodash",
      "severity": "high",
      "title": "Prototype Pollution",
      "cve": "CVE-2020-8203",
      "cvss_score": 7.4,
      "vulnerable_versions": "<4.17.21",
      "fixed_version": "4.17.21",
      "url": "https://github.com/advisories/GHSA-p6mc-m468-83gw"
    },
    {
      "package": "pillow",
      "severity": "critical",
      "title": "Arbitrary Code Execution",
      "cve": "CVE-2023-44271",
      "cvss_score": 9.8,
      "vulnerable_versions": "<10.0.1",
      "fixed_version": "10.0.1",
      "url": "https://github.com/advisories/GHSA-56pw-mpj4-fxww"
    }
  ]
}
```

## Step 3: Prioritize Fixes by Severity

### Critical Vulnerabilities (Fix Immediately)

**1. Pillow CVE-2023-44271 (Python)**
- CVSS Score: 9.8
- Current Version: 9.5.0
- Fixed Version: 10.0.1
- Impact: Remote code execution

**Fix:**
```bash
cd backend
pip install --upgrade pillow==10.0.1
pip freeze > requirements.txt
```

### High Vulnerabilities (Fix Within 1 Week)

**2. Lodash Prototype Pollution (JavaScript)**
- CVSS Score: 7.4
- Current Version: 4.17.15
- Fixed Version: 4.17.21
- Impact: Denial of service, property injection

**Fix:**
```bash
cd frontend
npm update lodash --save
# Verify
npm audit
```

## Step 4: Handle Transitive Dependencies

### Scenario: Vulnerable Indirect Dependency

**Problem:**
```
your-app
└── express-fileupload@1.3.1
    └── busboy@0.3.1 (VULNERABLE CVE-2022-XXXXX)
```

**Solution 1: Update Parent Package**
```bash
npm update express-fileupload --save
```

**Solution 2: Use Package Overrides (npm 8.3+)**
```json
{
  "name": "your-app",
  "overrides": {
    "busboy": "^1.6.0"
  }
}
```

**Solution 3: Use Resolutions (yarn)**
```json
{
  "resolutions": {
    "busboy": "^1.6.0"
  }
}
```

## Step 5: Language-Specific Workflows

### JavaScript/TypeScript (npm)

```bash
# Audit
npm audit

# Fix automatically (careful - may break things)
npm audit fix

# Fix only production dependencies
npm audit fix --only=prod

# Force fix (may introduce breaking changes)
npm audit fix --force

# Generate detailed report
npm audit --json > npm-audit.json
```

### Python (pip + safety)

```bash
# Install safety
pip install safety

# Scan
safety check

# Scan with JSON output
safety check --json > safety-report.json

# Check specific file
safety check -r requirements.txt

# Alternative: pip-audit
pip install pip-audit
pip-audit
```

### Rust (cargo-audit)

```bash
# Install cargo-audit
cargo install cargo-audit

# Scan
cargo audit

# JSON output
cargo audit --json > cargo-audit.json

# Fix advisories
cargo audit fix
```

### Go (govulncheck)

```bash
# Install govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest

# Scan
govulncheck ./...

# JSON output
govulncheck -json ./... > govulncheck.json
```

## Step 6: Evaluate "No Fix Available" Cases

### When a Fix Doesn't Exist

1. **Check if vulnerability affects your usage**
   - Read advisory details
   - Determine if vulnerable code path is executed
   - Assess actual risk vs theoretical risk

2. **Implement workarounds**
   - Input validation
   - Sandboxing
   - Rate limiting
   - Network segmentation

3. **Find alternative package**
   - Research replacements on npm/PyPI
   - Consider maintained forks
   - Evaluate migration effort

4. **Vendor patch** (last resort)
   - Fork the package
   - Apply security patch
   - Maintain fork until upstream fixes

### Example: No Fix Available

```javascript
// Vulnerable package with no fix
const oldParser = require('old-xml-parser'); // CVE-2024-XXXXX, no fix

// Workaround: Add input validation
function safeParseXML(xmlString) {
  // Validate input size
  if (xmlString.length > 1000000) {
    throw new Error('XML too large');
  }

  // Sanitize input
  const sanitized = xmlString.replace(/<!ENTITY/g, '');

  return oldParser.parse(sanitized);
}
```

## Step 7: Automated Dependency Updates

### Dependabot (GitHub)

Create `.github/dependabot.yml`:
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/frontend"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10

  - package-ecosystem: "pip"
    directory: "/backend"
    schedule:
      interval: "weekly"

  - package-ecosystem: "gomod"
    directory: "/api-gateway"
    schedule:
      interval: "weekly"

  - package-ecosystem: "cargo"
    directory: "/data-processor"
    schedule:
      interval: "weekly"
```

### Renovate

Create `renovate.json`:
```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:base"],
  "vulnerabilityAlerts": {
    "enabled": true
  },
  "packageRules": [
    {
      "matchUpdateTypes": ["major"],
      "automerge": false
    },
    {
      "matchUpdateTypes": ["minor", "patch"],
      "matchCurrentVersion": "!/^0/",
      "automerge": true
    }
  ]
}
```

## Step 8: CI/CD Integration

### GitHub Actions

```yaml
name: Security Scan - Dependencies
on: [push, pull_request]

jobs:
  scan-dependencies:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Scan JavaScript dependencies
        run: |
          cd frontend
          npm audit --audit-level=high

      - name: Scan Python dependencies
        run: |
          cd backend
          pip install safety
          safety check -r requirements.txt

      - name: Scan Go dependencies
        run: |
          cd api-gateway
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...

      - name: Scan Rust dependencies
        run: |
          cd data-processor
          cargo install cargo-audit
          cargo audit

      - name: Fail on critical vulnerabilities
        run: |
          bash scripts/scan-dependencies.sh .
          # Exit code 1 if critical/high found
```

## Step 9: Document Exceptions

### Create exceptions.json

For vulnerabilities you've assessed and accepted:

```json
{
  "exceptions": [
    {
      "package": "old-library",
      "cve": "CVE-2023-12345",
      "reason": "Vulnerability does not affect our usage (we don't use vulnerable function)",
      "approved_by": "security-team@company.com",
      "expiry_date": "2025-12-31",
      "compensating_controls": [
        "Input validation",
        "Network isolation"
      ]
    }
  ]
}
```

## Step 10: Regular Monitoring

### Weekly Routine

```bash
#!/bin/bash
# weekly-dependency-scan.sh

echo "=== Weekly Dependency Security Scan ==="
date

# Scan all projects
bash scripts/scan-dependencies.sh . > weekly-scan.json

# Check for new vulnerabilities
CRITICAL=$(jq '.severity_breakdown.critical' weekly-scan.json)
HIGH=$(jq '.severity_breakdown.high' weekly-scan.json)

echo "Critical: $CRITICAL"
echo "High: $HIGH"

# Alert if critical found
if [ "$CRITICAL" -gt 0 ]; then
  # Send alert (Slack, email, etc.)
  echo "ALERT: Critical vulnerabilities found!"
fi
```

## Best Practices

1. **Scan regularly** - Weekly minimum, daily for critical systems
2. **Automate updates** - Use Dependabot/Renovate for patch/minor updates
3. **Test before deploying** - Run full test suite after updates
4. **Monitor CVE databases** - Subscribe to security advisories
5. **Keep dependencies minimal** - Remove unused packages
6. **Pin major versions** - Avoid unexpected breaking changes
7. **Review dependency licenses** - Ensure license compliance
8. **Audit new dependencies** - Check before adding to project
9. **Maintain update schedule** - Regular maintenance windows
10. **Document exceptions** - Track accepted risks with expiry dates

## Next Steps

- [OWASP Compliance Example](./owasp-compliance.md)
- [CI/CD Security Integration](./ci-cd-security-integration.md)
- [Security Report Interpretation](./security-report-interpretation.md)
