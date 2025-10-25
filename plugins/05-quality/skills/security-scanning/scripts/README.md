# Security Scanning Scripts

Mechanical helper scripts for security vulnerability detection.

## Scripts

### scan-secrets.sh
**Purpose**: Detect exposed secrets and credentials in code
**Returns**: JSON with found secrets, file locations, line numbers
**Usage**: `./scan-secrets.sh [directory]`

### scan-dependencies.sh
**Purpose**: Check dependencies for known vulnerabilities
**Returns**: List of vulnerable packages with CVE details
**Usage**: `./scan-dependencies.sh`

### check-headers.sh
**Purpose**: Validate security headers configuration
**Returns**: Missing or misconfigured security headers
**Usage**: `./check-headers.sh`

### generate-security-report.sh
**Purpose**: Generate comprehensive security audit report
**Returns**: Markdown report with all findings
**Usage**: `./generate-security-report.sh [output-file]`

## Implementation Guidelines

- All scripts should be executable (`chmod +x`)
- Use `set -euo pipefail` for bash scripts
- Return structured JSON for programmatic consumption
- Severity levels: critical, high, medium, low, info
- Include remediation recommendations for each finding
- Support: npm audit, pip-audit, cargo audit, etc.
