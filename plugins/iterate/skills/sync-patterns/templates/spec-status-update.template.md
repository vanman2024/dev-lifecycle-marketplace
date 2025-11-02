---
status: {{STATUS}}
last_updated: {{TIMESTAMP}}
updated_by: {{UPDATED_BY}}
{{#if BLOCKED_REASON}}
blocked_reason: {{BLOCKED_REASON}}
{{/if}}
status_history:
  - status: {{STATUS}}, date: {{TIMESTAMP}}, by: {{UPDATED_BY}}{{#if REASON}}, reason: {{REASON}}{{/if}}
---

# {{SPEC_NAME}}

## Status Update

**Status Changed:** {{OLD_STATUS}} → {{STATUS}}
**Updated By:** {{UPDATED_BY}}
**Timestamp:** {{TIMESTAMP}}

{{#if REASON}}
**Reason:** {{REASON}}
{{/if}}

## Description

{{SPEC_DESCRIPTION}}

## Requirements

{{REQUIREMENTS_LIST}}

## Implementation Notes

{{IMPLEMENTATION_NOTES}}

---

*Last updated: {{TIMESTAMP}} by {{UPDATED_BY}}*
