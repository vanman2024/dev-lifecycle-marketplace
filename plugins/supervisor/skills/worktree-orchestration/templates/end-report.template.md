# Supervisor End Report: [SPEC_NAME]

**Phase**: END | **Date**: [TIMESTAMP] | **Spec**: [SPEC_PATH]
**Purpose**: PR readiness verification and worktree cleanup management

## Completion Verification

### Final Task Status
- **Total Tasks**: [TOTAL_TASKS]
- **Completed**: [COMPLETED_TASKS] ([COMPLETION_PERCENTAGE]%)
- **Incomplete**: [INCOMPLETE_TASKS]
- **Completion Status**: [COMPLETION_STATUS]

### Work Quality Assessment
| Agent | Tasks Complete | Quality Check | PR Ready |
|-------|---------------|---------------|----------|
| @claude | [CLAUDE_COMPLETION] | [CLAUDE_QUALITY] | [CLAUDE_PR_READY] |
| @copilot | [COPILOT_COMPLETION] | [COPILOT_QUALITY] | [COPILOT_PR_READY] |
| @codex | [CODEX_COMPLETION] | [CODEX_QUALITY] | [CODEX_PR_READY] |
| @qwen | [QWEN_COMPLETION] | [QWEN_QUALITY] | [QWEN_PR_READY] |
| @gemini | [GEMINI_COMPLETION] | [GEMINI_QUALITY] | [GEMINI_PR_READY] |

## Repository State Analysis

### Main Branch Status
**Protection Status**: [MAIN_PROTECTION_STATUS]  
**Agent Violations**: [MAIN_VIOLATIONS_COUNT]  
**Cleanup Required**: [MAIN_CLEANUP_REQUIRED]

### Worktree Management
**Active Worktrees**: [ACTIVE_WORKTREES_COUNT]  
**Cleanup Status**: [CLEANUP_STATUS]

#### Worktree Cleanup Commands
```bash
[CLEANUP_COMMANDS]
```

## PR Readiness Gates

### Critical Gates
- [ ] All tasks completed: [TASKS_GATE]
- [ ] Main branch clean: [MAIN_GATE] 
- [ ] No uncommitted work: [COMMIT_GATE]
- [ ] Quality standards met: [QUALITY_GATE]

### PR Creation Approval
**Status**: [PR_APPROVAL_STATUS]  
**Blockers**: [PR_BLOCKERS]

## Final Actions Required

### Before PR Creation
[PRE_PR_ACTIONS]

### After PR Merge
[POST_PR_ACTIONS]

## Summary
**Overall Status**: [OVERALL_STATUS]  
**PR Ready**: [PR_READY_STATUS]  
**Next Steps**: [FINAL_NEXT_STEPS]

---
**End Phase Complete**: [TIMESTAMP]  
**Worktree Cleanup**: [CLEANUP_TIMESTAMP]