# {feature-name} - Tasks

**Infrastructure Phase**: {N}
**Required Infrastructure**: {I001, I010, I012}
**Estimated Days**: {N}

## Prerequisites
- [ ] Verify infrastructure dependencies are complete:
  - [ ] {I001} - {name} (phase {N}) ✅
  - [ ] {I010} - {name} (phase {N}) ✅
- [ ] Verify feature dependencies are complete:
  - [ ] {F001} - {name} ✅

## Phase 1: Database
- [ ] Create migration file: `database/migrations/{timestamp}_{name}.sql`
- [ ] Define schema (tables, indexes, constraints)
- [ ] Add RLS policies for user isolation
- [ ] Test migration locally

## Phase 2: Backend
- [ ] Create service: `backend/api/services/{name}.py`
- [ ] Create routes: `backend/api/routes/{name}.py`
- [ ] Add Pydantic models for validation
- [ ] Add error handling
- [ ] Write unit tests

## Phase 3: Frontend
- [ ] Create page: `frontend/app/{route}/page.tsx`
- [ ] Create components: `frontend/components/{name}/`
- [ ] Connect to API endpoints
- [ ] Add loading states
- [ ] Add error handling

## Phase 4: Integration
- [ ] Wire with dependent features ({F001, F002})
- [ ] Test end-to-end flow
- [ ] Verify data flow through all layers

## Phase 5: Production Ready
- [ ] Performance check (<500ms response)
- [ ] Security review (auth, RLS, input validation)
- [ ] E2E tests with Playwright
- [ ] Update documentation
- [ ] Update features.json status to "completed"
