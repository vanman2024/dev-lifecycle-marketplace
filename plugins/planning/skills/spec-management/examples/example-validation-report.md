# Example: Validation Report Output

This example shows what the `validate-spec.sh` script output looks like for various scenarios.

---

## Scenario 1: Fully Valid Specification

```bash
$ bash scripts/validate-spec.sh specs/015-user-profile.md
```

**Output:**
```
[INFO] Validating specification: 015-user-profile.md

[SUCCESS] Frontmatter present

[INFO] Validating frontmatter fields...
[SUCCESS] Valid spec-id: 015
[SUCCESS] Valid title: User Profile Page
[SUCCESS] Valid status: draft
[SUCCESS] Valid priority: medium
[SUCCESS] Valid owner: frontend-team
[SUCCESS] Valid created date: 2025-01-15
[SUCCESS] Valid updated date: 2025-01-15
[SUCCESS] Valid tags: [feature, frontend, user-management]

[INFO] Validating required sections...
[SUCCESS] Section present: Problem Statement
[SUCCESS] Section present: Proposed Solution
[SUCCESS] Section present: Requirements
[SUCCESS] Section present: Task Breakdown
[SUCCESS] Section present: Success Criteria

[INFO] Validating task breakdown format...
[SUCCESS] Found 6 tasks

[INFO] Validating requirements structure...

[INFO] Validating success criteria...
[SUCCESS] Found 9 success criteria

[INFO] Checking spec length...
[SUCCESS] Spec length is reasonable (245 lines)

==================================
Validation Summary
==================================
[SUCCESS] All validation checks passed!
```

---

## Scenario 2: Spec with Warnings

```bash
$ bash scripts/validate-spec.sh specs/042-collaborative-editor.md
```

**Output:**
```
[INFO] Validating specification: 042-collaborative-editor.md

[SUCCESS] Frontmatter present

[INFO] Validating frontmatter fields...
[SUCCESS] Valid spec-id: 042
[SUCCESS] Valid title: Real-Time Collaborative Document Editor
[SUCCESS] Valid status: in-progress
[SUCCESS] Valid priority: high
[SUCCESS] Valid owner: platform-team
[SUCCESS] Valid created date: 2025-01-05
[SUCCESS] Valid updated date: 2025-01-15
[WARNING] Spec not updated in 13 days (consider reviewing)
[SUCCESS] Valid tags: [feature, collaboration, websockets, real-time, complex]

[INFO] Validating required sections...
[SUCCESS] Section present: Problem Statement
[SUCCESS] Section present: Proposed Solution
[SUCCESS] Section present: Requirements
[SUCCESS] Section present: Task Breakdown
[SUCCESS] Section present: Success Criteria

[INFO] Validating task breakdown format...
[SUCCESS] Found 13 tasks
[WARNING] 3 tasks missing time estimates

[INFO] Validating requirements structure...
[SUCCESS] Section present: Functional Requirements
[SUCCESS] Section present: Non-Functional Requirements

[INFO] Validating success criteria...
[SUCCESS] Found 30 success criteria
[WARNING] Some success criteria may be vague (found 2 potentially vague terms)

[INFO] Checking spec length...
[WARNING] Spec is very long (1245 lines) - consider splitting into multiple specs

==================================
Validation Summary
==================================
[WARNING] Validation passed with 4 warning(s)
```

---

## Scenario 3: Spec with Errors

```bash
$ bash scripts/validate-spec.sh specs/099-broken-spec.md
```

