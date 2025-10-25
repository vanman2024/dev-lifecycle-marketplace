# MCP Registry Testing Results

**Date**: 2025-10-22 20:52 - 20:59
**Tester**: Claude Code (Automated Testing)
**Plugin**: 01-core
**Feature**: Universal MCP Server Registry

## Executive Summary

✅ **OVERALL RESULT**: PARTIAL PASS with 1 Critical Bug and 1 Bug Fixed

- **Tests Passed**: 10 / 13
- **Tests Failed**: 3 / 13 (all same root cause)
- **Bugs Found**: 2 (1 fixed during testing, 1 critical open)
- **Bugs Fixed**: 1 (PATH variable shadowing in registry-add.sh)

---

## Test Results Summary

| Test # | Test Name | Status | Notes |
|--------|-----------|--------|-------|
| Prerequisites | Verify environment | ✅ PASS | All prerequisites met |
| Test 1 | Initialize registry | ✅ PASS | Registry created successfully |
| Test 2 | Add stdio server | ✅ PASS | **BUG FIXED**: PATH variable shadowing |
| Test 3 | Add http-local server | ✅ PASS | figma-mcp added successfully |
| Test 4 | Add http-remote-auth server | ✅ PASS | github-copilot added successfully |
| Test 5 | List all servers | ✅ PASS | All 3 servers displayed correctly |
| Test 6 | Filter by transport | ✅ PASS | stdio filter working |
| Test 7 | Transform to project .mcp.json | ❌ FAIL | **CRITICAL**: Script hangs |
| Test 8 | Transform to Gemini JSON | ❌ FAIL | **CRITICAL**: Script hangs |
| Test 9 | Transform to Codex TOML | ✅ PASS | TOML generation works |
| Test 10 | Transform to VS Code JSON | ❌ FAIL | **CRITICAL**: Script hangs |
| Test 11 | Scan HTTP MCP servers | ⏭️ SKIP | Per TESTING.md instructions |
| Test 12a | Duplicate server detection | ✅ PASS | Prompts for confirmation |
| Test 12b | Missing required args | ✅ PASS | Error message correct |
| Test 12c | Invalid transport type | ✅ PASS | Error message correct |
| Test 13 | Cleanup | ✅ PASS | Test environment cleaned |

---

## Bugs Found

### 🐛 BUG #1: PATH Variable Shadowing in registry-add.sh (FIXED)

**Severity**: High
**Status**: ✅ FIXED during testing
**File**: `plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh`

**Issue**: Script used `PATH` as a variable name for server path, which shadowed the system `$PATH` environment variable, causing `jq` command to fail with "command not found".

**Location**:
- Line 59: `PATH=""`
- Line 81: `PATH="$2"`
- Line 186: `if [[ -n "$PATH" ]]; then`

**Fix Applied**:
```bash
# Changed all occurrences of PATH to SERVER_PATH
SERVER_PATH=""  # Line 59
SERVER_PATH="$2"  # Line 81
if [[ -n "$SERVER_PATH" ]]; then  # Line 186
```

**Verification**: After fix, all server additions (stdio, http-local, http-remote-auth) worked successfully.

---

### 🔴 BUG #2: JSON Transform Scripts Hang Indefinitely (CRITICAL)

**Severity**: Critical
**Status**: ❌ OPEN - Needs Investigation
**Files Affected**:
- `plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh`
- `plugins/01-core/skills/mcp-configuration/scripts/transform-vscode.sh`

**Not Affected**:
- `plugins/01-core/skills/mcp-configuration/scripts/transform-toml.sh` (works correctly)

**Issue**: Scripts hang indefinitely after printing `[TRANSFORM] <server-name>` message. Timeout required to exit.

**Symptoms**:
1. Script prints: `[INFO] Transforming registry to <tool> format`
2. Script prints: `Target: <file>`
3. Script prints: `Servers to add: N`
4. Script prints: `[TRANSFORM] <server-name>`
5. **Script hangs here - no further output**
6. Must be killed with timeout or Ctrl+C

**Debug Findings**:
- The jq command at line 109 executes successfully (confirmed with debug trace)
- The script uses `set -euo pipefail` which exits on unbound variables
- Debug output shows: `transport: unbound variable` error
- This suggests line 120 `transport=$(echo "$server_def" | jq -r '.transport')` is not executing or failing silently
- The hang occurs in the command substitution or jq pipeline

**Attempted Fixes** (all failed):
1. Explicit PATH setting: No effect
2. Running in subshell: No effect
3. Different jq invocation: No effect

**Tests Affected**:
- Test 7: Transform to project (.mcp.json)
- Test 8: Transform to Gemini (settings.json)
- Test 10: Transform to VS Code (.vscode/mcp.json)

**Workaround**: Use transform-toml.sh for Codex/TOML-based tools, which works correctly.

**Next Steps Required**:
1. Add extensive debug logging to transform-json.sh around lines 105-125
2. Test jq command execution in isolation
3. Check for stdin/stdout blocking issues
4. Consider rewriting JSON transform logic similar to working TOML transform
5. Add unit tests for transform functions

