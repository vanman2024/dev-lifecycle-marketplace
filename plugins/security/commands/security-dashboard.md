---
description: View security reports, audit logs, and security events from security-validation skill
argument-hint: [daily|weekly|query] [--date=YYYY-MM-DD] [--agent=name] [--risk-level=level]
allowed-tools: Bash, Read
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

Goal: Display comprehensive security dashboard with audit logs, security events, and compliance reports

## Phase 1: Parse Arguments

Goal: Determine report type and filters

Actions:
- Parse $ARGUMENTS to extract mode (daily, weekly, query, or default to daily)
- Extract optional flags: --date, --agent, --risk-level
- Default date to today if not specified

## Phase 2: Generate Report

Goal: Query audit logs using security-validation skill

Actions:

**For daily report:**
!{bash python plugins/security/skills/security-validation/scripts/audit-logger.py report --date="$(date +%Y-%m-%d)"}

**For weekly report:**
!{bash for i in {0..6}; do date=$(date -d "$i days ago" +%Y-%m-%d); python plugins/security/skills/security-validation/scripts/audit-logger.py report --date="$date"; done}

**For custom query:**
!{bash python plugins/security/skills/security-validation/scripts/audit-logger.py query --date="$DATE" --agent="$AGENT" --risk-level="$RISK_LEVEL"}

Parse JSON output and aggregate statistics

## Phase 3: Format Dashboard

Goal: Display results as markdown dashboard

Actions:
- Format report with sections: Summary, Security Events, Activity by Agent, Risk Distribution, Recent Critical Events, Compliance Metrics
- Use emojis for severity: 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low
- Show totals, percentages, and trends
- List critical events with timestamps and details
- Calculate compliance metrics (PII masking rate, secret blocking rate)
- Provide actionable recommendations based on patterns

## Phase 4: Display & Options

Goal: Show dashboard and offer drill-down

Actions:
- Display the formatted dashboard
- Show audit log file location: ~/.claude/security/audit-logs/
- Suggest query commands for drill-down
- Offer to export dashboard to markdown file
- Provide cleanup option for old logs: !{bash python plugins/security/skills/security-validation/scripts/audit-logger.py cleanup --days=90}

## Summary

Display completion message with report type, date range, total events, and critical issues count. Suggest next steps for security review.
