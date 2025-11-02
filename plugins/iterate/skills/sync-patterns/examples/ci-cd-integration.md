# CI/CD Integration Examples

This document shows how to integrate sync-patterns scripts into your CI/CD pipeline for automated sync checking.

---

## GitHub Actions

### Basic Sync Check on Pull Request

```yaml
# .github/workflows/sync-check.yml
name: Spec Sync Check

on:
  pull_request:
    branches: [main, develop]
  workflow_dispatch:

jobs:
  check-sync:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Find completed tasks not marked in specs
        id: find_completed
        run: |
          bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
            specs/ src/ --json > completed-tasks.json

          # Count completed tasks
          COMPLETED_COUNT=$(jq '.likely_completed_tasks' completed-tasks.json)
          echo "completed_count=$COMPLETED_COUNT" >> $GITHUB_OUTPUT

      - name: Generate sync report
        run: |
          bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh \
            specs/ sync-report.md --code-dir=src/

      - name: Upload sync report as artifact
        uses: actions/upload-artifact@v3
        with:
          name: sync-report
          path: sync-report.md

      - name: Comment on PR with completed tasks
        if: steps.find_completed.outputs.completed_count > 0
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const completedTasks = JSON.parse(fs.readFileSync('completed-tasks.json', 'utf8'));

            let comment = '## 📋 Sync Check Results\n\n';
            comment += `Found ${completedTasks.likely_completed_tasks} tasks that appear completed but not marked in specs.\n\n`;

            if (completedTasks.completed_tasks.length > 0) {
              comment += '### Tasks to Mark Complete:\n\n';
              completedTasks.completed_tasks.slice(0, 5).forEach(task => {
                comment += `- [ ] ${task.task} (${task.spec_file})\n`;
              });

              if (completedTasks.completed_tasks.length > 5) {
                comment += `\n... and ${completedTasks.completed_tasks.length - 5} more\n`;
              }

              comment += '\n**Action Required:** Please update the spec files to mark these tasks as complete.\n';
            }

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

      - name: Fail if sync percentage is below threshold
        run: |
          SYNC_PERCENT=$(jq -r '.sync_percentage' completed-tasks.json 2>/dev/null || echo "0")
          if [ "$SYNC_PERCENT" -lt 70 ]; then
            echo "❌ Sync percentage ($SYNC_PERCENT%) is below 70% threshold"
            exit 1
          else
            echo "✅ Sync percentage: $SYNC_PERCENT%"
          fi
```

---

### Weekly Sync Report Generation

```yaml
# .github/workflows/weekly-sync-report.yml
name: Weekly Sync Report

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM UTC
  workflow_dispatch:

jobs:
  generate-report:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Generate comprehensive sync report
        run: |
          bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh \
            specs/ \
            reports/sync-report-$(date +%Y-%m-%d).md \
            --code-dir=src/ \
            --include-files

      - name: Commit and push report
        run: |
          git config user.name "Sync Bot"
          git config user.email "sync-bot@example.com"
          git add reports/
          git commit -m "chore: Add weekly sync report $(date +%Y-%m-%d)" || exit 0
          git push

      - name: Create issue if sync is low
        run: |
          # Parse sync percentage from report
          SYNC_PERCENT=$(grep -oP 'Coverage: \K\d+' reports/sync-report-*.md | tail -1)

          if [ "$SYNC_PERCENT" -lt 60 ]; then
            gh issue create \
              --title "⚠️ Low Spec Sync: ${SYNC_PERCENT}%" \
              --body "Weekly sync check shows sync percentage at ${SYNC_PERCENT}%. Please review and update specs." \
              --label "documentation,sync"
          fi
        env:
          GH_TOKEN: ${{ github.token }}
```

---

### Compare Specific Spec on File Change