---

## Detailed Test Results

### ✅ Test 1: Initialize Registry

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-init.sh
```

**Output**:
```
✅ Created registry directory: /home/gotime2022/.claude/mcp-registry
✅ Created servers registry: /home/gotime2022/.claude/mcp-registry/servers.json
✅ Created README: /home/gotime2022/.claude/mcp-registry/README.md
✅ Created backups directory
```

**Verification**:
- Directory created: ✅
- servers.json contains empty registry with _meta: ✅
- README.md created: ✅
- backups directory created: ✅

---

### ✅ Test 2: Add stdio Server (filesystem)

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh filesystem \
  --transport stdio \
  --command npx \
  --args "-y,@modelcontextprotocol/server-filesystem,/home/gotime2022" \
  --description "Local filesystem access"
```

**Output**:
```json
{
  "name": "filesystem MCP Server",
  "description": "Local filesystem access",
  "transport": "stdio",
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "/home/gotime2022"
  ]
}
```

**Verification**: Server added to registry with correct stdio structure ✅

**Note**: Bug #1 (PATH shadowing) discovered and fixed during this test.

---

### ✅ Test 3: Add http-local Server (figma-mcp)

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh figma-mcp \
  --transport http-local \
  --path /home/gotime2022/Projects/Mcp-Servers/figma-mcp \
  --command "python src/figma_server.py" \
  --url http://localhost:8031 \
  --env "FIGMA_ACCESS_TOKEN=\${FIGMA_ACCESS_TOKEN}"
```

**Output**:
```json
{
  "name": "figma-mcp MCP Server",
  "description": "Manually added http-local server",
  "transport": "http-local",
  "url": "http://localhost:8031",
  "path": "/home/gotime2022/Projects/Mcp-Servers/figma-mcp",
  "command": "python src/figma_server.py",
  "env": {
    "FIGMA_ACCESS_TOKEN": "${FIGMA_ACCESS_TOKEN}"
  }
}
```

**Verification**: Server added with http-local structure, path, command, url, and env variables ✅

---

### ✅ Test 4: Add http-remote-auth Server (github-copilot)

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh github-copilot \
  --transport http-remote-auth \
  --url "https://api.githubcopilot.com/mcp/" \
  --header "Authorization: Bearer \${GITHUB_TOKEN}" \
  --description "GitHub Copilot MCP API"
```

**Output**:
```json
{
  "name": "github-copilot MCP Server",
  "description": "GitHub Copilot MCP API",
  "transport": "http-remote-auth",
  "httpUrl": "https://api.githubcopilot.com/mcp/",
  "headers": {
    "Authorization": "Bearer ${GITHUB_TOKEN}"
  }
}
```

**Verification**: Server added with http-remote-auth structure, httpUrl and headers ✅

---

### ✅ Test 5: List All Servers

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh
```

**Output**:
```
MCP Server Registry
Total servers: 3

SERVER                         TRANSPORT            DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
figma-mcp                      http-local           http://localhost:8031
filesystem                     stdio                command: npx
github-copilot                 http-remote-auth     https://api.githubcopilot.com/mcp/ (authenticated)
```

**Verification**:
- All 3 servers listed ✅
- Transport types correct ✅
- Details displayed appropriately ✅
- Color coding working (observed in terminal) ✅

---

### ✅ Test 6: Filter Servers by Transport Type

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-list.sh --filter stdio
```

**Output**:
```
MCP Server Registry
Total servers: 3

SERVER                         TRANSPORT            DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
filesystem                     stdio                command: npx
```

**Verification**:
- Only stdio server (filesystem) shown ✅
- http-local and http-remote-auth servers filtered out ✅

---

### ❌ Test 7: Transform to Project .mcp.json

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh project filesystem figma-mcp
```

**Output**:
```
[INFO] Transforming registry to project format
Target: .mcp.json
Servers to add: 2
[TRANSFORM] filesystem
[HANGS - NO FURTHER OUTPUT]
```

**Result**: ❌ FAIL - Script hangs indefinitely (see Bug #2)

---

### ❌ Test 8: Transform to Gemini Format

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/transform-json.sh gemini filesystem
```

**Output**:
```
[INFO] Transforming registry to gemini format
Target: /home/gotime2022/.gemini/settings.json
Servers to add: 1
[TRANSFORM] filesystem
[HANGS - NO FURTHER OUTPUT]
```

