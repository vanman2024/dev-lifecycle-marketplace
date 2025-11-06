# GitHub Environment Protection Rules

This guide shows how to configure GitHub environment protection rules to enforce approval requirements at the repository level.

## Overview

Environment protection rules provide a second layer of approval enforcement directly in GitHub, complementing approval gate workflows.

## Setup Steps

### 1. Create Environments

Navigate to your repository on GitHub:

```
Settings → Environments → New environment
```

Create the following environments:
- `production`
- `staging`
- `development`

### 2. Configure Production Environment Protection

For the `production` environment:

#### Required Reviewers

```
Settings → Environments → production → Required reviewers
```

Add required reviewers:
- `@tech-lead`
- `@release-manager`
- `@product-owner`

Set minimum approvals: **2**

#### Wait Timer

```
Settings → Environments → production → Wait timer
```

Set wait timer: **0 minutes** (immediate deployment after approval)

Or set grace period: **15 minutes** (allows time to cancel)

#### Deployment Branches

```
Settings → Environments → production → Deployment branches
```

Configure allowed branches:
- `main` (or `master`)
- `release/*` (for release branches)

**DO NOT** allow:
- Feature branches
- Development branches
- Pull request branches

### 3. Configure Staging Environment Protection

For the `staging` environment:

#### Required Reviewers

Add QA team:
- `@qa-lead`
- `@qa-engineer`

Set minimum approvals: **1**

#### Deployment Branches

Allow:
- `main`
- `develop`
- `release/*`
- `staging/*`

### 4. Configure Workflow to Use Environments

Update your deployment workflow to reference environments:

```yaml
jobs:
  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://app.example.com
    steps:
      - name: Deploy
        run: |
          # Deployment steps here
          echo "Deploying to production..."
```

## Environment Protection Rules Reference

### Protection Rule Types

1. **Required Reviewers**
   - Enforces approval from specific users or teams
   - Minimum approval count (1-6 reviewers)
   - Reviewers must have write access to repository

2. **Wait Timer**
   - Delays deployment for specified minutes
   - Allows time to cancel deployment
   - Range: 0-43,200 minutes (30 days)

3. **Deployment Branches**
   - Restricts which branches can deploy to environment
   - Options:
     - Selected branches (branch name patterns)
     - Protected branches only
     - All branches

4. **Environment Secrets**
   - Environment-specific secrets
   - Override repository secrets
   - Scoped to environment deployments only

### Best Practices

#### Production Environment

```yaml
Required reviewers: 2+ (Tech Lead + Release Manager)
Wait timer: 0-15 minutes
Deployment branches: main, release/*
Secrets: PROD_API_KEY, PROD_DB_URL
```

#### Staging Environment

```yaml
Required reviewers: 1 (QA Lead)
Wait timer: 0 minutes
Deployment branches: main, develop, release/*
Secrets: STAGING_API_KEY, STAGING_DB_URL
```

#### Development Environment

```yaml
Required reviewers: None
Wait timer: 0 minutes
Deployment branches: All branches
Secrets: DEV_API_KEY, DEV_DB_URL
```

## Integrating with Approval Workflows

### Workflow Pattern

1. **Approval Workflow** (using approval-gates.yml):
   - Collects stakeholder approvals via GitHub issues
   - Documents approval decisions and audit trail
   - Generates approval records

2. **Deployment Workflow** (using environment protection):
   - References `production` environment
   - Enforces GitHub-native approval requirements
   - Requires approval before deployment steps execute

### Combined Example

```yaml
# Approval workflow (manual trigger)
name: Release Approval
on:
  workflow_dispatch:
    inputs:
      version:
        required: true
jobs:
  collect-approvals:
    # Use approval-gates.yml workflow
    # Collects all stakeholder approvals

# Deployment workflow (triggered after approval)
name: Deploy to Production
on:
  push:
    tags:
      - 'v*.*.*'
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Requires GitHub environment approval
    steps:
      - name: Deploy
        run: ./deploy.sh
```

## Security Considerations

### Never Bypass Protection Rules

❌ **DO NOT**:
- Give deployment workflows `environment: write` permission to bypass rules
- Use personal access tokens (PATs) to circumvent approval requirements
- Allow feature branches to deploy to production
- Store production secrets in repository secrets (use environment secrets)

✅ **DO**:
- Require approvals from multiple stakeholders
- Use environment-specific secrets
- Restrict deployment branches
- Audit environment access logs
- Review protection rules quarterly

### Emergency Access

For emergency deployments (hotfixes, security patches):

1. **Option 1: Emergency Override** (if configured in approval-gates.yml)
   - Requires CTO/Engineering Manager approval
   - Documents justification
   - Creates audit trail

2. **Option 2: Temporary Rule Relaxation**
   - Admin temporarily reduces approval count
   - Deploy emergency fix
   - Restore protection rules immediately
   - Document in post-mortem

## Troubleshooting

### Deployment Stuck on Approval

**Symptoms**: Workflow shows "Waiting for review"

**Solutions**:
1. Check required reviewers have been notified
2. Verify reviewers have write access to repository
3. Ensure branch is allowed in deployment branches
4. Check approval hasn't timed out

### Unable to Deploy After Approval

**Symptoms**: Approved but workflow still blocked

**Solutions**:
1. Verify approval came from configured required reviewer
2. Check minimum approval count met
3. Ensure wait timer (if configured) has elapsed
4. Confirm no new commits pushed after approval

### Wrong Environment Selected

**Symptoms**: Production deployment uses staging secrets

**Solutions**:
1. Verify workflow references correct environment: `environment: production`
2. Check environment secrets are properly scoped
3. Validate deployment branch matches protection rules

## Additional Resources

- [GitHub Docs: Using environments for deployment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [GitHub Docs: Environment protection rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-protection-rules)
- [GitHub Docs: Environment secrets](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets)
