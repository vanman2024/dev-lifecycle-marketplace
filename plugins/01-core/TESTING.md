# Universal MCP Registry Testing Checklist

**Plugin**: 01-core
**Feature**: Universal MCP Server Registry
**Date**: 2025-10-22

## Prerequisites

- [ ] Running from `/home/gotime2022/Projects/project-automation`
- [ ] Have 40+ HTTP MCP servers in `/home/gotime2022/Projects/Mcp-Servers/`
- [ ] `jq` installed (`which jq` should return `/usr/bin/jq`)
- [ ] Clean state (no existing registry)

## Test 1: Initialize Registry

**Command:**
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh
```

**Expected Output:**
```
✅ Created registry directory: /home/gotime2022/.claude/mcp-registry
✅ Created servers registry: /home/gotime2022/.claude/mcp-registry/servers.json
✅ Created README: /home/gotime2022/.claude/mcp-registry/README.md
✅ Created backups directory
```

**Verify:**
- [ ] Directory exists: `ls -la ~/.claude/mcp-registry`
- [ ] servers.json created: `cat ~/.claude/mcp-registry/servers.json`
- [ ] Should show empty servers object: `{"_meta": {...}, "servers": {}}`

---

## Test 2: Add stdio Server Manually

**Command:**
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh filesystem \
  --transport stdio \
  --command npx \
  --args "-y,@modelcontextprotocol/server-filesystem,/home/gotime2022" \
  --description "Local filesystem access"
```

**Expected Output:**
```
✅ Server Added to Registry
Server: filesystem
Transport: stdio
```

**Verify:**
- [ ] Check registry: `jq '.servers.filesystem' ~/.claude/mcp-registry/servers.json`
- [ ] Should show stdio server with command and args

---

## Test 3: Add http-local Server Manually

**Command:**
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh figma-mcp \
  --transport http-local \
  --path /home/gotime2022/Projects/Mcp-Servers/figma-mcp \
  --command "python src/figma_server.py" \
  --url http://localhost:8031 \
  --env "FIGMA_ACCESS_TOKEN=\${FIGMA_ACCESS_TOKEN}"
```

**Expected Output:**
```
✅ Server Added to Registry
Server: figma-mcp
Transport: http-local
```

**Verify:**
- [ ] Check registry: `jq '.servers."figma-mcp"' ~/.claude/mcp-registry/servers.json`
- [ ] Should show http-local with path, command, url, env

---

## Test 4: Add http-remote-auth Server Manually

**Command:**
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh github-copilot \
  --transport http-remote-auth \
  --url "https://api.githubcopilot.com/mcp/" \
  --header "Authorization: Bearer \${GITHUB_TOKEN}" \
  --description "GitHub Copilot MCP API"
```

**Expected Output:**
```
✅ Server Added to Registry
Server: github-copilot
Transport: http-remote-auth
```

**Verify:**
- [ ] Check registry: `jq '.servers."github-copilot"' ~/.claude/mcp-registry/servers.json`
- [ ] Should show http-remote-auth with httpUrl and headers

---

## Test 5: List All Servers in Registry

**Command:**
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh
```

**Expected Output:**
```
MCP Server Registry
Total servers: 3

SERVER                         TRANSPORT            DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
filesystem                     stdio                command: npx
figma-mcp                      http-local           http://localhost:8031
github-copilot                 http-remote-auth     https://api.githubcopilot.com/mcp/ (authenticated)
```

**Verify:**
- [ ] All 3 servers listed
- [ ] Colors displayed correctly (stdio=green, http-local=yellow, http-remote-auth=cyan)
- [ ] Transport types shown correctly

---

## Test 6: Filter Servers by Transport Type

**Command:**
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh --filter stdio
```

**Expected Output:**
```
Only shows stdio servers (filesystem)
```

**Verify:**
- [ ] Only filesystem server shown
- [ ] figma-mcp and github-copilot not shown

---

## Test 7: Add Servers to Project (.mcp.json)

**Setup:**
```bash
cd /tmp/test-project
mkdir -p .
echo '{"mcpServers":{}}' > .mcp.json
```

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh project filesystem figma-mcp
```

**Expected Output:**
```
✅ Transform Complete
Tool: project
Servers added: 2
Target file: .mcp.json
```

**Verify:**
- [ ] Check .mcp.json: `cat .mcp.json | jq`
- [ ] Should have filesystem and figma-mcp in mcpServers
- [ ] stdio server has command + args
- [ ] http-local server has url

---

## Test 8: Transform to Gemini Format

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh gemini filesystem
```

**Expected Output:**
```
✅ Transform Complete
Tool: gemini
Servers added: 1
Target file: /home/gotime2022/.gemini/settings.json
```

