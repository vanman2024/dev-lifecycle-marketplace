# Success Criteria Template

Use this template to define measurable outcomes and acceptance criteria for your feature specification.

## What are Success Criteria?

Success criteria are specific, measurable outcomes that define when a feature is considered complete and successful. They should be:
- **Measurable**: Quantifiable with metrics
- **Testable**: Can be verified through testing
- **Achievable**: Realistic given constraints
- **Specific**: Clear and unambiguous
- **Time-bound**: Include timeframes where relevant

---

## Success Criteria Categories

### 1. Functional Completeness
- All functional requirements implemented
- All acceptance criteria met
- All edge cases handled

### 2. Quality Metrics
- Test coverage thresholds
- Bug counts and severity
- Code quality standards

### 3. Performance Metrics
- Response times
- Throughput
- Resource usage

### 4. User Acceptance
- User satisfaction scores
- Usability testing results
- Adoption rates

### 5. Business Metrics
- Business KPIs achieved
- Cost targets met
- Timeline adherence

---

## Template Format

Use checkboxes for trackable criteria:

- [ ] **Criterion Name**: Specific measurable outcome
  - Metric: How to measure
  - Target: Specific target value
  - Verification: How to verify
  - Timeline: When to achieve by

---

## Complete Example: User Authentication Feature

### Functional Completeness

- [ ] **All authentication flows working**
  - Metric: Manual and automated testing
  - Target: 100% of specified flows functional
  - Verification: Pass all E2E tests
  - Timeline: Before staging deployment

- [ ] **Registration flow complete**
  - Metric: User can create account end-to-end
  - Target: All validation, email, and storage working
  - Verification: Manual test + automated test suite
  - Timeline: Sprint 1 complete

- [ ] **Login flow complete**
  - Metric: User can authenticate and access protected resources
  - Target: JWT tokens issued and validated correctly
  - Verification: Integration tests pass
  - Timeline: Sprint 1 complete

- [ ] **Password reset functional**
  - Metric: User can reset password via email
  - Target: Token generation, email, and password update working
  - Verification: E2E test + manual verification
  - Timeline: Sprint 2 complete

- [ ] **Session management working**
  - Metric: Sessions created, validated, and expired correctly
  - Target: Token refresh and logout working properly
  - Verification: Unit tests + integration tests
  - Timeline: Sprint 2 complete

### Quality Metrics

- [ ] **Test coverage exceeds 80%**
  - Metric: Code coverage from test suite
  - Target: >80% line coverage, >75% branch coverage
  - Verification: Run coverage report (npm run coverage)
  - Timeline: Before production deployment

- [ ] **No critical or high-severity bugs**
  - Metric: Bug count by severity in tracking system
  - Target: 0 critical, 0 high-severity bugs
  - Verification: Bug tracker shows 0 critical/high bugs
  - Timeline: Production deployment gate

- [ ] **All code reviewed and approved**
  - Metric: Pull request approval status
  - Target: 100% of code reviewed by 2+ engineers
  - Verification: GitHub/GitLab PR approval records
  - Timeline: Before merge to main

- [ ] **Linting and code quality checks pass**
  - Metric: ESLint, TypeScript, and SonarQube results
  - Target: 0 errors, <5 warnings per file
  - Verification: CI/CD pipeline checks pass
  - Timeline: Every commit

- [ ] **Security audit passes**
  - Metric: Security scan results (OWASP, Snyk)
  - Target: 0 critical, 0 high vulnerabilities
  - Verification: Security scan report
  - Timeline: Before production deployment

### Performance Metrics

- [ ] **Login API response time < 200ms**
  - Metric: p95 response time from load testing
  - Target: <200ms for p95, <100ms for p50
  - Verification: Load test with 1000 concurrent users
  - Timeline: Before production deployment

- [ ] **Registration API response time < 300ms**
  - Metric: p95 response time from load testing
  - Target: <300ms for p95, <150ms for p50
  - Verification: Load test report
  - Timeline: Before production deployment

- [ ] **Token refresh < 100ms**
  - Metric: p95 response time
  - Target: <100ms for p95, <50ms for p50
  - Verification: Load test + production monitoring
  - Timeline: Before production deployment

