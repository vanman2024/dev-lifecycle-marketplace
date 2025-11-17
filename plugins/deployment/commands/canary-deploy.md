---
description: Progressive traffic rollout with auto-rollback monitoring
argument-hint: [deployment-target]
---

---
🚨 **EXECUTION NOTICE FOR CLAUDE**

When you invoke this command via SlashCommand, the system returns THESE INSTRUCTIONS below.

**YOU are the executor. This is NOT an autonomous subprocess.**

- ✅ The phases below are YOUR execution checklist
- ✅ YOU must run each phase immediately using tools (Bash, Read, Write, Edit, TodoWrite)
- ✅ Complete ALL phases before considering this command done
- ❌ DON't wait for "the command to complete" - YOU complete it by executing the phases
- ❌ DON't treat this as status output - it IS your instruction set

**Immediately after SlashCommand returns, start executing Phase 0, then Phase 1, etc.**

See `@CLAUDE.md` section "SlashCommand Execution - YOU Are The Executor" for detailed explanation.

---


**Arguments**: $ARGUMENTS

Goal: Deploy new version with progressive traffic rollout and automatic rollback on failure detection

Core Principles:
- Progressive rollout minimizes risk exposure
- Monitor health metrics at each traffic percentage
- Auto-rollback on threshold violations
- Track rollout progress with TodoWrite

Phase 1: Discovery
Goal: Understand deployment target and current production state

Actions:
- Create comprehensive todo list using TodoWrite:
  - Phase 1: Discover target and validate prerequisites
  - Phase 2: Deploy canary version (0% traffic)
  - Phase 3: Progressive traffic rollout (10% → 50% → 100%)
  - Phase 4: Monitor health metrics and rollback if needed
  - Phase 5: Finalize deployment or rollback
- Parse $ARGUMENTS for deployment target (default to current directory)
- Detect project type: !{bash ls -1 package.json next.config.js vercel.json .mcp.json 2>/dev/null}
- Detect platform linkage:
  - Vercel: !{bash [ -f ".vercel/project.json" ] && cat .vercel/project.json | jq -r '.projectId'}
  - DigitalOcean: !{bash [ -f ".do/config.yml" ] && cat .do/config.yml | grep app_id}
- Get current production deployment:
  - Vercel: !{bash vercel ls --prod --token "$VERCEL_TOKEN" | head -5}
  - DigitalOcean: !{bash doctl apps list-deployments "$APP_ID" --format ID,Phase | head -3}
- Validate prerequisites: CLI tools, authentication, project linkage
- Update todos

Phase 2: Canary Deployment
Goal: Deploy new version without traffic

Actions:
- Build and deploy canary version with zero traffic:
  - Vercel: !{bash vercel --prod --token "$VERCEL_TOKEN"}
  - DigitalOcean: !{bash doctl apps create-deployment "$APP_ID"}
- Capture canary deployment URL and ID
- Wait for deployment completion: !{bash sleep 30}
- Verify canary is accessible: !{bash curl -f "$CANARY_URL" > /dev/null && echo "✅ Canary accessible"}
- Run smoke tests on canary:
  - Health endpoint: !{bash curl -f "$CANARY_URL/health" || curl -f "$CANARY_URL/api/health"}
  - Basic functionality checks
- Update todos

Phase 3: Progressive Traffic Rollout
Goal: Gradually shift traffic while monitoring metrics

Actions:
- Rollout Step 1: 10% traffic to canary
  - Vercel: Configure traffic split via Vercel API
  - DigitalOcean: Use App Platform traffic routing
  - Wait and monitor: !{bash sleep 60}
  - Check error rate: !{bash curl "$DEPLOYMENT_URL/metrics" | jq '.error_rate'}
  - If error_rate > 5%: ABORT rollout, proceed to rollback
  - Update todos

- Rollout Step 2: 50% traffic to canary
  - Increase traffic split to 50%
  - Wait and monitor: !{bash sleep 120}
  - Check metrics: error rate, latency p95, CPU usage
  - If any threshold violated: ABORT rollout, proceed to rollback
  - Update todos

- Rollout Step 3: 100% traffic to canary
  - Complete traffic migration
  - Wait and monitor: !{bash sleep 60}
  - Final metrics check
  - If issues detected: Immediate rollback
  - Update todos

Phase 4: Health Monitoring
Goal: Continuous monitoring during rollout with auto-rollback triggers

Actions:
- Define rollback thresholds:
  - Error rate: > 5%
  - Latency p95: > 2000ms
  - CPU usage: > 90%
  - Memory usage: > 90%
- Monitor during each rollout step
- If ANY threshold violated:
  - Log violation details
  - Trigger immediate rollback
  - Skip to Phase 5 with rollback flag
- Update todos

Phase 5: Finalization or Rollback
Goal: Complete successful deployment or rollback to previous version

Actions:
- Check rollout status from Phase 3 and Phase 4
- If successful (all traffic migrated, metrics healthy):
  - Mark canary as production
  - Decommission previous version
  - Update deployment records
  - Mark todos complete
  - Report success with new deployment URL

- If rollback triggered:
  - Revert traffic to previous production (100%)
  - Verify previous version health
  - Mark canary deployment as failed
  - Generate rollback report with violation details
  - Suggest fixes based on observed metrics
  - Mark todos complete with rollback status

Phase 6: Summary
Goal: Report deployment outcome and next steps

Actions:
- Display deployment summary:
  - **Target**: $ARGUMENTS
  - **Platform**: Vercel/DigitalOcean/Railway
  - **Outcome**: Success or Rollback
  - **Canary URL**: $CANARY_URL
  - **Production URL**: $PRODUCTION_URL
  - **Traffic Split History**: 0% → 10% → 50% → 100% (or rollback point)
  - **Final Metrics**: Error rate, latency, resource usage

- If successful:
  - Congratulate on successful canary deployment
  - Provide monitoring URLs for continued observation
  - Suggest: Monitor for next 24 hours

- If rolled back:
  - Explain why rollback occurred (threshold violations)
  - Show metric comparison: canary vs previous
  - Provide troubleshooting steps:
    1. Review application logs: !{bash vercel logs --token "$VERCEL_TOKEN"}
    2. Check error patterns in monitoring
    3. Fix issues in code
    4. Retry canary deployment after fixes

- Mark all todos complete
