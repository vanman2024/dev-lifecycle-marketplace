---
description: Test if agents can execute slash commands
argument-hint: none
allowed-tools: Task, Read, Write, Bash
---

Goal: Test whether agents invoked via Task tool can execute slash commands

Phase 1: Launch Test Agent

Invoke the test-slash-executor agent:

```
Task(
  description="Test slash command execution",
  subagent_type="quality:test-slash-executor",
  prompt="You are the test-slash-executor agent. Execute your test procedure to determine if agents can run slash commands."
)
```

Phase 2: Analyze Results

After the agent completes, check what happened:
- Did the agent successfully execute /foundation:detect?
- Was .claude/project.json created/updated?
- What errors (if any) were reported?

Phase 3: Report Findings

Display clear results:
- ✅ Agents CAN execute slash commands (show evidence)
- ❌ Agents CANNOT execute slash commands (show error messages)
- 📋 Implications for validator design

This test will determine our implementation strategy for validators.
