---
id: F{NNN}
name: {feature-name}
infrastructure_phase: {0-5}
infrastructure_dependencies: [{I001}, {I010}]
priority: {P0|P1|P2}
status: planned
---

# {feature-name}

## Overview
{brief-description}

## User Stories
**As a** {user-type}
**I want** {capability}
**So that** {benefit}

## Acceptance Criteria
- [ ] {criterion-1}
- [ ] {criterion-2}
- [ ] {criterion-3}

## Infrastructure Dependencies
**Required infrastructure (must be built first):**
- {I001} - {name} (phase {N})
- {I010} - {name} (phase {N})

**Infrastructure phase**: {N} - Feature cannot be built until phase {N} infrastructure exists

## Feature Dependencies
- **Requires**: {F001, F002} - features that must be built first
- **Blocks**: {F007, F008} - features waiting on this

## References
- **Architecture**: `docs/architecture/{section}.md#{anchor}`
- **ADR**: `docs/adr/{number}-{decision}.md`
- **Infrastructure Specs**: `specs/infrastructure/phase-{N}/{number}-{name}/`

## Scope
**Included:**
- {what-is-included-1}
- {what-is-included-2}

**Out of Scope:**
- {what-is-NOT-included}

## Technical Notes
{architecture-notes-specific-to-this-feature}
