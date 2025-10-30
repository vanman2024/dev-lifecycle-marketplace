# CI/CD Security Integration Example

Automating security scans in GitHub Actions, GitLab CI, and Jenkins pipelines.

## Scenario

Integrate all security scans into your CI/CD pipeline to catch vulnerabilities before they reach production.

## GitHub Actions Implementation

### .github/workflows/security-scan.yml

```yaml
name: Security Scan Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM

jobs:
  security-scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up scan environment
        run: |
          mkdir -p security-scans
          sudo apt-get update
          sudo apt-get install -y jq

      - name: Scan for secrets
        id: secrets
        run: |
          bash scripts/scan-secrets.sh . > security-scans/secrets.json
          SECRETS_COUNT=$(jq '.total_findings' security-scans/secrets.json)
          echo "secrets_found=$SECRETS_COUNT" >> $GITHUB_OUTPUT
        continue-on-error: true

      - name: Scan dependencies
        id: deps
        run: |
          bash scripts/scan-dependencies.sh . > security-scans/dependencies.json
          CRITICAL=$(jq '.severity_breakdown.critical' security-scans/dependencies.json)
          echo "critical_vulns=$CRITICAL" >> $GITHUB_OUTPUT
        continue-on-error: true

      - name: Scan OWASP patterns
        id: owasp
        run: |
          bash scripts/scan-owasp.sh . > security-scans/owasp.json
          OWASP_COUNT=$(jq '.total_findings' security-scans/owasp.json)
          echo "owasp_findings=$OWASP_COUNT" >> $GITHUB_OUTPUT
        continue-on-error: true

      - name: Generate security report
        run: |
          bash scripts/generate-security-report.sh security-scans html security-report
          bash scripts/generate-security-report.sh security-scans json security-report

      - name: Upload scan results
        uses: actions/upload-artifact@v3
        with:
          name: security-scan-results
          path: |
            security-scans/*.json
            security-report.html
            security-report.json

      - name: Evaluate results
        run: |
          SECRETS=${{ steps.secrets.outputs.secrets_found }}
          CRITICAL=${{ steps.deps.outputs.critical_vulns }}

          echo "Security Scan Results:"
          echo "  Secrets found: $SECRETS"
          echo "  Critical vulnerabilities: $CRITICAL"

          # Fail build if critical issues found
          if [ "$SECRETS" -gt 0 ]; then
            echo "ERROR: Secrets detected in codebase!"
            exit 1
          fi

          if [ "$CRITICAL" -gt 0 ]; then
            echo "ERROR: Critical vulnerabilities detected!"
            exit 1
          fi

      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('security-report.json', 'utf8'));

            const body = `## Security Scan Results

            | Metric | Count |
            |--------|-------|
            | Total Findings | ${report.executive_summary.total_findings} |
            | Critical | ${report.executive_summary.severity_breakdown.critical} |
            | High | ${report.executive_summary.severity_breakdown.high} |
            | Medium | ${report.executive_summary.severity_breakdown.medium} |
            | Low | ${report.executive_summary.severity_breakdown.low} |

            **Risk Score:** ${report.executive_summary.risk_score}/100
            **Risk Level:** ${report.executive_summary.risk_level}

            [View full report](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})
            `;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
```

## GitLab CI Implementation

### .gitlab-ci.yml

```yaml
stages:
  - security-scan
  - report
  - deploy

variables:
  SCAN_DIR: "security-scans"

security:scan:
  stage: security-scan
  image: ubuntu:22.04
  before_script:
    - apt-get update && apt-get install -y jq curl
    - mkdir -p $SCAN_DIR
  script:
    # Run all scans
    - bash scripts/scan-secrets.sh . > $SCAN_DIR/secrets.json || true
    - bash scripts/scan-dependencies.sh . > $SCAN_DIR/dependencies.json || true
    - bash scripts/scan-owasp.sh . > $SCAN_DIR/owasp.json || true

    # Check for critical issues
    - |
      SECRETS=$(jq '.total_findings' $SCAN_DIR/secrets.json)
      CRITICAL=$(jq '.severity_breakdown.critical' $SCAN_DIR/dependencies.json)

      if [ "$SECRETS" -gt 0 ]; then
        echo "ERROR: Secrets detected!"
        exit 1
      fi

      if [ "$CRITICAL" -gt 0 ]; then
        echo "ERROR: Critical vulnerabilities!"
        exit 1
      fi
  artifacts:
    paths:
      - $SCAN_DIR/
    expire_in: 30 days
    when: always

security:report:
  stage: report
  image: ubuntu:22.04
  needs: [security:scan]
  before_script:
    - apt-get update && apt-get install -y jq
  script:
    - bash scripts/generate-security-report.sh $SCAN_DIR html security-report
    - bash scripts/generate-security-report.sh $SCAN_DIR json security-report
  artifacts:
    reports:
      sast: security-report.json
    paths:
      - security-report.html
      - security-report.json
    expire_in: 90 days

deploy:production:
  stage: deploy
  needs: [security:scan, security:report]
  only:
    - main
  script:
    - echo "Deploying to production..."
    # Your deployment steps
```

