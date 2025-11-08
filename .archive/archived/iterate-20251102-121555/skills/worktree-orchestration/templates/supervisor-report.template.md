# Supervisor Report: [SPEC_NAME]

**Phase**: [PHASE] | **Date**: [TIMESTAMP] | **Spec**: [SPEC_PATH]
**Input**: Agent compliance check for `/specs/[SPEC_NAME]/`

## Execution Flow (/supervisor [PHASE] command scope)
```
1. Load spec directory and agent assignments
   → [LOAD_STATUS]
2. Check agent worktree compliance
   → [WORKTREE_STATUS]
3. Verify agent role adherence
   → [ROLE_STATUS]
4. Monitor task progress and coordination
   → [PROGRESS_STATUS]
5. Generate compliance report
   → [REPORT_STATUS]
```

## Summary
[SUMMARY_TEXT]

## Agent Compliance Status

### Worktree Verification
**@claude**: [CLAUDE_WORKTREE_STATUS]
**@copilot**: [COPILOT_WORKTREE_STATUS]  
**@codex**: [CODEX_WORKTREE_STATUS]
**@qwen**: [QWEN_WORKTREE_STATUS]
**@gemini**: [GEMINI_WORKTREE_STATUS]

### Role Adherence Check
**@claude**: [CLAUDE_ROLE_STATUS] - [CLAUDE_ROLE_DETAILS]
**@copilot**: [COPILOT_ROLE_STATUS] - [COPILOT_ROLE_DETAILS]
**@codex**: [CODEX_ROLE_STATUS] - [CODEX_ROLE_DETAILS]
**@qwen**: [QWEN_ROLE_STATUS] - [QWEN_ROLE_DETAILS]
**@gemini**: [GEMINI_ROLE_STATUS] - [GEMINI_ROLE_DETAILS]

### Task Progress Monitoring
[TASK_PROGRESS_TABLE]

## Phase-Specific Checks

### [PHASE] Phase Verification
[PHASE_SPECIFIC_CHECKS]

## Issues Detected
[ISSUES_LIST]

## Recommendations
[RECOMMENDATIONS_LIST]

## Compliance Gates

### Critical Gates
- [ ] All agents in proper worktrees: [WORKTREE_GATE_STATUS]
- [ ] No role boundary violations: [ROLE_GATE_STATUS]
- [ ] Task coordination functioning: [COORDINATION_GATE_STATUS]
- [ ] [PHASE]-specific requirements met: [PHASE_GATE_STATUS]

### Quality Gates  
- [ ] Proper commit patterns: [COMMIT_GATE_STATUS]
- [ ] Code quality standards: [QUALITY_GATE_STATUS]
- [ ] Documentation compliance: [DOCS_GATE_STATUS]

## Next Steps
[NEXT_STEPS_LIST]

## Audit Trail
**Generated**: [TIMESTAMP]
**Phase**: [PHASE] phase verification
**Agents Monitored**: [AGENTS_COUNT]
**Issues Found**: [ISSUES_COUNT]
**Critical Blockers**: [BLOCKERS_COUNT]

---
*Supervisor system ensuring agent compliance and coordination*