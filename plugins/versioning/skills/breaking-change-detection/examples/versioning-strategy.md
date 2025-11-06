# Example: Complete Versioning Strategy with Breaking Change Detection

This example demonstrates a complete versioning workflow integrating automated breaking change detection into the development lifecycle.

## Scenario

A SaaS company maintains a REST API and database that serves thousands of clients. They need a robust versioning strategy that:

1. Automatically detects breaking changes
2. Enforces proper semantic versioning
3. Generates migration guides
4. Manages deprecation lifecycle
5. Supports multiple active API versions

## Project Structure

```
myproject/
├── VERSION                           # Version file
├── CHANGELOG.md                      # Generated changelog
├── api/
│   ├── v1/
│   │   └── openapi.yaml             # v1 API spec
│   └── v2/
│       └── openapi.yaml             # v2 API spec (in development)
├── database/
│   ├── schema.sql                   # Current schema
│   └── migrations/
│       ├── 001_initial.sql
│       ├── 002_add_users.sql
│       └── 003_uuid_migration.sql
├── .github/
│   └── workflows/
│       ├── breaking-changes.yml      # Breaking change detection
│       ├── version-bump.yml          # Automated version management
│       └── release.yml               # Release automation
└── scripts/
    └── versioning/
        ├── detect-breaking.sh
        └── generate-migration-guide.sh
```

## Workflow

### Step 1: Developer Makes Changes

Developer creates PR with API and schema changes:

```bash
# Developer's workflow
git checkout -b feature/user-profiles

# Make API changes
vim api/v2/openapi.yaml

# Make schema changes
vim database/migrations/004_add_profiles.sql

# Commit changes
git add .
git commit -m "feat: Add user profile support"

# Push and create PR
git push origin feature/user-profiles
gh pr create --title "Add user profile support"
```

### Step 2: Automated Breaking Change Detection

GitHub Actions workflow runs automatically:

**File:** `.github/workflows/breaking-changes.yml`

