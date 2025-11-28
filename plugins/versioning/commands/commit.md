---
description: Smart commit - auto-groups changed files by relationship, pick a group to commit
argument-hint: "[--dry-run]"
---

---
**EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- The phases below are YOUR execution checklist
- YOU must run each phase immediately using tools (Bash, Read, Write, Edit, AskUserQuestion)
- Complete ALL phases before considering this command done
- DON'T wait for "the command to complete" - YOU complete it by executing the phases

---

**Arguments**: $ARGUMENTS

Goal: Intelligently analyze all changed files, cluster them into related groups, and let user pick which group to commit. Perfect for multi-terminal workflows where different features accumulate uncommitted changes.

Core Principles:
- NO keyword required - automatically detects file relationships
- Groups files by: directory, imports, naming patterns, content similarity
- User picks a group number to commit (or "all")
- Generates smart commit message based on group analysis

---

## Phase 1: Validate and Scan Changed Files

Validate git state:
- Verify git repository: `git rev-parse --git-dir`
- Check there are changes: `git status --porcelain`
- If no changes, exit: "No changed files found"

Get all changed files with their status:

```bash
# Get all changed files (modified, added, deleted, untracked)
git status --porcelain
```

Parse into a list of files with their paths.

## Phase 2: Analyze and Cluster Files into Groups

**Clustering Algorithm** - Group files by these signals (in priority order):

### 2.1 Directory Clustering (Primary)
Group files by their parent directories:
```bash
# Extract directory patterns
for file in changed_files:
    dir = dirname(file)
    # Group by top 2 levels: src/auth/*, src/blog/*, components/ui/*
```

### 2.2 Naming Pattern Clustering
Find common naming patterns:
- Files with same prefix: `blog-*.ts`, `auth-*.tsx`
- Files with same suffix: `*-service.ts`, `*-utils.ts`
- Files with same keyword: `*Blog*`, `*Auth*`, `*Payment*`

### 2.3 Import Relationship Analysis
For TypeScript/JavaScript files, check if files import each other:
```bash
# For each file, extract imports
grep -E "^import.*from ['\"]" <file> | extract imported paths
# If file A imports file B, they belong to same group
```

### 2.4 Content Similarity (for mixed directories)
Analyze git diff content for common keywords:
```bash
git diff <file> | extract significant words
# Files with overlapping keywords → same group
```

### 2.5 Fallback: Config/Misc Group
Files that don't fit elsewhere:
- `package.json`, `tsconfig.json`, `.env*`
- Root-level config files
- Put in "config" or "misc" group

**Output**: Create named groups like:
- `blog` (5 files) - files in blog/, BlogCard.tsx, blog-api.ts
- `auth` (3 files) - auth/, middleware/auth.ts
- `config` (2 files) - package.json, tsconfig.json

## Phase 3: Present Groups to User

Display the detected groups:

```
📦 Detected change groups:

[1] blog (5 files)
    - src/pages/blog/index.tsx
    - src/pages/blog/[slug].tsx
    - src/components/BlogCard.tsx
    - src/lib/blog-api.ts
    - src/types/blog.ts

[2] auth (3 files)
    - src/lib/auth.ts
    - src/middleware/auth.ts
    - src/pages/api/auth/login.ts

[3] config (2 files)
    - package.json
    - tsconfig.json

Which group to commit?
```

Use AskUserQuestion with options:
- "[1] blog (5 files)"
- "[2] auth (3 files)"
- "[3] config (2 files)"
- "all - Commit everything"
- "cancel"

If `--dry-run` flag is set:
- Show groups and exit without prompting
- Display: "[DRY RUN] These groups were detected. Run without --dry-run to commit."

## Phase 4: Stage and Commit Selected Group

Get selected group's files.

Stage only those files:
```bash
git add <file1> <file2> <file3> ...
```

Determine commit type from files:
- Test files (`test/`, `*.test.*`, `*.spec.*`) → `test`
- Docs (`docs/`, `*.md`) → `docs`
- Styles (`*.css`, `*.scss`) → `style`
- Fixes (if group name contains "fix" or files have "fix" in path) → `fix`
- Default → `feat`

Generate commit message using group name as scope:

```
<type>(<group-name>): update <group-name> files

Files:
- file1.ts
- file2.tsx
- file3.ts

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Create the commit:
```bash
git commit -m "<commit_message>"
```

## Phase 5: Display Results and Remaining Groups

Show commit result:
```
✅ Committed: <commit_hash>
<type>(<group-name>): update <group-name> files

Files committed (N):
- file1.ts
- file2.tsx

📋 Remaining uncommitted groups:
- [2] auth (3 files)
- [3] config (2 files)

Run /versioning:commit-topic again to commit another group.
```

---

## Clustering Examples

**Example 1: Blog Feature**
Changed files:
- `src/pages/blog/index.tsx`
- `src/components/BlogCard.tsx`
- `src/lib/blog-api.ts`

Detected: All contain "blog" → Group: `blog`

**Example 2: Auth + API**
Changed files:
- `src/lib/auth.ts`
- `src/middleware.ts` (imports from auth.ts)
- `src/pages/api/login.ts`

Detected: Import chain + "auth" keyword → Group: `auth`

**Example 3: Mixed Changes**
Changed files:
- `src/pages/blog/index.tsx`
- `src/lib/auth.ts`
- `package.json`

Detected: 3 separate groups:
- `blog` (1 file)
- `auth` (1 file)
- `config` (1 file)

---

## Error Handling

| Error | Message | Suggestion |
|-------|---------|------------|
| Not a git repo | "Not a git repository" | "Run from a git project directory" |
| No changes | "No changed files found" | "Make some changes first" |
| User cancelled | "Commit cancelled" | - |
| Git commit fails | "Commit failed: <error>" | "Check git status" |

---

## Examples

```bash
# Smart detection - shows groups, pick one
/versioning:commit-topic
# Shows: [1] blog (5 files), [2] auth (3 files), [3] config (2 files)
# User picks: 1
# Commits only blog files

# Preview groups without committing
/versioning:commit-topic --dry-run
# Shows detected groups, exits without committing
```
