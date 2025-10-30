---
number: NNNN
title: [Short Noun Phrase Describing the Decision]
date: YYYY-MM-DD
status: proposed
deciders: [Name1, Name2]
consulted: [Name1, Name2]
informed: [Team1, Team2]
---

# NNNN: [Title]

## Status

**proposed**

Possible statuses:
- **proposed**: Under discussion, not yet decided
- **accepted**: Approved and being implemented
- **deprecated**: No longer recommended but may still be in use
- **superseded**: Replaced by a newer ADR

## Context

What is the issue that we're seeing that is motivating this decision or change?

Describe the forces at play:

### Technical Forces
- What are the technical constraints?
- What technologies are we currently using?
- What are the performance requirements?
- What are the scalability needs?

### Business Forces
- What are the business requirements?
- What are the deadlines or time constraints?
- What is the budget?
- What are the regulatory or compliance requirements?

### Team Forces
- What is the team's current skill set?
- What resources are available?
- How many people will work on this?
- What is the team's experience with the options?

### Stakeholder Forces
- What do stakeholders expect?
- What are the political considerations?
- Who needs to approve this decision?
- What are the communication requirements?

## Decision

We will [describe the decision in full sentences, with active voice].

Use clear, direct language:
- "We will use PostgreSQL as our primary database"
- "We will adopt a microservices architecture"
- "We will implement OAuth 2.0 for authentication"

NOT vague statements like:
- "It might be good to use PostgreSQL"
- "We're thinking about microservices"
- "Maybe we should look into OAuth"

### Considered Alternatives

List all alternatives that were considered, even briefly.

#### Alternative 1: [Name]

Brief description of this alternative.

**Pros:**
- What makes this option attractive
- What problems it solves well
- What advantages it has

**Cons:**
- What makes this option less suitable
- What problems or limitations it has
- What disadvantages it brings

**Why Not Chosen:**
- Specific reasons this wasn't selected
- What was the deciding factor against it

#### Alternative 2: [Name]

Brief description of this alternative.

**Pros:**
- What makes this option attractive
- What problems it solves well
- What advantages it has

**Cons:**
- What makes this option less suitable
- What problems or limitations it has
- What disadvantages it brings

**Why Not Chosen:**
- Specific reasons this wasn't selected
- What was the deciding factor against it

#### Alternative 3: [Name]

Brief description of this alternative.

**Pros:**
- What makes this option attractive
- What problems it solves well
- What advantages it has

**Cons:**
- What makes this option less suitable
- What problems or limitations it has
- What disadvantages it brings

**Why Not Chosen:**
- Specific reasons this wasn't selected
- What was the deciding factor against it

### Why This Decision

Explain in detail why the chosen decision is the best option given the context:

1. **Addresses Key Requirements**: How it solves the main problems
2. **Best Fit for Context**: Why it fits our situation better than alternatives
3. **Acceptable Trade-offs**: What we're giving up and why that's okay
4. **Stakeholder Alignment**: How it meets stakeholder needs
5. **Risk Profile**: Why the risks are acceptable

## Consequences

### Positive Consequences

What becomes easier or better:
- Improved performance, scalability, or reliability
- Better developer experience or productivity
- Enhanced security or compliance
- Reduced costs or complexity
- New capabilities or opportunities
- Better alignment with business goals

### Negative Consequences

What becomes harder or more complex:
- Increased learning curve for the team
- Higher initial implementation cost
- Migration effort from current approach
- New dependencies or maintenance burden
- Performance trade-offs in certain scenarios
- Limitations or constraints introduced

### Neutral Consequences

What changes but isn't clearly positive or negative:
- Different operational procedures
- New monitoring or alerting needs
- Changed team responsibilities
- Different debugging or troubleshooting approaches
- Shift in architectural patterns

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| [Risk description] | High/Med/Low | High/Med/Low | [How we'll address it] |
| [Risk description] | High/Med/Low | High/Med/Low | [How we'll address it] |
| [Risk description] | High/Med/Low | High/Med/Low | [How we'll address it] |

## Implementation

### Required Changes

Specific changes needed to implement this decision:

#### Code Changes
- [File or module changes needed]
- [New code to be written]
- [Code to be removed or refactored]

#### Configuration Changes
- [Environment variables to add/change]
- [Configuration files to update]
- [Feature flags to set]

#### Infrastructure Changes
- [New services or resources to provision]
- [Existing infrastructure to modify]
- [Monitoring or alerting to configure]

#### Documentation Changes
- [Documentation to create or update]
- [Team training or onboarding materials]
- [Architecture diagrams to modify]

### Migration Strategy

How to transition from current state to new state:

#### Phase 1: [Phase Name]
- **Duration**: [Time estimate]
- **Activities**: [What happens in this phase]
- **Success Criteria**: [How we know it's complete]

#### Phase 2: [Phase Name]
- **Duration**: [Time estimate]
- **Activities**: [What happens in this phase]
- **Success Criteria**: [How we know it's complete]

#### Phase 3: [Phase Name]
- **Duration**: [Time estimate]
- **Activities**: [What happens in this phase]
- **Success Criteria**: [How we know it's complete]

### Rollback Plan

How to reverse this decision if needed:

1. **Triggers**: What would cause us to rollback
   - [Condition 1]
   - [Condition 2]
   - [Condition 3]

2. **Rollback Steps**:
   - [Step 1]
   - [Step 2]
   - [Step 3]

3. **Data Preservation**:
   - [What data needs to be preserved]
   - [How to maintain backwards compatibility]

4. **Timeline**: How quickly can we rollback
   - [Time estimate and considerations]

## Validation and Success Criteria

How we'll know if this decision was successful:

### Metrics to Track
- [Metric 1]: Target value
- [Metric 2]: Target value
- [Metric 3]: Target value

### Success Indicators
- [Indicator 1]
- [Indicator 2]
- [Indicator 3]

### Review Date
- **Initial Review**: [Date] - Check if implementation is on track
- **Post-Implementation Review**: [Date] - Evaluate if decision achieved goals
- **Long-term Review**: [Date] - Assess long-term impact

## References

### Internal References
- [Link to related ADRs]
- [Link to design documents]
- [Link to technical specifications]
- [Link to meeting notes or discussion threads]

### External References
- [Link to technology documentation]
- [Link to blog posts or articles]
- [Link to research papers]
- [Link to similar implementations or case studies]

### Tools and Resources
- [Development tools]
- [Libraries or frameworks]
- [Testing tools]
- [Documentation tools]

## Notes

### Open Questions
- [Question 1]
- [Question 2]

### Future Considerations
- [Future enhancement 1]
- [Future enhancement 2]

### Assumptions
- [Assumption 1]
- [Assumption 2]

### Dependencies
- [Dependency on other ADRs]
- [Dependency on external factors]

---

*Date: YYYY-MM-DD*
*Deciders: [Names]*
*Status: proposed*