```yaml
name: Breaking Change Detection

on:
  pull_request:
    branches: [main]

jobs:
  detect-breaking-changes:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout PR
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup tools
        run: |
          sudo apt-get update
          sudo apt-get install -y jq diffutils
          pip install yq

      - name: Extract base specs
        run: |
          mkdir -p /tmp/old /tmp/new

          # Get specs from base branch
          git show origin/main:api/v2/openapi.yaml > /tmp/old/openapi.yaml || true
          git show origin/main:database/schema.sql > /tmp/old/schema.sql || true

          # Get specs from PR
          cp api/v2/openapi.yaml /tmp/new/openapi.yaml || true
          cp database/schema.sql /tmp/new/schema.sql || true

      - name: Run breaking change analysis
        id: analysis
        continue-on-error: true
        run: |
          bash plugins/versioning/skills/breaking-change-detection/scripts/analyze-breaking.sh \
            --old-api /tmp/old/openapi.yaml \
            --new-api /tmp/new/openapi.yaml \
            --old-schema /tmp/old/schema.sql \
            --new-schema /tmp/new/schema.sql \
            --output /tmp/breaking-changes-report.md

          EXIT_CODE=$?
          echo "exit_code=$EXIT_CODE" >> $GITHUB_OUTPUT

          if [ $EXIT_CODE -eq 1 ]; then
            echo "breaking_detected=true" >> $GITHUB_OUTPUT

            # Extract counts
            CRITICAL=$(grep -c "CRITICAL" /tmp/breaking-changes-report.md || echo "0")
            HIGH=$(grep -c "HIGH" /tmp/breaking-changes-report.md || echo "0")

            echo "critical_count=$CRITICAL" >> $GITHUB_OUTPUT
            echo "high_count=$HIGH" >> $GITHUB_OUTPUT
          else
            echo "breaking_detected=false" >> $GITHUB_OUTPUT
          fi

      - name: Check version bump requirement
        if: steps.analysis.outputs.breaking_detected == 'true'
        run: |
          # Get current version
          CURRENT=$(cat VERSION | jq -r '.version')
          CURRENT_MAJOR=$(echo $CURRENT | cut -d. -f1)

          # Get version in PR
          PR_VERSION=$(cat VERSION | jq -r '.version')
          PR_MAJOR=$(echo $PR_VERSION | cut -d. -f1)

          echo "Current version: $CURRENT"
          echo "PR version: $PR_VERSION"

          # Verify major version bumped
          if [ "$PR_MAJOR" -le "$CURRENT_MAJOR" ]; then
            echo "❌ Breaking changes detected but major version not bumped!"
            echo "Expected major version: $((CURRENT_MAJOR + 1))"
            echo "Got: $PR_VERSION"
            exit 1
          fi

          echo "✅ Major version correctly bumped"

      - name: Generate migration guide
        if: steps.analysis.outputs.breaking_detected == 'true'
        run: |
          cat > /tmp/migration-guide.md <<'EOF'
          # Migration Guide: v$CURRENT → v$PR_VERSION

          ## Breaking Changes Summary

          - Critical Issues: ${{ steps.analysis.outputs.critical_count }}
          - High Priority: ${{ steps.analysis.outputs.high_count }}

          ## Detailed Report

          $(cat /tmp/breaking-changes-report.md)

          ## Migration Timeline

          - **Announcement:** $(date +%Y-%m-%d)
          - **Deprecation Period:** 6 months
          - **Migration Deadline:** $(date -d "+6 months" +%Y-%m-%d)
          - **Old Version Sunset:** $(date -d "+9 months" +%Y-%m-%d)

          ## Support Resources

          - Documentation: https://docs.example.com/migration
          - Support Email: support@example.com
          - Migration Tool: https://github.com/example/migration-tool
          EOF

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: breaking-change-reports
          path: |
            /tmp/breaking-changes-report.md
            /tmp/migration-guide.md

      - name: Comment on PR
        if: steps.analysis.outputs.breaking_detected == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('/tmp/breaking-changes-report.md', 'utf8');

            const severity = ${{ steps.analysis.outputs.critical_count }} > 0 ? '🔴 CRITICAL' :
                           ${{ steps.analysis.outputs.high_count }} > 0 ? '🟠 HIGH' : '🟡 MEDIUM';

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## ⚠️ Breaking Changes Detected (${severity})

            This PR introduces **breaking changes** that require a **MAJOR version bump**.

            ### Summary
            - 🔴 Critical Issues: ${{ steps.analysis.outputs.critical_count }}
            - 🟠 High Priority: ${{ steps.analysis.outputs.high_count }}

            ### Required Actions
            - [x] Major version bumped ✅
            - [ ] Migration guide created
            - [ ] Deprecation notices added
            - [ ] Communication plan prepared
            - [ ] Backward compatibility period planned

            <details>
            <summary>📋 Full Breaking Change Report</summary>

            ${report}

            </details>

            ### Next Steps
            1. Review the detailed report above
            2. Create migration guide for users
            3. Plan deprecation timeline (recommend 6+ months)
            4. Update documentation
            5. Prepare communication for users

            **Note:** This PR cannot be merged until all required actions are completed.
            `
            });

      - name: Add PR labels
        if: steps.analysis.outputs.breaking_detected == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.addLabels({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              labels: ['breaking-change', 'major-version', 'needs-migration-guide']
            });

      - name: Request reviews
        if: steps.analysis.outputs.breaking_detected == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.pulls.requestReviewers({
              pull_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              reviewers: ['tech-lead', 'api-owner'],  // Require senior review
              team_reviewers: ['architecture-team']
            });
```

### Step 3: Developer Addresses Feedback

Based on automated analysis, developer takes action:

```bash
# Option 1: Fix breaking changes (if possible)
vim api/v2/openapi.yaml  # Make backwards compatible

# Option 2: Create migration guide
bash scripts/versioning/generate-migration-guide.sh \
  --version 2.0.0 \
  --breaking-report /tmp/breaking-changes-report.md \
  --output docs/migration-v2.md

git add docs/migration-v2.md
git commit -m "docs: Add v2 migration guide"