```yaml
# .github/workflows/spec-changed.yml
name: Spec Changed Check

on:
  pull_request:
    paths:
      - 'specs/**/*.md'

jobs:
  check-spec-implementation:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Get changed spec files
        id: changed_specs
        run: |
          CHANGED_SPECS=$(git diff --name-only origin/${{ github.base_ref }} HEAD | grep '^specs/.*\.md$' || true)
          echo "specs<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGED_SPECS" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Compare each changed spec with code
        if: steps.changed_specs.outputs.specs != ''
        run: |
          echo "${{ steps.changed_specs.outputs.specs }}" | while read spec_file; do
            if [ -f "$spec_file" ]; then
              echo "Checking $spec_file..."
              bash plugins/iterate/skills/sync-patterns/scripts/compare-specs-vs-code.sh \
                "$spec_file" src/ >> spec-comparison.txt
            fi
          done

      - name: Upload comparison results
        if: steps.changed_specs.outputs.specs != ''
        uses: actions/upload-artifact@v3
        with:
          name: spec-comparison
          path: spec-comparison.txt
```

---

## GitLab CI

### Sync Check Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - report

sync-check:
  stage: validate
  image: ubuntu:latest
  script:
    - apt-get update && apt-get install -y bash grep jq
    - bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh specs/ src/ --json > completed-tasks.json
    - SYNC_PERCENT=$(jq -r '.sync_percentage' completed-tasks.json 2>/dev/null || echo "0")
    - echo "Sync percentage: $SYNC_PERCENT%"
    - |
      if [ "$SYNC_PERCENT" -lt 70 ]; then
        echo "ERROR: Sync percentage below 70%"
        exit 1
      fi
  artifacts:
    paths:
      - completed-tasks.json
    when: always
  only:
    - merge_requests

generate-sync-report:
  stage: report
  image: ubuntu:latest
  script:
    - apt-get update && apt-get install -y bash grep
    - bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh specs/ sync-report.md --code-dir=src/
  artifacts:
    paths:
      - sync-report.md
    expire_in: 30 days
  only:
    - schedules
```

---

## Jenkins Pipeline

### Declarative Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any

    triggers {
        cron('0 9 * * 1')  // Weekly on Monday
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Find Completed Tasks') {
            steps {
                sh '''
                    bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
                        specs/ src/ --json > completed-tasks.json
                '''
            }
        }

        stage('Generate Sync Report') {
            steps {
                sh '''
                    bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh \
                        specs/ sync-report.md --code-dir=src/
                '''

                archiveArtifacts artifacts: 'sync-report.md', fingerprint: true
            }
        }

        stage('Check Sync Threshold') {
            steps {
                script {
                    def syncData = readJSON file: 'completed-tasks.json'
                    def syncPercent = syncData.sync_percentage ?: 0

                    if (syncPercent < 70) {
                        error("Sync percentage (${syncPercent}%) below 70% threshold")
                    } else {
                        echo "✅ Sync percentage: ${syncPercent}%"
                    }
                }
            }
        }

        stage('Publish Report') {
            steps {
                publishHTML([
                    reportName: 'Sync Report',
                    reportDir: '.',
                    reportFiles: 'sync-report.md',
                    keepAll: true
                ])
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'completed-tasks.json', allowEmptyArchive: true
        }

        failure {
            emailext(
                to: 'team@example.com',
                subject: "Sync Check Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Spec sync check failed. Please review the sync report."
            )
        }
    }
}
```

---

## CircleCI

### Sync Check Configuration