- [ ] **Database queries optimized**
  - Metric: Query execution time from profiling
  - Target: User lookup <10ms, session validation <5ms
  - Verification: Database profiling tools
  - Timeline: Sprint 2 complete

- [ ] **System handles 1000 concurrent users**
  - Metric: Load test success rate
  - Target: >99.9% success rate at 1000 concurrent users
  - Verification: Load testing report (JMeter/Artillery)
  - Timeline: Before production deployment

### Security Metrics

- [ ] **Password storage meets OWASP standards**
  - Metric: Code review of password hashing implementation
  - Target: bcrypt with cost factor 12+
  - Verification: Security audit + code review
  - Timeline: Sprint 1 complete

- [ ] **Rate limiting prevents brute force**
  - Metric: Brute force simulation test results
  - Target: Block after 5 failed attempts in 15 minutes
  - Verification: Penetration test
  - Timeline: Before production deployment

- [ ] **Tokens secured properly**
  - Metric: Token security audit
  - Target: httpOnly, secure cookies, signed JWTs
  - Verification: Security code review
  - Timeline: Sprint 1 complete

- [ ] **CSRF protection enabled**
  - Metric: CSRF test results
  - Target: All state-changing operations protected
  - Verification: Security testing
  - Timeline: Before production deployment

- [ ] **HTTPS enforced**
  - Metric: HTTP requests redirected to HTTPS
  - Target: 100% of auth endpoints HTTPS-only
  - Verification: Network monitoring
  - Timeline: Production deployment

### User Experience Metrics

- [ ] **Form validation clear and helpful**
  - Metric: Usability testing feedback
  - Target: >90% of testers understand error messages
  - Verification: User testing session (n=10)
  - Timeline: Sprint 2 complete

- [ ] **Accessibility score > 95**
  - Metric: Lighthouse accessibility score
  - Target: >95 in Lighthouse audit
  - Verification: Run Lighthouse audit
  - Timeline: Before production deployment

- [ ] **WCAG 2.1 Level AA compliance**
  - Metric: Accessibility audit results
  - Target: 0 WCAG AA violations
  - Verification: axe DevTools or WAVE audit
  - Timeline: Before production deployment

- [ ] **Mobile responsive and functional**
  - Metric: Mobile device testing
  - Target: Works on iOS Safari, Chrome Android
  - Verification: Manual testing on real devices
  - Timeline: Before production deployment

- [ ] **Password reset success rate > 95%**
  - Metric: Analytics tracking reset flow completion
  - Target: >95% of users who request reset complete it
  - Verification: Analytics dashboard
  - Timeline: 1 week post-launch

### Business Metrics

- [ ] **User registration conversion > 70%**
  - Metric: Analytics tracking registration funnel
  - Target: >70% of users who start registration complete it
  - Verification: Google Analytics funnel report
  - Timeline: 2 weeks post-launch

- [ ] **Login success rate > 98%**
  - Metric: Backend analytics (successful logins / attempts)
  - Target: >98% success rate
  - Verification: Application monitoring dashboard
  - Timeline: 1 week post-launch

- [ ] **Zero unplanned downtime in first week**
  - Metric: Uptime monitoring
  - Target: 100% uptime (excluding planned maintenance)
  - Verification: Uptime monitoring service (DataDog, New Relic)
  - Timeline: 1 week post-launch

- [ ] **Average session duration > 15 minutes**
  - Metric: Analytics tracking session time
  - Target: >15 minutes average session
  - Verification: Analytics dashboard
  - Timeline: 2 weeks post-launch

### Documentation & Deployment

- [ ] **API documentation complete**
  - Metric: Documentation coverage
  - Target: All endpoints documented with examples
  - Verification: Documentation review checklist
  - Timeline: Before staging deployment

- [ ] **User guide published**
  - Metric: Guide completeness checklist
  - Target: Registration, login, reset guides complete
  - Verification: Documentation team review
  - Timeline: Before production launch

