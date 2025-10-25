---
allowed-tools: Bash(*), Read(*), Grep(*)
description: Code validation and linting
argument-hint: [--fix]
---

**Arguments**: $ARGUMENTS

## Overview

Validates code quality through linting, type checking, and style enforcement.

## Step 1: Detect Project Type and Tools

!{bash test -f package.json && echo "Node.js project" || test -f requirements.txt && echo "Python project" || test -f Cargo.toml && echo "Rust project" || echo "Unknown"}

## Step 2: Run Linter

Execute appropriate linter based on project type:

!{bash if test -f package.json; then npx eslint . 2>/dev/null || echo "ESLint not configured"; elif test -f requirements.txt; then pylint **/*.py 2>/dev/null || flake8 . 2>/dev/null || echo "No Python linter found"; elif test -f Cargo.toml; then cargo clippy 2>/dev/null || echo "Clippy not available"; fi}

## Step 3: Run Type Checker

!{bash if test -f tsconfig.json; then npx tsc --noEmit 2>/dev/null || echo "TypeScript check not available"; elif test -f requirements.txt && grep -q "mypy" requirements.txt; then mypy . 2>/dev/null || echo "MyPy not configured"; fi}

## Step 4: Check Code Style

!{bash if test -f package.json && grep -q "prettier" package.json; then npx prettier --check . 2>/dev/null || echo "Prettier not configured"; elif test -f requirements.txt && grep -q "black" requirements.txt; then black --check . 2>/dev/null || echo "Black not configured"; fi}

## Step 5: Apply Fixes (if requested)

If $ARGUMENTS contains --fix:

!{bash if test -f package.json; then npx eslint . --fix 2>/dev/null && npx prettier --write . 2>/dev/null; elif test -f requirements.txt; then black . 2>/dev/null && autopep8 --in-place --recursive . 2>/dev/null; fi && echo "Fixes applied"}

## Step 6: Report Results

Display validation summary:
- Linting errors and warnings
- Type errors
- Style violations
- Files affected
- Fix recommendations
