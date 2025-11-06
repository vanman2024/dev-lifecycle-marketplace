# Conditional Approval Example

Different approval requirements based on release type and scope of changes.

## Approval Rules by Release Type

### Patch Release (1.2.3 → 1.2.4)

**Requirements**: Minimal approval for low-risk changes

```yaml
patch_release:
  auto_approve_if:
    - docs_only: true
    - no_code_changes: true
    - dependency_patch_only: true
  required_approvals:
    development: 1  # One dev sufficient
    qa: 1           # Quick QA check
    security: 0     # Auto-approved if no code changes
    release: 1      # Release manager only
```

**Example workflow:**
```bash
# Patch release with docs only
/versioning:bump patch

# Automatic approval decision
if docs_only && all_tests_passing; then
  auto_approve development, security
  require qa=1, release=1
fi
```

### Minor Release (1.2.0 → 1.3.0)

**Requirements**: Standard approval for new features

```yaml
minor_release:
  required_approvals:
    development: 2
    qa: 1
    security: 1 (if new dependencies or auth changes)
    release: 2
```

### Major Release (1.0.0 → 2.0.0)

**Requirements**: Maximum scrutiny for breaking changes

```yaml
major_release:
  required_approvals:
    development: 2
    qa: 1
    security: 1 (mandatory, veto power)
    release: 2
  additional_requirements:
    - migration_guide: required
    - breaking_changes_documented: required
    - stakeholder_communication: required
```

## Conditional Logic Implementation

### Configuration

```yaml
# .github/releases/approval-gates.yml
conditional_rules:
  - condition:
      type: "patch"
      files_changed: "< 5"
      only_docs: true
    approvals:
      development: 1
      qa: 1
      security: auto
      release: 1

  - condition:
      type: "minor"
      breaking_changes: false
    approvals:
      development: 2
      qa: 1
      security: conditional  # Only if deps changed
      release: 2

  - condition:
      type: "major"
      breaking_changes: true
    approvals:
      development: 2
      qa: 1
      security: mandatory
      release: 2
    additional_checks:
      - migration_guide_exists
      - changelog_includes_breaking_section
```

### Script Logic

```bash
#!/bin/bash
# Determine approval requirements based on release type

VERSION="$1"
PREV_VERSION=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null)

# Parse version components
IFS='.' read -r CURR_MAJOR CURR_MINOR CURR_PATCH <<< "$VERSION"
IFS='.' read -r PREV_MAJOR PREV_MINOR PREV_PATCH <<< "${PREV_VERSION#v}"

# Determine release type
if [ "$CURR_MAJOR" != "$PREV_MAJOR" ]; then
  RELEASE_TYPE="major"
elif [ "$CURR_MINOR" != "$PREV_MINOR" ]; then
  RELEASE_TYPE="minor"
else
  RELEASE_TYPE="patch"
fi

# Check for breaking changes
BREAKING_CHANGES=$(git log --format=%s $PREV_VERSION..HEAD | grep -i "BREAKING CHANGE" | wc -l)

# Check files changed
FILES_CHANGED=$(git diff --name-only $PREV_VERSION..HEAD | wc -l)
DOCS_ONLY=$(git diff --name-only $PREV_VERSION..HEAD | grep -v "\.md$" | wc -l)

# Determine required approvals
case "$RELEASE_TYPE" in
  patch)
    if [ "$DOCS_ONLY" -eq 0 ]; then
      echo "Auto-approval eligible: docs only"
      REQUIRED_DEV=1
      REQUIRED_QA=1
      REQUIRED_SEC=0
      REQUIRED_REL=1
    else
      REQUIRED_DEV=1
      REQUIRED_QA=1
      REQUIRED_SEC=1
      REQUIRED_REL=1
    fi
    ;;
  minor)
    REQUIRED_DEV=2
    REQUIRED_QA=1
    if [ "$BREAKING_CHANGES" -gt 0 ]; then
      REQUIRED_SEC=1
    else
      REQUIRED_SEC=0
    fi
    REQUIRED_REL=2
    ;;
  major)
    REQUIRED_DEV=2
    REQUIRED_QA=1
    REQUIRED_SEC=1  # Mandatory
    REQUIRED_REL=2
    ;;
esac

echo "Release type: $RELEASE_TYPE"
echo "Required approvals: dev=$REQUIRED_DEV, qa=$REQUIRED_QA, sec=$REQUIRED_SEC, rel=$REQUIRED_REL"
```

