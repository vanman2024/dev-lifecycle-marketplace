# [Feature Name] - Implementation Tasks

**Feature**: [Feature Name]
**Spec**: `specs/XXX-feature-name/spec.md`
**Plan**: `specs/XXX-feature-name/plan.md`

---

## Task Legend

- `[ ]` - Not started
- `[~]` - In progress
- `[x]` - Completed
- `[P]` - Can be done in parallel with other [P] tasks
- `[depends: X.Y]` - Requires task X.Y to be completed first

---

## Phase 1: Database Setup

**Goal**: Create database schema, tables, RLS policies, and seed data

- [ ] 1.1 Create database migration file [P]
  - File: `supabase/migrations/YYYYMMDDHHMMSS_feature_name.sql`
  - Tables: [list table names]

- [ ] 1.2 Define table schemas with columns and constraints [depends: 1.1]
  - Include: id, timestamps, foreign keys, indexes

- [ ] 1.3 Add Row Level Security (RLS) policies [P]
  - SELECT, INSERT, UPDATE, DELETE policies
  - User isolation and admin access

- [ ] 1.4 Create seed data for development [P]
  - File: `supabase/seed/feature_name.sql`
  - Test users, sample data

- [ ] 1.5 Test migration locally [depends: 1.2, 1.3]
  - Run: `supabase migration up`
  - Verify: Tables created, RLS working

- [ ] 1.6 Generate TypeScript types [depends: 1.5]
  - Run: `supabase gen types typescript`
  - File: `types/database.ts`

---

## Phase 2: Backend API

**Goal**: Create FastAPI endpoints with business logic

- [ ] 2.1 Create Pydantic models [P]
  - File: `backend/models/feature_name.py`
  - Request/response schemas

- [ ] 2.2 Create database service layer [P]
  - File: `backend/services/feature_name.py`
  - CRUD operations with Supabase client

- [ ] 2.3 Implement API endpoints [depends: 2.1, 2.2]
  - File: `backend/routers/feature_name.py`
  - POST, GET, PUT, DELETE routes

- [ ] 2.4 Add authentication middleware [P]
  - Verify JWT tokens
  - Extract user context

- [ ] 2.5 Add error handling [depends: 2.3]
  - Try/catch blocks
  - Custom exception handlers
  - Meaningful error messages

- [ ] 2.6 Add request/response validation [P]
  - Pydantic validation
  - Type checking

- [ ] 2.7 Write API tests [depends: 2.3, 2.5]
  - File: `backend/tests/test_feature_name.py`
  - Test all endpoints
  - Test error cases

---

## Phase 3: Frontend UI

**Goal**: Build Next.js pages and components

- [ ] 3.1 Create Next.js page(s) [P]
  - File: `app/feature-name/page.tsx`
  - Server/Client component decision

- [ ] 3.2 Build UI components [P]
  - Files: `components/feature-name/*.tsx`
  - Using shadcn/ui components

- [ ] 3.3 Create API client functions [depends: 2.3]
  - File: `lib/api/feature-name.ts`
  - Typed fetch wrappers

- [ ] 3.4 Connect components to API [depends: 3.2, 3.3]
  - React Server Components for data fetching
  - Client components for interactions

- [ ] 3.5 Add form validation [depends: 3.4]
  - Zod schemas
  - React Hook Form
  - Inline error messages

- [ ] 3.6 Add loading states [P]
  - Skeleton loaders
  - Suspense boundaries
  - Loading spinners

- [ ] 3.7 Add error boundaries [P]
  - Error boundary components
  - Retry logic
  - User-friendly error messages

- [ ] 3.8 Implement optimistic updates [depends: 3.4]
  - Instant UI feedback
  - Rollback on error

---

## Phase 4: Integration

**Goal**: Wire up with other features and external services

- [ ] 4.1 Integrate with [001-feature-name] [depends: 3.4]
  - Import shared types/functions
  - API calls to related endpoints

- [ ] 4.2 Integrate with [External Service] [P]
  - Setup SDK/client
  - Add environment variables
  - Error handling for service failures

- [ ] 4.3 Add webhook handlers (if needed) [depends: 4.2]
  - File: `app/api/webhooks/feature-name/route.ts`
  - Signature verification
  - Event processing

- [ ] 4.4 Test end-to-end flow [depends: 4.1, 4.2]
  - Primary user scenario
  - Edge cases
  - Error scenarios

---

## Phase 5: Polish & Production Readiness

**Goal**: Accessibility, performance, monitoring, documentation

- [ ] 5.1 Accessibility audit [depends: 3.4]
  - Keyboard navigation
  - Screen reader support
  - ARIA labels
  - Color contrast

- [ ] 5.2 Performance optimization [depends: 4.4]
  - Code splitting
  - Image optimization
  - Database query optimization
  - Caching strategy

- [ ] 5.3 Add monitoring and logging [P]
  - Error tracking (Sentry/similar)
  - Analytics events
  - Performance metrics

- [ ] 5.4 Security review [depends: 4.4]
  - Check RLS policies
  - Verify auth flows
  - Test authorization
  - Input validation review

- [ ] 5.5 Update documentation [P]
  - API documentation
  - Component storybook (if applicable)
  - README updates

- [ ] 5.6 Create E2E tests [depends: 4.4]
  - File: `tests/e2e/feature-name.spec.ts`
  - Playwright tests for primary flows

- [ ] 5.7 Final QA testing [depends: 5.1, 5.2, 5.4, 5.6]
  - Test on all browsers
  - Test on mobile
  - Test all user roles
  - Verify error handling

---

## Implementation Notes

### Parallel Work Opportunities
Tasks marked [P] can be worked on simultaneously:
- Phase 1: 1.1, 1.3, 1.4 can all start together
- Phase 2: 2.1, 2.2, 2.4, 2.6 can be built in parallel
- Phase 3: 3.1, 3.2, 3.6, 3.7 don't depend on each other

### Critical Path
These tasks are on the critical path (must be done sequentially):
1. 1.1 → 1.2 → 1.5 → 1.6 (Database foundation)
2. 2.3 (API) depends on database being ready
3. 3.4 (Connect UI) depends on API being ready
4. 4.4 (E2E test) depends on everything being wired up

### Estimated Timeline
- Phase 1: [X hours/days]
- Phase 2: [X hours/days]
- Phase 3: [X hours/days]
- Phase 4: [X hours/days]
- Phase 5: [X hours/days]
- **Total**: [X hours/days]

### Dependencies on Other Features
- Blocked by: [List specs this depends on]
- Blocks: [List specs that depend on this]

---

**Tasks Guidelines:**
- Each task should be completable in < 4 hours
- Mark parallelization opportunities clearly
- Note all dependencies explicitly
- Include file paths for implementation
- Keep tasks specific and actionable
- Group related tasks into logical phases
