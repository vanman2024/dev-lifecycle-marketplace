# Correct Workflow Order: Foundation vs Planning

## The Confusion

There are **TWO DIFFERENT starting points** depending on whether you have existing code or not:

| Starting Point | Commands to Use | Creates |
|----------------|-----------------|---------|
| **Greenfield** (No code exists) | /planning:wizard | Architecture docs, features.json |
| **Brownfield** (Code exists) | /foundation:detect | project.json (from existing code) |

## Scenario 1: Greenfield Project (No Code Yet)

**Starting point**: User has an idea but no code

```bash
# Step 1: PLANNING WIZARD - Complete project planning
/planning:wizard
# Creates:
# - docs/architecture/*.md (8 architecture docs: frontend, backend, data, ai, infrastructure, security, integrations, README)
# - docs/adr/*.md (architectural decisions)
# - docs/ROADMAP.md (project roadmap)
# - .claude/project.json (extracted from architecture docs) ✅
# - features.json (from feature breakdown) ✅
# - specs/features/*/ (feature spec directories)

# Step 2: PLANNING - Generate remaining feature specs
/planning:init-project
# READS:
# - features.json (created by wizard)
# - .claude/project.json (created by wizard)
# Creates:
# - specs/features/F001-*/ (any missing spec directories)
# - Complete spec.md, setup.md, tasks.md for each feature

# Step 3: FOUNDATION - Generate infrastructure specs
/foundation:generate-infrastructure-specs
# READS:
# - .claude/project.json infrastructure section (created by wizard)
# Creates:
# - specs/infrastructure/001-authentication/
# - specs/infrastructure/002-database/
# - specs/infrastructure/003-caching/
# - etc.

# Step 4: START BUILDING - Follow the specs
# Build features from specs/features/
# Build infrastructure from specs/infrastructure/

# Step 5: (OPTIONAL) Re-detect after building
/foundation:detect
# Updates:
# - .claude/project.json (with actual built code details)
```

### Why This Order?

1. **Wizard creates everything**: project.json AND features.json come from architecture analysis
2. **init-project reads, doesn't create**: It uses the files wizard created
3. **Infrastructure from architecture**: project.json infrastructure section comes from docs/architecture/infrastructure.md
4. **No code detection needed**: Everything planned upfront from requirements and architecture

## Scenario 2: Brownfield Project (Code Already Exists)

**Starting point**: User has existing codebase

```bash
# Step 1: FOUNDATION FIRST - Detect what exists
/foundation:detect
# Analyzes existing code:
# - package.json → Next.js, React, TypeScript
# - requirements.txt → FastAPI, Python
# - .env → Supabase, Clerk, Redis
# Creates:
# - .claude/project.json (with detected tech stack AND infrastructure)

# Step 2: FOUNDATION - Generate infrastructure specs
/foundation:generate-infrastructure-specs
# Creates:
# - specs/infrastructure/001-authentication/ (Clerk detected)
# - specs/infrastructure/002-database/ (Supabase detected)
# - specs/infrastructure/003-caching/ (Redis detected)

# Step 3: PLANNING - Create features.json from requirements
/planning:wizard  # OR /planning:add-feature
# Creates:
# - features.json (if missing)

# Step 4: PLANNING - Generate feature specs
/planning:init-project
# Creates:
# - specs/features/F001-*/
# - specs/features/F002-*/

# Step 5: PLANNING - Sync specs with actual code
/iterate:sync
# Checks if code matches specs
```

### Why This Order?

1. **Code first**: You have something to analyze
2. **Detect infrastructure**: foundation:detect finds auth, caching, monitoring
3. **Document infrastructure**: Generate specs for what exists
4. **Plan features**: Document what the app DOES (user-facing)

## What Each Command Actually Does

### /foundation:detect

**Purpose**: Analyze EXISTING code to detect tech stack

**Reads**:
- package.json (dependencies)
- requirements.txt (Python packages)
- .env files (services used)
- config files (next.config.js, etc.)
- .github/workflows/ (CI/CD)

**Creates**:
- .claude/project.json

**Example project.json**:
```json
{
  "name": "my-app",
  "framework": "Next.js 15",
  "languages": ["TypeScript", "Python"],
  "infrastructure": {
    "authentication": {
      "provider": "Clerk",  // ← DETECTED from package.json
      "backend_sdk": "@clerk/clerk-sdk-node"
    },
    "caching": {
      "provider": "Redis",  // ← DETECTED from package.json
      "strategy": "query caching"
    },
    "monitoring": {
      "provider": "Sentry"  // ← DETECTED from package.json
    }
  }
}
```