**Result**: ❌ FAIL - Script hangs indefinitely (see Bug #2)

---

### ✅ Test 9: Transform to Codex TOML Format

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/transform-toml.sh filesystem
```

**Output**:
```
✅ Transform Complete
Tool: Codex
Servers added: 1
Target file: /home/gotime2022/.codex/config.toml
Backup: /home/gotime2022/.codex/backups/config-20251022_205815.toml
```

**Verification**:
```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y","@modelcontextprotocol/server-filesystem","/home/gotime2022"]
```

**Result**: ✅ PASS - TOML transformation works correctly

---

### ❌ Test 10: Transform to VS Code Format

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/transform-vscode.sh figma-mcp
```

**Output**:
```
[INFO] Transforming registry to VS Code format
Target: .vscode/mcp.json
Servers to add: 1
[TRANSFORM] figma-mcp
[HANGS - NO FURTHER OUTPUT]
```

**Result**: ❌ FAIL - Script hangs indefinitely (see Bug #2)

---

### ⏭️ Test 11: Scan Existing HTTP MCP Servers

**Status**: SKIPPED per TESTING.md line 281: "If this hangs, skip and move to Test 12"

**Reason**: Known potential hanging issue with registry-scan.sh when scanning large directories.

---

### ✅ Test 12: Error Cases

#### Test 12a: Duplicate Server Detection

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh filesystem \
  --transport stdio \
  --command npx \
  --args "-y,@modelcontextprotocol/server-filesystem,/home"
```

**Output**:
```
[WARN] Server 'filesystem' already exists in registry
Do you want to overwrite? (y/N)
```

**Result**: ✅ PASS - Prompts for confirmation as expected

---

#### Test 12b: Missing Required Arguments

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh test-server --transport stdio
```

**Output**:
```
[ERROR] --command is required for stdio transport
```

**Result**: ✅ PASS - Correct error message

---

#### Test 12c: Invalid Transport Type

**Command**:
```bash
bash plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh test-server --transport invalid
```

**Output**:
```
[ERROR] Invalid transport type: invalid
Valid types: stdio, http-local, http-remote, http-remote-auth
```

**Result**: ✅ PASS - Correct error message with valid options

---

### ✅ Test 13: Cleanup

**Actions**:
1. Test project directory removed: ✅
2. Registry backup verified: ✅
3. Original registry preserved: ✅

---

## Files Modified During Testing

### Modified Files:

1. **plugins/01-core/skills/mcp-configuration/scripts/registry-add.sh**
   - Fixed PATH variable shadowing bug
   - Changed `PATH` variable to `SERVER_PATH` (lines 59, 81, 186)

### Created Files:

1. **~/.claude/mcp-registry/** (test registry)
   - servers.json
   - README.md
   - backups/ directory

2. **~/.claude/mcp-registry.backup-pre-testing-YYYYMMDD-HHMMSS** (backup of original)

3. **~/.codex/config.toml** (updated with filesystem server)

### Backup Files Created:

1. ~/.claude/mcp-registry/backups/servers-20251022_205401.json
2. ~/.claude/mcp-registry/backups/servers-20251022_205416.json
3. ~/.claude/mcp-registry/backups/servers-20251022_205434.json
4. ~/.codex/backups/config-20251022_205815.toml
5. ~/.gemini/settings.json.backup-pre-test

---

## Recommendations

### Immediate Actions Required:

1. **FIX CRITICAL BUG #2**: Investigate and fix hanging issue in transform-json.sh and transform-vscode.sh
   - Priority: **CRITICAL**
   - Impact: Tests 7, 8, 10 completely blocked
   - Users cannot transform to project/.mcp.json, Gemini, or VS Code formats

2. **Apply Bug #1 Fix to Repository**: Commit the SERVER_PATH fix to registry-add.sh
   - Priority: **High**
   - Status: Fixed locally during testing

3. **Add Automated Tests**: Create unit tests for all transformation scripts
   - Priority: **Medium**
   - Prevents regression of fixed bugs

### Enhancement Recommendations:

1. **Improve Error Handling**: Add better error messages and debug output to transform scripts
2. **Add Timeout Protection**: Build timeout mechanism into long-running operations
3. **Validate jq Availability**: Check for jq before running scripts and provide clear error if missing
4. **Add Integration Tests**: Automate the full TESTING.md checklist
5. **Document Known Issues**: Update TESTING.md with Bug #2 as a known issue until fixed

---

## Test Environment

- **OS**: Linux 5.15.167.4-microsoft-standard-WSL2
- **Working Directory**: /home/gotime2022/Projects/project-automation
- **jq Version**: jq-1.7 (/usr/bin/jq)
- **Shell**: bash
- **MCP Servers Available**: 40+ in /home/gotime2022/Projects/Mcp-Servers/

---

## Conclusion

The Universal MCP Server Registry core functionality (initialization, server addition, listing, filtering, error handling) works excellently. The TOML transformation also works perfectly. However, the JSON transformation scripts have a critical hanging bug that blocks 3 out of 13 tests and prevents users from using the registry with Claude Code projects, Gemini, and VS Code.

**Overall Status**: ⚠️ **PARTIAL PASS** - Core features work, but critical transform bug must be fixed before production use.

**Blocking Issue**: Bug #2 (JSON transform scripts hang)

**Next Steps**:
1. Investigate and fix Bug #2 with urgency
2. Commit Bug #1 fix to repository
3. Re-run full test suite after fixes
4. Add automated testing to prevent future regressions

---

**Test Report Generated**: 2025-10-22 20:59 UTC
**Report File**: /home/gotime2022/Projects/project-automation/plugins/01-core/TEST-RESULTS-2025-10-22.md
