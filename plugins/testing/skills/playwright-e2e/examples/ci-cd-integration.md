# CI/CD Integration - Playwright E2E Testing

Integrate Playwright tests into your CI/CD pipeline for automated testing on every commit, pull request, and deployment.

## GitHub Actions

### Basic Workflow

Create `.github/workflows/playwright.yml`:

```yaml
name: Playwright Tests

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test:
    timeout-minutes: 60
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright Browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npx playwright test

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

### Advanced Workflow with Matrix

Test across multiple environments:

```yaml
name: Playwright Tests Matrix

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    timeout-minutes: 60
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [18, 20]
        browser: [chromium, firefox, webkit]

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps ${{ matrix.browser }}

      - name: Run Playwright tests
        run: npx playwright test --project=${{ matrix.browser }}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report-${{ matrix.os }}-${{ matrix.browser }}
          path: playwright-report/
```

### With Test Sharding

Speed up tests by running in parallel:

```yaml
name: Playwright Tests (Sharded)

on: [push, pull_request]

jobs:
  test:
    timeout-minutes: 60
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        shardIndex: [1, 2, 3, 4]
        shardTotal: [4]

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npx playwright test --shard=${{ matrix.shardIndex }}/${{ matrix.shardTotal }}

      - name: Upload blob report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: blob-report-${{ matrix.shardIndex }}
          path: blob-report/
          retention-days: 1

  merge-reports:
    if: always()
    needs: [test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Download blob reports
        uses: actions/download-artifact@v3
        with:
          path: all-blob-reports

      - name: Merge into HTML Report
        run: npx playwright merge-reports --reporter html ./all-blob-reports

      - name: Upload HTML report
        uses: actions/upload-artifact@v3
        with:
          name: html-report-merged
          path: playwright-report
```

## GitLab CI

### Basic Configuration

Create `.gitlab-ci.yml`:

```yaml
image: mcr.microsoft.com/playwright:v1.40.0-focal

stages:
  - test

e2e-tests:
  stage: test
  script:
    - npm ci
    - npx playwright test
  artifacts:
    when: always
    paths:
      - playwright-report/
      - test-results/
    expire_in: 1 week
  only:
    - main
    - merge_requests
```

### With Caching

```yaml
image: mcr.microsoft.com/playwright:v1.40.0-focal

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/

stages:
  - test

e2e-tests:
  stage: test
  before_script:
    - npm ci --cache .npm --prefer-offline
  script:
    - npx playwright test
  artifacts:
    when: always
    paths:
      - playwright-report/
      - test-results/
    reports:
      junit: test-results/junit.xml
    expire_in: 1 week
```

## Jenkins

### Jenkinsfile

```groovy
pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/playwright:v1.40.0-focal'
        }
    }

    stages {
        stage('Install') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Test') {
            steps {
                sh 'npx playwright test'
            }
        }
    }

    post {
        always {
            publishHTML([
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Playwright Test Report',
                keepAll: true,
                alwaysLinkToLastBuild: true
            ])
            archiveArtifacts artifacts: 'test-results/**/*', allowEmptyArchive: true
        }
    }
}
```

## CircleCI

### Configuration

Create `.circleci/config.yml`:

```yaml
version: 2.1

orbs:
  node: circleci/node@5.0.2

jobs:
  test:
    docker:
      - image: mcr.microsoft.com/playwright:v1.40.0-focal
    steps:
      - checkout

      - node/install-packages:
          pkg-manager: npm

      - run:
          name: Install Playwright
          command: npx playwright install

      - run:
          name: Run tests
          command: npx playwright test

      - store_artifacts:
          path: playwright-report/
          destination: playwright-report

      - store_test_results:
          path: test-results/

workflows:
  test:
    jobs:
      - test
```

## Docker Integration

### Dockerfile for Testing

```dockerfile
FROM mcr.microsoft.com/playwright:v1.40.0-focal

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy test files
COPY . .

# Run tests
CMD ["npx", "playwright", "test"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  playwright-tests:
    build: .
    volumes:
      - ./tests:/app/tests
      - ./playwright-report:/app/playwright-report
      - ./test-results:/app/test-results
    environment:
      - CI=true
      - BASE_URL=http://app:3000
    depends_on:
      - app

  app:
    image: your-app-image:latest
    ports:
      - "3000:3000"
```

Run tests:

```bash
docker-compose up --abort-on-container-exit
```

## Azure Pipelines

### azure-pipelines.yml

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '18.x'
    displayName: 'Install Node.js'

  - script: |
      npm ci
    displayName: 'Install dependencies'

  - script: |
      npx playwright install --with-deps
    displayName: 'Install Playwright browsers'

  - script: |
      npx playwright test
    displayName: 'Run Playwright tests'

  - task: PublishTestResults@2
    displayName: 'Publish test results'
    inputs:
      testResultsFormat: 'JUnit'
      testResultsFiles: 'test-results/junit.xml'
      failTaskOnFailedTests: true
    condition: always()

  - task: PublishPipelineArtifact@1
    displayName: 'Publish HTML report'
    inputs:
      targetPath: 'playwright-report'
      artifact: 'playwright-report'
    condition: always()
```

## Configuration for CI

### playwright.config.ts for CI

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // Run tests in CI with specific settings
  workers: process.env.CI ? 1 : undefined,
  retries: process.env.CI ? 2 : 0,
  forbidOnly: !!process.env.CI,

  // CI-specific reporter
  reporter: process.env.CI
    ? [
        ['html', { open: 'never' }],
        ['junit', { outputFile: 'test-results/junit.xml' }],
        ['github'],
      ]
    : [['html', { open: 'on-failure' }]],

  use: {
    // Base URL from environment variable
    baseURL: process.env.BASE_URL || 'http://localhost:3000',

    // Collect trace on first retry
    trace: 'on-first-retry',

    // Screenshots and videos
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Add more browsers as needed
  ],

  // Start dev server in CI if needed
  webServer: process.env.CI
    ? undefined
    : {
        command: 'npm run dev',
        url: 'http://localhost:3000',
        reuseExistingServer: true,
      },
});
```

## Environment Variables

### Setting Environment Variables

#### GitHub Actions

```yaml
env:
  BASE_URL: https://staging.example.com
  API_KEY: ${{ secrets.API_KEY }}
