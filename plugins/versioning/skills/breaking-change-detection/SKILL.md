---
name: breaking-change-detection
description: OpenAPI diff tools, schema comparison, and migration guide templates for detecting breaking changes in APIs, databases, and contracts. Use when analyzing API changes, comparing OpenAPI specs, detecting breaking changes, validating backward compatibility, creating migration guides, analyzing database schema changes, or when user mentions breaking changes, API diff, schema comparison, migration guide, backward compatibility, contract validation, or API versioning.
allowed-tools: Bash, Read, Write, Edit
---

# Breaking Change Detection

Comprehensive patterns, scripts, and templates for detecting and documenting breaking changes across APIs, databases, and contracts during version bumps.

## Overview

This skill provides functional tools for detecting breaking changes in:
- **OpenAPI/REST APIs**: Endpoint changes, request/response schema modifications
- **Database schemas**: Table structure, column types, constraints
- **GraphQL schemas**: Type changes, field modifications, directive updates
- **gRPC/Protobuf**: Message structure, field number changes
- **Library contracts**: Public API changes, function signatures

All scripts include proper error handling, diff algorithms, and detailed reporting.

## Instructions

### 1. Detecting API Breaking Changes

**Analyze OpenAPI Specification Changes:**
1. Use `scripts/openapi-diff.sh` to compare two OpenAPI spec versions
2. Identifies removed endpoints, changed response codes, modified schemas
3. Generates detailed diff with breaking/non-breaking classifications
4. Use `templates/breaking-change-report.md` for documentation

**Common Breaking Changes Detected:**
- Removed endpoints or operations
- Changed HTTP methods
- Removed or renamed request/response properties
- Changed property types (string to number, etc.)
- Added required fields without defaults
- Changed authentication requirements
- Modified error response formats

### 2. Database Schema Comparison

**Detect Database Migration Issues:**
1. Use `scripts/schema-compare.sh` to compare database schemas
2. Identifies table drops, column removals, type changes
3. Detects constraint modifications (foreign keys, unique constraints)
4. Flags backward-incompatible changes

**Breaking Changes in Databases:**
- Dropped tables or views
- Removed columns
- Changed column types (especially narrowing: int to smallint)
- Added NOT NULL constraints to existing columns
- Removed or modified foreign key relationships
- Changed primary key structure

### 3. Comprehensive Breaking Change Analysis

**Analyze All Changes Across Systems:**
1. Use `scripts/analyze-breaking.sh` as orchestrator script
2. Runs all detection scripts (API, schema, contract)
3. Aggregates results into unified report
4. Assigns severity levels (CRITICAL, HIGH, MEDIUM, LOW)
5. Generates migration guide template

**Analysis Process:**
```bash
# Run comprehensive analysis
bash scripts/analyze-breaking.sh \
  --old-api old-spec.yaml \
  --new-api new-spec.yaml \
  --old-schema old-schema.sql \
  --new-schema new-schema.sql \
  --output breaking-changes-report.md
```

### 4. Creating Migration Guides

**Document Breaking Changes for Users:**
1. Use `templates/migration-guide.md` as starting template
2. Use `templates/migration-guide-api.md` for API-specific changes
3. Use `templates/migration-guide-database.md` for schema changes
4. Include before/after code examples
5. Provide step-by-step migration instructions
6. Document workarounds and alternatives

**Migration Guide Structure:**
- **Summary**: Overview of breaking changes
- **Impact**: Who is affected and how
- **Migration Steps**: Step-by-step instructions
- **Code Examples**: Before and after
- **Timeline**: Deprecation schedule if applicable
- **Support**: Where to get help

### 5. Automated Detection in CI/CD

**Integrate Breaking Change Detection:**
1. Use `templates/ci-cd-breaking-check.yaml` for GitHub Actions/GitLab CI
2. Run detection on every PR that modifies API specs or schemas
3. Fail builds if breaking changes detected without proper versioning
4. Generate automated migration guide drafts
5. Post results as PR comments

**CI/CD Integration Pattern:**
```yaml
# Detect breaking changes before merge
- name: Check for breaking changes
  run: bash scripts/analyze-breaking.sh --old $BASE_BRANCH --new $HEAD_BRANCH

- name: Fail if breaking changes without major version bump
  if: breaking_detected && !major_version_bump
  run: exit 1
```

### 6. Severity Classification

**Classify Breaking Changes by Impact:**

**CRITICAL (Immediate user impact):**
- Removed API endpoints
- Dropped database tables
- Changed authentication requirements

**HIGH (Requires code changes):**
- Renamed fields/properties
- Changed data types
- Added required parameters

**MEDIUM (Behavior changes):**
- Modified validation rules
- Changed default values
- Updated error messages

**LOW (Documentation updates):**
- Deprecated but still functional
- Added optional fields
- Changed response ordering

### 7. Backward Compatibility Strategies

