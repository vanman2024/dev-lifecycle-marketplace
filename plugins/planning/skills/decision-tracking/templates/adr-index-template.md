# Architecture Decision Records (ADR)

This document provides an index of all Architecture Decision Records (ADRs) for this project.

## About ADRs

Architecture Decision Records (ADRs) are documents that capture important architectural decisions made during the project's lifecycle. Each ADR describes:

- **The context**: What problem or situation is being addressed
- **The decision**: What was decided and why
- **The consequences**: What impact this decision will have

ADRs follow the format proposed by Michael Nygard in his article ["Documenting Architecture Decisions"](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

## Why Use ADRs?

### For Current Team Members
- **Understand the "why"**: Learn the reasoning behind architectural decisions
- **Avoid repeating mistakes**: See what alternatives were tried and why they didn't work
- **Make consistent decisions**: Follow established patterns and principles
- **Onboard faster**: Quickly understand the project's architectural evolution

### For Future Team Members
- **Historical context**: Understand why the system is designed the way it is
- **Decision rationale**: See what constraints and forces influenced past decisions
- **Evolution tracking**: Follow how the architecture changed over time
- **Avoid revisiting settled issues**: Know what was already considered and decided

### For Stakeholders
- **Transparency**: Visibility into architectural decisions and their justification
- **Accountability**: Clear record of who made decisions and when
- **Risk awareness**: Understanding of trade-offs and potential issues
- **Alignment**: Ensure technical decisions support business goals

## ADR Lifecycle

ADRs can have the following statuses:

- **Proposed** (`proposed`): The ADR is under discussion and not yet decided
- **Accepted** (`accepted`): The decision has been approved and is being implemented
- **Deprecated** (`deprecated`): The decision is no longer recommended but may still be in use
- **Superseded** (`superseded`): The decision has been replaced by a newer ADR

### Status Transitions

```
proposed --> accepted --> deprecated
               |
               v
           superseded
```

## Statistics

- **Total ADRs**: [NUMBER]
- **Accepted**: [NUMBER]
- **Proposed**: [NUMBER]
- **Deprecated**: [NUMBER]
- **Superseded**: [NUMBER]

*Last updated: YYYY-MM-DD*

---

## Accepted Decisions

These decisions have been approved and are currently in effect:

- [ADR-0001: Decision Title](0001-decision-title.md) - *YYYY-MM-DD*
  - Brief one-line summary of the decision
  - Tags: `database`, `architecture`

- [ADR-0003: Another Decision](0003-another-decision.md) - *YYYY-MM-DD*
  - Brief one-line summary of the decision
  - Tags: `security`, `authentication`

- [ADR-0007: Yet Another Decision](0007-yet-another-decision.md) - *YYYY-MM-DD*
  - Brief one-line summary of the decision
  - Tags: `performance`, `caching`

## Proposed Decisions

These decisions are under discussion and awaiting approval:

- [ADR-0010: Proposed Decision](0010-proposed-decision.md) - *YYYY-MM-DD*
  - Brief one-line summary of the decision
  - Tags: `api`, `architecture`
  - Status: Under review by Architecture Team

- [ADR-0011: Another Proposal](0011-another-proposal.md) - *YYYY-MM-DD*
  - Brief one-line summary of the decision
  - Tags: `deployment`, `infrastructure`
  - Status: Awaiting security review

## Deprecated Decisions

These decisions are no longer recommended but may still be in use:

- [ADR-0002: Old Approach](0002-old-approach.md) - *YYYY-MM-DD*
  - Brief one-line summary of the decision
  - Tags: `legacy`, `database`
  - Reason: Performance issues at scale

## Superseded Decisions

These decisions have been replaced by newer ADRs:

- [ADR-0004: Original Decision](0004-original-decision.md) - *YYYY-MM-DD*
  - Superseded by: [ADR-0008: New Approach](0008-new-approach.md)
  - Reason: Better alternative became available

- [ADR-0005: Early Decision](0005-early-decision.md) - *YYYY-MM-DD*
  - Superseded by: [ADR-0009: Improved Approach](0009-improved-approach.md)
  - Reason: Requirements changed

---

## ADRs by Category

### Database and Storage
- [ADR-0001: Use PostgreSQL for Primary Database](0001-use-postgresql.md) - `accepted`
- [ADR-0002: Use Redis for Caching](0002-use-redis-cache.md) - `deprecated`
- [ADR-0012: Add pgvector for Vector Storage](0012-add-pgvector.md) - `proposed`

### Security and Authentication
- [ADR-0003: Implement OAuth 2.0](0003-implement-oauth.md) - `accepted`
- [ADR-0006: Use JWT for API Authentication](0006-use-jwt.md) - `accepted`

### Architecture Patterns
- [ADR-0004: Adopt Monolithic Architecture](0004-monolithic.md) - `superseded`
- [ADR-0008: Migrate to Microservices](0008-microservices.md) - `accepted`

### Infrastructure and Deployment
- [ADR-0007: Deploy on AWS](0007-deploy-aws.md) - `accepted`
- [ADR-0009: Use Kubernetes for Orchestration](0009-use-kubernetes.md) - `accepted`

### APIs and Integrations
- [ADR-0010: REST API Design Standards](0010-rest-api-standards.md) - `proposed`
- [ADR-0011: GraphQL for Client API](0011-graphql-api.md) - `proposed`

---

## Decision Timeline

Chronological view of all architectural decisions:

```
2025-01 | ADR-0001: PostgreSQL Database
        | ADR-0002: Redis Caching
        |
2025-02 | ADR-0003: OAuth 2.0 Authentication
        | ADR-0004: Monolithic Architecture
        |
2025-03 | ADR-0005: (superseded)
        | ADR-0006: JWT Authentication
        |
2025-04 | ADR-0007: AWS Deployment
        | ADR-0008: Microservices Migration (supersedes ADR-0004)
        |
2025-05 | ADR-0009: Kubernetes Orchestration
        |
2025-06 | ADR-0010: REST API Standards (proposed)
        | ADR-0011: GraphQL API (proposed)
```

---

## Creating a New ADR

To create a new ADR, use the provided script:

```bash
./scripts/create-adr.sh "Title of Your Decision"
```

The script will:
1. Automatically assign the next sequential ADR number
2. Create a new file with the proper Michael Nygard ADR format
3. Populate the file with frontmatter and sections
4. Update this index automatically

### Manual Creation

If you prefer to create an ADR manually:

1. Determine the next ADR number (check the last ADR in the list)
2. Create a new file: `NNNN-title-in-kebab-case.md`
3. Copy the template from `templates/adr-template.md`
4. Fill in all sections with relevant information
5. Update this index file

## Working with ADRs

### Listing ADRs

To list all ADRs with filtering:

```bash
# List all ADRs
./scripts/list-adrs.sh

# List only accepted ADRs
./scripts/list-adrs.sh --status=accepted

# List with brief summaries
./scripts/list-adrs.sh --summary
```

### Searching ADRs

To search through ADR content:

```bash
# Simple search
./scripts/search-adrs.sh "search term"

# Regex pattern search
./scripts/search-adrs.sh "auth.*strategy" --regex

# Search in specific section
./scripts/search-adrs.sh "microservices" --section=decision
```

### Superseding an ADR

To mark an ADR as superseded and create a replacement:

```bash
./scripts/supersede-adr.sh 0004 "New Decision Title"
```

This will:
1. Mark the old ADR (ADR-0004) as superseded
2. Create a new ADR with a reference to the superseded one
3. Link both ADRs together
4. Update this index

### Updating the Index

To regenerate this index:

```bash
./scripts/update-adr-index.sh
```

The script scans all ADR files and rebuilds this index with current information.

---

## Best Practices

### Writing Effective ADRs

1. **Be Specific and Clear**
   - State exactly what is being decided
   - Use concrete examples
   - Avoid vague or ambiguous language

2. **Provide Context**
   - Explain the problem being solved
   - Describe the forces and constraints
   - Include relevant background information

3. **Document Alternatives**
   - List all options that were considered
   - Explain why each alternative was or wasn't chosen
   - Show the decision-making process

4. **Describe Consequences**
   - Include both positive and negative impacts
   - Be honest about trade-offs
   - List neutral changes as well

5. **Use Active Voice**
   - "We will use PostgreSQL" ✓
   - "PostgreSQL will be used" ✗

### When to Create an ADR

Create an ADR for decisions that:
- Have significant architectural impact
- Affect multiple teams or components
- Are difficult or expensive to reverse
- Represent a choice between viable alternatives
- Will influence future decisions

Examples:
- Choosing core technologies (databases, frameworks, languages)
- Defining architectural patterns (monolith vs microservices)
- Establishing security or authentication strategies
- Setting API design standards
- Selecting deployment platforms or strategies

### When NOT to Create an ADR

Don't create ADRs for:
- Routine bug fixes or minor refactoring
- Implementation details of already-decided features
- Temporary workarounds or experiments
- Decisions that can be easily reversed
- Team process decisions (use meeting notes instead)

### Reviewing and Maintaining ADRs

- **Regular Reviews**: Review accepted ADRs quarterly to ensure they're still relevant
- **Update Status**: Change status when circumstances change (accepted → deprecated)
- **Supersede When Needed**: Don't be afraid to supersede old decisions with better ones
- **Keep History**: Never delete ADRs, always supersede them to maintain history
- **Link Related ADRs**: Reference related decisions to show relationships

---

## Templates and Resources

### Templates
- [ADR Template](templates/adr-template.md) - Complete ADR structure
- [Frontmatter Template](templates/adr-frontmatter.yaml) - YAML frontmatter fields
- [Decision Matrix](templates/decision-matrix.md) - For comparing alternatives
- [Consequences Template](templates/consequences-template.md) - Detailed impact analysis

### External Resources
- [Michael Nygard's original article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR GitHub organization](https://adr.github.io/)
- [Architecture Decision Records in Action](https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records)

---

## Contributing

When contributing ADRs to this project:

1. **Follow the format**: Use the Michael Nygard ADR format consistently
2. **Get feedback**: Share draft ADRs with relevant stakeholders before finalizing
3. **Be thorough**: Complete all sections, don't leave placeholders
4. **Update status**: Change from "proposed" to "accepted" once approved
5. **Maintain the index**: Run the update script after creating or modifying ADRs

---

*This index is automatically generated by `scripts/update-adr-index.sh`*
*Manual edits to the ADR lists may be overwritten - edit the source ADR files instead*
