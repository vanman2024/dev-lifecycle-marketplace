# Infrastructure vs Features: Clear Separation Guide

**CRITICAL**: Infrastructure and Features must NEVER be mixed in the same specs directory or planning documents.

## What is Infrastructure?

**Infrastructure** = System-level components that make the application RUN but are NOT user-facing features.

### Infrastructure Components (project.json → specs/infrastructure/)

| Component | Examples | Where Detected |
|-----------|----------|----------------|
| **Authentication** | Clerk, Supabase Auth, Auth0, NextAuth | package.json, .env |
| **Database** | PostgreSQL, Supabase, MongoDB, MySQL | package.json, migrations/ |
| **Caching** | Redis, Memcached, in-memory cache | package.json, code |
| **Monitoring** | Sentry, DataDog, New Relic, Application Insights | package.json, .env |
| **Error Handling** | Sentry, custom error handlers, logging (winston, pino) | package.json, code |
| **Rate Limiting** | express-rate-limit, rate-limiter-flexible, Redis | package.json, code |
| **Backup** | Automated backups, disaster recovery plans | Supabase, scripts/ |
| **CI/CD** | GitHub Actions, GitLab CI, CircleCI | .github/workflows/ |
| **Email** | SendGrid, Mailgun, AWS SES | package.json, .env |
| **File Storage** | S3, Supabase Storage, Cloudinary | package.json, .env |
| **Queue/Workers** | Celery, Bull, RabbitMQ, AWS SQS | package.json, code |
| **Search** | Elasticsearch, Algolia, Typesense | package.json, .env |
| **Analytics** | Google Analytics, Mixpanel, Amplitude | package.json, code |
| **Payments** | Stripe (infrastructure setup), payment processing | package.json, .env |

### Infrastructure Spec Structure

```
specs/infrastructure/
├── 001-authentication/
│   ├── spec.md          # Clerk integration requirements
│   ├── setup.md         # OAuth setup, environment variables, API keys
│   └── tasks.md         # 5 phases: Setup → Config → Implementation → Monitoring → Docs
├── 002-database/
│   ├── spec.md          # Supabase PostgreSQL requirements
│   ├── setup.md         # Database provisioning, connection pooling
│   └── tasks.md
├── 003-caching/
│   ├── spec.md          # Redis cache requirements
│   ├── setup.md         # Redis setup, cache strategies
│   └── tasks.md
└── ...
```

## What is a Feature?

**Feature** = User-facing capabilities that provide VALUE to end users.

### Feature Examples (features.json → specs/features/)

| Feature ID | Name | Why It's a Feature |
|------------|------|-------------------|
| **F001** | Google File Search RAG System | Users search manuals (user-facing capability) |
| **F002** | Claude Agent SDK Study Partner | Users interact with AI tutor (core product value) |
| **F004** | Hybrid Question Generation | Users get personalized questions (user-facing) |
| **F007** | Progress Tracking & Readiness | Users see their progress (user-facing dashboard) |
| **F008** | Adaptive Quiz Assembly | Users take adaptive quizzes (user-facing feature) |
| **F009** | Streaming Chat Interface | Users chat with AI (user-facing UI) |
| **F018** | Full Practice Exam | Users take practice exams (user-facing capability) |

### Feature Spec Structure

```
specs/features/
├── F001-google-file-search-rag/
│   ├── spec.md          # Feature requirements, user stories
│   └── tasks.md         # Implementation tasks (includes setup in Phase 1)
├── F002-claude-agent-sdk-study-partner/
│   ├── spec.md          # AI tutor feature requirements
│   └── tasks.md
└── ...
```

## The Problem: Mixing Infrastructure and Features

### ❌ WRONG (RedAI's current features.json)

```json
{
  "features": [
    {
      "id": "F016",
      "name": "User Authentication (Clerk)",  // ← INFRASTRUCTURE
      "description": "Migrate from Supabase Auth to Clerk..."
    },
    {
      "id": "F017",
      "name": "Redis Caching Layer",  // ← INFRASTRUCTURE
      "description": "Redis cache for File Search results..."
    },
    {
      "id": "F025",
      "name": "Sentry Error Tracking",  // ← INFRASTRUCTURE
      "description": "Production error monitoring..."
    }
  ]
}
```

**Problems:**
1. Infrastructure mixed with features
2. `/planning:init-project` creates specs for infrastructure components
3. Duplication between project.json and features.json
4. Unclear what's system-level vs user-facing

### ✅ CORRECT Separation

