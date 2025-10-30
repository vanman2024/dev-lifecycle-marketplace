# Consequences Analysis Template

Use this template to thoroughly analyze and document the consequences of an architectural decision. This detailed analysis should be included in the Consequences section of your ADR.

---

## Decision Summary

**Decision**: [State the decision clearly in one sentence]

**ADR Number**: ADR-NNNN

**Date**: YYYY-MM-DD

---

## Impact Categories

Analyze the decision's impact across multiple dimensions:

### 1. Technical Impact

#### Positive Technical Consequences

**Performance**
- [How does this improve or affect performance?]
- [What performance metrics will improve?]
- [What performance issues are avoided?]

**Scalability**
- [How does this enable scaling?]
- [What scaling limitations are removed?]
- [What new scaling options are available?]

**Reliability**
- [How does this improve system reliability?]
- [What failure modes are eliminated or reduced?]
- [How does this affect uptime and availability?]

**Maintainability**
- [What becomes easier to maintain?]
- [How does this simplify operations?]
- [What debugging or monitoring improvements result?]

**Security**
- [What security improvements result?]
- [What attack vectors are eliminated?]
- [How does this strengthen security posture?]

#### Negative Technical Consequences

**Complexity**
- [What new complexity is introduced?]
- [What becomes harder to understand?]
- [What new failure modes are introduced?]

**Performance Trade-offs**
- [What performance compromises are made?]
- [Which operations become slower?]
- [What resource usage increases?]

**Technical Debt**
- [What shortcuts or compromises are being made?]
- [What will need to be addressed later?]
- [What legacy code or systems must be maintained?]

**Limitations**
- [What new constraints are introduced?]
- [What can no longer be done?]
- [What future options are limited?]

#### Neutral Technical Consequences

**Changed Patterns**
- [What architectural patterns change?]
- [What new patterns are introduced?]
- [What patterns are deprecated?]

**Operational Changes**
- [What operational procedures change?]
- [What new operational requirements emerge?]
- [What operational tasks are eliminated?]

---

### 2. Team and People Impact

#### Positive People Consequences

**Developer Experience**
- [What becomes easier for developers?]
- [What productivity improvements result?]
- [What frustrations are eliminated?]

**Skill Development**
- [What new skills can the team learn?]
- [What career development opportunities emerge?]
- [What expertise becomes more valuable?]

**Team Morale**
- [How does this positively affect team satisfaction?]
- [What pain points are addressed?]
- [What improvements to work-life balance result?]

#### Negative People Consequences

**Learning Curve**
- [What new knowledge is required?]
- [How steep is the learning curve?]
- [What training is needed?]

**Workload Impact**
- [What additional work is created?]
- [Who is most affected?]
- [What existing work is disrupted?]

**Resistance and Concerns**
- [Who might resist this change and why?]
- [What concerns need to be addressed?]
- [What fears or anxieties might arise?]

#### Neutral People Consequences

**Role Changes**
- [How do team roles or responsibilities change?]
- [Who takes on new responsibilities?]
- [What responsibilities are eliminated?]

**Communication Patterns**
- [How do team communication patterns change?]
- [What new collaboration is required?]
- [What meetings or ceremonies change?]

---

### 3. Business Impact

#### Positive Business Consequences

**Cost Savings**
- [What costs are reduced?]
- [What efficiency gains result?]
- [What waste is eliminated?]

**Revenue Opportunities**
- [What new capabilities enable revenue?]
- [What market opportunities open up?]
- [What competitive advantages result?]

**Time to Market**
- [What is delivered faster?]
- [What development cycles are shortened?]
- [What blockers are removed?]

**Customer Value**
- [How does this benefit end users?]
- [What customer problems are solved?]
- [What new features become possible?]

**Risk Reduction**
- [What business risks are reduced?]
- [What compliance requirements are met?]
- [What liabilities are decreased?]

#### Negative Business Consequences

**Costs**
- [What new costs are introduced?]
- [What investments are required?]
- [What ongoing expenses increase?]

**Timeline Impact**
- [What delays result?]
- [What deliverables are postponed?]
- [What opportunity costs exist?]

**Customer Impact**
- [What disruptions do customers experience?]
- [What features are delayed?]
- [What customer concerns arise?]

**Market Position**
- [How does this affect competitive position?]
- [What market opportunities are foregone?]
- [What competitors gain advantage?]

#### Neutral Business Consequences

**Process Changes**
- [What business processes change?]
- [What workflows are affected?]
- [What approval processes change?]

**Reporting and Metrics**
- [What metrics change?]
- [What new reporting is needed?]
- [What KPIs are affected?]

