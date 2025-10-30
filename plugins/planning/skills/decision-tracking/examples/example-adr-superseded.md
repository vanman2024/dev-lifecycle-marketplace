---
number: 0004
title: Use Monolithic Architecture
date: 2025-01-20
status: superseded
superseded_by: ADR-0015
superseded_date: 2025-03-10
deciders: [CTO, Tech Lead]
consulted: [Engineering Team]
informed: [Product Team]
tags: [architecture, legacy]
domain: system-architecture
technologies: [Node.js, Express]
impact: critical
---

# 0004: Use Monolithic Architecture

## Status

**superseded** by [ADR-0015: Adopt Modular Monolith Architecture](0015-adopt-modular-monolith-architecture.md)

*Superseded on: 2025-03-10*

## Historical Note

This ADR was superseded because:
- Application grew significantly beyond initial projections
- Team size increased from 5 to 20 engineers
- Coordination overhead and merge conflicts became problematic
- Need for module boundaries and team autonomy emerged
- A modular monolith provides better structure while maintaining operational simplicity

See [ADR-0015](0015-adopt-modular-monolith-architecture.md) for the replacement decision.

---

## Context

*This section captures the original context when the decision was made in January 2025*

We are building a new SaaS application for project management. The application is in its early stages with:
- MVP scope: User management, projects, tasks, basic reporting
- Expected initial users: 100-500 in first 6 months
- Team size: 5 engineers (3 backend, 2 frontend)
- Timeline: MVP in 3 months

We need to decide on the initial architectural approach.

### Technical Forces

**Current State:**
- Brand new greenfield project
- Simple feature set initially
- No legacy system to integrate with
- Need to move fast to prove product-market fit

**Requirements:**
- Support basic CRUD operations for users, projects, tasks
- API for future mobile app
- Simple reporting and analytics
- User authentication and authorization
- Expected load: <500 concurrent users initially

**Technical Constraints:**
- Small team with limited bandwidth
- Need to ship MVP in 3 months
- Budget constraints (startup seed funding)
- Team has strong Node.js/Express expertise

### Business Forces

**Startup Context:**
- Pre-product-market fit stage
- Need to iterate quickly based on customer feedback
- Limited runway (18 months of funding)
- Must prove concept before next funding round

**Risk Factors:**
- Uncertain product direction (may pivot)
- Feature requirements likely to change
- Need to demonstrate traction quickly
- Cost consciousness critical

### Team Forces

**Team Composition:**
- 3 backend engineers (all experienced with Node.js monoliths)
- 2 frontend engineers
- 0 DevOps engineers (using managed services)
- No one has microservices experience

**Team Preferences:**
- Want to focus on features, not infrastructure
- Prefer familiar technology
- Need simple deployment and debugging
- Want to ship fast

## Decision

*Original decision made in January 2025*

We will build the application as a **traditional monolithic architecture** using Node.js and Express.

**Specifically:**
- Single codebase for all backend functionality
- All features in one repository
- Single deployment unit
- Shared database
- Simple Express.js routing
- Minimal architectural complexity

### Considered Alternatives

*At the time, we considered:*

#### Alternative 1: Microservices

**Why Not Chosen in January 2025:**
- Team of 5 too small to manage multiple services
- Would slow down development significantly
- No DevOps capacity to manage orchestration
- Over-engineering for <500 users
- Would consume budget with infrastructure costs

#### Alternative 2: Serverless Functions

**Why Not Chosen in January 2025:**
- Cold start latency concerns
- Team unfamiliar with serverless patterns
- Vendor lock-in concerns (AWS Lambda)
- Complexity in local development
- Limited control over execution environment

### Why This Decision (January 2025)

Monolithic architecture was correct for our situation because:

1. **Team Size**: With 5 engineers, managing a single codebase is optimal
2. **Speed**: Fastest path to MVP
3. **Simplicity**: Easy to understand, debug, and deploy
4. **Cost**: Minimal infrastructure cost ($200/month)
5. **Team Expertise**: Team has years of monolith experience
6. **Scale**: Sufficient for initial user load

## Consequences

*These were the consequences we expected and experienced from Jan-March 2025*

### Positive Consequences Experienced

**Fast Development:**
- Shipped MVP in exactly 3 months as planned
- No time wasted on infrastructure or service coordination
- Simple debugging (all code in one place)

**Cost Efficiency:**
- Infrastructure costs stayed at $200/month
- No need for service mesh, orchestration, or distributed tracing
- Single server handled initial load easily

**Team Productivity:**
- High velocity with familiar architecture
- No learning curve for new technologies
- Easy onboarding for new engineers

**Operational Simplicity:**
- Single deployment (deploy script: 2 minutes)
- Easy rollback if issues arise
- Simple monitoring (one server to watch)
- Straightforward database backups

### Negative Consequences That Led to Superseding

*These issues emerged March 2025 that motivated ADR-0015:*

**Scaling Challenges:**
- Team grew to 20 engineers by March 2025
- Codebase became difficult to navigate (50,000 lines)
- Merge conflicts occurring 3-4 times per week
- Difficult to work on features in parallel

