---
name: Test Framework Integration
description: Integrate and execute test frameworks with project detection. Use when running tests, generating test scaffolds, analyzing test coverage, or when user mentions testing, test suites, unit tests, integration tests, test frameworks, Jest, Vitest, pytest, or test execution.
---

# Test Framework Integration

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides test framework detection, execution scripts, and test scaffold templates for various frameworks (Jest, Vitest, pytest, Mocha, Cargo test, etc.).

## Instructions

### Test Framework Detection

1. Analyze project files to detect test framework
2. Identify test directories and configuration files
3. Determine appropriate test commands

### Test Execution

1. Use `scripts/detect-test-framework.sh` to identify framework
2. Use `scripts/run-tests.sh` to execute test suite
3. Use `scripts/generate-coverage.sh` for coverage reports

### Test Scaffold Generation

1. Use templates for common test patterns
2. Generate test files based on detected framework
3. Include setup, teardown, and assertions

## Available Scripts

- **detect-test-framework.sh**: Analyzes project and returns test framework
- **run-tests.sh**: Executes tests with framework-specific commands
- **generate-coverage.sh**: Generates coverage reports
- **scaffold-test.sh**: Creates test file scaffolds

## Templates

- **jest-test.template**: Jest/Vitest test structure
- **pytest-test.template**: Python pytest structure
- **mocha-test.template**: Mocha test structure
- **rust-test.template**: Rust test structure

## Requirements

- Scripts must be project-agnostic (detect, don't assume)
- Support multiple test frameworks per project type
- Provide clear error messages when framework not detected
- Generate coverage reports in standard formats
