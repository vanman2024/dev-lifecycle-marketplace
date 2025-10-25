# Quality Plugin (05-quality)

Testing & Validation: Test, validate, secure, optimize, ensure compliance

## Overview

The Quality plugin provides comprehensive quality assurance tools for projects, including testing, security scanning, performance analysis, validation, and compliance checking.

## Commands

### Orchestrator
- `/quality` - Main quality orchestrator, routes to appropriate quality checks

### Granular Commands
- `/quality:test` - Run test suite for project
- `/quality:test-generate` - Generate test scaffolds
- `/quality:security` - Security vulnerability scanning
- `/quality:performance` - Performance analysis and optimization
- `/quality:validate` - Code validation and linting
- `/quality:compliance` - Compliance and licensing validation

## Agents

- **test-generator** - Generates comprehensive test suites
- **security-scanner** - Scans for security vulnerabilities
- **performance-analyzer** - Analyzes performance bottlenecks
- **compliance-checker** - Checks compliance requirements

## Skills

- **test-framework-integration** - Test framework detection and execution
- **security-scanning** - Security vulnerability scanning patterns
- **performance-monitoring** - Performance analysis and optimization

## Usage

```bash
# Run tests
/quality:test

# Generate test scaffolds
/quality:test-generate src/utils/helper.js

# Security scan
/quality:security

# Performance analysis
/quality:performance src/

# Validate code
/quality:validate --fix

# Check compliance
/quality:compliance --report
```

## Installation

This plugin is part of the ai-dev-marketplace lifecycle plugins.

## License

MIT
