---
description: Track deployment history (version → environment → URL)
argument-hint: <environment> <url> [--version=X.Y.Z]
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---


**Arguments**: $ARGUMENTS

Goal: Record deployment information (version, environment, URL, timestamp) in DEPLOYMENTS.md for tracking release history

Core Principles:
- Detect current version from VERSION file or accept override
- Validate environment and URL format
- Create DEPLOYMENTS.md if missing
- Append deployment record with git metadata

## Phase 1: Parse and Validate Arguments

Parse environment, URL, and optional version:

Actions:
- Extract environment from first argument (production, staging, development, etc.)
- Extract URL from second argument (must start with http:// or https://)
- Check for --version=X.Y.Z flag to override current version
- If missing arguments, display usage: /versioning:record-deployment <environment> <url> [--version=X.Y.Z]
- Normalize environment to lowercase
- Remove trailing slash from URL

## Phase 2: Determine Version

Identify version to record:

Actions:
- If --version flag provided, use specified version and validate semver format
- Otherwise, check if VERSION file exists via !{bash test -f VERSION && echo "found" || echo "missing"}
- If VERSION file missing and no --version flag, exit with: "Run /versioning:setup first or use --version flag"
- Read VERSION file and parse JSON to extract version string
- Display: "Recording deployment for version: X.Y.Z"

## Phase 3: Initialize Deployment History

Create DEPLOYMENTS.md if needed:

Actions:
- Check if DEPLOYMENTS.md exists: !{bash test -f DEPLOYMENTS.md && echo "exists" || echo "create"}
- If missing, create with markdown header documenting format
- Header should explain: Version, Environment, URL, Timestamp, Git Commit fields
- Display: "Initialized DEPLOYMENTS.md" (only if newly created)

## Phase 4: Gather Deployment Metadata

Collect deployment information:

Actions:
- Get ISO timestamp: !{bash date -u +"%Y-%m-%dT%H:%M:%SZ"}
- Get git commit hash: !{bash git rev-parse HEAD 2>/dev/null || echo "N/A"}
- Get git branch: !{bash git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A"}
- Prepare deployment entry with all metadata

## Phase 5: Record Deployment

Append deployment to DEPLOYMENTS.md:

Actions:
- Format entry as markdown with heading: [{environment}] v{version}
- Include fields: Version, Environment, URL, Timestamp, Git Commit, Git Branch
- Append to DEPLOYMENTS.md
- Verify write succeeded

## Phase 6: Git Commit Suggestion

Offer to commit the record:

Actions:
- Check if DEPLOYMENTS.md changed: !{bash git status --porcelain DEPLOYMENTS.md}
- If changed, suggest git commit command
- Format: git commit -m "chore(deploy): record v{version} deployment to {environment}"

## Phase 7: Summary

Display confirmation and recent deployments:

Actions:
- Show recorded deployment details (version, environment, URL, timestamp, commit)
- Suggest verification command: curl -I {url}
- Display last 3 deployments: !{bash grep -E "^## \[.*\] v[0-9]" DEPLOYMENTS.md | head -3}
- Show DEPLOYMENTS.md location

## Error Handling

Handle failures gracefully:

- Missing arguments: Show usage with examples
- Invalid version format: Explain semver (X.Y.Z)
- Invalid URL: Must be http:// or https://
- VERSION file missing without --version: Run /versioning:setup
- Write failure: Check file permissions
- Git failures: Continue with "N/A" for git metadata
