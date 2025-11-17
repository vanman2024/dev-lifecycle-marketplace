---
allowed-tools: Read, Write, Edit, Bash, Glob, AskUserQuestion
description: Manage semantic versioning and releases
argument-hint: [major|minor|patch] [--tag] [--changelog]
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

## Step 1: Detect Project Type and Current Version

Find version file based on project type:

!{bash find . -maxdepth 2 -type f \( -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "go.mod" -o -name "version.txt" \) 2>/dev/null | head -1}

Load and parse current version:

**Node.js (package.json):** @package.json
**Python (pyproject.toml):** @pyproject.toml
**Rust (Cargo.toml):** @Cargo.toml
**Go (version.txt or git tag):** !{git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0"}

Extract current version number.

## Step 2: Determine Version Bump Type

**If arguments provided:**
- major: 1.0.0 -> 2.0.0 (breaking changes)
- minor: 1.0.0 -> 1.1.0 (new features)
- patch: 1.0.0 -> 1.0.1 (bug fixes)

**If no arguments:**

Ask user which version component to bump:

AskUserQuestion:
- Version bump type? (major, minor, patch)
- Create git tag? (yes/no)
- Generate changelog? (yes/no)

## Step 3: Calculate New Version

Parse current version and increment:

Current: X.Y.Z

**Major bump:** (X+1).0.0
**Minor bump:** X.(Y+1).0
**Patch bump:** X.Y.(Z+1)

Display version change:
- Current version: X.Y.Z
- New version: A.B.C

## Step 4: Update Version Files

Update version based on project type:

**Node.js:**
Edit package.json version field

**Python:**
Edit pyproject.toml version field in [project] or [tool.poetry]

**Rust:**
Edit Cargo.toml version field in [package]

**Go:**
Create/update VERSION or version.txt file

**Generic:**
Create version.txt if no project file exists

## Step 5: Check for Uncommitted Changes

!{git status --porcelain}

**If uncommitted changes exist:**
- Display: "Warning: Uncommitted changes detected"
- Ask: "Commit version changes now?"

## Step 6: Commit Version Update

**If user confirms commit:**

Stage version file:

!{git add package.json pyproject.toml Cargo.toml VERSION version.txt 2>/dev/null}

Create version bump commit:

!{git commit -m "chore: bump version to NEW_VERSION"}

## Step 7: Create Git Tag (Optional)

**If --tag flag OR user selected yes:**

Create annotated tag:

!{git tag -a vNEW_VERSION -m "Release NEW_VERSION"}

Display: "Git tag vNEW_VERSION created"

**Note:** Push tags with: git push --tags

## Step 8: Generate Changelog (Optional)

**If --changelog flag OR user selected yes:**

Get commits since last tag:

!{git log --oneline --pretty=format:"%h %s" $(git describe --tags --abbrev=0 @^)..@ 2>/dev/null || git log --oneline --pretty=format:"%h %s"}

Parse conventional commit types:
- feat: New features
- fix: Bug fixes
- docs: Documentation
- chore: Maintenance
- refactor: Code refactoring
- test: Testing
- perf: Performance

Generate or update CHANGELOG.md with:
- Version number and date
- Categorized changes
- Commit links

## Step 9: Display Release Summary

Show version update details:
- Old version: X.Y.Z
- New version: A.B.C
- Files updated: [list]
- Git tag created: vA.B.C (if applicable)
- Changelog updated: yes/no

**Next steps:**
- Review CHANGELOG.md
- Push changes: git push
- Push tags: git push --tags
- Create GitHub release (if applicable)
- Publish package (npm publish, cargo publish, etc.)

**Version updated successfully!**
