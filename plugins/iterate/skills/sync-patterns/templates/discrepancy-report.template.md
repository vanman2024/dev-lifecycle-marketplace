# Sync Discrepancies Report

**Project:** {{PROJECT_NAME}}
**Generated:** {{REPORT_DATE}}
**Severity:** {{SEVERITY_LEVEL}}

---

## Summary

This report identifies discrepancies between specification documents and code implementation.

**Total Discrepancies Found:** {{TOTAL_DISCREPANCIES}}

### Breakdown by Type

- **Code without Spec:** {{CODE_WITHOUT_SPEC_COUNT}} items
- **Spec without Code:** {{SPEC_WITHOUT_CODE_COUNT}} items
- **Status Mismatch:** {{STATUS_MISMATCH_COUNT}} items
- **Outdated Specs:** {{OUTDATED_SPEC_COUNT}} items

---

## Critical Discrepancies

{{#each CRITICAL_DISCREPANCIES}}
### {{index}}. {{title}}

**Type:** {{type}}
**Severity:** 🔴 Critical
**Impact:** {{impact}}

**Details:**
{{description}}

**Location:**
- Spec: {{spec_file}}
- Code: {{code_file}}

**Recommended Action:**
{{recommendation}}

**Priority:** {{priority}}
**Estimated Effort:** {{effort}}

---
{{/each}}

## High Priority Discrepancies

{{#each HIGH_PRIORITY_DISCREPANCIES}}
### {{index}}. {{title}}

**Type:** {{type}}
**Severity:** 🟠 High

**Details:** {{description}}

**Action:** {{recommendation}}

---
{{/each}}

## Medium Priority Discrepancies

{{#each MEDIUM_PRIORITY_DISCREPANCIES}}
### {{index}}. {{title}}

**Type:** {{type}}
**Severity:** 🟡 Medium

**Summary:** {{summary}}
**Action:** {{recommendation}}

---
{{/each}}

## Low Priority Discrepancies

{{#if LOW_PRIORITY_COUNT}}
Found {{LOW_PRIORITY_COUNT}} low-priority discrepancies. These can be addressed during regular maintenance.

<details>
<summary>View Low Priority Items</summary>

{{#each LOW_PRIORITY_DISCREPANCIES}}
- {{title}} ({{type}})
{{/each}}

</details>
{{/if}}

---

## Discrepancy Details

### Type 1: Code Without Spec

These implementations exist in code but have no corresponding specification.

{{#each CODE_WITHOUT_SPEC}}
#### {{feature_name}}

**Files Affected:**
{{#each files}}
- {{this}}
{{/each}}

**Evidence:**
- Tests: {{test_count}}
- Implementation files: {{impl_count}}

**Action Required:**
- [ ] Create specification document
- [ ] Document requirements
- [ ] Add to project roadmap

---
{{/each}}

### Type 2: Spec Without Code

These specifications exist but have no implementation evidence.

{{#each SPEC_WITHOUT_CODE}}
#### {{spec_name}}

**Spec File:** {{spec_file}}
**Status in Spec:** {{spec_status}}
**Last Updated:** {{last_updated}}

**Tasks Listed:**
- Total: {{total_tasks}}
- Marked Complete: {{completed_tasks}}
- Actually Implemented: 0

**Action Required:**
- [ ] Implement missing features
- [ ] Or mark spec as deprecated/canceled
- [ ] Update spec status to reflect reality

---
{{/each}}

### Type 3: Status Mismatch

Spec status doesn't match implementation reality.

{{#each STATUS_MISMATCH}}
#### {{spec_name}}

**Spec Status:** {{spec_status}}
**Actual Status:** {{actual_status}}

**Reason for Mismatch:**
{{reason}}

**Action Required:**
- [ ] Update spec status
- [ ] Add status_history entry
- [ ] Notify team of status change

---
{{/each}}

---

## Resolution Plan

### Immediate Actions (This Week)

{{#each IMMEDIATE_ACTIONS}}
- [ ] {{action}} (Priority: {{priority}})
{{/each}}

### Short-term Actions (This Month)

{{#each SHORT_TERM_ACTIONS}}
- [ ] {{action}}
{{/each}}

### Long-term Actions (This Quarter)

{{#each LONG_TERM_ACTIONS}}
- [ ] {{action}}
{{/each}}

---

## Impact Analysis

### Development Impact

**Velocity:** {{#if HIGH_DISCREPANCY}}Slowed by unclear requirements{{else}}Minimal impact{{/if}}

**Code Quality:** {{#if CODE_WITHOUT_SPEC}}Risk of undocumented features{{else}}Well documented{{/if}}

**Technical Debt:** {{TECH_DEBT_LEVEL}}

### Business Impact

**Risk Level:** {{RISK_LEVEL}}
**Customer Impact:** {{CUSTOMER_IMPACT}}
**Compliance:** {{COMPLIANCE_STATUS}}

---

## Recommendations

### Process Improvements

1. **Spec-First Development**
   - Require spec approval before coding
   - Use spec reviews as gate for implementation
   - Keep specs updated during development

2. **Regular Sync Checks**
   - Weekly sync reviews
   - Automated sync validation in CI
   - Pre-PR sync verification

3. **Documentation Standards**
   - Clear status definitions
   - Mandatory frontmatter
   - Task tracking requirements

### Tooling Improvements

1. **Automation**
   - Auto-detect code without specs
   - Flag status mismatches in PRs
   - Generate sync reports automatically

2. **Integration**
   - Link specs to tickets/issues
   - Connect specs to test coverage
   - Sync with project management tools

---

## Appendix

### Methodology

**Detection Methods:**
- Keyword matching between specs and code
- Evidence scoring (tests, implementation, config)
- Status frontmatter analysis
- File modification timestamps

**Evidence Thresholds:**
- Minimum evidence score: {{MIN_EVIDENCE}}
- Confidence level: {{CONFIDENCE_LEVEL}}
- False positive rate: {{FALSE_POSITIVE_RATE}}

### Data Sources

- **Specs:** {{SPEC_DIRECTORY}}
- **Code:** {{CODE_DIRECTORY}}
- **Analysis Date:** {{ANALYSIS_DATE}}
- **Tool Version:** {{TOOL_VERSION}}

---

*This report was generated automatically by the sync-patterns skill.*
*Review and validate findings before taking action.*
