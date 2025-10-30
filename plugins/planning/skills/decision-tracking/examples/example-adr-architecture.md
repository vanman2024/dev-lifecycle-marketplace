---
number: 0015
title: Adopt Modular Monolith Architecture
date: 2025-03-10
status: accepted
deciders: [CTO, Tech Lead, Architecture Team]
consulted: [All Engineering Teams, DevOps, Product]
informed: [Executive Team, Customer Success]
tags: [architecture, scalability, modularity]
domain: system-architecture
technologies: [Node.js, TypeScript, NX Monorepo]
impact: critical
effort: high
owner: Architecture Team
completion_date: 2025-06-30
review_cycle: quarterly
next_review: 2025-09-30
---

# 0015: Adopt Modular Monolith Architecture

## Status

**accepted**

Decision was accepted on 2025-03-15 and implementation target is 2025-06-30.

## Context

Our SaaS application has grown significantly over the past year:
- Started as a simple monolithic application
- Now has 15 distinct feature areas (auth, billing, projects, tasks, analytics, etc.)
- Team has grown from 5 to 20 engineers
- Codebase has become harder to navigate and maintain
- Deployment times have increased to 15 minutes
- Different features have different scaling needs
- Experiencing merge conflicts and coordination overhead

We need to decide on the architectural pattern that will support us for the next 2-3 years of growth.

### Technical Forces

**Current State:**
- Single Node.js application (~50,000 lines of code)
- All code in one repository
- Shared database with no module boundaries
- Circular dependencies between feature areas
- Difficult to test features in isolation
- All features deploy together (risky deployments)

**Requirements:**
- Support 10,000 concurrent users
- Enable 4-5 engineering teams to work independently
- Reduce deployment risk and enable faster releases
- Allow features to scale independently if needed
- Maintain fast development velocity
- Keep operational complexity manageable

**Technical Constraints:**
- Team has deep Node.js/TypeScript expertise
- Limited DevOps capacity (2 engineers)
- Cannot afford 6+ month rewrite
- Must maintain feature development during transition

### Business Forces

**Growth Trajectory:**
- Current: 5,000 active users
- 12-month target: 25,000 active users
- 24-month target: 100,000 active users

**Time Pressure:**
- Major feature releases planned every 6 weeks
- Cannot pause development for architecture changes
- Need to incrementally migrate over 3-4 months

**Cost Considerations:**
- Current infrastructure: $3,000/month
- Budget for architecture change: Up to $6,000/month
- Must demonstrate ROI within 12 months

### Team Forces

**Team Structure:**
- 4 feature teams (5 engineers each)
- 1 platform team (DevOps, infrastructure)
- Teams frequently block each other on deployments
- Merge conflicts occurring 3-4 times per week

**Team Expertise:**
- Strong with monolithic applications
- Limited microservices experience (1 engineer has 2 years)
- No Kubernetes experience
- 2 engineers have Docker experience
- Excellent CI/CD knowledge

**Team Preferences:**
- Want more autonomy and faster deployment
- Prefer gradual migration over big-bang rewrite
- Concerned about operational complexity

### Stakeholder Forces

**CTO Requirements:**
- Reduce deployment coordination overhead
- Enable teams to work independently
- Maintain system reliability (99.9% uptime)
- Keep infrastructure costs predictable

**Product Requirements:**
- Continue fast feature delivery
- Support A/B testing per feature
- Enable feature flags for gradual rollouts

**Engineering Requirements:**
- Clear module boundaries
- Ability to test features in isolation
- Reduced merge conflicts
- Faster CI/CD pipelines

## Decision

We will adopt a **Modular Monolith** architecture, organizing our codebase into well-defined, independently deployable modules within a single deployment unit initially, with the option to extract to services later.

**Specifically:**

1. **Module Organization:**
   - Organize code into bounded contexts (auth, billing, projects, tasks, analytics, etc.)
   - Each module has its own API, business logic, and data access layer
   - Modules communicate through well-defined interfaces (no direct database access)
   - Use NX monorepo tooling to enforce module boundaries

