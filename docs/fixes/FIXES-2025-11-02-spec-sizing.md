# Dev Lifecycle Marketplace Fixes - Spec Sizing and Architecture Integration

**Date:** 2025-11-02
**Issue:** Specs were too large (647 lines, 45 tasks) and didn't use architecture docs
**Solution:** Reference architecture docs, create focused features with no artificial count limits

---

## Problem Statement

### Before Fixes:
1. `/planning:init-project` created 4 massive features:
   - 647 lines per spec.md
   - 45 tasks per feature
   - Duplicate architecture content everywhere
   - No architecture doc reading

2. Feature count artificially limited to "max 10 features"
   - What if project needs 200 features?
   - Artificial limit forced oversized features

3. Workflow order wrong:
   - Specs created FIRST
   - Architecture created SECOND (backwards!)

---

## Fixes Applied

### 1. Fixed `/planning/commands/init-project.md` ✅

**Added Phase 1: Load Existing Documentation**
```markdown
Phase 1: Load Existing Documentation
Goal: Read all architecture docs created by /planning:architecture, /planning:decide, /planning:roadmap

Actions:
- Check if architecture docs exist
- If docs/architecture/ exists:
  - Read all architecture docs (frontend.md, backend.md, data.md, ai.md, etc.)
  - Read all ADRs (docs/adr/*.md)
  - Read roadmap (docs/ROADMAP.md)
  - Combine into /tmp/architecture-context.txt (~150KB)
- If not exists:
  - Use $ARGUMENTS only (architecture docs recommended)
```

**Updated Feature-Analyzer Prompt**
```markdown
YOUR TASK:
Break this into AS MANY focused features as needed. NO ARTIFICIAL LIMITS.

The project might have 10 features, 50 features, or 200 features - THAT'S OK.
What matters: Each feature is small, focused, and implementable in 2-3 days.

CRITICAL: Each feature should be:
- Implementable in 2-3 days (if >3 days, SPLIT IT)
- Result in 200-300 line specs (NOT 647!)
- Have 15-25 tasks (NOT 45!)
- Single responsibility
- Reference architecture docs for details (don't duplicate)

SIZING RULE: If a feature needs >3 days or >25 tasks, it's TOO LARGE - split it.
```

---

### 2. Fixed `/planning/agents/feature-analyzer.md` ✅

**Changed Philosophy: Unlimited Features**

Before:
```markdown
- Limit to max 10 features (force grouping if more identified)
- Target: 10-20 features total
```

After:
```markdown
- **NO ARTIFICIAL LIMITS** - Project might need 10, 50, 100, or 200+ features
- **SIZING RULE**: If feature needs >3 days or >25 tasks, SPLIT IT into smaller features
- **COUNT DOESN'T MATTER** - What matters: each feature is properly sized (2-3 days)
- **NO LIMIT on feature count** - Could be 10, 50, 100, 200+ features
```

**Added Architecture Doc Reading**
```markdown
### 1. Discovery & Initial Analysis
- Read ALL input sources:
  - Architecture Documentation: @/tmp/architecture-context.txt (~150KB)
  - Project Description: User's $ARGUMENTS
- If architecture docs exist:
  - Read docs/architecture/*.md, docs/adr/*.md, docs/ROADMAP.md
  - Use as PRIMARY source for technical details
```

**Updated Output Standards**
```markdown
- Feature list (AS MANY AS NEEDED - no limit) with:
  - number (001, 002, ..., 050, ..., 200, etc.)
  - estimatedDays (2-3 typical, MAX 3)
  - architectureReferences (which docs to reference)
- **No limit on feature count** - break down until each is 2-3 days
```

**Updated Verification Checklist**
```markdown
- ✅ **Each feature is 2-3 days MAX** (if >3, MUST split into smaller features)
- ✅ Each feature will result in 200-300 line spec (not 647!)
- ✅ Each feature will have 15-25 tasks (not 45!)
- ✅ **Feature count is WHATEVER IS NEEDED** (no artificial 10-20 limit)
- ✅ Large projects with 100+ features are FINE if each is properly sized
```

---

### 3. Fixed `/planning/agents/spec-writer.md` ✅

