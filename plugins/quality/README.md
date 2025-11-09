# Quality Plugin

Code quality validation, performance analysis, and compliance checking for projects.

## Overview

This plugin provides comprehensive quality assurance capabilities:
- **Code Validation**: Review implementation against spec requirements, security rules
- **Task Validation**: Verify tasks marked complete have actual implementation
- **Performance Analysis**: Identify bottlenecks and optimization opportunities
- **Compliance Checking**: Ensure licensing, code standards, and regulatory compliance
- **Agent Auditing**: Validate agent/command files for architectural compliance

## Commands

- `/quality:validate-code` - Review implementation code against spec requirements and generate test recommendations
- `/quality:validate-tasks` - Validate that completed tasks have corresponding implementation work
- `/quality:performance` - Analyze performance and identify bottlenecks with optimization recommendations

## Skills

- **api-schema-analyzer**: Analyze OpenAPI and Postman schemas for MCP tool generation. Use when analyzing API specifications, extracting endpoint information, generating tool signatures, or when user mentions OpenAPI, Swagger, API schema, endpoint analysis.

## Agents

- **agent-auditor**: Audits agent AND command files to identify slash command chaining anti-patterns, validate tool usage (slash commands, skills, MCP servers, hooks), and ensure compliance with Dan's Composition Pattern architectural principles
- **code-validator**: Review implementation code against spec requirements, check security rules, and generate comprehensive test recommendations
- **task-validator**: Validate that tasks marked complete in tasks.md actually have corresponding implementation work done
- **performance-analyzer**: Analyzes performance and identifies bottlenecks with optimization recommendations
- **compliance-checker**: Checks project compliance with licensing, code standards, and regulatory requirements

## Usage

```bash
# Validate code implementation
/quality:validate-code spec-001

# Validate task completion
/quality:validate-tasks spec-001

# Analyze performance
/quality:performance
```

## Dependencies

- Spec files in `specs/` directory
- Implementation code in project
- Task tracking in `tasks.md` files

## Status

Active - Production ready