### /planning:wizard

**Purpose**: Gather requirements from USER to design NEW system

**Reads**:
- User input (text description)
- Uploaded files (wireframes, docs)
- URLs (competitor sites)

**Creates**:
- docs/architecture/*.md (NEW design)
- docs/adr/*.md (NEW decisions)
- features.json (NEW features)

**Example features.json**:
```json
{
  "features": [
    {
      "id": "F001",
      "name": "AI Study Partner",  // ← FROM user requirements
      "description": "Intelligent tutoring system..."
    },
    {
      "id": "F002",
      "name": "Progress Dashboard",  // ← FROM user requirements
      "description": "Track student readiness..."
    }
  ]
}
```

## The Key Insight

**foundation:detect does NOT read wizard output!**
**planning:wizard does NOT read detect output!**

They are **independent starting points**:

```
Greenfield Path:
User Idea → wizard → features.json → build code → detect → project.json

Brownfield Path:
Existing Code → detect → project.json → wizard (optional) → features.json
```

## Common Mistakes

### ❌ WRONG: Running detect first on greenfield

```bash
# You have no code yet, just an idea...
/foundation:detect  # ← ERROR: Nothing to detect!
```

**Problem**: foundation:detect analyzes CODE - you have none!

### ❌ WRONG: Running wizard on brownfield without detect

```bash
# You have existing app with Clerk, Redis, Sentry...
/planning:wizard  # ← Creates features but ignores existing infrastructure
```

**Problem**: wizard doesn't detect infrastructure - you'll miss what's already built!

### ✅ CORRECT: Match command to situation

```bash
# Greenfield: Start with planning
/planning:wizard → features.json → build → /foundation:detect

# Brownfield: Start with detection
/foundation:detect → project.json → /planning:wizard (optional)
```

## Updated Workflow Documentation

### For New Projects (Greenfield)

```bash
# 1. Planning - Design the system
/planning:wizard
# Output: docs/architecture/, docs/adr/, features.json

# 2. Planning - Generate feature specs
/planning:init-project
# Output: specs/features/F001-*/, specs/features/F002-*/

# 3. Build features (following specs)
# ... developer work ...

# 4. Foundation - Detect built infrastructure
/foundation:detect
# Output: .claude/project.json (with infrastructure section)

# 5. Foundation - Generate infrastructure specs
/foundation:generate-infrastructure-specs
# Output: specs/infrastructure/001-*/
```

### For Existing Projects (Brownfield)

```bash
# 1. Foundation - Detect current state
/foundation:detect
# Output: .claude/project.json (with infrastructure section)

# 2. Foundation - Document infrastructure
/foundation:generate-infrastructure-specs
# Output: specs/infrastructure/001-authentication/, 002-database/

# 3. Planning - Document features
/planning:wizard  # OR /planning:add-feature for each feature
# Output: features.json

# 4. Planning - Generate feature specs
/planning:init-project
# Output: specs/features/F001-*/

# 5. Iterate - Sync code with specs
/iterate:sync
```

## Summary Table

| Command | Purpose | Reads | Creates | When to Use |
|---------|---------|-------|---------|-------------|
| **/foundation:detect** | Analyze existing code | package.json, code, .env | project.json | **After** code exists (brownfield) |
| **/planning:wizard** | Complete project planning | User input, files, URLs | project.json, features.json, architecture docs, specs/ | **Before** code exists (greenfield) |
| **/foundation:generate-infrastructure-specs** | Document infrastructure | project.json infrastructure section | specs/infrastructure/ | **After** wizard OR detect |
| **/planning:init-project** | Generate feature specs | features.json, project.json | specs/features/ | **After** wizard creates features.json |

**CRITICAL FACTS**:
- **Greenfield**: wizard creates BOTH project.json AND features.json from architecture
- **Brownfield**: detect creates project.json from existing code
- **init-project READS features.json** (doesn't create it)
- **Wizard is the complete greenfield initialization command**

**REMEMBER**:
- **Greenfield**: wizard (creates project.json + features.json) → init-project (reads them) → generate-infrastructure-specs
- **Brownfield**: detect (creates project.json) → generate-infrastructure-specs → wizard (optional, creates features.json)
