# CI/CD Pipeline Integration Examples

This guide demonstrates how to integrate deployment-scripts with various CI/CD platforms.

## Overview

Automate deployments using:
- GitHub Actions
- GitLab CI/CD
- CircleCI
- Jenkins
- Bitbucket Pipelines

## GitHub Actions Integration

### Complete Deployment Workflow

Use the provided template as a starting point:

```bash
# Copy template
mkdir -p .github/workflows
cp plugins/deployment/skills/deployment-scripts/templates/github-actions-deploy.yml \
   .github/workflows/deploy.yml
```

### Custom GitHub Actions Workflow

```yaml
name: Deploy Application

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    name: Validate Deployment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Validate environment
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh \
            .env.production.example

      - name: Validate build
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

  deploy:
    name: Deploy to Platform
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://my-app.com
    steps:
      - uses: actions/checkout@v4

      - name: Install Vercel CLI
        run: npm install -g vercel

      - name: Deploy with helper script
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
            --platform vercel \
            --env production
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}

      - name: Health check
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh \
            https://my-app.com
```

### Reusable Workflow

Create `.github/workflows/reusable-deploy.yml`:

```yaml
name: Reusable Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      platform:
        required: true
        type: string
    secrets:
      DEPLOY_TOKEN:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4

      - name: Validate
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh \
            .env.${{ inputs.environment }}

      - name: Deploy
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
            --platform ${{ inputs.platform }} \
            --env ${{ inputs.environment }}
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

Use in other workflows:

```yaml
name: Deploy Staging

on:
  push:
    branches: [develop]

jobs:
  deploy:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
      platform: vercel
    secrets:
      DEPLOY_TOKEN: ${{ secrets.VERCEL_TOKEN }}
```

## GitLab CI/CD Integration

### Complete Pipeline

Use the provided template:

```bash
# Copy template
cp plugins/deployment/skills/deployment-scripts/templates/gitlab-ci-deploy.yml \
   .gitlab-ci.yml
```

### Custom GitLab Pipeline with Deployment Scripts

```yaml
stages:
  - validate
  - build
  - deploy
  - verify

variables:
  SKILLS_DIR: "plugins/deployment/skills/deployment-scripts/scripts"

validate:env:
  stage: validate
  image: ubuntu:22.04
  before_script:
    - apt-get update && apt-get install -y curl bash
  script:
    - bash $SKILLS_DIR/validate-env.sh .env.production.example
  only:
    - main
    - develop

validate:build:
  stage: validate
  image: node:18
  before_script:
    - npm ci
  script:
    - bash $SKILLS_DIR/validate-build.sh .
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

deploy:production:
  stage: deploy
  image: node:18
  dependencies:
    - validate:build
  environment:
    name: production
    url: https://my-app.com
    on_stop: rollback:production
  script:
    - npm install -g vercel
    - bash $SKILLS_DIR/check-auth.sh vercel
    - bash $SKILLS_DIR/deploy-helper.sh --platform vercel --env production
  only:
    - main
  when: manual

verify:production:
  stage: verify
  image: curlimages/curl:latest
  dependencies: []
  script:
    - bash $SKILLS_DIR/health-check.sh https://my-app.com
  only:
    - main

rollback:production:
  stage: deploy
  image: node:18
  environment:
    name: production
    action: stop
  script:
    - npm install -g vercel
    - bash $SKILLS_DIR/rollback-deployment.sh vercel
  when: manual
  only:
    - main
```

## CircleCI Integration

Create `.circleci/config.yml`:

```yaml
version: 2.1

orbs:
  node: circleci/node@5.1

jobs:
  validate:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - node/install-packages

      - run:
          name: Validate environment
          command: |
            bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh \
              .env.production.example

      - run:
          name: Validate build
          command: |
            bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

  deploy:
    docker:
      - image: cimg/node:18.0
    steps:
      - checkout
      - node/install-packages

      - run:
          name: Install Vercel CLI
          command: npm install -g vercel

      - run:
          name: Deploy to production
          command: |
            bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
              --platform vercel \
              --env production
          environment:
            VERCEL_TOKEN: $VERCEL_TOKEN

      - run:
          name: Health check
          command: |
            bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh \
              https://my-app.com

workflows:
  deploy-production:
    jobs:
      - validate
      - deploy:
          requires:
            - validate
          filters:
            branches:
              only: main
