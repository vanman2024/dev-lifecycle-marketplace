---
allowed-tools: Task, Read, Write, Edit, Bash, Grep, Glob, SlashCommand, AskUserQuestion
description: Initialize complete project foundation - chains init, detect, git-setup, mcp-setup based on context
argument-hint: [--skip-git] [--skip-mcp] [--force]
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

## Step 1: Detect Project State

Check what exists in the current project:

!{bash ls -la .claude/project.json .git package.json requirements.txt Cargo.toml go.mod 2>/dev/null | head -20 || echo "Checking project structure..."}

## Step 2: Determine What to Initialize

Based on what exists, determine which commands to run:

**Detection Logic:**
- If `.claude/project.json` missing → Run `/core:detect` OR `/core:init`
- If `.git/` missing → Run `/core:git-setup`
- If MCP not configured → Run `/core:mcp-setup`

## Step 3: Run Detection or Initialization

If `.claude/project.json` does NOT exist:

**Ask user:**
- "No project configuration detected. Would you like to:"
  - Option 1: Detect existing project (if package.json/requirements.txt/etc. exists)
  - Option 2: Bootstrap new project (create from scratch)

If user chooses **Detect existing**:

SlashCommand: /core:detect

Wait for detection to complete.

If user chooses **Bootstrap new**:

SlashCommand: /core:init

Wait for initialization to complete.

If `.claude/project.json` ALREADY exists:
- Skip to Step 4 (detection already done)

## Step 4: Setup Git (Conditional)

If `.git/` directory does NOT exist AND `$ARGUMENTS` does NOT contain `--skip-git`:

SlashCommand: /core:git-setup

Wait for git setup to complete.

If `$ARGUMENTS` contains `--skip-git`:
- Skip git setup

## Step 5: Configure MCP (Conditional)

If `$ARGUMENTS` does NOT contain `--skip-mcp`:

Check if MCP is already configured:

!{bash test -f ~/.claude/claude_desktop_config.json && echo "MCP_CONFIGURED" || echo "MCP_NOT_CONFIGURED"}

If MCP_NOT_CONFIGURED:

SlashCommand: /core:mcp-setup

Wait for MCP setup to complete.

If `$ARGUMENTS` contains `--skip-mcp`:
- Skip MCP setup

## Step 6: Report Foundation Status

Display comprehensive summary:

**Project Foundation Initialized:**
- ✅ Project detected/initialized (.claude/project.json)
- ✅ Git configured (if ran)
- ✅ MCP environment setup (if ran)

**Next Steps:**
- Review `.claude/project.json` to verify detected framework/stack
- Use `/core:mcp-info` to see available MCP servers
- Run `/planning:plan` to create implementation plans
- Run `/develop:feature` to start building

**Project Ready for Development** 🚀