**Added Architecture Context Loading**
```markdown
### 1. Load Architecture Context & Templates
- You receive FOUR inputs from orchestrator:
  - Architecture Documentation: @/tmp/architecture-context.txt (~150KB)
  - Full Project Context
  - Feature Focus (from /tmp/feature-breakdown.json)
  - Dependency Info
- If architecture docs exist:
  - Extract relevant sections for THIS feature using architectureReferences
  - Read specific docs/architecture/*.md sections
  - Use as PRIMARY source for technical details
  - REFERENCE these docs (don't duplicate content)
```

**Spec Sizing Constraints**
```markdown
### 2. Create spec.md - TARGET: 150-200 LINES
- Keep spec to 150-200 lines MAX (not 647!)
- REFERENCE architecture docs instead of duplicating
- Example: "Database schema defined in @docs/architecture/data.md#user-schema"
- 5-10 requirements (not 30)
- 1-2 scenarios only (for focused features)

### 3. Create plan.md - TARGET: 100-150 LINES
- Keep plan.md to 100-150 lines (REFERENCE architecture docs for details)
- Example: "Architecture defined in @docs/architecture/security.md#authentication"
- CREATE TABLE with key columns only (reference full schema in architecture docs)
- Brief RLS policy summary (link to architecture docs for details)

### 4. Create tasks.md - TARGET: 15-25 TASKS
- **CRITICAL**: Total 15-25 tasks (NOT 45!)
- **CRITICAL**: If >25 tasks, feature is too large - needs to be split
- Phase 1: 3-5 tasks
- Phase 2: 4-6 tasks
- Phase 3: 4-6 tasks
- Phase 4: 2-3 tasks
- Phase 5: 2-3 tasks
```

**Updated Verification**
```markdown
- spec.md is 150-200 lines MAX (✓ not 647!)
- plan.md is 100-150 lines (✓ references docs for details)
- tasks.md has 15-25 tasks (✓ not 45!)
- Architecture docs referenced (✓ not duplicated)
```

---

### 4. Verified `ai-tech-stack-1/commands/build-full-stack-phase-0.md` ✅

**Already in Correct Order:**
```bash
Line 55:  !{slashcommand /planning:architecture design $ARGUMENTS}  # FIRST
Line 67:  !{slashcommand /planning:decide "AI Tech Stack 1"}        # SECOND
Line 79:  !{slashcommand /planning:roadmap}                         # THIRD
Line 93:  !{slashcommand /planning:init-project}                    # FOURTH (reads architecture)
```

✅ No changes needed - workflow already correct!

---

## Key Principles Established

### 1. Feature Sizing (Not Feature Counting)
- ❌ **WRONG**: "Create max 10 features"
- ✅ **RIGHT**: "Create as many features as needed, each 2-3 days"

### 2. Unlimited Features
- Small project: 10-20 features
- Medium project: 50-80 features
- Large project: 100-200+ features
- **All valid if each feature is properly sized!**

### 3. Architecture First
- Create architecture docs FIRST (`/planning:architecture`)
- Document decisions (`/planning:decide`)
- Create roadmap (`/planning:roadmap`)
- THEN generate specs (`/planning:init-project`) that REFERENCE architecture

### 4. Reference, Don't Duplicate
- Specs: 150-200 lines (reference architecture for details)
- Plans: 100-150 lines (link to architecture docs)
- Tasks: 15-25 tasks (calibrated to 2-3 day features)

---

## Example: Large Project (200 Features)

**Scenario:** Enterprise SaaS platform with 200 features

**Before Fixes:**
- Forced into "max 10 features"
- Each feature = 647 lines, 45 tasks, 20+ days
- Impossible to implement
- Massive duplicate content

**After Fixes:**
- 200 focused features allowed
- Each feature = 200 lines, 20 tasks, 2-3 days
- Implementable and manageable
- Architecture docs referenced (not duplicated)