**Output:**
```
[INFO] Validating specification: 099-broken-spec.md

[SUCCESS] Frontmatter present

[INFO] Validating frontmatter fields...
[SUCCESS] Valid spec-id: 099
[ERROR] Title is empty
[ERROR] Invalid status: working (must be draft, in-progress, review, approved, implemented, or rejected)
[SUCCESS] Valid priority: high
[ERROR] Owner is empty
[SUCCESS] Valid created date: 2025-01-10
[ERROR] Invalid updated date format: 2025-1-10 (must be YYYY-MM-DD)
[WARNING] Tags are empty (consider adding relevant tags)

[INFO] Validating required sections...
[SUCCESS] Section present: Problem Statement
[ERROR] Missing required section: Proposed Solution
[SUCCESS] Section present: Requirements
[WARNING] Section 'Requirements' is empty
[ERROR] Missing required section: Task Breakdown
[SUCCESS] Section present: Success Criteria
[WARNING] Section 'Success Criteria' is empty

[WARNING] Missing optional section: Technical Design
[WARNING] Missing optional section: Dependencies
[WARNING] Missing optional section: Timeline
[WARNING] Missing optional section: Risks

[INFO] Validating task breakdown format...
[ERROR] No tasks found in Task Breakdown section (use numbered list with checkboxes)

[INFO] Validating requirements structure...
[WARNING] Missing Functional Requirements subsection
[WARNING] Missing Non-Functional Requirements subsection

[INFO] Validating success criteria...
[ERROR] No success criteria found (use checklist format)

[INFO] Checking spec length...
[WARNING] Spec is very short (87 lines) - may need more detail

==================================
Validation Summary
==================================
[ERROR] Validation failed with 6 error(s) and 10 warning(s)
```

---

## Scenario 4: Missing Frontmatter

```bash
$ bash scripts/validate-spec.sh specs/no-frontmatter.md
```

**Output:**
```
[INFO] Validating specification: no-frontmatter.md

[ERROR] Missing frontmatter (YAML front matter not found)

[INFO] Validating frontmatter fields...
[ERROR] Missing required field: spec-id
[ERROR] Missing required field: title
[ERROR] Missing required field: status
[ERROR] Missing required field: priority
[ERROR] Missing required field: owner
[ERROR] Missing required field: created
[ERROR] Missing required field: updated
[WARNING] Missing optional field: tags

[INFO] Validating required sections...
[SUCCESS] Section present: Problem Statement
[SUCCESS] Section present: Proposed Solution
[SUCCESS] Section present: Requirements
[SUCCESS] Section present: Task Breakdown
[SUCCESS] Section present: Success Criteria

[INFO] Validating task breakdown format...
[SUCCESS] Found 4 tasks

[INFO] Validating requirements structure...

[INFO] Validating success criteria...
[SUCCESS] Found 8 success criteria

[INFO] Checking spec length...
[SUCCESS] Spec length is reasonable (198 lines)

==================================
Validation Summary
==================================
[ERROR] Validation failed with 8 error(s) and 2 warning(s)
```

---

## Scenario 5: Outdated Spec

```bash
$ bash scripts/validate-spec.sh specs/001-old-feature.md
```

**Output:**
```
[INFO] Validating specification: 001-old-feature.md

[SUCCESS] Frontmatter present

[INFO] Validating frontmatter fields...
[SUCCESS] Valid spec-id: 001
[SUCCESS] Valid title: Old Feature
[SUCCESS] Valid status: draft
[SUCCESS] Valid priority: medium
[SUCCESS] Valid owner: legacy-team
[SUCCESS] Valid created date: 2024-06-15
[SUCCESS] Valid updated date: 2024-06-20
[WARNING] Spec not updated in 212 days (consider reviewing)
[SUCCESS] Valid tags: [legacy, old]

[INFO] Validating required sections...
[SUCCESS] Section present: Problem Statement
[SUCCESS] Section present: Proposed Solution
[SUCCESS] Section present: Requirements
[SUCCESS] Section present: Task Breakdown
[SUCCESS] Section present: Success Criteria

[INFO] Validating task breakdown format...
[SUCCESS] Found 5 tasks

[INFO] Validating requirements structure...

[INFO] Validating success criteria...
[SUCCESS] Found 7 success criteria

[INFO] Checking spec length...
[SUCCESS] Spec length is reasonable (156 lines)

==================================
Validation Summary
==================================
[WARNING] Validation passed with 1 warning(s)

RECOMMENDATION: This spec is over 6 months old. Consider:
- Reviewing if still relevant
- Updating to reflect current status
- Archiving if no longer needed
```

---

## Validation Error Reference

### Critical Errors (Block Implementation)