**Verify:**
- [ ] Backup created in `~/.gemini/backups/`
- [ ] filesystem added to settings.json under mcpServers
- [ ] Original settings preserved (autoApproval, ideMode, etc.)

---

## Test 9: Transform to Codex TOML Format

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/transform-toml.sh filesystem
```

**Expected Output:**
```
✅ Transform Complete
Tool: Codex
Servers added: 1
Target file: /home/gotime2022/.codex/config.toml
```

**Verify:**
- [ ] Backup created in `~/.codex/backups/`
- [ ] New section added: `[mcp_servers.filesystem]`
- [ ] TOML format: `command = "npx"` and `args = ["-y", "..."]`

---

## Test 10: Transform to VS Code Format

**Setup:**
```bash
cd /tmp/test-project
mkdir -p .vscode
echo '{"servers":{}}' > .vscode/mcp.json
```

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/transform-vscode.sh figma-mcp
```

**Expected Output:**
```
✅ Transform Complete
Tool: VS Code
Servers added: 1
Target file: .vscode/mcp.json
```

**Verify:**
- [ ] Check .vscode/mcp.json: `cat .vscode/mcp.json | jq`
- [ ] Uses "servers" key (not "mcpServers")
- [ ] figma-mcp added with url

---

## Test 11: Scan Existing HTTP MCP Servers (SKIP IF HANGS)

**Command:**
```bash
timeout 30 bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/registry-scan.sh /home/gotime2022/Projects/Mcp-Servers
```

**Expected Output:**
```
Scanning for MCP servers in: /home/gotime2022/Projects/Mcp-Servers
[SCAN] Found: figma-mcp
  ✅ Added: figma (http-local, port 8031)
[SCAN] Found: github-http-mcp
  ✅ Added: github (http-local, port 8032)
...
✅ Scan Complete
Servers found: 40+
Servers added to registry: 40+
```

**Verify:**
- [ ] Multiple servers detected
- [ ] Ports auto-detected from config files
- [ ] All added to registry

**Note:** If this hangs, skip and move to Test 12

---

## Test 12: Error Cases

### Test 12a: Add Duplicate Server

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh filesystem \
  --transport stdio \
  --command npx \
  --args "-y,@modelcontextprotocol/server-filesystem,/home"
```

**Expected Output:**
```
⚠️  Server 'filesystem' already exists in registry
Do you want to overwrite? (y/N)
```

**Verify:**
- [ ] Prompts for confirmation
- [ ] Type 'N' and it should cancel

### Test 12b: Missing Required Arguments

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh test-server --transport stdio
```

**Expected Output:**
```
❌ ERROR: --command is required for stdio transport
```

**Verify:**
- [ ] Error message shown
- [ ] Script exits with error

### Test 12c: Invalid Transport Type

**Command:**
```bash
bash /home/gotime2022/Projects/project-automation/plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh test-server --transport invalid
```

**Expected Output:**
```
❌ ERROR: Invalid transport type: invalid
Valid types: stdio, http-local, http-remote, http-remote-auth
```

**Verify:**
- [ ] Error message shown
- [ ] Script exits with error

---

## Test 13: Cleanup and Reset

**Command:**
```bash
# Backup existing registry
mv ~/.claude/mcp-registry ~/.claude/mcp-registry.backup-testing

# Clean test directory
rm -rf /tmp/test-project
```

**Verify:**
- [ ] Registry backed up
- [ ] Can reinitialize fresh registry if needed

---

## Summary Checklist

### Core Functionality
- [ ] Registry initialization works
- [ ] Can add stdio servers manually
- [ ] Can add http-local servers manually
- [ ] Can add http-remote-auth servers manually
- [ ] Can list all servers
- [ ] Can filter servers by transport type

### Transform Scripts
- [ ] Transform to Claude Code (.mcp.json) works
- [ ] Transform to Gemini (settings.json) works
- [ ] Transform to Codex (config.toml) works
- [ ] Transform to VS Code (.vscode/mcp.json) works

### Error Handling
- [ ] Duplicate detection works
- [ ] Missing required arguments caught
- [ ] Invalid transport types rejected

### File Operations
- [ ] Backups created correctly
- [ ] JSON formatting preserved
- [ ] TOML formatting correct

---

## Known Issues

1. **registry-scan.sh may hang** - If scanning /Projects/Mcp-Servers hangs after 30 seconds, skip Test 11
2. **jq dependency** - All scripts require jq installed at /usr/bin/jq

---

## Success Criteria

✅ **PASS**: All non-skipped tests complete successfully
✅ **PASS**: Registry contains added servers
✅ **PASS**: Transform scripts generate valid config files
✅ **PASS**: Error cases handled gracefully

---

## Test Results

**Date Tested**: ___________
**Tested By**: ___________
**Result**: [ ] PASS / [ ] FAIL
**Notes**:

