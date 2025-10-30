# CI/CD Integration Examples

This guide demonstrates how to integrate health checks into various CI/CD pipelines for automated deployment validation.

## Table of Contents

1. [GitHub Actions](#github-actions)
2. [GitLab CI](#gitlab-ci)
3. [Jenkins](#jenkins)
4. [CircleCI](#circleci)
5. [Azure DevOps](#azure-devops)
6. [Deployment Strategies](#deployment-strategies)

---

## GitHub Actions

### Complete Deployment Workflow

```yaml
# .github/workflows/deploy-and-validate.yml
name: Deploy and Validate

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options:
          - staging
          - production

env:
  HEALTH_CHECK_PATH: ./deployment/health-checks/scripts

jobs:
  deploy:
    name: Deploy Application
    runs-on: ubuntu-latest
    outputs:
      deployment-url: ${{ steps.deploy.outputs.url }}

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to environment
        id: deploy
        run: |
          # Your deployment logic here
          echo "url=https://example.com" >> $GITHUB_OUTPUT

  health-check:
    name: Health Check Validation
    needs: deploy
    runs-on: ubuntu-latest
    timeout-minutes: 15

    strategy:
      fail-fast: false
      matrix:
        check:
          - name: HTTP
            script: http-health-check.sh
            args: ${{ needs.deploy.outputs.deployment-url }} 200 3000
          - name: API
            script: api-health-check.sh
            args: ${{ needs.deploy.outputs.deployment-url }}/api/health "Bearer ${{ secrets.API_TOKEN }}"
          - name: SSL
            script: ssl-tls-validator.sh
            args: example.com 443 30
          - name: Performance
            script: performance-tester.sh
            args: ${{ needs.deploy.outputs.deployment-url }} 50 500 10

    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y curl jq openssl bc

      - name: Run ${{ matrix.check.name }} health check
        id: health-check
        run: |
          bash ${{ env.HEALTH_CHECK_PATH }}/${{ matrix.check.script }} \
            ${{ matrix.check.args }}
        continue-on-error: true

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: health-check-${{ matrix.check.name }}
          path: /tmp/perf-test-*/

      - name: Check result
        if: steps.health-check.outcome != 'success'
        run: |
          echo "::error::${{ matrix.check.name }} health check failed"
          exit 1

  rollback:
    name: Rollback on Failure
    needs: [deploy, health-check]
    if: failure()
    runs-on: ubuntu-latest

    steps:
      - name: Trigger rollback
        run: |
          echo "Health checks failed - triggering rollback"
          # Your rollback logic here

      - name: Notify team
        uses: slackapi/slack-github-action@v1.24.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: incoming-webhook
          payload: |
            {
              "text": "🚨 Deployment failed and rolled back",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Deployment Failed*\nHealth checks did not pass. Deployment has been rolled back."
                  }
                }
              ]
            }

  notify-success:
    name: Notify Success
    needs: health-check
    if: success()
    runs-on: ubuntu-latest

    steps:
      - name: Notify team
        uses: slackapi/slack-github-action@v1.24.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: incoming-webhook
          payload: |
            {
              "text": "✅ Deployment successful",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Deployment Successful*\nAll health checks passed."
                  }
                }
              ]
            }
```

### Scheduled Health Monitoring

```yaml
# .github/workflows/scheduled-health-check.yml
name: Scheduled Health Monitoring

on:
  schedule:
    # Run every 15 minutes
    - cron: '*/15 * * * *'
  workflow_dispatch:

jobs:
  monitor:
    name: Production Health Monitor
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: sudo apt-get install -y curl jq openssl bc

      - name: Run health checks
        id: health
        run: |
          FAILED=0

          bash ./scripts/http-health-check.sh https://example.com || FAILED=$((FAILED+1))
          bash ./scripts/api-health-check.sh https://api.example.com/health || FAILED=$((FAILED+1))
          bash ./scripts/ssl-tls-validator.sh example.com || FAILED=$((FAILED+1))

          echo "failed=$FAILED" >> $GITHUB_OUTPUT

      - name: Alert on failure
        if: steps.health.outputs.failed != '0'
        uses: slackapi/slack-github-action@v1.24.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: incoming-webhook
          payload: |
            {
              "text": "⚠️ Production health check failures detected: ${{ steps.health.outputs.failed }}"
            }
```

---

## GitLab CI

### Complete Pipeline with Health Checks

```yaml
# .gitlab-ci.yml
variables:
  HEALTH_CHECK_SCRIPTS: ./scripts/health-checks

stages:
  - build
  - deploy
  - validate
  - rollback

build:
  stage: build
  image: node:18
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

deploy:staging:
  stage: deploy
  image: alpine:latest
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - echo "Deploying to staging..."
    # Your deployment commands
  only:
    - merge_requests
    - develop

deploy:production:
  stage: deploy
  image: alpine:latest
  environment:
    name: production
    url: https://example.com
  script:
    - echo "Deploying to production..."
    # Your deployment commands
  only:
    - main
  when: manual

validate:staging:
  stage: validate
  image: ubuntu:22.04
  dependencies: []
  before_script:
    - apt-get update && apt-get install -y curl jq openssl bc
  variables:
    BASE_URL: "https://staging.example.com"
  script:
    - bash $HEALTH_CHECK_SCRIPTS/http-health-check.sh "$BASE_URL"
    - bash $HEALTH_CHECK_SCRIPTS/api-health-check.sh "$BASE_URL/api/health" "Bearer $STAGING_API_TOKEN"
    - bash $HEALTH_CHECK_SCRIPTS/performance-tester.sh "$BASE_URL" 25 250 10
  only:
    - merge_requests
    - develop
  allow_failure: false

validate:production:
  stage: validate
  image: ubuntu:22.04
  dependencies: []
  before_script:
    - apt-get update && apt-get install -y curl jq openssl bc
  variables:
    BASE_URL: "https://example.com"
  script:
    - bash $HEALTH_CHECK_SCRIPTS/http-health-check.sh "$BASE_URL"
    - bash $HEALTH_CHECK_SCRIPTS/api-health-check.sh "$BASE_URL/api/health" "Bearer $PROD_API_TOKEN"
    - bash $HEALTH_CHECK_SCRIPTS/ssl-tls-validator.sh example.com 443 30
    - bash $HEALTH_CHECK_SCRIPTS/performance-tester.sh "$BASE_URL" 50 500 15
  artifacts:
    when: always
    paths:
      - /tmp/perf-test-*/
    expire_in: 7 days
  only:
    - main
  allow_failure: false

rollback:production:
  stage: rollback
  image: alpine:latest
  script:
    - echo "Rolling back production deployment..."
    # Your rollback commands
  only:
    - main
  when: on_failure
  needs:
    - deploy:production
    - validate:production
```

### Parallel Health Checks

```yaml
# .gitlab-ci.yml (partial)
validate:parallel:
  stage: validate
  image: ubuntu:22.04
  before_script:
    - apt-get update && apt-get install -y curl jq openssl bc
  parallel:
    matrix:
      - CHECK: http
        SCRIPT: http-health-check.sh
        ARGS: "https://example.com 200 3000"
      - CHECK: api
        SCRIPT: api-health-check.sh
        ARGS: "https://api.example.com/health"
      - CHECK: ssl
        SCRIPT: ssl-tls-validator.sh
        ARGS: "example.com 443 30"
      - CHECK: mcp
        SCRIPT: mcp-server-health-check.sh
        ARGS: "https://mcp.example.com"
  script:
    - bash ./scripts/health-checks/$SCRIPT $ARGS
```

---

## Jenkins

### Declarative Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['staging', 'production'],
            description: 'Target environment'
        )
        booleanParam(
            name: 'SKIP_HEALTH_CHECKS',
            defaultValue: false,
            description: 'Skip health check validation (not recommended)'
        )
    }

    environment {
        HEALTH_CHECK_SCRIPTS = "${WORKSPACE}/scripts/health-checks"
        STAGING_URL = 'https://staging.example.com'
        PROD_URL = 'https://example.com'
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    env.DEPLOYMENT_URL = params.ENVIRONMENT == 'production' ?
                        env.PROD_URL : env.STAGING_URL
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENVIRONMENT}..."
                // Your deployment steps
            }
        }

        stage('Health Check - HTTP') {
            when {
                expression { !params.SKIP_HEALTH_CHECKS }
            }
            steps {
                sh """
                    bash ${HEALTH_CHECK_SCRIPTS}/http-health-check.sh \
                        ${DEPLOYMENT_URL} 200 3000
                """
            }
        }

        stage('Health Check - API') {
            when {
                expression { !params.SKIP_HEALTH_CHECKS }
            }
            steps {
                withCredentials([string(credentialsId: 'api-token', variable: 'API_TOKEN')]) {
                    sh """
                        bash ${HEALTH_CHECK_SCRIPTS}/api-health-check.sh \
                            ${DEPLOYMENT_URL}/api/health \
                            "Bearer ${API_TOKEN}" \
                            ".status" "ok"
                    """
                }
            }
        }

        stage('Health Check - SSL') {
            when {
                expression {
                    !params.SKIP_HEALTH_CHECKS && params.ENVIRONMENT == 'production'
                }
            }
            steps {
                script {
                    def hostname = env.DEPLOYMENT_URL.replaceAll('https://', '').split('/')[0]
                    sh """
                        bash ${HEALTH_CHECK_SCRIPTS}/ssl-tls-validator.sh \
                            ${hostname} 443 30
                    """
                }
            }
        }

        stage('Health Check - Performance') {
            when {
                expression { !params.SKIP_HEALTH_CHECKS }
            }
            steps {
                script {
                    def concurrent = params.ENVIRONMENT == 'production' ? 100 : 50
                    def total = params.ENVIRONMENT == 'production' ? 1000 : 500

                    sh """
                        bash ${HEALTH_CHECK_SCRIPTS}/performance-tester.sh \
                            ${DEPLOYMENT_URL} ${concurrent} ${total} 15
                    """
                }
            }
        }

        stage('Archive Results') {
            when {
                expression { !params.SKIP_HEALTH_CHECKS }
            }
            steps {
                archiveArtifacts(
                    artifacts: '/tmp/perf-test-*/*',
                    allowEmptyArchive: true,
                    fingerprint: true
                )
            }
        }
    }

    post {
        failure {
            script {
                if (!params.SKIP_HEALTH_CHECKS) {
                    echo "Health checks failed - triggering rollback"
                    // Rollback logic here
                }
            }

            slackSend(
                color: 'danger',
                message: """
                    Deployment Failed: ${params.ENVIRONMENT}
                    Job: ${env.JOB_NAME} [${env.BUILD_NUMBER}]
                    Health checks: FAILED
                    ${env.BUILD_URL}
                """
            )
        }

        success {
            slackSend(
                color: 'good',
                message: """
                    Deployment Successful: ${params.ENVIRONMENT}
                    Job: ${env.JOB_NAME} [${env.BUILD_NUMBER}]
                    Health checks: PASSED
                """
            )
        }
    }
}
```

---

## CircleCI

### Complete Workflow

```yaml
# .circleci/config.yml
version: 2.1

orbs:
  slack: circleci/slack@4.12.0

executors:
  health-check-executor:
    docker:
      - image: cimg/base:stable
    resource_class: small

commands:
  install-health-check-deps:
    steps:
      - run:
          name: Install dependencies
          command: |
            sudo apt-get update
            sudo apt-get install -y curl jq openssl bc

  run-health-check:
    parameters:
      script:
        type: string
      args:
        type: string
        default: ""
    steps:
      - run:
          name: Health Check - << parameters.script >>
          command: |
            bash ./scripts/health-checks/<< parameters.script >> << parameters.args >>

jobs:
  deploy-staging:
    executor: health-check-executor
    steps:
      - checkout
      - run:
          name: Deploy to staging
          command: |
            echo "Deploying to staging..."
            # Your deployment commands

  deploy-production:
    executor: health-check-executor
    steps:
      - checkout
      - run:
          name: Deploy to production
          command: |
            echo "Deploying to production..."
            # Your deployment commands

  health-check-http:
    executor: health-check-executor
    parameters:
      url:
        type: string
    steps:
      - checkout
      - install-health-check-deps
      - run-health-check:
          script: http-health-check.sh
          args: << parameters.url >> 200 3000

  health-check-api:
    executor: health-check-executor
    parameters:
      url:
        type: string
    steps:
      - checkout
      - install-health-check-deps
      - run-health-check:
          script: api-health-check.sh
          args: << parameters.url >>/api/health "Bearer $API_TOKEN"

  health-check-performance:
    executor: health-check-executor
    parameters:
      url:
        type: string
      concurrent:
        type: integer
        default: 50
      total:
        type: integer
        default: 500
    steps:
      - checkout
      - install-health-check-deps
      - run-health-check:
          script: performance-tester.sh
          args: << parameters.url >> << parameters.concurrent >> << parameters.total >> 10
      - store_artifacts:
          path: /tmp/perf-test-*/

  rollback:
    executor: health-check-executor
    steps:
      - checkout
      - run:
          name: Rollback deployment
          command: |
            echo "Rolling back deployment..."
            # Your rollback commands

workflows:
  deploy-and-validate:
    jobs:
      # Staging
      - deploy-staging:
          filters:
            branches:
              only: develop

      - health-check-http:
          name: staging-http-check
          url: https://staging.example.com
          requires:
            - deploy-staging

      - health-check-api:
          name: staging-api-check
          url: https://staging.example.com
          requires:
            - deploy-staging

      - health-check-performance:
          name: staging-perf-check
          url: https://staging.example.com
          concurrent: 25
          total: 250
          requires:
            - deploy-staging

      # Production
      - deploy-production:
          filters:
            branches:
              only: main
          requires:
            - approve-production

      - approve-production:
          type: approval
          filters:
            branches:
              only: main

      - health-check-http:
          name: production-http-check
          url: https://example.com
          requires:
            - deploy-production

      - health-check-api:
          name: production-api-check
          url: https://example.com
          requires:
            - deploy-production

      - health-check-performance:
          name: production-perf-check
          url: https://example.com
          concurrent: 100
          total: 1000
          requires:
            - deploy-production

      # Rollback on failure
      - rollback:
          requires:
            - production-http-check
            - production-api-check
            - production-perf-check
          filters:
            branches:
              only: main
          when: on_fail
```

---

## Azure DevOps

### Pipeline with Health Checks

```yaml
# azure-pipelines.yml
trigger:
  - main
  - develop