**Minimize Breaking Changes:**
1. Add new fields instead of modifying existing
2. Deprecate before removing (gradual migration)
3. Support multiple versions simultaneously
4. Use feature flags for behavioral changes
5. Provide adapter/shim layers
6. Document deprecation timelines clearly

**Non-Breaking Alternatives:**
- Add new v2 endpoints instead of modifying v1
- Add optional fields instead of required
- Expand types instead of narrowing (accept more)
- Add database columns as nullable

## Available Scripts

1. **openapi-diff.sh**: Compare two OpenAPI/Swagger specifications and identify breaking changes
   - Detects endpoint changes, schema modifications, authentication changes
   - Classifies changes as breaking/non-breaking
   - Generates detailed diff report with examples

2. **schema-compare.sh**: Compare database schemas (SQL, migrations, Prisma, etc.)
   - Identifies table/column drops, type changes, constraint modifications
   - Works with PostgreSQL, MySQL, SQLite schemas
   - Detects data migration requirements

3. **analyze-breaking.sh**: Orchestrator script that runs all detection tools
   - Unified interface for comprehensive analysis
   - Aggregates results across API, database, and contract changes
   - Generates prioritized action items
   - Creates migration guide template

4. **graphql-diff.sh**: Compare GraphQL schemas for breaking changes
   - Type changes, field removals, directive modifications
   - Argument type changes, nullability changes

5. **proto-diff.sh**: Compare Protobuf definitions for gRPC services
   - Field number changes, message structure modifications
   - Service method signature changes

## Available Templates

1. **breaking-change-report.md**: Comprehensive report template with sections for each change type
2. **migration-guide.md**: General migration guide template with step-by-step structure
3. **migration-guide-api.md**: API-specific migration guide with code examples
4. **migration-guide-database.md**: Database migration guide with SQL snippets
5. **ci-cd-breaking-check.yaml**: GitHub Actions/GitLab CI workflow template
6. **deprecation-notice.md**: Deprecation announcement template for gradual migrations

## Available Examples

1. **api-contract-analysis.md**: Real-world example of OpenAPI diff analysis with breaking changes identified
2. **database-migration-detection.md**: Database schema comparison example with migration steps
3. **graphql-schema-changes.md**: GraphQL type evolution example with client impact analysis
4. **versioning-strategy.md**: Complete versioning strategy example integrating breaking change detection
5. **ci-cd-integration.md**: Full CI/CD pipeline integration with automated detection and reporting

## Requirements

**Core Requirements:**
- `jq` - JSON parsing and manipulation
- `yq` - YAML parsing (for OpenAPI specs)
- `diff` - File comparison utility
- `git` - Version control for diff context

**Optional Requirements:**
- `openapi-diff` - Enhanced OpenAPI comparison (npm package)
- `oasdiff` - Alternative OpenAPI diff tool
- `schemacrawler` - Database schema analysis
- `protoc` - Protocol buffer compiler (for gRPC)
- `rover` - GraphQL schema tooling (Apollo)

**Installation Commands:**
```bash
# Core tools (usually pre-installed)
apt-get install jq diffutils git

# YAML parsing
pip install yq

# Optional OpenAPI tools
npm install -g openapi-diff oasdiff

# Database tools
brew install schemacrawler  # macOS
apt-get install schemacrawler  # Linux
```

## Exit Codes

All scripts follow standard exit code conventions:

- `0` - No breaking changes detected
- `1` - Breaking changes detected (see report)
- `2` - Invalid arguments or missing dependencies
- `3` - File read/parse errors
- `4` - Comparison failed (incompatible formats)

## Best Practices

1. **Run detection on every PR** - Catch breaking changes before merge
2. **Version appropriately** - Breaking changes require major version bump
3. **Document thoroughly** - Create comprehensive migration guides
4. **Test migrations** - Validate migration steps in staging environment
5. **Communicate early** - Announce breaking changes well in advance
6. **Provide alternatives** - Document workarounds and migration paths
7. **Support multiple versions** - Allow gradual migration when possible
8. **Use deprecation periods** - Give users time to adapt
9. **Automate detection** - Integrate into CI/CD pipelines
10. **Archive breaking changes** - Keep historical record for reference

## Integration with Versioning Commands

This skill is used by versioning plugin commands:

- **/versioning:bump** - Runs breaking change detection before version bump
- **/versioning:info** - Shows breaking changes in current version
- **/versioning:validate** - Validates breaking changes match version bump type

## Progressive Disclosure

For additional reference material:
- Read `examples/api-contract-analysis.md` for OpenAPI diff examples
- Read `examples/database-migration-detection.md` for schema change patterns
- Read `examples/ci-cd-integration.md` for pipeline integration
- Read `examples/versioning-strategy.md` for complete workflow

---

**Skill Location**: plugins/versioning/skills/breaking-change-detection/SKILL.md
**Version**: 1.0.0
