---
description: AI-powered release notes with migration guides and breaking change analysis
argument-hint: "[version] [--output=FILE]"
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Generate comprehensive AI-powered release notes with changelog, migration guides, breaking change analysis, and upgrade instructions

Core Principles:
- Parse version from arguments or detect from VERSION file
- Generate changelog using changelog-generator agent
- Validate release quality using release-validator agent
- Add AI-powered analysis for migration guidance
- Detect breaking changes and generate upgrade paths
- Format as professional release notes

## Available Skills

This command has access to the following skills from the versioning plugin:

- **version-manager**: Version parsing, changelog formatting, and release note templates

**To use a skill:**
Use the skill command pattern when you need:
- Domain-specific templates and examples
- Validation scripts and automation
- Best practices and patterns
- Configuration generators

Skills provide pre-built resources to accelerate your work.

---


## Phase 1: Parse Arguments and Determine Version

Parse target version and output options:

Actions:
- Extract version from $ARGUMENTS (e.g., "1.2.3" or "v1.2.3")
- Check for --output=FILE flag to save to file
- If no version provided, read from VERSION file
- Normalize version format (strip "v" prefix if present)
- Validate version matches semver: MAJOR.MINOR.PATCH
- Display: "Generating release notes for vX.Y.Z"

## Phase 2: Validate Release Readiness

Invoke the release-validator agent to check quality:

Actions:
- Invoke the release-validator agent with instruction: "Validate release readiness for version X.Y.Z"
- Capture validation report
- Extract critical issues and warnings
- If critical issues: display errors, list fixes, exit
- If warnings: display warnings, continue generation

## Phase 3: Generate Changelog

Invoke the changelog-generator agent to create formatted output:

Actions:
- Invoke the changelog-generator agent with instruction: "Generate changelog for version X.Y.Z"
- Capture formatted changelog
- Parse sections: Breaking Changes, Features, Bug Fixes, Performance
- Extract commit count and contributor count

## Phase 4: Analyze Breaking Changes

Generate migration guidance for breaking changes:

Actions:
- Extract breaking change commits from changelog
- For each: identify affected APIs, analyze diff, determine impact
- Create Migration Guide section with upgrade instructions and code examples
- If no breaking changes: note backward-compatible release

## Phase 5: Generate Upgrade Instructions

Create language-specific upgrade commands:

Actions:
- Detect project type: check pyproject.toml or package.json
- Generate upgrade commands: pip/poetry for Python, npm/yarn for JavaScript
- Add verification steps: check version, run tests

## Phase 6: Create Release Highlights

Generate AI summary of key changes:

Actions:
- Analyze features from changelog
- Identify significant changes: new features, performance, security fixes
- Create 3-5 sentence summary with key capabilities and improvements

## Phase 7: Format and Output Release Notes

Combine sections into comprehensive release notes:

Actions:
- Construct release notes: header, highlights, breaking changes, migration guide, changelog, upgrade instructions, validation summary, contributors
- Format with Markdown syntax
- Include GitHub compare and download links
- If --output flag: write to file
- Otherwise: display to stdout
- Show next steps: gh release create command and tips

## Error Handling

- Invalid version format → display semver requirements
- VERSION file missing → suggest /versioning:setup
- Not git repository → exit with error
- No commits → exit with "no changes to document"
- Agent failure → display error, suggest manual generation
- Critical validation issues → block generation, list fixes