**Coordination Overhead:**
- Teams blocking each other on deployments
- Need to coordinate release schedules
- Testing one feature affects all features
- Difficult to isolate feature flags

**Code Organization:**
- Circular dependencies emerged
- No clear module boundaries
- Hard to test features in isolation
- Feature areas became intertwined

**Build and Deploy Times:**
- Build time increased from 3 minutes to 12 minutes
- Test suite takes 15 minutes to run
- Deploy frequency limited to 2x per week
- Fear of deploying due to blast radius

### Why Superseding Was Necessary

By March 2025, the context had changed dramatically:
- **Team grew 4x** (5 → 20 engineers)
- **Codebase grew 5x** (10,000 → 50,000 lines)
- **Users grew 10x** (500 → 5,000 users)
- **Features grew 3x** (5 → 15 major feature areas)

The monolithic approach that was **correct** for January 2025 became **limiting** by March 2025.

## What We Learned

### The Decision Was Right for Its Time

- Monolith was **absolutely the correct choice** for a 5-person team building an MVP
- Enabled us to prove product-market fit quickly
- Kept costs low during uncertain early stage
- Allowed team to focus on features, not infrastructure

### When to Transition Away

Signals that it was time to evolve the architecture:
- Team size exceeded 15 engineers
- Merge conflicts became frequent (>2 per week)
- Build/test times exceeded 10 minutes
- Teams started blocking each other
- Clear feature boundaries emerged

### Migration Lessons

- **Gradual migration is key**: Trying to maintain velocity during transition
- **Module boundaries**: Should have enforced them earlier
- **Monitoring**: Need better per-feature metrics
- **Team structure**: Architecture should match team structure

### Would We Do It Again?

**Yes, absolutely.**

Starting with a monolith was the right decision. The mistake would have been:
- **Starting with microservices** (over-engineering)
- **Staying with pure monolith** (under-evolving)

The key insight: **Architecture should evolve with the organization.**

## Historical Value

### Why Keep This ADR?

Even though superseded, this ADR has value:

1. **Shows Decision Evolution**: Demonstrates that architectural decisions should evolve
2. **Captures Context**: Explains why monolith was right initially
3. **Learning Record**: Documents when and why we transitioned
4. **Pattern Recognition**: Helps identify when future transitions are needed
5. **New Hire Context**: Helps new engineers understand our architectural journey

### Related Decisions

- **Superseded by**: [ADR-0015: Adopt Modular Monolith Architecture](0015-adopt-modular-monolith-architecture.md)
- **Related**: [ADR-0001: Use PostgreSQL for Primary Database](0001-use-postgresql.md) - Database decision remains valid
- **Related**: [ADR-0008: Implement OAuth 2.1](0008-oauth-authentication.md) - Auth decision remains valid

## References

### Internal References
- [Original Architecture Proposal (January 2025)](https://docs.internal/original-architecture)
- [MVP Launch Retrospective](https://docs.internal/mvp-retro)
- [Architecture Evolution Discussion (March 2025)](https://docs.internal/arch-evolution)

### External References
- [Monolith First by Martin Fowler](https://martinfowler.com/bliki/MonolithFirst.html)
- [Don't Start with Microservices](https://martinfowler.com/articles/dont-start-monolith.html)

---

## Appendix: Original Success Criteria

*For historical reference, these were our success criteria in January 2025:*

### Metrics Tracked

**Development Velocity:**
- MVP delivered: ✓ On time (3 months)
- Feature velocity: ✓ 8-10 story points per sprint
- Bug rate: ✓ <5% of stories

**Performance:**
- Response time: ✓ <200ms average
- Uptime: ✓ 99.5% (target was 99%)
- Error rate: ✓ <0.5%

**Cost:**
- Infrastructure: ✓ $200/month (within budget)
- No cost overruns

**Team Satisfaction:**
- Developer happiness: ✓ 8/10
- Ease of deployment: ✓ 9/10
- Code maintainability: ✓ 7/10 (started declining in month 3)

### Success Indicators Met

**3 Months:**
- ✓ MVP launched successfully
- ✓ Team velocity maintained
- ✓ First 100 paying customers acquired
- ✓ No major outages

**Conclusion:** The monolithic architecture successfully supported the MVP phase and early growth. It was superseded not because it failed, but because we succeeded and grew beyond its optimal use case.

---

*Original Date: 2025-01-20*
*Original Deciders: CTO, Tech Lead*
*Original Status: accepted*
*Superseded: 2025-03-10*
*Final Status: superseded*

---

## Note to Readers

This ADR is kept for historical and educational purposes. When reading it:

1. **Understand the context**: In January 2025, with 5 engineers and 500 users, monolith was correct
2. **Recognize the change**: By March 2025, with 20 engineers and 5,000 users, evolution was needed
3. **Learn the pattern**: Architecture should evolve with team size and complexity
4. **Avoid both mistakes**: Don't over-engineer early OR resist evolution later

For current architectural guidance, see [ADR-0015: Adopt Modular Monolith Architecture](0015-adopt-modular-monolith-architecture.md).