2. **Database Strategy:**
   - Maintain single database initially
   - Logically separate schemas by module (e.g., auth_*, billing_*, projects_*)
   - Enforce that modules only access their own schemas
   - Prepare for future database splitting if needed

3. **Deployment Model:**
   - Deploy as single application initially
   - Each module can be independently tested and versioned
   - Build system supports future split into separate services
   - Feature flags enable per-module rollouts

4. **Module Communication:**
   - Modules expose clean APIs (interfaces/contracts)
   - Use event bus for async communication between modules
   - No direct function calls across module boundaries
   - Shared code lives in common libraries

### Considered Alternatives

#### Alternative 1: Pure Monolith (Status Quo)

**Description:** Continue with current monolithic architecture, just add better code organization.

**Pros:**
- Zero migration effort
- Simple to understand and operate
- No distributed system complexity
- Fastest development for small features
- Single deployment simplifies ops

**Cons:**
- Cannot address team coordination issues
- Merge conflicts will continue
- Cannot scale features independently
- Difficult to enforce boundaries without tooling
- Single point of failure
- Slow build and test times

**Why Not Chosen:**
- Doesn't solve the core problem of team coordination
- Build/test times will only get worse
- Cannot support independent team work
- Scaling limitations will become critical within 12 months

#### Alternative 2: Microservices

**Description:** Split application into 10-15 independent services, each with its own database and deployment.

**Pros:**
- Maximum team independence
- Can scale services independently
- Technology diversity possible
- Clear service boundaries
- Failures are isolated

**Cons:**
- Massive increase in operational complexity (10-15 services to monitor)
- Requires Kubernetes or similar orchestration (team has no experience)
- Distributed transactions are complex
- Debugging spans multiple services
- Network latency between services
- Requires 6+ month migration
- 3-4x infrastructure costs initially
- Need experienced DevOps team (we have 2 engineers)

**Why Not Chosen:**
- Team lacks microservices and Kubernetes experience
- DevOps capacity cannot handle 15 services
- 6-month migration timeline unacceptable
- Infrastructure costs exceed budget
- Over-engineering for current scale
- Too much operational risk

#### Alternative 3: Service-Oriented Architecture (SOA)

**Description:** Create 4-5 larger services, each owning a major domain area.

**Pros:**
- Less operational complexity than microservices
- Some team independence
- Clearer boundaries than monolith
- More manageable service count

**Cons:**
- Still requires service orchestration
- Distributed system challenges
- Increased infrastructure costs
- Complex inter-service communication
- Requires significant upfront planning
- 3-4 month migration timeline

**Why Not Chosen:**
- Still too much operational complexity for team size
- Doesn't provide enough benefit over modular monolith
- Higher cost and risk than modular approach
- Harder to revert if issues arise

#### Alternative 4: Micro-frontends with Shared Backend

**Description:** Split frontend into micro-frontends but keep backend monolithic.

**Pros:**
- Frontend teams can work independently
- Backend remains simple
- Some deployment independence

**Cons:**
- Doesn't address backend coordination issues
- Frontend complexity increases
- Doesn't solve database coupling
- Backend still a bottleneck
- Limited scalability benefits

**Why Not Chosen:**
- Doesn't solve the primary problem (backend coordination)
- Adds complexity without addressing root cause
- Backend remains a deployment bottleneck

### Why This Decision

Modular Monolith is the optimal choice because:

1. **Incremental Migration Path:**
   - Can migrate module-by-module over 3-4 months
   - Continue feature development during migration
   - No big-bang rewrite risk
   - Can extract to services later if truly needed

2. **Team Capabilities:**
   - Plays to team's monolith expertise
   - Minimal new technology learning
   - Can be implemented with current team size
   - DevOps team can handle single deployment

