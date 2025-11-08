---
description: Detect breaking changes and recommend version bump
argument-hint: "[--from=tag] [--detailed]"
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

Goal: Analyze commit history to detect breaking changes, categorize commits, and recommend appropriate semantic version bump

Core Principles:
- Scan git commits for breaking change indicators
- Analyze conventional commit types
- Detect API/schema changes in code
- Recommend version bump based on findings
- Provide detailed report with evidence

## Available Skills

- **version-manager**: Version analysis and changelog patterns

Use: `!{skill version-manager}` when needed for templates and validation scripts.

---


## Phase 1: Parse Arguments and Validate

Parse arguments and determine analysis scope:

Actions:
- Parse $ARGUMENTS for flags:
  - `--from=<tag>`: Start analysis from specific tag (default: last tag)
  - `--detailed`: Enable detailed analysis with changelog-generator agent
- Validate git repository exists: `git rev-parse --git-dir`
- Check VERSION file exists (optional, for context)
- Determine commit range:
  - If `--from` specified: Use provided tag as starting point
  - Otherwise: Find last tag: `git describe --tags --abbrev=0 --match "v*" 2>/dev/null`
  - If no tags: Use initial commit: `git rev-list --max-parents=0 HEAD`

## Phase 2: Extract Commit History

Get commits in analysis range:

Actions:
- Extract commit data: `git log <from>..<to> --pretty=format:"%H|%h|%s|%b"`
- Parse each commit into structured data:
  - Full hash, short hash, subject, body
- Count total commits to analyze
- Display: "Analyzing X commits since <from_reference>"

## Phase 3: Detect Breaking Changes

Scan commits for breaking change indicators:

Actions:
- **Explicit Breaking Changes**:
  - Check commit type for `!`: `feat!:`, `fix!:`, `refactor!:`
  - Check commit body for `BREAKING CHANGE:` or `BREAKING-CHANGE:` footer
  - Extract breaking change descriptions

- **Implicit Breaking Changes** (code analysis):
  - Search for removed public APIs using Grep
  - Check for dependency major version bumps in manifests
  - Scan for removed CLI commands or schema changes

- Store findings with commit references and descriptions

## Phase 4: Categorize Commit Types

Categorize all commits by conventional type:

Actions:
- **Features** (minor): Pattern `^feat:` or `^feat\(.+\):` - count and collect
- **Bug Fixes** (patch): Pattern `^fix:` or `^fix\(.+\):` - count and collect
- **Performance** (patch): Pattern `^perf:` or `^perf\(.+\):` - count and collect
- **Breaking Changes** (major): From Phase 3 detection - count and collect
- **Other Changes** (no bump): Pattern `^(chore|docs|ci|test|style|refactor):` - count only

## Phase 5: Analyze Impact and Recommend Bump

Determine appropriate version bump:

Actions:
- Apply semantic versioning rules:
  - If breaking changes detected → **MAJOR bump** required
  - Else if features detected → **MINOR bump** recommended
  - Else if fixes/perf detected → **PATCH bump** recommended
  - Else → **No bump needed** (only chores/docs)

- Calculate risk level:
  - **HIGH**: Multiple breaking changes or public API removals
  - **MEDIUM**: Single breaking change or new features
  - **LOW**: Only bug fixes or performance improvements
  - **NONE**: No functional changes

- Determine confidence level:
  - **HIGH**: Clear conventional commit markers
  - **MEDIUM**: Some implicit indicators found
  - **LOW**: Ambiguous changes detected

## Phase 6: Generate Detailed Report (Optional)

If `--detailed` flag provided, invoke changelog-generator:

Actions:
- Check if `--detailed` flag is present
- If yes, invoke: `Task(changelog-generator, "Generate changelog for range: <from>..<to>")`
- Agent generates comprehensive changelog with categorized commits
- Include changelog output in final report

## Phase 7: Display Analysis Report

Present findings in structured format:

Actions:
- Display report with sections:
  - Commit Summary: Total commits, range, date
  - Breaking Changes: Count, list with commit hashes and descriptions
    - Type: Explicit (BREAKING CHANGE:) or Implicit (API removal)
    - Impact explanation
  - Features: Count, list top 5 with commit hashes
  - Bug Fixes: Count, list top 5 with commit hashes
  - Performance: Count
  - Other Changes: Count (chores/docs/tests)

- Display recommendation:
  - Recommended Version Bump: MAJOR | MINOR | PATCH | NONE
  - Confidence Level: HIGH | MEDIUM | LOW
  - Risk Level: HIGH | MEDIUM | LOW | NONE
  - Detailed explanation of recommendation

- Display next steps:
  - Review breaking changes
  - Update CHANGELOG.md with migration guide
  - Bump version: `/versioning:bump <type>`
  - Test thoroughly before release

- Include documentation links: semver.org, conventionalcommits.org
- If `--detailed` flag was used, append full changelog from agent

## Error Handling

Handle analysis failures gracefully:

- Not a git repository → Exit with "Must be run in git repository"
- No commits in range → Display "No commits to analyze"
- Invalid `--from` tag → Exit with "Tag not found: <tag>"
- Unable to read manifests → Warn but continue analysis
- Grep failures → Warn about limited implicit detection

Provide helpful error messages and suggested fixes for each scenario.
