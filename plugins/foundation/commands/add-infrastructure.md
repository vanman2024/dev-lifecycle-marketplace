---
description: Add infrastructure component to project.json and generate spec - handles webhooks, email, storage, queues, search, analytics, payments
argument-hint: <component-type> "<description>"
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---

**Arguments**: $ARGUMENTS

Goal: Add a new infrastructure component to project.json and generate corresponding spec in specs/infrastructure/. This is for SYSTEM-LEVEL components, NOT user-facing features.

## Infrastructure vs Features

**Infrastructure** (use this command):
- Webhooks, email services, file storage, message queues
- Search engines, analytics, payment processing infrastructure
- Rate limiting, backup systems, CI/CD pipelines
- Monitoring, error tracking, caching, logging

**Features** (use /planning:add-feature):
- User-facing capabilities that provide direct value
- Things users interact with or pay for specifically
- Shown in marketing materials

Phase 1: Parse Arguments
Goal: Extract infrastructure component type and description

Actions:
- Create todo list tracking phases
- Parse arguments: `<component-type> "<description>"`
- Valid component types:
  - `authentication` - Auth providers (Clerk, Auth0, Supabase Auth)
  - `database` - Database setup (PostgreSQL, MongoDB, Redis)
  - `caching` - Cache layers (Redis, Memcached)
  - `monitoring` - Observability (Sentry, DataDog, New Relic)
  - `error_handling` - Error tracking and logging
  - `rate_limiting` - API rate limiting
  - `ci_cd` - CI/CD pipelines (GitHub Actions, GitLab CI)
  - `webhooks` - Webhook handling (inbound/outbound)
  - `email` - Email services (SendGrid, Mailgun, AWS SES)
  - `storage` - File storage (S3, Supabase Storage, Cloudinary)
  - `queue` - Message queues (Celery, Bull, RabbitMQ, SQS)
  - `search` - Search engines (Elasticsearch, Algolia, Typesense)
  - `analytics` - Analytics platforms (Google Analytics, Mixpanel)
  - `payments` - Payment processing infrastructure (Stripe setup)
  - `backup` - Backup and disaster recovery
  - `logging` - Structured logging (Winston, Pino, structured logs)
- Example: `webhooks "Stripe webhook handling for payment events"`
- Update todos

Phase 2: Check Existing Infrastructure
Goal: Verify component doesn't already exist and determine next number

Actions:
- Read .claude/project.json
- Check if component type already exists in infrastructure section
- If exists, ask user if they want to update or add another instance
- Count existing specs in specs/infrastructure/ to determine next number
- Example: If 001-authentication, 002-database exist → next is 003
- Update todos

Phase 3: Update project.json
Goal: Add infrastructure component to project.json

Actions:
- Read current .claude/project.json
- Add new infrastructure component with structure:
  ```json
  "infrastructure": {
    "webhooks": {
      "provider": "Custom / Stripe",
      "description": "User-provided description",
      "features": ["inbound webhooks", "signature verification", "retry handling"],
      "integration": "Determined from description"
    }
  }
  ```
- Infer provider and features from description
- Write updated project.json
- Update todos

Phase 4: Generate Infrastructure Spec
Goal: Create spec directory and files in specs/infrastructure/

Actions:
- Create directory: `specs/infrastructure/{number}-{component-type}/`
- Generate three files:

**spec.md** (~200-300 lines):
```markdown
# Infrastructure: {Component Type}

## Overview
{Description from user input}

## Provider
{Inferred provider}

## Requirements
- Functional requirements
- Non-functional requirements (performance, security)

## Configuration
- Environment variables needed
- API keys / secrets
- Connection strings

## Integration Points
- Which features depend on this
- How other components connect

## Security Considerations
- Authentication/authorization
- Data protection
- Compliance requirements

## Monitoring & Alerting
- Health checks
- Metrics to track
- Alert thresholds
```

**setup.md** (~150-250 lines):
```markdown
# Setup: {Component Type}

## Prerequisites
- Required accounts/services
- Required tools

## Installation Steps
1. Step-by-step installation
2. Configuration steps
3. Environment variable setup

## Verification
- How to verify setup is correct
- Test commands

## Troubleshooting
- Common issues and solutions
```

**tasks.md** (~100-150 lines):
```markdown
# Implementation Tasks: {Component Type}

## Phase 1: Setup & Configuration
- [ ] Create service account / API keys
- [ ] Configure environment variables
- [ ] Install dependencies

## Phase 2: Core Implementation
- [ ] Implement main functionality
- [ ] Add error handling
- [ ] Add logging

## Phase 3: Integration
- [ ] Connect to dependent features
- [ ] Add to application startup
- [ ] Configure routing/middleware

## Phase 4: Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] Load testing (if applicable)

## Phase 5: Documentation
- [ ] Update API docs
- [ ] Add runbook for operations
- [ ] Document monitoring/alerting
```

- Update todos

Phase 5: Update Dependencies
Goal: Update any features that depend on this infrastructure

Actions:
- Check features.json for features that might depend on this infrastructure
- If webhooks → payment features, subscription features
- If email → notification features, onboarding features
- If storage → upload features, media features
- If queue → background job features, async processing features
- Add infrastructure dependency to relevant features
- Update todos

Phase 6: Summary
Goal: Display results and next steps

Actions:
- Display completion message:
  ```
  ✅ Infrastructure Component Added!

  Updated Files:
  - .claude/project.json (added {component-type} to infrastructure)
  
  Created Spec:
  - specs/infrastructure/{number}-{component-type}/
    - spec.md (requirements and design)
    - setup.md (installation guide)
    - tasks.md (implementation tasks)

  Component Details:
  - Type: {component-type}
  - Provider: {inferred provider}
  - Description: {user description}

  Next Steps:
  1. Review and customize the generated spec files
  2. Follow tasks.md to implement the infrastructure
  3. Run /foundation:generate-infrastructure-specs to regenerate all specs if needed
  4. Features depending on this infrastructure: {list or "None yet"}
  ```
- Mark all todos completed

## Examples

```bash
# Add webhook handling
/foundation:add-infrastructure webhooks "Stripe webhook handling for payment events with signature verification"

# Add email service
/foundation:add-infrastructure email "SendGrid transactional emails for user notifications and password resets"

# Add file storage
/foundation:add-infrastructure storage "Supabase Storage for user uploads with CDN and image transformations"

# Add message queue
/foundation:add-infrastructure queue "Celery with Redis broker for async task processing"

# Add search
/foundation:add-infrastructure search "Typesense for full-text search of course content"

# Add analytics
/foundation:add-infrastructure analytics "Mixpanel for user behavior tracking and funnel analysis"
```