variables:
  healthCheckScripts: '$(Build.SourcesDirectory)/scripts/health-checks'

stages:
  - stage: Deploy
    jobs:
      - deployment: DeployApp
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self

                - script: |
                    echo "Deploying application..."
                    # Your deployment commands
                  displayName: 'Deploy Application'

  - stage: Validate
    dependsOn: Deploy
    jobs:
      - job: HealthChecks
        displayName: 'Run Health Checks'
        pool:
          vmImage: 'ubuntu-latest'

        steps:
          - checkout: self

          - script: |
              sudo apt-get update
              sudo apt-get install -y curl jq openssl bc
            displayName: 'Install Dependencies'

          - task: Bash@3
            displayName: 'HTTP Health Check'
            inputs:
              targetType: 'inline'
              script: |
                bash $(healthCheckScripts)/http-health-check.sh \
                  https://example.com 200 3000

          - task: Bash@3
            displayName: 'API Health Check'
            env:
              API_TOKEN: $(API_TOKEN)
            inputs:
              targetType: 'inline'
              script: |
                bash $(healthCheckScripts)/api-health-check.sh \
                  https://api.example.com/health \
                  "Bearer $API_TOKEN"

          - task: Bash@3
            displayName: 'Performance Test'
            inputs:
              targetType: 'inline'
              script: |
                bash $(healthCheckScripts)/performance-tester.sh \
                  https://example.com 50 500 10

          - task: PublishBuildArtifacts@1
            condition: always()
            inputs:
              pathToPublish: '/tmp/perf-test-*'
              artifactName: 'health-check-results'

  - stage: Rollback
    dependsOn: Validate
    condition: failed()
    jobs:
      - job: RollbackDeployment
        steps:
          - script: |
              echo "Rolling back deployment..."
              # Your rollback commands
            displayName: 'Rollback'
```

---

## Deployment Strategies

### Canary Deployment with Progressive Validation

```bash
#!/bin/bash
# canary-health-check.sh

CANARY_URL="https://canary.example.com"
PRODUCTION_URL="https://example.com"
CANARY_TRAFFIC_PERCENT=10

echo "Canary Deployment Validation"
echo "Canary URL: $CANARY_URL"
echo "Canary Traffic: ${CANARY_TRAFFIC_PERCENT}%"

# Validate canary deployment
echo -e "\nStep 1: Validating canary deployment..."
if ! bash scripts/http-health-check.sh "$CANARY_URL"; then
    echo "✗ Canary failed - aborting"
    exit 1
fi

# Performance comparison
echo -e "\nStep 2: Comparing canary vs production performance..."
bash scripts/performance-tester.sh "$CANARY_URL" 10 100 10 > /tmp/canary-perf.txt
bash scripts/performance-tester.sh "$PRODUCTION_URL" 10 100 10 > /tmp/prod-perf.txt

echo "✓ Canary validated - safe to increase traffic"
```

This comprehensive guide provides production-ready CI/CD integration patterns for all major platforms.
