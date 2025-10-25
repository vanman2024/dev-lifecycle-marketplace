---
allowed-tools: Bash(*), Read(*), Grep(*)
description: Run test suite for project
argument-hint: [--coverage]
---

**Arguments**: $ARGUMENTS

## Overview

Runs the test suite for the current project, detecting the test framework and executing appropriately.

## Step 1: Detect Project Type

!{bash test -f package.json && echo "Node.js project" || test -f requirements.txt && echo "Python project" || test -f Cargo.toml && echo "Rust project" || test -f pom.xml && echo "Java project" || echo "Unknown project type"}

## Step 2: Detect Test Framework

For Node.js:
!{bash test -f package.json && grep -q "jest" package.json && echo "Jest" || grep -q "vitest" package.json && echo "Vitest" || grep -q "mocha" package.json && echo "Mocha" || echo "No test framework detected"}

For Python:
!{bash test -f requirements.txt && grep -q "pytest" requirements.txt && echo "Pytest" || grep -q "unittest" requirements.txt && echo "Unittest" || echo "No test framework detected"}

## Step 3: Run Tests

Execute appropriate test command:

!{bash if test -f package.json; then npm test; elif test -f requirements.txt; then python -m pytest; elif test -f Cargo.toml; then cargo test; elif test -f pom.xml; then mvn test; else echo "No test command found"; fi}

## Step 4: Generate Coverage (if requested)

If $ARGUMENTS contains --coverage:

!{bash if test -f package.json; then npm run test:coverage 2>/dev/null || npx jest --coverage; elif test -f requirements.txt; then pytest --cov; else echo "Coverage not available"; fi}

## Step 5: Report Results

Display test results summary:
- Tests passed/failed
- Coverage percentage (if available)
- Recommendations for failing tests