---

### 4. Organizational Impact

#### Positive Organizational Consequences

**Alignment**
- [How does this align with company strategy?]
- [What organizational goals does this support?]
- [What synergies are created?]

**Culture**
- [How does this support desired culture?]
- [What positive cultural shifts result?]
- [What values are reinforced?]

**Collaboration**
- [What cross-team collaboration improves?]
- [What silos are broken down?]
- [What partnerships are strengthened?]

#### Negative Organizational Consequences

**Organizational Friction**
- [What conflicts might arise?]
- [What dependencies are created?]
- [What coordination is required?]

**Resource Allocation**
- [What teams are stretched thin?]
- [What resource conflicts emerge?]
- [What priorities must shift?]

**Political Challenges**
- [What political sensitivities exist?]
- [Who might feel threatened?]
- [What power dynamics change?]

#### Neutral Organizational Consequences

**Structural Changes**
- [What organizational structure changes?]
- [What reporting lines change?]
- [What team boundaries shift?]

**Governance**
- [What governance changes are needed?]
- [What approval processes change?]
- [What policies need updating?]

---

## Quantitative Impact Analysis

### Cost Analysis

| Cost Category | Current State | Future State | Delta | Timeline |
|---------------|---------------|--------------|-------|----------|
| Infrastructure | $X/month | $Y/month | +/- $Z | Immediate |
| Development | $X/month | $Y/month | +/- $Z | 6 months |
| Operations | $X/month | $Y/month | +/- $Z | Ongoing |
| Maintenance | $X/month | $Y/month | +/- $Z | Ongoing |
| Training | - | $Y total | + $Y | 3 months |
| Migration | - | $Y total | + $Y | 1 month |
| **TOTAL** | **$X/month** | **$Y/month** | **+/- $Z** | - |

**ROI Calculation**:
- Initial investment: $[amount]
- Monthly savings: $[amount]
- Break-even point: [X] months
- 3-year total savings: $[amount]

### Performance Impact

| Metric | Current | Target | Improvement | Timeline |
|--------|---------|--------|-------------|----------|
| Response Time | Xms | Yms | -Z% | 3 months |
| Throughput | X req/s | Y req/s | +Z% | 3 months |
| Error Rate | X% | Y% | -Z% | 1 month |
| Uptime | X% | Y% | +Z% | Ongoing |
| Resource Usage | X% | Y% | -Z% | 3 months |

### Effort Estimation

| Task | Effort (person-days) | Duration (calendar) | Dependencies |
|------|---------------------|---------------------|--------------|
| Planning | X days | Y weeks | None |
| Implementation | X days | Y weeks | Planning complete |
| Testing | X days | Y weeks | Implementation 50% |
| Migration | X days | Y weeks | Testing complete |
| Documentation | X days | Y weeks | Throughout |
| Training | X days | Y weeks | Implementation 80% |
| **TOTAL** | **X days** | **Y weeks** | - |

---

## Risk Assessment

### High-Impact Risks

| Risk | Likelihood | Impact | Severity | Mitigation | Owner |
|------|------------|--------|----------|------------|-------|
| [Risk 1] | High/Med/Low | High | Critical | [Strategy] | [Name] |
| [Risk 2] | High/Med/Low | High | Critical | [Strategy] | [Name] |

### Medium-Impact Risks

| Risk | Likelihood | Impact | Severity | Mitigation | Owner |
|------|------------|--------|----------|------------|-------|
| [Risk 3] | High/Med/Low | Medium | Moderate | [Strategy] | [Name] |
| [Risk 4] | High/Med/Low | Medium | Moderate | [Strategy] | [Name] |

### Low-Impact Risks

| Risk | Likelihood | Impact | Severity | Mitigation | Owner |
|------|------------|--------|----------|------------|-------|
| [Risk 5] | High/Med/Low | Low | Minor | [Strategy] | [Name] |
| [Risk 6] | High/Med/Low | Low | Minor | [Strategy] | [Name] |

---

## Stakeholder Impact Analysis

### Affected Stakeholders

| Stakeholder | Impact Level | Concerns | Benefits | Communication Plan |
|-------------|--------------|----------|----------|-------------------|
| Development Team | High | Learning curve | Better tools | Weekly updates |
| Operations Team | High | New procedures | Easier ops | Training sessions |
| Product Team | Medium | Timeline | Features | Monthly reviews |
| Customers | Low | Minor changes | Performance | Release notes |
| Leadership | Medium | Costs | ROI | Quarterly reports |

### Communication Strategy

