# Build Command Reference

**Project**: my-saas-app
**Generated**: 2025-01-07T10:30:00Z
**Source**: Architecture detected from `docs/architecture/README.md`

## Tech Stack

- nextjs-15
- fastapi
- supabase
- vercel-ai-sdk
- openrouter
- mem0

## Build Layers

### Layer 1: Infrastructure Foundation

**Execution**: Sequential
**Estimated Time**: 5-10 minutes

```bash
/foundation:detect
/planning:wizard
/planning:architecture
/supervisor:init --all
```

### Layer 2: Tech Stack Initialization

**Execution**: Parallel
**Estimated Time**: 10-15 minutes

```bash
/nextjs-frontend:init
/fastapi-backend:init
/supabase:init
/vercel-ai-sdk:new-app
/openrouter:init
/mem0:init-platform
```

### Layer 3: Feature Implementation

**Execution**: Spec-driven

Available commands organized by category - reference when building features.

### Layer 4: Quality & Deployment

**Execution**: Sequential
**Estimated Time**: 15-20 minutes

```bash
/quality:test
/deployment:deploy
/versioning:bump patch
```

## Summary

**Total Commands**: 28
**Total Plugins**: 12
**Missing Plugins**: 0