**Example Feature Breakdown:**
```
Authentication Module (20 features):
001-basic-auth (2 days, 18 tasks)
002-oauth-google (2 days, 15 tasks)
003-oauth-github (2 days, 15 tasks)
004-mfa-totp (1 day, 12 tasks)
005-mfa-sms (2 days, 18 tasks)
006-password-reset (1 day, 10 tasks)
007-email-verification (1 day, 10 tasks)
008-session-management (2 days, 20 tasks)
009-jwt-tokens (2 days, 18 tasks)
010-refresh-tokens (1 day, 12 tasks)
... (10 more auth features)

Payment Module (15 features):
021-stripe-integration (3 days, 25 tasks)
022-subscription-plans (2 days, 20 tasks)
023-billing-portal (2 days, 18 tasks)
... (12 more payment features)

User Management (12 features):
036-user-profiles (2 days, 18 tasks)
037-user-roles (2 days, 20 tasks)
... (10 more user features)

... (150+ more features across other modules)
```

---

## Migration Guide

### For Existing Projects Using Old System:

**If you have 4 massive features (647 lines each):**

1. Run `/planning:architecture design` to create architecture docs
2. Run `/planning:init-project` again
3. Feature-analyzer will now:
   - Read your architecture docs
   - Break into 20-50+ focused features (not 4)
   - Each feature: 200 lines, 20 tasks, 2-3 days

**You'll get:**
- Same functionality coverage
- 10x more features (properly sized)
- 3x smaller specs
- 2x fewer tasks per feature
- Architecture referenced (not duplicated)

---

## Success Metrics

### Before:
- ❌ 4 features @ 647 lines = 2,588 total lines
- ❌ 4 features @ 45 tasks = 180 total tasks
- ❌ 4 features @ 20+ days each = 80+ days sequential
- ❌ Architecture duplicated in every spec

### After (Example):
- ✅ 20 features @ 200 lines = 4,000 total lines (more detail, less duplication)
- ✅ 20 features @ 20 tasks = 400 total tasks (more granular)
- ✅ 20 features @ 2-3 days each = 40-60 days (50%+ parallelizable)
- ✅ Architecture referenced (written once in docs/)

**Net Result:**
- Better organized
- More implementable
- Faster execution (parallel features)
- Single source of truth (architecture docs)

---

## Files Modified

1. `/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/commands/init-project.md`
   - Added Phase 1: Load Existing Documentation
   - Updated feature-analyzer prompt (no limits)
   - Updated all phase numbers

2. `/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/agents/feature-analyzer.md`
   - Removed "max 10 features" limit
   - Changed to "as many as needed"
   - Added architecture doc reading
   - Updated verification checklist

3. `/home/gotime2022/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/agents/spec-writer.md`
   - Added architecture context loading
   - Added size constraints (150-200 lines spec, 100-150 lines plan, 15-25 tasks)
   - Added architecture reference examples
   - Updated verification

4. `/home/gotime2022/.claude/plugins/marketplaces/ai-dev-marketplace/plugins/ai-tech-stack-1/commands/build-full-stack-phase-0.md`
   - ✅ Already correct (no changes needed)

---

## Testing Recommendations

### Test Case 1: Small Project (10 features expected)
```bash
/planning:architecture design "Simple blog platform"
/planning:init-project
# Expected: 8-12 features, each 2-3 days
```

### Test Case 2: Medium Project (50 features expected)
```bash
/planning:architecture design "E-commerce platform with inventory, payments, shipping"
/planning:init-project
# Expected: 40-60 features, each 2-3 days
```

### Test Case 3: Large Project (200 features expected)
```bash
/planning:architecture design "Enterprise SaaS platform with multi-tenancy, billing, integrations, analytics, etc."
/planning:init-project
# Expected: 150-250 features, each 2-3 days
```

### Validation Criteria:
For each generated feature, verify:
- ✅ estimatedDays ≤ 3
- ✅ spec.md is 150-250 lines
- ✅ plan.md is 100-150 lines
- ✅ tasks.md has 15-25 tasks
- ✅ spec.md references architecture docs (uses @docs/architecture/...)
- ✅ plan.md references architecture docs

---

## Summary

**Core Change:** Shifted from **feature count limits** to **feature size limits**

**Before:** "Create max 10-20 features" (arbitrary limit)
**After:** "Create as many features as needed, each 2-3 days" (quality limit)

**Result:** System can now handle projects of any size by creating appropriately-sized, focused features that reference architecture docs instead of duplicating content.

---

**End of Fixes Document**
