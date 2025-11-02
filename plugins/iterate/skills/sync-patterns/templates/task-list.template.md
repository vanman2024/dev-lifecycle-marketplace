# {{FEATURE_NAME}} Task List

**Status:** {{STATUS}}
**Target Date:** {{TARGET_DATE}}
**Owner:** {{OWNER}}

## Phase 1: Planning and Design

- [ ] Define requirements and acceptance criteria
- [ ] Create technical design document
- [ ] Review design with team
- [ ] Get stakeholder approval
- [ ] Update project timeline

## Phase 2: Implementation

### Backend

- [ ] Create database schema/migrations
- [ ] Implement core business logic
- [ ] Add API endpoints
- [ ] Write unit tests
- [ ] Write integration tests

### Frontend

- [ ] Design UI mockups
- [ ] Implement components
- [ ] Connect to API
- [ ] Add form validation
- [ ] Write component tests

### Infrastructure

- [ ] Configure environment variables
- [ ] Set up CI/CD pipeline
- [ ] Add monitoring and logging
- [ ] Configure security settings

## Phase 3: Testing

- [ ] Run unit tests (target: >80% coverage)
- [ ] Run integration tests
- [ ] Perform manual QA testing
- [ ] Security audit
- [ ] Performance testing
- [ ] Cross-browser testing (if applicable)

## Phase 4: Documentation

- [ ] Update README
- [ ] Write API documentation
- [ ] Create user guide
- [ ] Document configuration options
- [ ] Add inline code comments

## Phase 5: Deployment

- [ ] Deploy to staging environment
- [ ] Smoke tests in staging
- [ ] Get approval for production
- [ ] Deploy to production
- [ ] Verify production deployment
- [ ] Monitor for issues

## Phase 6: Post-Deployment

- [ ] Mark spec as complete
- [ ] Close related tickets
- [ ] Schedule retrospective
- [ ] Update changelog
- [ ] Communicate to stakeholders

---

## Progress Summary

**Completed:** {{COMPLETED_COUNT}}/{{TOTAL_COUNT}} tasks ({{COMPLETION_PERCENTAGE}}%)
**In Progress:** {{IN_PROGRESS_COUNT}} tasks
**Blocked:** {{BLOCKED_COUNT}} tasks

## Blocking Issues

{{#if BLOCKING_ISSUES}}
{{#each BLOCKING_ISSUES}}
- **{{title}}** ({{issue_id}})
  - Blocked by: {{blocked_by}}
  - Impact: {{impact}}
  - Resolution plan: {{resolution}}
{{/each}}
{{else}}
No blocking issues.
{{/if}}

---

*Generated: {{GENERATED_DATE}}*