3. **Operational Simplicity:**
   - Single deployment unit (initially)
   - One database to monitor and backup
   - Simpler debugging (no distributed tracing needed)
   - Lower infrastructure costs ($4,000/month vs $9,000 for microservices)

4. **Team Independence:**
   - Clear module boundaries enable parallel work
   - Reduced merge conflicts through NX tooling
   - Teams can own modules end-to-end
   - Independent testing per module

5. **Future Flexibility:**
   - Can extract hot modules to services later
   - Architecture supports gradual evolution
   - Not locked into monolith forever
   - Can respond to actual scaling needs vs. predicted

6. **Best Practices:**
   - Industry pattern for teams of our size (20 engineers)
   - Proven by companies like Shopify, GitHub (pre-split)
   - Recommended by Domain-Driven Design community

## Consequences

### Positive Consequences

**Team Productivity:**
- **Reduced Coordination:** Teams can work on modules independently, reducing synchronization meetings
- **Fewer Merge Conflicts:** Module boundaries naturally reduce code conflicts (estimated 70% reduction)
- **Faster Onboarding:** New engineers can focus on single module vs. entire codebase
- **Clear Ownership:** Each team owns specific modules, improving accountability

**Code Quality:**
- **Enforced Boundaries:** NX tooling prevents accidental cross-module dependencies
- **Better Testing:** Modules can be unit tested in isolation
- **Improved Architecture:** Forces thinking about interfaces and contracts
- **Reduced Coupling:** Prevents spaghetti code across features

**Deployment:**
- **Safer Releases:** Module changes are isolated, reducing blast radius
- **Faster CI/CD:** Can test only affected modules (30% reduction in CI time)
- **Feature Flags:** Can toggle modules independently for gradual rollouts
- **Rollback Granularity:** Can disable problematic modules without full rollback

**Scalability:**
- **Logical Separation:** Prepares for future service extraction if needed
- **Resource Optimization:** Can profile and optimize per module
- **Database Preparation:** Schema separation enables future database splitting

**Development Experience:**
- **Faster Builds:** NX caching speeds up builds (estimated 40% improvement)
- **Better IDE Performance:** Smaller module context improves autocomplete
- **Clearer Code Navigation:** Modules provide natural navigation boundaries

### Negative Consequences

**Implementation Effort:**
- **Migration Time:** 3-4 months of gradual migration work
- **Learning Curve:** Team needs to learn NX tooling and module patterns (2 weeks)
- **Initial Slowdown:** First month will be slower as patterns are established
- **Refactoring Required:** Existing circular dependencies must be broken

**Complexity:**
- **Module Boundaries:** Determining correct boundaries requires upfront design
- **Interface Management:** Module APIs need to be versioned and maintained
- **Event Bus Overhead:** Async communication adds complexity vs. function calls
- **Build Configuration:** NX requires more sophisticated build setup