```yaml
# .circleci/config.yml
version: 2.1

jobs:
  sync-check:
    docker:
      - image: ubuntu:latest
    steps:
      - checkout

      - run:
          name: Install dependencies
          command: |
            apt-get update
            apt-get install -y bash grep jq

      - run:
          name: Find completed tasks
          command: |
            bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
              specs/ src/ --json > completed-tasks.json

      - run:
          name: Generate sync report
          command: |
            bash plugins/iterate/skills/sync-patterns/scripts/generate-sync-report.sh \
              specs/ sync-report.md --code-dir=src/

      - store_artifacts:
          path: sync-report.md

      - store_artifacts:
          path: completed-tasks.json

      - run:
          name: Check sync threshold
          command: |
            SYNC_PERCENT=$(jq -r '.sync_percentage' completed-tasks.json)
            if [ "$SYNC_PERCENT" -lt 70 ]; then
              echo "Sync percentage ($SYNC_PERCENT%) below 70%"
              exit 1
            fi

workflows:
  version: 2
  sync-checks:
    jobs:
      - sync-check:
          filters:
            branches:
              only:
                - main
                - develop

  weekly-report:
    triggers:
      - schedule:
          cron: "0 9 * * 1"
          filters:
            branches:
              only: main
    jobs:
      - sync-check
```

---

## Pre-commit Hook

### Local Git Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running spec sync check..."

# Check if any spec files were modified
SPEC_CHANGED=$(git diff --cached --name-only | grep '^specs/.*\.md$' || true)

if [ -n "$SPEC_CHANGED" ]; then
    echo "Spec files modified. Checking sync status..."

    # Find completed tasks
    bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
        specs/ src/ --json > /tmp/completed-tasks.json

    COMPLETED_COUNT=$(jq -r '.likely_completed_tasks' /tmp/completed-tasks.json 2>/dev/null || echo "0")

    if [ "$COMPLETED_COUNT" -gt 0 ]; then
        echo "⚠️  Warning: Found $COMPLETED_COUNT tasks that appear completed but not marked in specs"
        echo "Consider updating the following specs before committing:"
        jq -r '.completed_tasks[].spec_file' /tmp/completed-tasks.json | sort -u | head -5

        read -p "Continue with commit? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Commit aborted."
            exit 1
        fi
    fi
fi

echo "✅ Sync check passed"
exit 0
```

---

## Make it Executable

```bash
chmod +x .git/hooks/pre-commit
```

---

## Custom Integration Script

### Slack Notification on Low Sync

```bash
#!/bin/bash
# scripts/notify-low-sync.sh

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Generate sync report
bash plugins/iterate/skills/sync-patterns/scripts/find-completed-tasks.sh \
    specs/ src/ --json > /tmp/sync-data.json

SYNC_PERCENT=$(jq -r '.sync_percentage' /tmp/sync-data.json)
COMPLETED_TASKS=$(jq -r '.likely_completed_tasks' /tmp/sync-data.json)

if [ "$SYNC_PERCENT" -lt 70 ]; then
    MESSAGE=$(cat <<EOF
{
  "text": "⚠️ Low Spec Sync Alert",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Spec Sync Below Threshold*\n\nCurrent sync: *${SYNC_PERCENT}%*\nCompleted but unmarked: *${COMPLETED_TASKS}* tasks\n\nPlease review and update specifications."
      }
    }
  ]
}
EOF
)

    curl -X POST -H 'Content-type: application/json' \
        --data "$MESSAGE" \
        "$WEBHOOK_URL"
fi
```

---

## Best Practices for CI/CD Integration

### 1. Run on Multiple Triggers

- **Pull Requests:** Catch sync issues before merge
- **Scheduled:** Weekly reports for ongoing monitoring
- **On Spec Changes:** Immediate feedback when specs updated

### 2. Set Appropriate Thresholds

- **70%+:** Good sync, project healthy
- **50-69%:** Moderate sync, needs attention
- **<50%:** Poor sync, block merges

### 3. Artifact Storage

- Store sync reports as build artifacts
- Keep historical reports for trend analysis
- Archive JSON data for programmatic access

### 4. Notification Strategy

- **Critical:** Slack/email for <50% sync
- **Warning:** PR comments for <70% sync
- **Info:** Weekly reports regardless of status

### 5. Fail Fast

- Block PRs with critical sync issues
- Allow warnings but require acknowledgment
- Provide clear remediation steps

---

*Integrate these patterns into your CI/CD pipeline for automated spec sync monitoring.*