```

#### GitLab CI

```yaml
variables:
  BASE_URL: https://staging.example.com
  API_KEY: $CI_API_KEY
```

#### Jenkins

```groovy
environment {
    BASE_URL = 'https://staging.example.com'
    API_KEY = credentials('api-key')
}
```

### Using in Tests

```typescript
// Access environment variables
const baseURL = process.env.BASE_URL || 'http://localhost:3000';
const apiKey = process.env.API_KEY;

test('api test with env vars', async ({ page }) => {
  await page.goto(baseURL);
  await page.setExtraHTTPHeaders({
    'X-API-Key': apiKey,
  });
});
```

## Caching Strategies

### Cache Playwright Browsers

#### GitHub Actions

```yaml
- name: Cache Playwright browsers
  uses: actions/cache@v3
  with:
    path: ~/.cache/ms-playwright
    key: ${{ runner.os }}-playwright-${{ hashFiles('**/package-lock.json') }}
```

#### GitLab CI

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - ~/.cache/ms-playwright/
```

### Cache npm Dependencies

```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

## Parallel Execution

### Run Tests in Parallel

Playwright automatically parallelizes:

```typescript
// playwright.config.ts
export default defineConfig({
  workers: process.env.CI ? 2 : undefined,
  fullyParallel: true,
});
```

### Control Parallelization

```bash
# Run with specific number of workers
npx playwright test --workers=4

# Run serially (one at a time)
npx playwright test --workers=1
```

## Test Reporting

### Multiple Reporters

```typescript
// playwright.config.ts
export default defineConfig({
  reporter: [
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['github'], // GitHub annotations
    ['list'], // Console output
  ],
});
```

### Publish Reports

#### GitHub Actions - GitHub Pages

```yaml
- name: Deploy report to GitHub Pages
  if: always()
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./playwright-report
```

#### Upload to S3

```yaml
- name: Upload to S3
  if: always()
  uses: jakejarvis/s3-sync-action@master
  with:
    args: --acl public-read --follow-symlinks
  env:
    AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    SOURCE_DIR: 'playwright-report'
```

## Notifications

### Slack Notifications

```yaml
- name: Slack Notification
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Playwright tests failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Email Notifications

```yaml
- name: Send email on failure
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Playwright Tests Failed
    to: team@example.com
    from: CI/CD
    body: The Playwright tests have failed. Check the logs.
```

## Best Practices

### 1. Use CI-Specific Configuration

```typescript
const config = {
  workers: process.env.CI ? 1 : undefined,
  retries: process.env.CI ? 2 : 0,
  timeout: process.env.CI ? 60000 : 30000,
};
```

### 2. Cache Dependencies and Browsers

Speeds up CI runs significantly.

### 3. Run Tests on Multiple Browsers

Ensure cross-browser compatibility:

```typescript
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  { name: 'webkit', use: { ...devices['Desktop Safari'] } },
];
```

### 4. Use Test Sharding for Large Suites

Split tests across multiple machines.

### 5. Store Artifacts

Always upload test results and reports:

```yaml
- uses: actions/upload-artifact@v3
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
```

### 6. Retry Flaky Tests

```typescript
retries: process.env.CI ? 2 : 0;
```

### 7. Set Appropriate Timeouts

```typescript
timeout: 60 * 1000; // 60 seconds per test in CI
```

## Troubleshooting

### Out of Memory

```yaml
- name: Increase Node memory
  run: export NODE_OPTIONS="--max-old-space-size=4096"
```

### Browser Installation Issues

```bash
# Install system dependencies
npx playwright install-deps
```

### Flaky Tests in CI

```typescript
// Add retries for CI
test('flaky test', async ({ page }) => {
  test.slow(); // Triple timeout
  // test code
});
```

## Resources

- [Playwright CI Guide](https://playwright.dev/docs/ci)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitLab CI](https://docs.gitlab.com/ee/ci/)
- [Docker Hub - Playwright Images](https://hub.docker.com/_/microsoft-playwright)