**Technical Debt:**
- **Not True Services:** Still shares database, so not fully isolated
- **Deployment Coupling:** All modules deploy together (can't scale independently yet)
- **Single Point of Failure:** Database or deployment issue affects all modules
- **Testing Challenges:** Integration tests span multiple modules

**Operational:**
- **Monitoring Granularity:** Need module-level metrics and logging
- **Debugging:** Harder to trace requests across module boundaries
- **Documentation:** Need to document module APIs and contracts
- **Governance:** Need architectural reviews to maintain boundaries

### Neutral Consequences

**Process Changes:**
- Need architectural review board for cross-module changes
- Establish module interface versioning strategy
- Create shared libraries for common functionality
- Define event schema governance

**Tooling Changes:**
- Adopt NX for monorepo management
- Implement event bus (likely using existing Redis)
- Add module boundary linting rules
- Enhance CI to test by module

**Team Structure:**
- Each team owns 2-3 modules
- Platform team owns common libraries
- Need module interface change approval process

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| Module boundaries wrong | Medium | High | Start with obvious boundaries (auth, billing), refactor iteratively |
| Migration takes longer | High | Medium | Allocate 50% sprint capacity, deprioritize non-critical features |
| Team resists change | Low | High | Involve teams in module design, show quick wins, provide training |
| NX learning curve | Medium | Low | 2-day workshop, pair programming, documentation |
| Performance regression | Low | Medium | Benchmark before/after, optimize event bus, use caching |
| Database becomes bottleneck | Medium | Medium | Monitor query performance, add indexes, prepare for read replicas |

## Implementation

### Required Changes

#### Code Changes
- Restructure codebase into NX monorepo structure
- Define module boundaries and interfaces
- Refactor circular dependencies (auth → user → auth)
- Create shared libraries for common utilities
- Implement event bus for inter-module communication
- Add module-level testing infrastructure

#### Configuration Changes
- Set up NX workspace configuration
- Define module dependency rules (nx.json)
- Configure module-specific environment variables
- Set up feature flags per module
- Configure module-level logging

#### Infrastructure Changes
- No immediate infrastructure changes (same deployment target)
- Add module-level monitoring (Datadog tags by module)
- Separate database schemas logically (auth_users, billing_invoices)
- Configure Redis as event bus
- Add module-level health check endpoints

#### Documentation Changes
- Create architecture decision record (this document)
- Document each module's purpose and boundaries
- Create module API documentation
- Write migration guide for developers
- Create troubleshooting guide for module issues

### Migration Strategy

#### Phase 1: Foundation Setup (Weeks 1-2)
- **Duration**: 2 weeks
- **Activities**:
  - Set up NX workspace and convert existing project
  - Define initial module boundaries with team input
  - Create proof of concept with 2 modules (auth and billing)
  - Establish patterns and conventions
  - Train team on NX tooling
- **Success Criteria**:
  - NX workspace builds successfully
  - 2 modules extracted and working
  - Team comfortable with NX basics
  - CI/CD pipeline working with new structure

#### Phase 2: Core Modules Migration (Weeks 3-6)
- **Duration**: 4 weeks
- **Activities**:
  - Extract core modules: projects, tasks, analytics
  - Define and implement module interfaces
  - Refactor circular dependencies
  - Implement event bus for async communication
  - Create shared libraries
- **Success Criteria**:
  - 7-8 modules extracted
  - No circular dependencies
  - Event bus handling inter-module events
  - Tests passing for all modules
  - Build time reduced by 20%

#### Phase 3: Remaining Modules (Weeks 7-10)
- **Duration**: 4 weeks
- **Activities**:
  - Extract remaining feature modules
  - Implement module-level monitoring
  - Add feature flags per module
  - Optimize inter-module communication
  - Performance testing and optimization
- **Success Criteria**:
  - All modules extracted
  - Module boundaries enforced by linting
  - Module-level metrics visible in Datadog
  - Feature flags working per module
  - Performance equal or better than before

#### Phase 4: Optimization and Polish (Weeks 11-12)
- **Duration**: 2 weeks
- **Activities**:
  - Optimize build configuration
  - Improve documentation
  - Team retrospective and learning
  - Performance tuning
  - Prepare for independent module deployment (future)
- **Success Criteria**:
  - Build time reduced by 40%
  - All documentation complete
  - Team velocity back to pre-migration levels
  - Zero production incidents from migration

### Rollback Plan

**Triggers for Rollback:**
- Critical production issues lasting > 4 hours
- Team velocity drops > 30% for 2+ sprints
- Cannot complete migration within 4 months
- Performance regression > 20% that can't be fixed

**Rollback Steps:**
1. Stop new module extractions
2. Revert to standard TypeScript project structure
3. Remove NX configuration
4. Consolidate module code back to original structure
5. Restore original CI/CD pipeline

**Partial Rollback Option:**
- Keep modules that are working well
- Revert problematic modules
- Adjust migration timeline

**Data Preservation:**
- No data changes, only code structure
- Git history preserved for rollback

**Timeline:**
- Can rollback partially in 1 week
- Full rollback takes 2-3 weeks

## Validation and Success Criteria

### Metrics to Track

**Development Velocity:**
- Sprint velocity: Baseline 40 story points, maintain within 10%
- Merge conflicts: Reduce from 3-4/week to < 1/week
- Code review time: Reduce from 8 hours to < 4 hours
- Time to merge: Reduce from 2 days to < 1 day

**Build and Deployment:**
- Build time: Reduce from 12 minutes to < 8 minutes
- Test execution time: Reduce from 15 minutes to < 10 minutes
- Deployment frequency: Increase from 2x/week to 5x/week
- Deployment failure rate: Maintain < 5%

**Code Quality:**
- Circular dependencies: Reduce to zero
- Test coverage per module: > 80%
- Module boundary violations: Zero (enforced by linting)

**Team Satisfaction:**
- Developer happiness score: > 8/10
- Perceived code maintainability: > 7/10
- Deployment confidence: > 8/10

### Success Indicators

**3 Months (Short-term):**
- All modules extracted successfully
- Build time reduced by 40%
- Team velocity maintained
- Zero major incidents from migration

**6 Months (Medium-term):**
- Teams working independently on modules
- Merge conflicts reduced by 70%
- Deployment frequency doubled
- Clear patterns established and documented

**12 Months (Long-term):**
- Successfully scaled to 25,000 users with current architecture
- Module boundaries still make sense
- Team unanimously agrees architecture was right choice
- Successfully extracted 1-2 hot modules to services (if needed)

### Review Schedule

- **Weekly during migration** (March-June 2025): Check progress, address blockers
- **30-day review** (July 10, 2025): Evaluate immediate impact on velocity and quality
- **90-day review** (September 10, 2025): Assess team satisfaction and architectural health
- **6-month review** (September 30, 2025): Full retrospective and metrics analysis
- **Quarterly reviews thereafter**: Ensure boundaries remain appropriate as system evolves

## References

### Internal References
- [Module Boundary Design Doc](https://docs.internal/module-boundaries)
- [NX Migration Guide](https://docs.internal/nx-migration)
- [Event Bus Architecture](https://docs.internal/event-bus)
- [Team Structure Proposal](https://docs.internal/team-structure)

### External References
- [Modular Monoliths by Simon Brown](https://www.youtube.com/watch?v=5OjqD-ow8GE)
- [Shopify's Modular Monolith](https://shopify.engineering/shopify-monolith)
- [NX Monorepo Documentation](https://nx.dev/)
- [Domain-Driven Design by Eric Evans](https://www.domainlanguage.com/ddd/)

### Tools and Resources
- NX for monorepo management
- TypeScript for type-safe module boundaries
- Redis for event bus
- Datadog for module-level monitoring
- Feature flag service (LaunchDarkly or similar)

## Notes

### Open Questions Resolved
- ✓ Should we use database-per-module? No, single database with logical separation initially
- ✓ Do we need Kubernetes? No, single deployment sufficient for 2+ years
- ✓ How to handle shared code? Use shared libraries with clear ownership

### Future Considerations
- Extract high-traffic modules (analytics, real-time) to services when needed (likely 18-24 months)
- Consider database splitting for modules with different scaling needs
- Evaluate edge computing for globally distributed features
- Explore serverless for spiky workload modules

### Assumptions
- Team size remains 15-25 engineers for next 2 years
- Traffic growth is gradual (not viral spike)
- Database can handle 100K users (monitoring will confirm)
- Current deployment infrastructure sufficient
- Team is willing to learn new patterns and tooling

### Dependencies
- Need budget approval for NX Enterprise ($500/month)
- Requires 50% sprint capacity for 3-4 months
- Need architectural review board established
- Platform team must support NX setup

---

*Date: 2025-03-10*
*Deciders: CTO, Tech Lead, Architecture Team*
*Status: accepted*
*Implementation Target: 2025-06-30*