# Option 3: Add deprecation notices
vim api/v1/openapi.yaml  # Add deprecation warnings

git add api/v1/openapi.yaml
git commit -m "docs: Add deprecation notices for v1"
```

### Step 4: Manual Review & Approval

Senior engineers review:

1. **Architecture Review:**
   - Are breaking changes necessary?
   - Can they be avoided with better design?
   - Is the migration path clear?

2. **Business Impact:**
   - How many users affected?
   - What's the migration timeline?
   - Support resources needed?

3. **Documentation:**
   - Migration guide complete?
   - Examples provided?
   - Support plan in place?

### Step 5: Merge with Version Bump

Once approved:

```bash
# Merge PR
gh pr merge --squash

# Automated version bump workflow runs
# Tags release as v2.0.0
# Generates changelog
# Creates GitHub release
```

**File:** `.github/workflows/version-bump.yml`

```yaml
name: Version Bump & Release

on:
  push:
    branches: [main]

jobs:
  bump-version:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get version change
        id: version
        run: |
          OLD=$(git show HEAD~1:VERSION | jq -r '.version')
          NEW=$(cat VERSION | jq -r '.version')

          echo "old=$OLD" >> $GITHUB_OUTPUT
          echo "new=$NEW" >> $GITHUB_OUTPUT

          if [ "$OLD" != "$NEW" ]; then
            echo "changed=true" >> $GITHUB_OUTPUT
          else
            echo "changed=false" >> $GITHUB_OUTPUT
          fi

      - name: Generate changelog
        if: steps.version.outputs.changed == 'true'
        run: |
          bash plugins/versioning/skills/version-manager/scripts/generate-changelog.sh \
            "v${{ steps.version.outputs.old }}" \
            HEAD \
            "${{ steps.version.outputs.new }}" \
            > CHANGELOG_NEW.md

      - name: Create Git tag
        if: steps.version.outputs.changed == 'true'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          git tag -a "v${{ steps.version.outputs.new }}" -F CHANGELOG_NEW.md
          git push origin "v${{ steps.version.outputs.new }}"

      - name: Create GitHub Release
        if: steps.version.outputs.changed == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const changelog = fs.readFileSync('CHANGELOG_NEW.md', 'utf8');

            github.rest.repos.createRelease({
              owner: context.repo.owner,
              repo: context.repo.repo,
              tag_name: 'v${{ steps.version.outputs.new }}',
              name: 'v${{ steps.version.outputs.new }}',
              body: changelog,
              draft: false,
              prerelease: false
            });
```

### Step 6: Deprecation Management

Run both API versions in parallel:

```python
# app.py - Support v1 and v2 simultaneously

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.middleware("http")
async def add_deprecation_headers(request: Request, call_next):
    response = await call_next(request)

    # Add deprecation warnings for v1
    if request.url.path.startswith("/api/v1"):
        response.headers["X-API-Version"] = "1.0.0"
        response.headers["X-API-Deprecated"] = "true"
        response.headers["X-API-Sunset"] = "2025-06-01"
        response.headers["X-API-Migration-Guide"] = "https://docs.example.com/migration-v2"
        response.headers["Link"] = '</api/v2>; rel="successor-version"'

    return response

# v1 endpoints (deprecated but still functional)
@app.get("/api/v1/users")
async def get_users_v1():
    # Old implementation
    return {"users": [...]}

# v2 endpoints (current)
@app.get("/api/v2/users")
async def get_users_v2():
    # New implementation
    return {"data": [...], "meta": {...}}
```

### Step 7: User Communication

Automated notifications sent:

```python
# scripts/notify-users.py

import smtplib
from email.mime.text import MIMEText