```

## Jenkins Integration

Create `Jenkinsfile`:

```groovy
pipeline {
    agent any

    environment {
        SKILLS_DIR = 'plugins/deployment/skills/deployment-scripts/scripts'
        VERCEL_TOKEN = credentials('vercel-token')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Validate Environment') {
            steps {
                sh "bash ${SKILLS_DIR}/validate-env.sh .env.production"
            }
        }

        stage('Validate Build') {
            steps {
                sh "bash ${SKILLS_DIR}/validate-build.sh ."
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'

                sh '''
                    npm install -g vercel
                    bash ${SKILLS_DIR}/deploy-helper.sh \
                      --platform vercel \
                      --env production
                '''
            }
        }

        stage('Health Check') {
            when {
                branch 'main'
            }
            steps {
                sh "bash ${SKILLS_DIR}/health-check.sh https://my-app.com"
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
            slackSend(
                color: 'good',
                message: "Deployment succeeded: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            )
        }
        failure {
            echo 'Deployment failed!'
            slackSend(
                color: 'danger',
                message: "Deployment failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            )
        }
    }
}
```

## Bitbucket Pipelines Integration

Create `bitbucket-pipelines.yml`:

```yaml
image: node:18

definitions:
  steps:
    - step: &validate
        name: Validate
        caches:
          - node
        script:
          - npm ci
          - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production.example
          - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

    - step: &deploy
        name: Deploy to Production
        deployment: production
        script:
          - npm install -g vercel
          - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/check-auth.sh vercel
          - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh --platform vercel --env production
        after-script:
          - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh https://my-app.com

pipelines:
  branches:
    main:
      - step: *validate
      - step: *deploy

  pull-requests:
    '**':
      - step: *validate
```

## Travis CI Integration

Create `.travis.yml`:

```yaml
language: node_js
node_js:
  - '18'

cache:
  directories:
    - node_modules

stages:
  - validate
  - deploy

jobs:
  include:
    - stage: validate
      name: "Validate Environment and Build"
      script:
        - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production.example
        - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

    - stage: deploy
      name: "Deploy to Production"
      if: branch = main AND type = push
      before_script:
        - npm install -g vercel
      script:
        - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh --platform vercel --env production
      after_script:
        - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/health-check.sh https://my-app.com
```

## Docker-Based CI/CD

### GitHub Actions with Docker

```yaml
name: Docker Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: |
          docker build \
            -f plugins/deployment/skills/deployment-scripts/templates/Dockerfile.node \
            -t my-app:latest .

      - name: Run validation in container
        run: |
          docker run --rm my-app:latest \
            bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .

      - name: Push to registry
        run: |
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker tag my-app:latest myregistry/my-app:latest
          docker push myregistry/my-app:latest

      - name: Deploy to Fly.io
        run: |
          bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/deploy-helper.sh \
            --platform fly \
            --env production
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

## Best Practices

### 1. Secret Management

Never commit secrets to version control:

```yaml
# GitHub Actions - Use secrets
env:
  VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}

# GitLab - Use CI/CD variables
script:
  - export VERCEL_TOKEN=$VERCEL_TOKEN
```

### 2. Environment-Specific Pipelines

```yaml
# Deploy to different environments based on branch
deploy:staging:
  only:
    - develop
  environment: staging

deploy:production:
  only:
    - main
  environment: production
  when: manual  # Require approval
```

### 3. Rollback Capabilities

```yaml
rollback:
  stage: deploy
  script:
    - bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/rollback-deployment.sh vercel
  when: manual
```

### 4. Notifications

```yaml
# Slack notification
after_script:
  - |
    curl -X POST $SLACK_WEBHOOK \
      -d "{'text': 'Deployment ${CI_JOB_STATUS}'}"
```

### 5. Caching

```yaml
# GitLab
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/

# GitHub Actions
- uses: actions/cache@v3
  with:
    path: node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

## Troubleshooting

### Pipeline Fails at Validation

```bash
# Run validation locally first
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-env.sh .env.production
bash ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/deployment/skills/deployment-scripts/scripts/validate-build.sh .
```

### Authentication Issues in CI

```yaml
# Ensure secrets are configured
# GitHub: Repository Settings > Secrets
# GitLab: Settings > CI/CD > Variables
```

### Timeout Issues

```yaml
# Increase timeout
timeout-minutes: 30  # GitHub Actions

# GitLab
timeout: 30m
```

## Next Steps

- Implement blue-green deployments
- Set up canary deployments
- Configure automated rollback on health check failure
- Add deployment approvals for production
