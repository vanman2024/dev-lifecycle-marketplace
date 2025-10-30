# Architecture Decision Records (ADR)

This document provides an index of all Architecture Decision Records (ADRs) for this project.

## About ADRs

Architecture Decision Records (ADRs) are documents that capture important architectural decisions made during the project's lifecycle. Each ADR describes:

- **The context**: What problem or situation is being addressed
- **The decision**: What was decided and why
- **The consequences**: What impact this decision will have

ADRs follow the format proposed by Michael Nygard in his article ["Documenting Architecture Decisions"](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

## Statistics

- **Total ADRs**: 18
- **Accepted**: 12
- **Proposed**: 3
- **Deprecated**: 1
- **Superseded**: 2

*Last updated: 2025-03-15*

---

## Accepted Decisions

These decisions have been approved and are currently in effect:

- [ADR-0001: Use PostgreSQL for Primary Database](0001-use-postgresql.md) - *2025-01-15*
  - Selected PostgreSQL for relational data, ACID compliance, and future pgvector support
  - Tags: `database`, `architecture`, `backend`

- [ADR-0002: Deploy on AWS with Terraform](0002-deploy-aws-terraform.md) - *2025-01-18*
  - Chose AWS as cloud provider with Terraform for infrastructure as code
  - Tags: `infrastructure`, `deployment`, `devops`

- [ADR-0003: Use React with TypeScript for Frontend](0003-react-typescript-frontend.md) - *2025-01-20*
  - Adopted React 18 with TypeScript for type safety and developer experience
  - Tags: `frontend`, `typescript`, `react`

- [ADR-0005: Implement Continuous Deployment with GitHub Actions](0005-cd-github-actions.md) - *2025-01-25*
  - Set up automated deployment pipeline with GitHub Actions and automated testing
  - Tags: `deployment`, `ci-cd`, `automation`

- [ADR-0006: Use Prisma as ORM](0006-use-prisma-orm.md) - *2025-01-28*
  - Selected Prisma for type-safe database access and excellent DX
  - Tags: `database`, `orm`, `backend`

- [ADR-0007: Implement Feature Flags with LaunchDarkly](0007-feature-flags-launchdarkly.md) - *2025-02-01*
  - Adopted LaunchDarkly for feature management and gradual rollouts
  - Tags: `deployment`, `feature-management`

- [ADR-0008: Implement OAuth 2.1 with PKCE for Authentication](0008-oauth-authentication.md) - *2025-02-05*
  - Implemented OAuth 2.1 with Auth0 for secure authentication and SSO support
  - Tags: `security`, `authentication`, `compliance`

- [ADR-0009: Use Jest and React Testing Library for Testing](0009-jest-rtl-testing.md) - *2025-02-10*
  - Standardized on Jest and RTL for comprehensive frontend testing
  - Tags: `testing`, `frontend`, `quality`

- [ADR-0010: Implement Redis for Caching and Sessions](0010-redis-caching.md) - *2025-02-15*
  - Added Redis for application caching and session management
  - Tags: `performance`, `caching`, `backend`

- [ADR-0011: Use Datadog for Observability](0011-datadog-observability.md) - *2025-02-20*
  - Adopted Datadog for metrics, logging, and APM
  - Tags: `monitoring`, `observability`, `operations`

- [ADR-0013: Implement Rate Limiting with Redis](0013-rate-limiting-redis.md) - *2025-02-28*
  - Added API rate limiting using Redis for DDoS protection
  - Tags: `security`, `api`, `performance`

- [ADR-0015: Adopt Modular Monolith Architecture](0015-adopt-modular-monolith-architecture.md) - *2025-03-10*
  - Transitioned to modular monolith with NX for better team scalability
  - Tags: `architecture`, `scalability`, `modularity`

## Proposed Decisions

These decisions are under discussion and awaiting approval:

- [ADR-0016: Add GraphQL API Alongside REST](0016-graphql-api.md) - *2025-03-12*
  - Proposal to add GraphQL for complex client data requirements
  - Tags: `api`, `graphql`, `architecture`
  - Status: Under review by Architecture Team, target decision: 2025-03-25

- [ADR-0017: Implement Event Sourcing for Audit Trail](0017-event-sourcing-audit.md) - *2025-03-13*
  - Proposal to add event sourcing for comprehensive audit logging
  - Tags: `architecture`, `compliance`, `audit`
  - Status: Awaiting security team review

- [ADR-0018: Add Mobile App with React Native](0018-react-native-mobile.md) - *2025-03-14*
  - Proposal to build iOS and Android apps with React Native
  - Tags: `mobile`, `react-native`, `frontend`
  - Status: Awaiting budget approval from leadership

## Deprecated Decisions

These decisions are no longer recommended but may still be in use:

- [ADR-0012: Use Local File Storage for Uploads](0012-local-file-storage.md) - *2025-02-25*
  - Brief one-line summary: Initially stored uploads locally, now migrating to S3
  - Tags: `storage`, `legacy`
  - Reason: Doesn't scale, file loss risk, migrating to S3

## Superseded Decisions

These decisions have been replaced by newer ADRs:

- [ADR-0004: Use Monolithic Architecture](0004-monolithic-architecture.md) - *2025-01-20*
  - Superseded by: [ADR-0015: Adopt Modular Monolith Architecture](0015-adopt-modular-monolith-architecture.md)
  - Reason: Team growth required better module boundaries and coordination

- [ADR-0014: Use SendGrid for Transactional Email](0014-sendgrid-email.md) - *2025-03-01*
  - Superseded by: [ADR-0019: Migrate to AWS SES for Email](0019-aws-ses-email.md) *(not yet created)*
  - Reason: Cost reduction and better integration with AWS infrastructure

---

## ADRs by Category

### Database and Storage
- [ADR-0001: Use PostgreSQL for Primary Database](0001-use-postgresql.md) - `accepted`
- [ADR-0010: Implement Redis for Caching and Sessions](0010-redis-caching.md) - `accepted`
- [ADR-0012: Use Local File Storage for Uploads](0012-local-file-storage.md) - `deprecated`

### Security and Authentication
- [ADR-0008: Implement OAuth 2.1 with PKCE](0008-oauth-authentication.md) - `accepted`
- [ADR-0013: Implement Rate Limiting with Redis](0013-rate-limiting-redis.md) - `accepted`
- [ADR-0017: Implement Event Sourcing for Audit Trail](0017-event-sourcing-audit.md) - `proposed`

### Architecture Patterns
- [ADR-0004: Use Monolithic Architecture](0004-monolithic-architecture.md) - `superseded`
- [ADR-0015: Adopt Modular Monolith Architecture](0015-adopt-modular-monolith-architecture.md) - `accepted`

### Frontend
- [ADR-0003: Use React with TypeScript](0003-react-typescript-frontend.md) - `accepted`
- [ADR-0009: Use Jest and React Testing Library](0009-jest-rtl-testing.md) - `accepted`
- [ADR-0018: Add Mobile App with React Native](0018-react-native-mobile.md) - `proposed`

### Infrastructure and Deployment
- [ADR-0002: Deploy on AWS with Terraform](0002-deploy-aws-terraform.md) - `accepted`
- [ADR-0005: Implement Continuous Deployment](0005-cd-github-actions.md) - `accepted`
- [ADR-0007: Implement Feature Flags](0007-feature-flags-launchdarkly.md) - `accepted`

### APIs and Integrations
- [ADR-0006: Use Prisma as ORM](0006-use-prisma-orm.md) - `accepted`
- [ADR-0016: Add GraphQL API](0016-graphql-api.md) - `proposed`

### Monitoring and Operations
- [ADR-0011: Use Datadog for Observability](0011-datadog-observability.md) - `accepted`

---

## Decision Timeline

Chronological view of all architectural decisions:

```
2025-01 | ADR-0001: PostgreSQL Database ✓
        | ADR-0002: AWS + Terraform ✓
        | ADR-0003: React + TypeScript ✓
        | ADR-0004: Monolithic Architecture (→ superseded by ADR-0015)
        | ADR-0005: GitHub Actions CI/CD ✓
        | ADR-0006: Prisma ORM ✓
        |
2025-02 | ADR-0007: LaunchDarkly Feature Flags ✓
        | ADR-0008: OAuth 2.1 Authentication ✓
        | ADR-0009: Jest + RTL Testing ✓
        | ADR-0010: Redis Caching ✓
        | ADR-0011: Datadog Observability ✓
        | ADR-0012: Local File Storage (→ deprecated)
        | ADR-0013: Rate Limiting ✓
        | ADR-0014: SendGrid Email (→ will be superseded)
        |
2025-03 | ADR-0015: Modular Monolith Architecture ✓
        | ADR-0016: GraphQL API (proposed)
        | ADR-0017: Event Sourcing (proposed)
        | ADR-0018: React Native Mobile (proposed)
```

Legend: ✓ = accepted, (proposed) = under review, (→ superseded) = replaced, (→ deprecated) = no longer recommended

---

## Creating a New ADR

To create a new ADR, use the provided script:

```bash
./scripts/create-adr.sh "Title of Your Decision"
```

The script will:
1. Automatically assign the next sequential ADR number (next: ADR-0019)
2. Create a new file with the proper Michael Nygard ADR format
3. Populate the file with frontmatter and sections
4. Update this index automatically

### Manual Creation

If you prefer to create an ADR manually:

1. Determine the next ADR number: **0019**
2. Create file: `0019-title-in-kebab-case.md`
3. Copy template from `templates/adr-template.md`
4. Fill in all sections
5. Run `./scripts/update-adr-index.sh` to update this index

## Working with ADRs

### Listing ADRs

```bash
# List all ADRs
./scripts/list-adrs.sh

# List only accepted ADRs
./scripts/list-adrs.sh --status=accepted

# List with brief summaries
./scripts/list-adrs.sh --summary
```

### Searching ADRs

```bash
# Simple search
./scripts/search-adrs.sh "PostgreSQL"

# Regex pattern search
./scripts/search-adrs.sh "auth.*strategy" --regex

# Search in specific section
./scripts/search-adrs.sh "microservices" --section=decision
```

### Superseding an ADR

```bash
# Mark ADR-0014 as superseded and create replacement
./scripts/supersede-adr.sh 0014 "Migrate to AWS SES for Email"
```

This will create ADR-0019 and link it to ADR-0014.

### Updating the Index

```bash
# Regenerate this index
./scripts/update-adr-index.sh
```

---

## Templates and Resources

### Available Templates
- [ADR Template](templates/adr-template.md) - Complete ADR structure
- [Frontmatter Template](templates/adr-frontmatter.yaml) - YAML frontmatter fields
- [Decision Matrix](templates/decision-matrix.md) - For comparing alternatives
- [Consequences Template](templates/consequences-template.md) - Detailed impact analysis

### Example ADRs
- [Technology Choice Example](examples/example-adr-technology.md) - Database selection
- [Architecture Example](examples/example-adr-architecture.md) - Modular monolith decision
- [Security Example](examples/example-adr-security.md) - OAuth implementation
- [Superseded Example](examples/example-adr-superseded.md) - Shows superseding workflow

### External Resources
- [Michael Nygard's original article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR GitHub organization](https://adr.github.io/)
- [Lightweight Architecture Decision Records](https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records)

---

## ADR Statistics and Insights

### Decision Velocity
- **Jan 2025**: 7 ADRs (initial architecture setup)
- **Feb 2025**: 8 ADRs (security, testing, operations)
- **Mar 2025**: 3 ADRs + 3 proposed (architectural evolution)

### Common Decision Categories
1. **Infrastructure & Deployment**: 5 ADRs (28%)
2. **Security & Auth**: 3 ADRs (17%)
3. **Database & Storage**: 3 ADRs (17%)
4. **Frontend**: 3 ADRs (17%)
5. **Architecture**: 2 ADRs (11%)
6. **APIs**: 2 ADRs (11%)

### Superseding Rate
- 2 out of 18 ADRs superseded (11%)
- Average time before superseding: 6-8 weeks
- Reason for superseding: Team/scale growth, cost optimization

### Review Schedule
- **Quarterly architectural review**: Check if ADRs still applicable
- **Next review date**: 2025-06-15
- **Responsible**: Architecture Team

---

## Best Practices for This Project

### When to Create an ADR

Based on our experience, create ADRs for:
- Technology selection (databases, frameworks, libraries)
- Architectural patterns (monolith vs microservices, module structure)
- Security and authentication strategies
- Infrastructure and deployment approaches
- API design standards
- Cross-cutting concerns (logging, monitoring, error handling)

### When NOT to Create an ADR

Don't create ADRs for:
- Routine bug fixes
- Feature implementation details
- UI/UX design decisions (use design docs)
- Temporary experiments
- Individual service implementations within established patterns

### Our ADR Workflow

1. **Propose**: Draft ADR with status "proposed"
2. **Review**: Architecture team reviews within 1 week
3. **Discuss**: Present at architecture meeting if needed
4. **Decide**: Update status to "accepted" with decision date
5. **Implement**: Reference ADR number in implementation PRs
6. **Review**: Quarterly review of all accepted ADRs

### Quality Standards

All ADRs must include:
- Clear problem statement in Context
- At least 2 alternatives considered
- Explicit decision with rationale
- Both positive and negative consequences
- Success criteria and metrics
- Review date

---

## Contributing

### Adding New ADRs

1. Check this index for next ADR number (currently: 0019)
2. Run `./scripts/create-adr.sh "Your Decision Title"`
3. Fill in all sections thoroughly
4. Submit PR with ADR for team review
5. Update status to "accepted" after approval
6. Index updates automatically via script

### Updating Existing ADRs

- **Adding context**: Always acceptable, add "Updated: YYYY-MM-DD" note
- **Clarifying decision**: Acceptable with update note
- **Changing decision**: Don't edit! Create new superseding ADR instead
- **Fixing typos**: Acceptable, no note needed

### Superseding ADRs

Use the supersede script to maintain proper links:
```bash
./scripts/supersede-adr.sh <old-number> "New Decision Title"
```

Never delete ADRs. Always supersede them to maintain history.

---

## Questions?

- **Architecture questions**: Ask in #architecture Slack channel
- **Process questions**: See [ADR Process Documentation](https://docs.internal/adr-process)
- **Tool issues**: File issue in this repository

---

*This index is automatically generated by `scripts/update-adr-index.sh`*
*Last manual edit: 2025-03-15*
*Next automated update: On next ADR creation*