def send_deprecation_notice(user_email, version_info):
    """Send deprecation notice to API users"""

    message = f"""
    Subject: Important: API v1 Deprecation Notice

    Dear User,

    We're writing to inform you that API v1 will be deprecated in 6 months.

    What's Changing:
    - Current version: v1.0.0
    - New version: v2.0.0
    - Deprecation date: {version_info['deprecation_date']}
    - Sunset date: {version_info['sunset_date']}

    Action Required:
    Please migrate to API v2 before {version_info['sunset_date']}.

    Migration Resources:
    - Migration Guide: {version_info['migration_guide_url']}
    - API Documentation: {version_info['docs_url']}
    - Support: support@example.com

    Timeline:
    - Now: Both v1 and v2 available
    - {version_info['deprecation_date']}: v1 marked deprecated
    - {version_info['sunset_date']}: v1 removed

    Questions? Reply to this email or visit our documentation.

    Best regards,
    API Team
    """

    # Send email
    send_email(user_email, message)

# Get all API v1 users
users = get_api_v1_users()

for user in users:
    send_deprecation_notice(user.email, {
        'deprecation_date': '2025-01-01',
        'sunset_date': '2025-06-01',
        'migration_guide_url': 'https://docs.example.com/migration-v2',
        'docs_url': 'https://docs.example.com/api/v2'
    })
```

### Step 8: Monitor Migration Progress

Track API version usage:

```python
# analytics.py

from prometheus_client import Counter, Histogram

api_requests = Counter(
    'api_requests_total',
    'Total API requests',
    ['version', 'endpoint']
)

def track_api_usage(version, endpoint):
    api_requests.labels(version=version, endpoint=endpoint).inc()

# Grafana dashboard query
# Show percentage of v1 vs v2 usage over time
```

**Grafana Dashboard:**
```
API Version Adoption
┌─────────────────────────────────┐
│ v1: 80% ▓▓▓▓▓▓▓▓░░              │
│ v2: 20% ▓▓░░░░░░░░              │
└─────────────────────────────────┘

Migration Progress
┌─────────────────────────────────┐
│  Dec   Jan   Feb   Mar   Apr    │
│  ▓▓    ▓▓▓   ▓▓▓▓  ▓▓▓▓▓ ▓▓▓▓▓▓│
│  ▓▓    ▓▓▓   ▓▓▓▓  ▓▓▓▓▓ ▓▓▓▓▓▓│
└─────────────────────────────────┘
```

### Step 9: Sunset Old Version

After 6 months, remove v1:

```bash
# Remove v1 code
git rm -r api/v1/
git commit -m "feat!: Remove deprecated API v1"

# Version bump to v3.0.0 (removing v1 is breaking for stragglers)
vim VERSION  # Update to 3.0.0

git push
```

## Key Metrics

Track throughout process:

1. **Detection Metrics:**
   - Time to detect breaking changes: < 2 minutes (automated)
   - False positive rate: < 5%
   - Coverage: 100% of API/schema changes

2. **Migration Metrics:**
   - Users migrated: 95% within 6 months
   - Support tickets: < 50 related to migration
   - Downtime: 0 (zero-downtime migration)

3. **Process Metrics:**
   - PRs blocked for missing migration guide: 3
   - Breaking changes caught before production: 100%
   - Average time to create migration guide: 2 hours

## Lessons Learned

1. **Automation is Key:** Automated detection catches 100% of breaking changes
2. **Early Detection:** Catching in PR prevents production issues
3. **Clear Communication:** Users appreciate advance notice and migration guides
4. **Parallel Versions:** Running both versions reduces migration pressure
5. **Monitoring:** Track adoption to know when to sunset old version

## Best Practices

1. **Always version your APIs:** Use `/v1/`, `/v2/` prefixes
2. **Automate breaking change detection:** Don't rely on manual review
3. **Enforce version bumps:** Block PRs without proper versioning
4. **Provide migration period:** Give users 6+ months to migrate
5. **Monitor adoption:** Track usage to inform sunset decisions
6. **Document everything:** Migration guides are critical
7. **Communicate early:** Notify users as soon as deprecation decided

## Related Resources

- Breaking Change Detection: `scripts/openapi-diff.sh`, `scripts/schema-compare.sh`
- Migration Guide Templates: `templates/migration-guide.md`, `templates/migration-guide-api.md`
- CI/CD Integration: `templates/ci-cd-breaking-check.yaml`
- Deprecation Notice: `templates/deprecation-notice.md`
