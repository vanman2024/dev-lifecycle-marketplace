# Test Framework Detection Report

**Project**: {{project_path}}
**Date**: {{date}}

## Detected Frameworks

### Unit Testing
- **Framework**: {{unit_framework}}
- **Config**: {{unit_config}}
- **Command**: {{unit_command}}
- **Confidence**: {{unit_confidence}}

### E2E Testing
- **Framework**: {{e2e_framework}}
- **Config**: {{e2e_config}}

### API Contract Testing
- **Framework**: {{api_framework}}
- **Collections**: {{api_collections_count}} found
- **Auth Strategy**: {{auth_strategy}}

### Coverage
- **Tool**: {{coverage_tool}}
- **Threshold**: {{coverage_threshold}}%

## CI/CD Integration
- **Workflows Found**: {{ci_workflow_count}}
{{#ci_workflows}}
- `{{.}}`
{{/ci_workflows}}

## AI Framework Detection
- **AI Detected**: {{ai_detected}}
{{#ai_detected}}
- **Note**: LLM output testing should use the `llm-evals` plugin. Focus unit/E2E tests on deterministic behavior only.
{{/ai_detected}}

## Recommendations

{{#no_unit}}
- [ ] Install a unit test framework (recommended: {{recommended_unit}})
{{/no_unit}}
{{#no_e2e}}
- [ ] Install Playwright for E2E testing
{{/no_e2e}}
{{#no_ci}}
- [ ] Add CI test workflow (run `/testing:generate-ci`)
{{/no_ci}}
{{#low_coverage}}
- [ ] Coverage below {{coverage_threshold}}% threshold - generate more tests
{{/low_coverage}}
