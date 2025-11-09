# Testing Plugin

Automated testing infrastructure for API and E2E browser testing.

## Overview

This plugin provides comprehensive testing capabilities using industry-standard tools:
- **Newman/Postman**: API testing with collections, environments, and assertions
- **Playwright**: End-to-end browser testing with cross-browser support

## Commands

- `/quality:test` - Run comprehensive test suite (Newman API + Playwright E2E)

## Skills

- **newman-testing**: Newman/Postman collection testing patterns
- **newman-runner**: Execute Newman tests with reporting
- **playwright-e2e**: Playwright E2E testing patterns
- **postman-collection-manager**: Manage Postman collections
- **api-schema-analyzer**: Analyze OpenAPI/Postman schemas

## Agents

None currently - testing is handled via commands and skills.

## Usage

```bash
# Run all tests
/quality:test

# Run specific test types
/quality:test api      # Newman API tests only
/quality:test e2e      # Playwright E2E tests only
```

## Dependencies

- Newman (npm package)
- Playwright (npm package)
- Postman collections
- Test environment configuration

## Status

Active - Production ready