## Real-World Example

### Scenario 1: Docs-Only Patch (Auto-Approve)

```bash
# Changes: README.md, docs/
git diff --name-only v1.2.3..HEAD
# Output:
# README.md
# docs/api.md
# docs/guides/quickstart.md

# Request approval
/versioning:approve-release 1.2.4

# Conditional logic applied:
# ✅ Development: Auto-approved (docs only)
# ✅ QA: Quick review required (1 approval)
# ✅ Security: Auto-approved (no code changes)
# ✅ Release: Manager approval required (1 approval)

# Approval completes in 30 minutes (vs 4 hours for full review)
```

### Scenario 2: Minor Release with New Feature

```bash
# Changes: src/features/export.ts, tests/export.test.ts
git log --format="%s" v1.2.0..HEAD
# Output:
# feat: add CSV export functionality
# test: add export tests
# docs: update export documentation

# Request approval
/versioning:approve-release 1.3.0

# Conditional logic applied:
# ⏳ Development: 2 approvals required
# ⏳ QA: 1 approval required
# ✅ Security: Auto-approved (no dependency or auth changes)
# ⏳ Release: 2 approvals required

# Approval completes in 2 hours (vs 4 hours with security review)
```

### Scenario 3: Major Release with Breaking Changes

```bash
# Changes: Multiple files with breaking API changes
git log --format="%s" v1.0.0..HEAD | grep "BREAKING CHANGE"
# Output:
# feat!: redesign authentication API
# BREAKING CHANGE: auth tokens now require explicit expiry
# feat!: remove deprecated endpoints
# BREAKING CHANGE: /api/v1/legacy/* endpoints removed

# Request approval
/versioning:approve-release 2.0.0

# Conditional logic applied:
# ⏳ Development: 2 approvals required
# ⏳ QA: 1 approval required
# ⏳ Security: MANDATORY (veto power, breaking auth changes)
# ⏳ Release: 2 approvals required
# ⚠️  Additional checks:
#    - Migration guide: REQUIRED
#    - Breaking changes documented: REQUIRED
#    - Stakeholder communication: REQUIRED

# Approval completes in 6 hours (full review process)
```

## Benefits

1. **Faster patch releases**: Auto-approve low-risk changes
2. **Resource efficiency**: Security team not needed for docs-only
3. **Risk-appropriate scrutiny**: More approvals for breaking changes
4. **Clear expectations**: Developers know requirements up front

## Configuration Template

```yaml
# .github/releases/approval-gates.yml
approval_gates:
  - stage: development
    approvers: ["@tech-lead", "@senior-dev"]
    required: conditional  # Determined by release type
    rules:
      patch: 1
      minor: 2
      major: 2

  - stage: qa
    approvers: ["@qa-lead"]
    required: 1
    auto_approve_if:
      - docs_only: true
      - no_code_changes: true

  - stage: security
    approvers: ["@security-team-lead"]
    required: conditional
    rules:
      patch: 0 (if docs_only)
      minor: 1 (if deps_changed or auth_changed)
      major: 1 (mandatory)
    veto_power: true

  - stage: release
    approvers: ["@release-manager", "@product-owner"]
    required: conditional
    rules:
      patch: 1
      minor: 2
      major: 2
```

## Next Steps

- Implement Slack integration: See `slack-integration-complete.md`
- Automate conditional logic: See `automated-gating.md`
- Set up emergency overrides: See approval-gates.yml policy section
