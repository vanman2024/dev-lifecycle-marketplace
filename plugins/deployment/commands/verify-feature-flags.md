---
description: Pre-deployment feature flag validation and verification
argument-hint: [project-path]
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Validate feature flag configurations before deployment to prevent production issues

Core Principles:
- Detect feature flag systems in use
- Validate configuration completeness
- Verify environment-specific settings
- Prevent deployment with misconfigured flags

Phase 1: Discovery
Goal: Identify feature flag systems and configuration files

Actions:
- Parse $ARGUMENTS for project path (default to current directory)
- Detect feature flag systems in use:
  - !{bash find $ARGUMENTS -type f -name "*.env*" -o -name "config.*" -o -name "feature-flags.*" 2>/dev/null | head -20}
- Check for common feature flag providers:
  - LaunchDarkly (.launchdarkly files, ld-client-sdk)
  - Split.io (split.yml, split-sdk)
  - Flagsmith (flagsmith config)
  - Unleash (unleash config)
  - Custom implementations (feature-flags.json, flags.ts)
- Load project configuration:
  - @package.json (if exists)
  - @pyproject.toml (if exists)

Phase 2: Configuration Validation
Goal: Verify feature flag configurations are complete and valid

Actions:
- For each detected feature flag system:
  - Check configuration file syntax and structure
  - Validate required fields are present
  - Verify flag naming conventions
  - Check for deprecated flags
- Environment-specific validation:
  - !{bash grep -r "FEATURE_FLAG" $ARGUMENTS/.env.example $ARGUMENTS/.env.production 2>/dev/null || echo "No feature flag env vars found"}
  - Verify production vs development flag differences
  - Check staging environment configurations
  - Validate environment variable presence
- Scan codebase for flag usage:
  - !{bash grep -r "featureFlag\|feature_flag\|isEnabled" $ARGUMENTS/src 2>/dev/null | wc -l}
  - Identify flags referenced in code
  - Cross-reference with configuration files

Phase 3: Deployment Readiness Checks
Goal: Ensure flags are deployment-ready

Actions:
- Verify critical flags:
  - Production flags are explicitly defined (not defaulting)
  - No test/debug flags enabled in production config
  - All referenced flags have configurations
  - No orphaned flags in config (unused in code)
- Check flag defaults:
  - Ensure safe defaults if flag service unavailable
  - Verify fallback behavior is defined
  - Test default values align with production requirements
- Security validation:
  - No hardcoded API keys in flag configurations
  - Feature flag SDK keys use environment variables
  - Sensitive flags have appropriate access controls
- Performance checks:
  - Flag evaluation caching configured
  - No synchronous blocking flag checks in critical paths
  - SDK initialization properly configured

Phase 4: Summary
Goal: Report validation results and recommendations

Actions:
- Display comprehensive validation report:
  - **Project Path:** $ARGUMENTS
  - **Feature Flag Systems Detected:** List all systems found
  - **Total Flags Configured:** Count from config files
  - **Total Flags Used in Code:** Count from code scan
  - **Configuration Status:** Valid/Invalid with details
  - **Environment Coverage:** Production/Staging/Development status
  - **Critical Issues:** List blockers for deployment
  - **Warnings:** Non-critical issues to address
  - **Recommendations:** Best practices to implement
- If validation fails:
  - Highlight deployment blockers
  - Provide specific remediation steps
  - Recommend NOT deploying until issues resolved
- If validation passes:
  - Confirm feature flags are deployment-ready
  - Suggest monitoring setup for flag changes
  - Recommend post-deployment flag verification
- Next steps:
  - If issues found: Fix configurations before deployment
  - If passed: Proceed with deployment using /deployment:deploy
  - Consider: Set up feature flag monitoring alerts
