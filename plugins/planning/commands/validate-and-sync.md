---
description: Validate architecture docs and sync to Mem0 if ready
argument-hint: [--force]
allowed-tools: Task, Bash, AskUserQuestion, TodoWrite
---

**Arguments**: $ARGUMENTS

Goal: Ensure only validated, quality documentation is synced to Mem0. Prevents garbage data by validating architecture, ADRs, and specs before storing relationships.

Core Principles:
- Quality gate before Mem0 sync
- Multi-agent validation (technical + security + completeness)
- User control over sync decision
- Clear visibility into doc quality

Phase 1: Validation (Multi-Agent)
Goal: Validate all documentation using multiple specialized agents

Actions:
- Create todo list: !{TodoWrite}
- Parse $ARGUMENTS for --force flag

Task(description="Technical validation", subagent_type="planning:technical-validator", prompt="Validate all architecture documentation in docs/architecture/, docs/adr/.

Check for:
- Architecture completeness (diagrams, component descriptions)
- Cross-references validity (links between docs)
- Mermaid diagram syntax
- Technical quality

Generate validation report:
TECHNICAL_SCORE: XX%
ISSUES: [list or 'None']
WARNINGS: [list or 'None']")

Task(description="Security validation", subagent_type="quality:agent-auditor", prompt="Scan all documentation for security issues.

Check for:
- Hardcoded API keys or secrets
- Exposed credentials in examples
- Security vulnerabilities in architecture

Generate security report:
SECURITY_SCORE: XX%
CRITICAL: [list or 'None']
WARNINGS: [list or 'None']")

Task(description="Completeness validation", subagent_type="planning:spec-analyzer", prompt="Analyze documentation completeness.

Check:
- All specs have architecture references
- ADRs reference affected specs
- Architecture docs reference relevant ADRs
- No orphaned documents

Generate completeness report:
COMPLETENESS_SCORE: XX%
MISSING: [list or 'None']
RECOMMENDATIONS: [list]")

- Update todo: "Validation complete"

Phase 2: Calculate Overall Score
Goal: Combine validation results into overall score

Actions:
- Parse scores from all three agents
- Calculate: OVERALL_SCORE = (TECHNICAL + SECURITY + COMPLETENESS) / 3
- Determine status:
  * < 70%: NOT_READY
  * 70-89%: WARNING
  * 90%+: READY

- Display validation report:
  ```
  📊 Validation Report
  ═══════════════════
  Technical:     XX% ✅/⚠️/❌
  Security:      XX% ✅/⚠️/❌
  Completeness:  XX% ✅/⚠️/❌
  ─────────────────────
  Overall:       XX%

  Status: READY/WARNING/NOT_READY
  ```

Phase 3: Decision Gate
Goal: Determine if sync should proceed

Actions:
- **If --force flag present**:
  - Display: "⚠️  --force flag detected. Skipping validation gate."
  - Skip to Phase 4

- **If score < 70% (NOT_READY)**:
  - Display: "❌ Documentation not ready for Mem0 sync"
  - Display: "Critical issues must be fixed:"
  - List all CRITICAL and major ISSUES
  - Display: "Recommendations:"
  - List top 3 recommendations
  - Display: "Run /planning:validate-and-sync again after fixes"
  - EXIT (do not sync)

- **If score 70-89% (WARNING)**:
  - Display: "⚠️  Documentation has warnings but is acceptable"
  - Display: "Warnings found:"
  - List WARNINGS
  - Use AskUserQuestion: "Sync to Mem0 anyway?"
    * Yes → Continue to Phase 4
    * No → EXIT

- **If score 90%+ (READY)**:
  - Display: "✅ Documentation validated successfully!"
  - Use AskUserQuestion: "Sync to Mem0?"
    * Yes → Continue to Phase 4
    * No → EXIT

Phase 4: Sync to Mem0
Goal: Execute doc-sync script

Actions:
- Display: "🔄 Syncing documentation to Mem0..."
- Run sync script:
  !{bash ~/.claude/venv/bin/python ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/doc-sync/scripts/sync-to-mem0.py}

- If sync successful:
  - Display: "✅ Documentation synced to Mem0"
- If sync failed:
  - Display: "❌ Sync failed. Check error above."
  - EXIT

Phase 5: Summary
Goal: Report final results

Actions:
- Mark todos complete
- Display: ""
- Display: "═══════════════════════════════════════"
- Display: "✅ Validation & Sync Complete"
- Display: "═══════════════════════════════════════"
- Display: ""
- Display: "📊 Final Scores:"
- Display: "   Technical:     XX%"
- Display: "   Security:      XX%"
- Display: "   Completeness:  XX%"
- Display: "   Overall:       XX%"
- Display: ""
- Display: "📝 Documents Synced:"
- Display: "   Architecture docs: XX"
- Display: "   ADRs: XX"
- Display: "   Specs: XX"
- Display: ""
- Display: "🔍 Query relationships:"
- Display: "   ~/.claude/venv/bin/python ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/doc-sync/scripts/query-relationships.py \"your question\""
- Display: ""
- Display: "Next sync: /planning:validate-and-sync"
- Display: ""

**Error Handling:**
- Validation agents fail → Show error, suggest manual validation
- Score calculation fails → Default to WARNING status
- Mem0 sync fails → Show error, provide sync script path for manual run
- No docs found → Warn and exit