**project.json (infrastructure section):**
```json
{
  "infrastructure": {
    "authentication": {
      "provider": "Clerk",
      "backend_sdk": "@clerk/clerk-sdk-node",
      "frontend_sdk": "@clerk/nextjs",
      "features": ["JWT validation", "Session management"]
    },
    "caching": {
      "provider": "Redis",
      "strategy": "query caching",
      "use_cases": ["File Search results", "user progress"]
    },
    "monitoring": {
      "provider": "Sentry",
      "features": ["error tracking", "performance monitoring"]
    }
  }
}
```

**features.json (user-facing features only):**
```json
{
  "features": [
    {
      "id": "F001",
      "name": "Google File Search RAG System",
      "description": "Managed RAG system for searching technical manuals"
    },
    {
      "id": "F002",
      "name": "Claude Agent SDK Study Partner",
      "description": "Intelligent study partner with Socratic teaching"
    }
  ]
}
```

## Decision Tree: Infrastructure or Feature?

Ask yourself:

1. **Is this visible to users?**
   - No → Infrastructure
   - Yes → Might be a feature

2. **Does this provide direct user value?**
   - No → Infrastructure
   - Yes → Feature

3. **Would users pay specifically for this?**
   - No → Infrastructure
   - Yes → Feature

4. **Is this in the marketing copy?**
   - No → Infrastructure
   - Yes → Feature

### Examples

| Component | Visible? | User Value? | Pay For? | Marketing? | Classification |
|-----------|----------|-------------|----------|------------|----------------|
| Clerk Auth | No | Indirectly | No | No | **Infrastructure** |
| Redis Cache | No | Indirectly | No | No | **Infrastructure** |
| Sentry | No | Indirectly | No | No | **Infrastructure** |
| AI Study Partner | Yes | Directly | YES | YES | **Feature** |
| Progress Dashboard | Yes | Directly | YES | YES | **Feature** |
| Practice Exams | Yes | Directly | YES | YES | **Feature** |
| Voice AI (ElevenLabs) | Yes | Directly | YES | YES | **Feature** |

## Workflow Separation

**IMPORTANT**: Workflow depends on whether you have existing code or not!

### Greenfield Project (No Code Yet)

```bash
# 1. PLANNING FIRST - Design features before building
/planning:wizard

# 2. Generate feature specs
/planning:init-project

# 3. BUILD features (following specs)
# ... developer work ...

# 4. FOUNDATION - Now detect infrastructure from built code
/foundation:detect

# 5. Generate infrastructure specs
/foundation:generate-infrastructure-specs

# Result:
specs/features/          # Created from wizard/planning
specs/infrastructure/    # Created from detected code
```

### Brownfield Project (Code Already Exists)

```bash
# 1. FOUNDATION FIRST - Detect what exists
/foundation:detect

# 2. Generate infrastructure specs from detected components
/foundation:generate-infrastructure-specs

# 3. PLANNING - Document user-facing features
/planning:wizard  # OR /planning:add-feature

# 4. Generate feature specs
/planning:init-project

# Result:
specs/infrastructure/    # Created from detected code
specs/features/          # Created from wizard/planning
```

**See docs/WORKFLOW-ORDER.md for detailed explanation of greenfield vs brownfield workflows.**

## Migration Guide: Fix Existing Projects

If you have infrastructure mixed in features.json:

### Step 1: Identify Infrastructure in features.json

Look for features that match infrastructure patterns:
- Authentication, caching, monitoring, error tracking
- Rate limiting, backup, CI/CD
- Email, file storage, queue/workers

### Step 2: Move to project.json

Add infrastructure section to project.json:
```bash
# Run detection to populate infrastructure
/foundation:detect
```

### Step 3: Remove from features.json

Delete infrastructure "features" from features.json:
- F016 (Auth) → Delete
- F017 (Caching) → Delete
- F025 (Sentry) → Delete
- F026 (Backup) → Delete
- F027 (Rate Limiting) → Delete

### Step 4: Generate Separate Specs

```bash
# Generate infrastructure specs
/foundation:generate-infrastructure-specs

# Regenerate feature specs (only real features remain)
/planning:init-project
```

## Summary

| Aspect | Infrastructure | Features |
|--------|---------------|----------|
| **Purpose** | Make app RUN | Provide user VALUE |
| **Visibility** | Backend/system | User-facing |
| **Source** | project.json | features.json |
| **Command** | /foundation:generate-infrastructure-specs | /planning:init-project |
| **Directory** | specs/infrastructure/ | specs/features/ |
| **Examples** | Auth, caching, monitoring | AI tutor, quizzes, dashboards |
| **Marketing** | Not mentioned | Heavily featured |
| **User Pays For** | No | Yes |

**REMEMBER**: Infrastructure enables features, but is NOT a feature itself.