- [ ] **Runbook for operations complete**
  - Metric: Runbook checklist
  - Target: Covers deployment, rollback, monitoring, incidents
  - Verification: Ops team review
  - Timeline: Before production deployment

- [ ] **Staging deployment successful**
  - Metric: Deployment success and smoke tests
  - Target: Clean deployment with all smoke tests passing
  - Verification: CI/CD pipeline + manual verification
  - Timeline: 1 week before production

- [ ] **Production deployment successful**
  - Metric: Deployment success and verification
  - Target: Zero-downtime deployment, all checks pass
  - Verification: Deployment checklist + monitoring
  - Timeline: Launch date

### Post-Launch Monitoring

- [ ] **No critical incidents in first week**
  - Metric: Incident tracking system
  - Target: 0 P0/P1 incidents
  - Verification: Incident tracker + on-call reports
  - Timeline: 1 week post-launch

- [ ] **Error rate < 0.1%**
  - Metric: Application error monitoring
  - Target: <0.1% of requests result in errors
  - Verification: Error tracking (Sentry, Rollbar)
  - Timeline: 1 week post-launch

- [ ] **Response time SLA maintained**
  - Metric: APM monitoring (New Relic, DataDog)
  - Target: Maintain <200ms p95 response time
  - Verification: APM dashboard
  - Timeline: Ongoing, 1 month review

- [ ] **User satisfaction score > 4.0/5.0**
  - Metric: In-app or email survey
  - Target: >4.0 average rating from 100+ responses
  - Verification: Survey results analysis
  - Timeline: 2 weeks post-launch

---

## Success Criteria Matrix

Track progress against all criteria:

| Category | Total Criteria | Completed | Completion % | Status |
|----------|----------------|-----------|--------------|--------|
| Functional | 5 | 3 | 60% | In Progress |
| Quality | 5 | 5 | 100% | Complete |
| Performance | 5 | 4 | 80% | In Progress |
| Security | 5 | 5 | 100% | Complete |
| UX | 5 | 3 | 60% | In Progress |
| Business | 4 | 0 | 0% | Not Started |
| Documentation | 5 | 4 | 80% | In Progress |
| Post-Launch | 4 | 0 | 0% | Not Started |
| **TOTAL** | **38** | **24** | **63%** | **In Progress** |

---

## Go/No-Go Decision Criteria

Before production launch, these critical criteria MUST be met:

1. [ ] All P0 (Critical) functional requirements complete
2. [ ] Test coverage > 80%
3. [ ] 0 critical or high-severity bugs
4. [ ] Security audit passes
5. [ ] Performance targets met (load testing)
6. [ ] Staging deployment successful
7. [ ] Rollback procedure tested
8. [ ] On-call team trained
9. [ ] Monitoring and alerts configured
10. [ ] Documentation complete

**If any Go/No-Go criterion is not met, production launch must be delayed.**

---

## Tips for Writing Success Criteria

1. **Use the SMART framework**: Specific, Measurable, Achievable, Relevant, Time-bound
2. **Focus on outcomes, not activities**: "API response time <200ms" not "Optimize API"
3. **Include metrics**: Always specify how to measure
4. **Set realistic targets**: Based on benchmarks and constraints
5. **Define verification method**: How will you prove criteria is met?
6. **Include timeframes**: When should each criterion be achieved?
7. **Balance coverage**: Include functional, quality, performance, UX, business
8. **Make it binary**: Each criterion should have clear pass/fail
9. **Get stakeholder buy-in**: Ensure criteria align with business goals
10. **Review and update**: Criteria may evolve as you learn more

## Common Pitfalls to Avoid

1. **Vague criteria**: "System should be fast" - not measurable
2. **Too many criteria**: Focus on most important outcomes
3. **Unmeasurable criteria**: Must be quantifiable
4. **Activities vs outcomes**: "Write tests" vs "Test coverage >80%"
5. **No verification method**: How will you know it's met?
6. **Unrealistic targets**: Set achievable goals
7. **Missing categories**: Don't focus only on features
8. **No timeframes**: When should each be achieved?
9. **Not prioritized**: Mark critical vs nice-to-have
10. **Set and forget**: Review and update regularly