**Who Needs to Know**:
- [Stakeholder group 1]: [What they need to know]
- [Stakeholder group 2]: [What they need to know]
- [Stakeholder group 3]: [What they need to know]

**Communication Timeline**:
1. **Before decision**: [Who to inform and when]
2. **At decision time**: [Announcement plan]
3. **During implementation**: [Update frequency and channels]
4. **After completion**: [Success communication]

---

## Long-Term Consequences (12+ months)

### Positive Long-Term Effects

**Technical Evolution**
- [How does this enable future technical improvements?]
- [What doors does this open?]
- [What technical debt is prevented?]

**Business Growth**
- [How does this support scaling the business?]
- [What future opportunities does this enable?]
- [How does this position us for the future?]

**Team Development**
- [How does this build team capability?]
- [What institutional knowledge is created?]
- [How does this attract or retain talent?]

### Negative Long-Term Effects

**Technical Debt**
- [What future maintenance burden is created?]
- [What becomes harder to change later?]
- [What dependencies become problematic?]

**Lock-in Effects**
- [What future flexibility is reduced?]
- [What becomes harder to change?]
- [What dependencies are we accepting?]

**Obsolescence Risk**
- [How might this decision age poorly?]
- [What if underlying assumptions change?]
- [What if better alternatives emerge?]

---

## Mitigation Strategies

### For Negative Consequences

| Negative Consequence | Mitigation Strategy | Owner | Timeline | Success Criteria |
|---------------------|---------------------|-------|----------|------------------|
| [Consequence 1] | [Strategy] | [Name] | [When] | [How to measure] |
| [Consequence 2] | [Strategy] | [Name] | [When] | [How to measure] |
| [Consequence 3] | [Strategy] | [Name] | [When] | [How to measure] |

### For Risks

| Risk | Prevention Strategy | Detection Strategy | Response Plan | Owner |
|------|---------------------|-------------------|---------------|-------|
| [Risk 1] | [How to prevent] | [How to detect] | [What to do] | [Name] |
| [Risk 2] | [How to prevent] | [How to detect] | [What to do] | [Name] |
| [Risk 3] | [How to prevent] | [How to detect] | [What to do] | [Name] |

---

## Success Metrics

### How We'll Measure Success

**Technical Metrics**
- [Metric 1]: Baseline [X], Target [Y], Timeline [Z]
- [Metric 2]: Baseline [X], Target [Y], Timeline [Z]
- [Metric 3]: Baseline [X], Target [Y], Timeline [Z]

**Business Metrics**
- [Metric 1]: Baseline [X], Target [Y], Timeline [Z]
- [Metric 2]: Baseline [X], Target [Y], Timeline [Z]
- [Metric 3]: Baseline [X], Target [Y], Timeline [Z]

**Team Metrics**
- [Metric 1]: Baseline [X], Target [Y], Timeline [Z]
- [Metric 2]: Baseline [X], Target [Y], Timeline [Z]
- [Metric 3]: Baseline [X], Target [Y], Timeline [Z]

### Review Schedule

- **30-day review**: Check if implementation is on track
- **90-day review**: Assess if consequences match predictions
- **6-month review**: Evaluate if success metrics are met
- **Annual review**: Determine if decision should continue or be revised

---

## Rollback Considerations

### When to Consider Rollback

**Triggers**:
- [Condition that would trigger rollback consideration]
- [Condition that would trigger rollback consideration]
- [Condition that would trigger rollback consideration]

### Rollback Difficulty

- **Ease of rollback**: [Easy / Moderate / Difficult / Impossible]
- **Rollback timeline**: [How long to rollback]
- **Rollback cost**: [Estimated cost]
- **Data impact**: [What happens to data]

### Rollback Plan

If rollback is needed:
1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Lessons Learned (Post-Implementation)

*This section should be filled out after the decision has been implemented and consequences have been observed*

### What We Got Right

- [Consequence we predicted correctly]
- [Benefit that materialized as expected]
- [Risk that we successfully mitigated]

### What We Missed

- [Unexpected positive consequence]
- [Unexpected negative consequence]
- [Risk we didn't anticipate]

### What We'd Do Differently

- [What we'd change in the decision process]
- [What we'd communicate differently]
- [What we'd plan for better]

### Advice for Future Similar Decisions

- [Lesson learned 1]
- [Lesson learned 2]
- [Lesson learned 3]

---

*Created: YYYY-MM-DD*
*Last Updated: YYYY-MM-DD*
*Owner: [Name]*
*Status: [Pre-implementation / In-progress / Post-implementation]*
