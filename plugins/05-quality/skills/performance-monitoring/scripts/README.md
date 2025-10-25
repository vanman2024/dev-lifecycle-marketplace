# Performance Monitoring Scripts

Mechanical helper scripts for performance analysis and optimization.

## Scripts

### analyze-performance.sh
**Purpose**: Identify performance bottlenecks in code
**Returns**: JSON with bottlenecks, locations, impact assessment
**Usage**: `./analyze-performance.sh [target-directory]`

### profile-memory.sh
**Purpose**: Analyze memory usage and detect leaks
**Returns**: Memory usage patterns and leak candidates
**Usage**: `./profile-memory.sh`

### check-complexity.sh
**Purpose**: Assess algorithm complexity
**Returns**: Functions with high complexity ratings
**Usage**: `./check-complexity.sh [target-file]`

### generate-performance-report.sh
**Purpose**: Generate comprehensive performance report
**Returns**: Markdown report with optimization recommendations
**Usage**: `./generate-performance-report.sh [output-file]`

## Implementation Guidelines

- All scripts should be executable (`chmod +x`)
- Use `set -euo pipefail` for bash scripts
- Return structured JSON for programmatic consumption
- Impact levels: critical, high, medium, low
- Include expected performance improvements (e.g., "50% faster")
- Provide concrete code examples for fixes
