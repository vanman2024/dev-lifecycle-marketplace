---
description: Zero-downtime parallel environment swap deployment
argument-hint: [project-path]
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

Goal: Execute zero-downtime blue-green deployment by deploying to new environment (green) while current environment (blue) serves traffic, then swap after health validation

Core Principles:
- Zero-downtime deployment strategy
- Health check before traffic swap
- Maintain rollback capability via blue environment
- Validate deployment at each step

Phase 1: Discovery
Goal: Understand current deployment state and platform

Actions:
- Create comprehensive todo list using TodoWrite:
  - Phase 1: Discover current deployment state
  - Phase 2: Deploy to green environment (new version)
  - Phase 3: Health check green environment
  - Phase 4: Swap traffic from blue to green
  - Phase 5: Verify and maintain blue as rollback
- Parse $ARGUMENTS for project path (default to current directory if empty)
- Navigate to project: !{bash cd $ARGUMENTS 2>/dev/null || pwd}
- Detect platform and current deployment:
  - Vercel: !{bash vercel inspect $(cat .vercel/project.json | jq -r '.projectId') 2>/dev/null || echo "No deployment"}
  - DigitalOcean: !{bash doctl apps list --format ID,Spec.Name 2>/dev/null}
  - Check deployment metadata: !{bash ls -la .deployment 2>/dev/null}
- Identify current environment (blue):
  - !{bash cat .deployment/current-env 2>/dev/null || echo "blue"}
- Determine target environment (green)
- Update todos to mark discovery complete

Phase 2: Green Environment Deployment
Goal: Deploy new version to green environment without affecting blue

Actions:

Task(description="Deploy new version to green environment", subagent_type="deployment-deployer", prompt="You are the deployment-deployer agent. Deploy new version to GREEN environment for $ARGUMENTS.

Context: Blue-green deployment strategy where:
- BLUE = Current production environment (serving traffic)
- GREEN = New deployment target (isolated, not serving traffic yet)

Requirements:
- Deploy to green environment using platform-specific approach
- For Vercel: Create new deployment with environment GREEN
- For DigitalOcean: Deploy to staging slot or create parallel app
- Capture green deployment URL and metadata
- DO NOT route traffic to green yet
- Save green deployment information to .deployment/green-env

Expected output: Green deployment URL, deployment ID, platform details")

- Wait for deployment agent to complete
- Verify green deployment metadata exists:
  - !{bash test -f .deployment/green-env && echo "Green deployed" || echo "Failed"}
- Extract green URL: !{bash cat .deployment/green-env | grep -oP 'URL: \K.*' || echo "No URL"}
- Update todos to mark green deployment complete

Phase 3: Health Validation
Goal: Verify green environment is healthy before traffic swap

Actions:

Task(description="Validate green environment health", subagent_type="deployment-validator", prompt="You are the deployment-validator agent. Validate GREEN environment health for blue-green deployment swap.

Context: Green environment is deployed and ready. Must verify health before directing production traffic.

Requirements:
- Check green deployment URL accessibility
- Run health endpoint checks (GET /health, GET /api/health)
- Verify critical endpoints respond correctly
- Test application functionality
- Validate response times are acceptable
- Check for errors in deployment logs
- Return PASS/FAIL status with details

Expected output: Health validation report with PASS/FAIL status and detailed checks")

- Wait for validation agent to complete
- Check validation result:
  - !{bash cat .deployment/green-validation 2>/dev/null | grep -q "PASS" && echo "Health check passed" || echo "Health check failed"}
- If validation FAILED:
  - Show validation errors
  - Ask user: Continue anyway or abort?
  - If abort: Keep blue as production, cleanup green
- Update todos to mark health validation complete

Phase 4: Traffic Swap
Goal: Route production traffic from blue to green

Actions:
- Confirm with user before swapping traffic
- Execute platform-specific traffic swap:
  - Vercel: !{bash vercel alias set $(cat .deployment/green-env | grep -oP 'URL: \K.*') $(vercel domains ls --format domain | head -1)}
  - DigitalOcean: !{bash doctl apps update $(cat .deployment/green-env | grep -oP 'APP_ID: \K.*') --spec .do/app.yaml}
  - Update routing configuration to point to green
- Verify traffic routing to green:
  - !{bash curl -f $(cat .deployment/production-url) 2>/dev/null && echo "Production accessible"}
- Monitor for immediate errors (30 seconds):
  - !{bash sleep 30}
  - Check green deployment logs for errors
- Update current environment marker:
  - !{bash echo "green" > .deployment/current-env}
- Update todos to mark traffic swap complete

Phase 5: Rollback Preservation
Goal: Maintain blue environment as rollback option

Actions:
- Save blue environment metadata: !{bash cp .deployment/blue-env .deployment/rollback-env 2>/dev/null}
- Keep blue environment active (do not destroy) for 24 hours
- Create rollback script: !{bash echo "#!/bin/bash" > .deployment/rollback.sh && chmod +x .deployment/rollback.sh}
- Update todos to mark rollback preservation complete

Phase 6: Summary
Goal: Report blue-green deployment completion and next steps

Actions:
- Mark all todos complete
- Display comprehensive summary:
  - Deployment Strategy: Blue-Green (Zero-Downtime)
  - Previous Environment (Blue): URL and status
  - Current Environment (Green): URL and status
  - Production URL: Active URL serving traffic
  - Health Status: PASS/FAIL with details
  - Rollback Available: Yes (blue environment preserved for 24 hours)
- Explain deployment flow:
  - New version deployed to green environment in parallel
  - Health validation passed before traffic swap
  - Traffic swapped from blue to green with zero downtime
  - Blue environment maintained as rollback option
- Provide next steps:
  - Monitor green environment logs and metrics
  - Rollback if needed: /deployment:rollback (within 24 hours)
  - Cleanup blue environment after 24 hours of stable operation
  - Next deployment: Current green becomes blue, new version becomes green
