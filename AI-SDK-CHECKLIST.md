# AI SDK Project Checklist: Spec → Production

**Tech Stack**: AI Tech Stack 1 (Next.js + FastAPI + Supabase + Vercel AI SDK + OpenRouter)

Run these commands in order. Check them off as you complete them.

---

## ✅ PHASE 1: FOUNDATION (15-20 min)

### 1.1 Project Setup
```bash
□ /foundation:start my-project       # Creates directory structure
```

### 1.2 Environment & Tools
```bash
□ /foundation:env-check              # Verify Node, Python installed
□ /foundation:env-vars setup         # Configure API keys
```

### 1.3 Framework Initialization
```bash
□ /nextjs-frontend:init              # Next.js + TypeScript + Tailwind
□ /fastapi-backend:init              # FastAPI + Uvicorn
□ /supabase:init                     # Database setup
□ /vercel-ai-sdk:new-app             # AI SDK
□ /openrouter:init                   # Multi-model access
□ /mem0:init-platform                # Memory layer
```

### 1.4 Git Repository (Optional)
```bash
□ /foundation:github-init my-project # GitHub repo + workflows
```

---

## ✅ PHASE 2: PLANNING (20-30 min)

### 2.1 Requirements Gathering
```bash
□ /planning:wizard                   # Interactive requirements
```
OR if you already have architecture docs:
```bash
□ /planning:add-feature "feature 1"  # Create feature specs
□ /planning:add-feature "feature 2"
```

### 2.2 Architecture & Design
```bash
□ /planning:architecture design      # System architecture
□ /planning:decide "decision 1"      # Document key decisions
□ /planning:roadmap                  # Project timeline
```

### 2.3 Database Schema
```bash
□ /supabase:create-schema            # Design tables
```

---

## ✅ PHASE 3: IMPLEMENTATION (Variable)

**For EACH feature** (F001, F002, etc.):

### 3.1 Layer Tasks
```bash
□ /iterate:tasks F001                # Creates layered-tasks.md
```

### 3.2 Build Layer 0 (Infrastructure)
```bash
□ /supabase:deploy-migration         # Apply database schema
□ /supabase:add-rls                  # Security policies
□ /supabase:add-auth                 # Authentication
□ /vercel-ai-sdk:add-provider openrouter
□ /openrouter:add-model-routing      # Model fallbacks
□ /mem0:add-conversation-memory      # Memory integration
```

### 3.3 Build Layer 1 (Core Components)
```bash
□ /nextjs-frontend:add-component ChatWindow
□ /nextjs-frontend:add-component MessageList
□ /nextjs-frontend:add-component InputBox
□ /fastapi-backend:add-endpoint "POST /api/chat"
□ /fastapi-backend:add-endpoint "GET /api/conversations"
```

### 3.4 Build Layer 2 (Features)
```bash
□ /vercel-ai-sdk:add-streaming       # Real-time responses
□ /nextjs-frontend:integrate-supabase
□ /fastapi-backend:setup-database    # SQLAlchemy + async
□ /supabase:add-realtime             # Live updates
□ /supabase:generate-types           # TypeScript types
```

### 3.5 Build Layer 3 (Integration)
```bash
□ /nextjs-frontend:add-page chat     # Wire everything together
□ /iterate:sync F001                 # Validate implementation
```

**Repeat 3.1-3.5 for each feature**

---

## ✅ PHASE 4: QUALITY (30-45 min)

### 4.1 Code Validation
```bash
□ /quality:validate-code F001        # Check against specs
```

### 4.2 Testing
```bash
□ /testing:generate-tests            # Auto-generate test suites
□ /testing:test                      # Run all tests
□ /testing:test-frontend             # Frontend-specific tests
```

### 4.3 Security
```bash
□ /security:security                 # Security scans
□ /quality:performance               # Performance analysis
```

---

## ✅ PHASE 5: DEPLOYMENT (20-30 min)

### 5.1 Prepare for Deploy
```bash
□ /deployment:prepare                # Pre-flight checks
□ /deployment:setup-cicd             # GitHub Actions
```

### 5.2 Deploy to Production
```bash
□ /deployment:deploy                 # Deploy everything
                                     # Frontend → Vercel
                                     # Backend → Railway
                                     # Database → Supabase
```

### 5.3 Post-Deploy
```bash
□ /deployment:validate <url>         # Health checks
□ /deployment:setup-monitoring sentry # Error tracking
```

---

## ✅ PHASE 6: VERSIONING (Optional, 15-20 min)

```bash
□ /versioning:setup typescript       # Setup versioning
□ /versioning:bump minor             # Create release
□ /versioning:generate-release-notes
□ /versioning:record-deployment production <url>
```

---

## 🎯 YOU ARE HERE

**Current Phase**: _________

**Last Completed Command**: _________

**Next Command to Run**: _________

---

## Quick Commands

```bash
# Show this checklist
cat AI-SDK-CHECKLIST.md

# Check project structure
/foundation:validate-structure

# See what's implemented
/iterate:sync F001

# Get help
/help
```

---

**Notes:**
- Check off items as you complete them
- If stuck, look at the command's phase number
- Commands can be run in any terminal
- Multiple commands in same layer can run in parallel