## Jenkins Pipeline

### Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        SCAN_DIR = 'security-scans'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup') {
            steps {
                sh 'mkdir -p ${SCAN_DIR}'
            }
        }

        stage('Security Scans') {
            parallel {
                stage('Secret Scan') {
                    steps {
                        sh '''
                            bash scripts/scan-secrets.sh . > ${SCAN_DIR}/secrets.json || true
                        '''
                    }
                }

                stage('Dependency Scan') {
                    steps {
                        sh '''
                            bash scripts/scan-dependencies.sh . > ${SCAN_DIR}/dependencies.json || true
                        '''
                    }
                }

                stage('OWASP Scan') {
                    steps {
                        sh '''
                            bash scripts/scan-owasp.sh . > ${SCAN_DIR}/owasp.json || true
                        '''
                    }
                }
            }
        }

        stage('Generate Report') {
            steps {
                sh '''
                    bash scripts/generate-security-report.sh ${SCAN_DIR} html security-report
                    bash scripts/generate-security-report.sh ${SCAN_DIR} json security-report
                '''
            }
        }

        stage('Evaluate Results') {
            steps {
                script {
                    def secrets = sh(
                        script: "jq '.total_findings' ${SCAN_DIR}/secrets.json",
                        returnStdout: true
                    ).trim().toInteger()

                    def critical = sh(
                        script: "jq '.severity_breakdown.critical' ${SCAN_DIR}/dependencies.json",
                        returnStdout: true
                    ).trim().toInteger()

                    echo "Secrets found: ${secrets}"
                    echo "Critical vulnerabilities: ${critical}"

                    if (secrets > 0) {
                        error("Secrets detected in codebase!")
                    }

                    if (critical > 0) {
                        error("Critical vulnerabilities detected!")
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'security-scans/*.json, security-report.*', allowEmptyArchive: true
            publishHTML([
                reportDir: '.',
                reportFiles: 'security-report.html',
                reportName: 'Security Scan Report'
            ])
        }

        failure {
            emailext (
                subject: "Security Scan Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """Security scan detected critical issues.

                View report: ${env.BUILD_URL}Security_Scan_Report/

                Build: ${env.BUILD_URL}
                """,
                to: "${env.SECURITY_TEAM_EMAIL}"
            )
        }
    }
}
```

## Pre-commit Hook

### .git/hooks/pre-commit

```bash
#!/bin/bash

echo "Running pre-commit security checks..."

# Quick secret scan
bash scripts/scan-secrets.sh . --quick > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: Secrets detected! Commit aborted."
    echo "Run 'bash scripts/scan-secrets.sh .' for details."
    exit 1
fi

echo "Security checks passed."
exit 0
```

## Notifications

### Slack Integration

```bash
# In CI/CD pipeline
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

curl -X POST $SLACK_WEBHOOK \
  -H 'Content-Type: application/json' \
  -d '{
    "text": "Security Scan Alert",
    "blocks": [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Security Scan Results*\n• Critical: '$CRITICAL'\n• High: '$HIGH'\n• Medium: '$MEDIUM'"
        }
      }
    ]
  }'
```

## Best Practices

1. **Fail fast** - Block builds with critical/high vulnerabilities
2. **Daily scans** - Schedule scans even without code changes
3. **Separate jobs** - Run scans in parallel for speed
4. **Cache dependencies** - Speed up subsequent runs
5. **Store artifacts** - Keep scan results for audit trail
6. **Alert stakeholders** - Notify security team of failures
7. **Track metrics** - Monitor security posture over time
8. **Document exceptions** - Track accepted risks
9. **Regular updates** - Keep scanning tools updated
10. **Test before deploy** - Never skip security checks

## Next Steps

- [Security Report Interpretation](./security-report-interpretation.md)
- [Basic Secret Scanning](./basic-secret-scanning.md)
- [Vulnerability Remediation](../templates/vulnerability-remediation.md)