1. **Missing frontmatter**: Spec cannot be processed without metadata
2. **Invalid status**: Status must be valid enum value
3. **Missing required sections**: Core sections must be present
4. **Empty required sections**: Sections must have content
5. **Invalid date format**: Dates must be YYYY-MM-DD
6. **No tasks in Task Breakdown**: Must have actionable tasks
7. **No success criteria**: Must define measurable outcomes

### Warnings (Should Address)

1. **Outdated spec**: Not updated in >30 days
2. **Empty tags**: Should categorize for organization
3. **Missing optional sections**: Best practice to include
4. **Tasks without estimates**: Hard to plan without estimates
5. **Vague success criteria**: Should be specific and measurable
6. **Very long spec**: >1000 lines may need splitting
7. **Very short spec**: <50 lines may lack detail

---

## Using Validation in CI/CD

```bash
# In your CI/CD pipeline (e.g., .github/workflows/validate-specs.yml)

name: Validate Specifications

on:
  pull_request:
    paths:
      - 'specs/**.md'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate all specs
        run: |
          EXIT_CODE=0
          for spec in specs/*.md; do
            echo "Validating $spec..."
            if ! bash scripts/validate-spec.sh "$spec"; then
              EXIT_CODE=1
            fi
            echo ""
          done
          exit $EXIT_CODE
```

---

## Pre-commit Hook

```bash
# In .git/hooks/pre-commit

#!/bin/bash
# Validate modified specs before commit

STAGED_SPECS=$(git diff --cached --name-only --diff-filter=ACM | grep '^specs/.*\.md$')

if [ -n "$STAGED_SPECS" ]; then
  echo "Validating staged specifications..."
  EXIT_CODE=0

  for spec in $STAGED_SPECS; do
    if [ -f "$spec" ]; then
      echo ""
      echo "Validating $spec..."
      if ! bash scripts/validate-spec.sh "$spec"; then
        EXIT_CODE=1
      fi
    fi
  done

  if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Specification validation failed!"
    echo "Fix errors before committing or use 'git commit --no-verify' to skip validation"
    exit 1
  fi

  echo ""
  echo "✅ All specifications validated successfully"
fi

exit 0
```

---

## Automated Validation Report

```markdown
# Weekly Specification Validation Report
Generated: 2025-01-20

## Summary

- Total Specs: 67
- Valid: 52 (78%)
- Warnings: 12 (18%)
- Errors: 3 (4%)

## Specs with Errors

| Spec ID | Title | Errors | Warnings |
|---------|-------|--------|----------|
| 099 | Broken Feature | 6 | 10 |
| 042 | Data Migration | 2 | 3 |
| 015 | Legacy API | 1 | 2 |

## Specs with Warnings

| Spec ID | Title | Warnings | Days Since Update |
|---------|-------|----------|-------------------|
| 001 | Old Feature | 1 | 212 |
| 005 | API v1 | 2 | 145 |
| 012 | Admin Panel | 3 | 67 |

## Recommendations

1. **Fix error specs immediately** - 3 specs cannot be implemented
2. **Review outdated specs** - 15 specs not updated in >30 days
3. **Add missing estimates** - 23 tasks lacking time estimates
4. **Improve success criteria** - 8 specs have vague criteria

## Trends

- 📈 Validation pass rate improved by 8% this week
- 📉 Average spec age decreased by 12 days
- ✅ 5 specs promoted from draft to in-progress
- ⚠️ 2 new specs created with warnings
```

---

## Tips for Passing Validation

1. **Use the template**: Start with `templates/spec-template.md`
2. **Fill all required fields**: Don't leave frontmatter empty
3. **Write clear sections**: Provide enough detail in each section
4. **Add measurable criteria**: Be specific in success criteria
5. **Include estimates**: Add time estimates to all tasks
6. **Update regularly**: Keep specs current (update every 2 weeks)
7. **Validate before commit**: Run validation locally first
8. **Address warnings**: Even if not errors, fix warnings for quality
9. **Keep specs focused**: Split if >1000 lines
10. **Add context**: Include enough detail (>50 lines minimum)
