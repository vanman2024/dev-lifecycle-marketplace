---
title: {{SPEC_TITLE}}
status: {{STATUS}}
priority: {{PRIORITY}}
created: {{CREATED_DATE}}
last_updated: {{LAST_UPDATED}}
updated_by: {{UPDATED_BY}}
tags: [{{TAGS}}]
{{#if BLOCKED_REASON}}
blocked_reason: {{BLOCKED_REASON}}
{{/if}}
{{#if ASSIGNED_TO}}
assigned_to: {{ASSIGNED_TO}}
{{/if}}
{{#if RELATED_SPECS}}
related_specs:
{{#each RELATED_SPECS}}
  - {{this}}
{{/each}}
{{/if}}
status_history:
{{#each STATUS_HISTORY}}
  - status: {{status}}, date: {{date}}, by: {{by}}{{#if reason}}, reason: {{reason}}{{/if}}
{{/each}}
---

# {{SPEC_TITLE}}

## Overview

{{OVERVIEW_TEXT}}

## Status

**Current Status:** {{STATUS}}
**Last Updated:** {{LAST_UPDATED}} by {{UPDATED_BY}}
{{#if BLOCKED_REASON}}
**Blocked Reason:** {{BLOCKED_REASON}}
{{/if}}

## Requirements

{{REQUIREMENTS_SECTION}}

## Implementation Notes

{{IMPLEMENTATION_NOTES}}

## Testing Criteria

{{TESTING_CRITERIA}}

## Related Documentation

{{RELATED_DOCS}}
