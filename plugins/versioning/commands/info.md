---
description: Display version information and validate configuration
argument-hint: [status|validate|history]
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


## Security Requirements

**CRITICAL:** All generated files must follow @docs/security/SECURITY-RULES.md

**Arguments**: $ARGUMENTS

Goal: Provide comprehensive version information, validate setup, and display version history

Core Principles:
- Display current version status
- Validate version management configuration
- Show version history and changelog
- Detect issues and suggest fixes

## Available Skills

- **version-manager**: Version validation scripts and templates

---

## Phase 1: Parse Action

Actions:
- Parse $ARGUMENTS for action: status, validate, or history
- Default to "status" if no argument provided
- Validate action is one of the three options

## Phase 2: Delegate to Inspector Agent

Launch version-inspector agent for detailed analysis:

```
Task(
  description="Inspect version information",
  subagent_type="versioning:version-inspector",
  prompt="You are the version-inspector agent.

**Action**: $ACTION (status/validate/history)

**Tasks**:

For 'status' action:
1. Check if VERSION file exists
   - If not: Display '❌ Version management not setup - run /versioning:setup'
   - Exit if not found

2. Read VERSION file and parse JSON:
   - Extract: version, commit, build_date, build_type

3. Check version consistency:
   - Python: Compare VERSION vs pyproject.toml
   - JavaScript/TypeScript: Compare VERSION vs package.json
   - Flag mismatches

4. Check git tags:
   - Get latest tag: git describe --tags --abbrev=0
   - Compare with VERSION file
   - Check if local is behind remote

5. Count pending commits since last tag:
   - Count total: git rev-list <tag>..HEAD --count
   - Categorize by type (feat, fix, docs, etc.)

6. Display formatted status:
   ```
   📦 Version Status

   Current Version: <version>
   Last Tag: <tag>
   Pending Commits: <count> (<breakdown by type>)

   Files:
   - VERSION: <version>
   - <manifest>: <version> (<match/mismatch>)

   Next Version: <suggested based on commits>
   ```

For 'validate' action:
1. Check VERSION file format (valid JSON)
2. Verify git tags exist and follow v*.*.* pattern
3. Check GitHub Actions workflow exists
4. Verify conventional commits in recent history
5. Check for version file sync scripts
6. Validate .gitmessage template exists

Display validation report:
   ```
   ✅ Validation Results

   - VERSION file: ✓/✗
   - Git tags: ✓/✗
   - GitHub workflow: ✓/✗
   - Conventional commits: ✓/✗
   - Commit template: ✓/✗

   Issues: <list any problems>
   Recommendations: <suggested fixes>
   ```

For 'history' action:
1. Get all version tags: git tag -l 'v*' --sort=-version:refname
2. For each tag, show:
   - Version number
   - Date created
   - Commit count from previous version
   - Changelog (if CHANGELOG.md exists)

Display history:
   ```
   📜 Version History

   v1.2.3 (2025-01-15) - 12 commits
   - feat: New feature X
   - fix: Bug fix Y

   v1.2.2 (2025-01-10) - 5 commits
   - fix: Critical bug Z
   ...
   ```

**Deliverable**: Formatted output for the requested action
"
)
```

## Phase 3: Display Results

Actions:
- Show agent output directly to user
- For status: Suggest next action based on pending commits
- For validate: Provide fix commands for any issues
- For history: Suggest using /versioning:bump for next release
