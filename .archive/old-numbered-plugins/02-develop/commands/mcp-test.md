---
allowed-tools: Bash, Read, Write, Edit, TodoWrite, Task, Glob, LS, MultiEdit, Grep
description: Comprehensive MCP server testing framework - validates servers thoroughly using FastMCP Client in-memory testing pattern. Executes 4-phase workflow with 32 steps covering functional testing, protocol compliance, and deployment readiness. Uses proven testing patterns that work reliably.
---

# MCP Comprehensive Testing Command

## Context Loading
- Current directory: !`pwd`
- MCP Kernel location: !`cd /home/gotime2022/mcp-kernel-new && pwd`
- Current branch: !`cd /home/gotime2022/mcp-kernel-new && git branch --show-current`
- Running servers: !`cd /home/gotime2022/mcp-kernel-new && ./scripts/mcp-manager.sh status 2>/dev/null | grep "✓ Running"`
- Existing test directories: !`cd /home/gotime2022/mcp-kernel-new && find . -name "test-*" -type d | head -5`

## User Input Gathering

### STEP 1: Ask for Server Information
First, gather the server to test by checking actual server configurations:

**Claude Code, you need to execute the following command to get available servers:**
```
Claude Code, your task is to list all available MCP servers for testing:

1. You (Claude Code) need to run:
   ./scripts/mcp-manager.sh status

2. Show the user which servers are ✓ Running and which are available to start

3. Also list available server directories by running:
   ls -1 /home/gotime2022/mcp-kernel-new/servers/http/ | grep -E "(mcp|http)" | sort

4. Show existing test directories:
   find . -name "test-*" -type d | head -10

Execute these commands using Bash tool and show the results to help the user choose which server to test.
```

After showing the available servers, ask:
```
Which MCP server would you like to test comprehensively?
(Choose from the servers listed above)
```

Store the response as SERVER_NAME for use throughout the workflow.

### STEP 2: Ask for Test Scope Level
```
What level of testing do you want to perform?

1. Quick Smoke Test (5-10 minutes)
   - Basic connectivity and tool discovery
   - Simple function calls
   - Health check validation

2. Standard Test Suite (15-20 minutes) 
   - Core functionality validation
   - Error handling testing
   - Database integration (if applicable)
   - HTTP MCP protocol compliance

3. Comprehensive Test (30-45 minutes)
   - Full integration testing
   - Performance benchmarking
   - Stress testing
   - Multi-session testing

4. Pre-Deployment Validation (60+ minutes)
   - Production readiness validation
   - Security compliance checking
   - Cloud deployment testing
   - Full regression testing

Choose option (1-4):
```
Store as TEST_LEVEL.

### STEP 3: Ask for Test Environment
```
Which environment should be tested?

1. Local only (localhost ports)
2. Cloud only (deployed servers at 137.184.212.136)
3. Both local and cloud environments
4. Staging environment (if available)

Choose option (1-4):
```
Store as TEST_ENV.

### STEP 4: Ask for Test Output Format
```
How should test results be presented?

1. Console output only (real-time results)
2. Generate detailed HTML report
3. Create JSON results file for CI/CD
4. All formats (console + HTML + JSON)

Choose option (1-4):
```
Store as OUTPUT_FORMAT.

### STEP 5: Confirm Testing Plan
```
Comprehensive Testing Plan Summary:
- Server: ${SERVER_NAME}
- Test Level: ${TEST_LEVEL}
- Environment: ${TEST_ENV}
- Output Format: ${OUTPUT_FORMAT}
- Estimated Duration: [varies by level]

This will execute a 4-phase testing workflow:
- Phase 1: Test Environment Setup (Steps 1-8)
- Phase 2: Direct Function Testing (Steps 9-16) 
- Phase 3: HTTP MCP Protocol Testing (Steps 17-24)
- Phase 4: Validation and Reporting (Steps 25-32)

Proceed with comprehensive testing? (y/n)
```

## Workflow Execution

Once user provides SERVER_NAME, TEST_LEVEL, TEST_ENV, and OUTPUT_FORMAT, proceed with the following 4-phase workflow:

### Multi-Agent Parallel Execution

Execute the following workflow in phases:

## PHASE 1: TEST ENVIRONMENT SETUP
**STEP 1**: Create comprehensive TodoWrite for all 32 testing steps
**STEP 2**: Set up test directory with timestamp
**STEP 3**: Verify server availability and configuration
**STEP 4**: Start server if not running (using mcp-manager.sh)
**STEP 5**: Set up Python testing environment and dependencies
**STEP 6**: Create test configuration file with server details
**STEP 7**: Backup existing test results for comparison
**STEP 8**: Initialize test logging and monitoring

## PHASE 2: DIRECT FUNCTION TESTING
**STEP 9**: Create direct testing script using mock patterns
**STEP 10**: Discover all available tools and functions
**STEP 11**: Test each function with valid inputs
**STEP 12**: Test error handling with invalid inputs
**STEP 13**: Validate return types and data structures
**STEP 14**: Test database integration (if applicable)
**STEP 15**: Run performance baseline measurements
**STEP 16**: Generate direct testing report

## PHASE 3: HTTP MCP PROTOCOL TESTING
**STEP 17**: Verify server is running on correct port
**STEP 18**: Test MCP initialization handshake
**STEP 19**: Test tools/list endpoint compliance
**STEP 20**: Test tools/call for each discovered tool
**STEP 21**: Test session management and isolation
**STEP 22**: Run stress testing (based on test level)
**STEP 23**: Test cloud endpoints (if TEST_ENV includes cloud)
**STEP 24**: Generate protocol compliance report

## PHASE 4: VALIDATION AND REPORTING
**STEP 25**: Compile results from all test phases
**STEP 26**: Calculate overall pass/fail rates and metrics
**STEP 27**: Generate deployment readiness assessment
**STEP 28**: Create comprehensive test report (based on OUTPUT_FORMAT)
**STEP 29**: Update server documentation and test database
**STEP 30**: Create deployment artifacts or issue lists
**STEP 31**: Clean up test environment and archive results
**STEP 32**: Provide final testing summary and recommendations

---

## Multi-Agent Task Execution

For comprehensive testing with parallel agents, generate and execute the following Task tool invocations:

```xml
<function_calls>
<!-- Phase 1 Agent: Test Environment Setup -->
<invoke name="Task">
<parameter name="description">Phase 1 Agent - Test Environment Setup for ${SERVER_NAME}</parameter>
<parameter name="prompt">PHASE 1 AGENT - TEST ENVIRONMENT SETUP

CRITICAL: Read these context files FIRST:
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_TESTING_PATTERNS.md
@/home/gotime2022/mcp-kernel-new/servers/http/MCP_TESTING_GUIDE.md
@/home/gotime2022/mcp-kernel-new/servers/http/test_template.py
@/home/gotime2022/mcp-kernel-new/servers/http/TESTING_QUICK_REFERENCE.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_DEPLOYMENT_CONTEXT.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_COMMAND_PATTERNS.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_DYNAMIC_PORT_DISCOVERY.md
- Check existing test files: servers/http/$(get_server_dir ${SERVER_NAME})/test_*.py
- Read successful example: servers/http/digitalocean-http-mcp/test_direct.py

CONFIGURATION:
- Server: ${SERVER_NAME}
- Test Level: ${TEST_LEVEL}
- Test Environment: ${TEST_ENV}  
- Output Format: ${OUTPUT_FORMAT}
- Working Directory: /home/gotime2022/mcp-kernel-new
- Phase: 1 of 4

MISSION: Execute Phase 1 (Steps 1-8) of comprehensive MCP server testing.

TASKS:
1. STEP 1: Create comprehensive TodoWrite tracking all 32 testing steps with phase groupings
2. STEP 2: Set up test directory with timestamp
   - Create directory: test-${SERVER_NAME}-comprehensive-$(date +%Y%m%d_%H%M%S)
   - Set up test structure with subdirectories: direct-tests/, protocol-tests/, reports/
   - Copy any existing test templates
3. STEP 3: Verify server availability and configuration
   - Check server directory: servers/http/$(get_server_dir ${SERVER_NAME})
   - Verify server files exist and are accessible
   - Read server configuration and requirements
4. STEP 4: Ensure server is running for live testing
   - Run: ./scripts/mcp-manager.sh status | grep ${SERVER_NAME}
   - If running: Continue with live testing (no interruption)
   - If NOT running: Start server using ./scripts/mcp-manager.sh start ${SERVER_NAME}
   - Wait for server to be ready and verify port accessibility
   - Once running: Proceed with live testing approach (no further restarts)
5. STEP 5: Set up Python testing environment and dependencies
   - Create virtual environment: python3 -m venv test-env
   - Install packages: httpx, aiohttp, pytest, unittest, requests
   - Set up environment variables for testing
6. STEP 6: Create test configuration file with server details
   - Get port from mcp-manager.sh PORT_MAP
   - Create config.json with server name, port, directory, test parameters
   - Include expected tools list and capabilities
7. STEP 7: Backup existing test results for comparison
   - Find previous test results for this server
   - Create backup directory with timestamps
   - Archive previous results for trend analysis
8. STEP 8: Initialize test logging and monitoring
   - Set up test logging with detailed output
   - Create monitoring for server health during tests
   - Initialize test metrics collection

Create marker file when complete: .test_phase1_complete</parameter>
</invoke>

<!-- Phase 2 Agent: Direct Function Testing -->
<invoke name="Task">
<parameter name="description">Phase 2 Agent - Direct Function Testing for ${SERVER_NAME}</parameter>
<parameter name="prompt">PHASE 2 AGENT - DIRECT FUNCTION TESTING

CRITICAL: Read these context files FIRST:
@/home/gotime2022/mcp-kernel-new/.claude/agents/mcp-tester.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_TESTING_PATTERNS.md
@/home/gotime2022/mcp-kernel-new/servers/http/MCP_TESTING_GUIDE.md
@/home/gotime2022/mcp-kernel-new/servers/http/test_template.py
@/home/gotime2022/mcp-kernel-new/servers/http/TESTING_QUICK_REFERENCE.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_DEPLOYMENT_CONTEXT.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_COMMAND_PATTERNS.md
- Check for existing test_*.py files in server directory
- Use FastMCP Client pattern for ALL functional testing
- Read successful example: servers/http/digitalocean-http-mcp/test_direct.py

IMPORTANT: Follow the mcp-tester agent's process exactly for all testing tasks.

CONFIGURATION:
- Server: ${SERVER_NAME}
- Test Level: ${TEST_LEVEL}
- Working Directory: /home/gotime2022/mcp-kernel-new  
- Phase: 2 of 4

PREREQUISITE: Wait for .test_phase1_complete marker file before starting.

MISSION: Execute Phase 2 (Steps 9-16) of comprehensive MCP server testing using direct function patterns.

CRITICAL TESTING PATTERN (use this exact approach):
```python
#!/usr/bin/env python3
\"\"\"Direct testing without Claude sessions - Universal Pattern\"\"\"
import asyncio
import os
import unittest.mock
import sys
from pathlib import Path

# Set environment variables BEFORE importing server
os.environ.update({
    'GITHUB_TOKEN': os.getenv('GITHUB_TOKEN', 'test-token'),
    'SUPABASE_URL': os.getenv('SUPABASE_URL', 'test-url'),
    'V0_API_KEY': os.getenv('V0_API_KEY', 'test-key')
})

# Mock FastMCP decorators to get raw functions
with unittest.mock.patch('fastmcp.FastMCP.tool', lambda self: lambda f: f):
    with unittest.mock.patch('fastmcp.FastMCP.resource', lambda self, uri: lambda f: f):
        # Import after mocking
        sys.path.insert(0, 'src')
        import server_module as server

class TestResults:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.results = []
    
    def add(self, name: str, passed: bool, details: str = \"\"):
        status = \"✅ PASS\" if passed else \"❌ FAIL\"
        result = f\"{status}: {name}\"
        if details:
            result += f\" - {details}\"
        print(result)
        self.results.append(result)
        if passed:
            self.passed += 1
        else:
            self.failed += 1
```

TASKS:
1. STEP 9: Create direct testing script using mock patterns
   - Navigate to server directory: servers/http/$(get_server_dir ${SERVER_NAME})/src
   - Create test script using the universal mock pattern above
   - Import server module and identify all available functions
2. STEP 10: Discover all available tools and functions
   - Scan for @mcp.tool decorated functions
   - List all available resources and capabilities  
   - Document function signatures and parameters
3. STEP 11: Test each function with valid inputs
   - Create test cases for each discovered function
   - Use realistic test data for each function type
   - Verify functions execute without errors
4. STEP 12: Test error handling with invalid inputs
   - Test each function with missing parameters
   - Test with invalid parameter types
   - Verify proper error responses
5. STEP 13: Validate return types and data structures
   - Check return value types match expectations
   - Validate JSON structure compliance
   - Test data format consistency
6. STEP 14: Test database integration (if applicable)  
   - Test database connections (Supabase, etc.)
   - Validate SQL queries and operations
   - Test CRUD operations if server supports them
7. STEP 15: Run performance baseline measurements
   - Measure function execution times
   - Test with various input sizes
   - Monitor memory usage during testing
8. STEP 16: Generate direct testing report
   - Compile all test results with pass/fail counts
   - Include performance metrics and benchmarks
   - Create detailed function-by-function report

Create marker file when complete: .test_phase2_complete</parameter>
</invoke>

<!-- Phase 3 Agent: HTTP MCP Protocol Testing -->
<invoke name="Task">
<parameter name="description">Phase 3 Agent - HTTP MCP Protocol Testing for ${SERVER_NAME}</parameter>
<parameter name="prompt">PHASE 3 AGENT - HTTP MCP PROTOCOL TESTING

CRITICAL: Read these context files FIRST:
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_TESTING_PATTERNS.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_DEPLOYMENT_CONTEXT.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_COMMAND_PATTERNS.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_DYNAMIC_PORT_DISCOVERY.md

IMPORTANT: Phase 3 HTTP testing is for protocol compliance only.
The real functional testing happens in Phase 2 with FastMCP Client.

CONFIGURATION:
- Server: ${SERVER_NAME}
- Test Level: ${TEST_LEVEL}
- Test Environment: ${TEST_ENV}
- Working Directory: /home/gotime2022/mcp-kernel-new
- Phase: 3 of 4

PREREQUISITE: Wait for .test_phase2_complete marker file before starting.

MISSION: Execute Phase 3 (Steps 17-24) of HTTP MCP protocol compliance testing.

TASKS:
1. STEP 17: Verify server is still running on correct port (DO NOT restart)
   - Get port from mcp-manager.sh PORT_MAP for ${SERVER_NAME}
   - Test port accessibility: curl http://localhost:[PORT]/health
   - Verify server responds to basic HTTP requests (server should still be running from Phase 1)
2. STEP 18: Test MCP initialization handshake
   - Send initialize request with proper JSON-RPC format
   - Verify server responds with capabilities
   - Test protocol version compatibility
3. STEP 19: Test tools/list endpoint compliance
   - Request: {"jsonrpc":"2.0","method":"tools/list","params":{},"id":1}
   - Verify response format matches MCP specification
   - Validate tool definitions and descriptions
4. STEP 20: Test tools/call for each discovered tool
   - For each tool from tools/list, test tools/call
   - Use valid parameters for each tool
   - Verify response formats and data types
5. STEP 21: Test session management and isolation
   - Create multiple concurrent sessions
   - Verify session isolation and state management
   - Test session cleanup and resource management
6. STEP 22: Run stress testing (based on test level)
   - Level 1-2: Basic concurrent requests (10-20 requests)
   - Level 3: High load testing (100+ requests)
   - Level 4: Extreme stress testing (1000+ requests)
   - Monitor response times and error rates
7. STEP 23: Test cloud endpoints (if TEST_ENV includes cloud)
   - If testing cloud: test http://137.184.212.136:[CLOUD_PORT]
   - Verify cloud deployment is accessible
   - Compare cloud vs local response consistency
8. STEP 24: Generate protocol compliance report
   - Document all MCP protocol tests and results
   - Include performance metrics and benchmarks
   - Note any protocol violations or issues

Create marker file when complete: .test_phase3_complete</parameter>
</invoke>

<!-- Phase 4 Agent: Validation and Reporting -->
<invoke name="Task">
<parameter name="description">Phase 4 Agent - Validation and Reporting for ${SERVER_NAME}</parameter>
<parameter name="prompt">PHASE 4 AGENT - VALIDATION AND REPORTING

CRITICAL: Read these context files FIRST:
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_TESTING_PATTERNS.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_DEPLOYMENT_CONTEXT.md
@/home/gotime2022/mcp-kernel-new/.claude/references/MCP_COMMAND_PATTERNS.md

CONFIGURATION:
- Server: ${SERVER_NAME}
- Test Level: ${TEST_LEVEL}
- Output Format: ${OUTPUT_FORMAT}
- Working Directory: /home/gotime2022/mcp-kernel-new
- Phase: 4 of 4

PREREQUISITE: Wait for .test_phase3_complete marker file before starting.

MISSION: Execute Phase 4 (Steps 25-32) of result compilation and reporting.

TASKS:
1. STEP 25: Compile results from all test phases
   - Read results from direct testing (Phase 2)
   - Read results from protocol testing (Phase 3)
   - Aggregate pass/fail counts and performance data
2. STEP 26: Calculate overall pass/fail rates and metrics
   - Calculate overall test success percentage
   - Identify critical failures vs minor issues
   - Compare performance against baseline metrics
3. STEP 27: Generate deployment readiness assessment
   - ✅ READY: >95% pass rate, no critical failures
   - ⚠️ NEEDS ATTENTION: 85-95% pass rate, minor issues
   - ❌ NOT READY: <85% pass rate, critical failures
4. STEP 28: Create comprehensive test report (based on OUTPUT_FORMAT)
   - Console: Detailed summary with key metrics
   - HTML: Full interactive report with charts
   - JSON: Machine-readable results for CI/CD
   - Create appropriate output files in reports/ directory
5. STEP 29: Update server documentation and test database
   - Update server README with test results
   - Log test results to central test database/log
   - Update server status and capabilities documentation
6. STEP 30: Create deployment artifacts or issue lists
   - If READY: Create deployment-ready configuration
   - If NEEDS ATTENTION: Create prioritized issue list
   - If NOT READY: Create critical fix requirements
7. STEP 31: Clean up test environment and archive results
   - Archive test results with timestamp
   - Clean up temporary files and test processes
   - Preserve important logs and artifacts
8. STEP 32: Provide final testing summary and recommendations
   - Executive summary of test results
   - Specific recommendations for deployment or fixes
   - Next steps and follow-up actions needed

Clean up marker files: rm .test_phase*_complete

FINAL: Update all TodoWrite items to completed status and provide comprehensive testing summary.</parameter>
</invoke>
</function_calls>
```

## Important Notes:

1. **The Task agents will handle all 32 steps autonomously** - The slash command gathers parameters and launches agents
2. **4-Phase approach** - Breaking 32 steps into logical testing phases  
3. **Uses existing test patterns** - Incorporates proven direct testing and HTTP protocol patterns
4. **Comprehensive validation** - Covers function-level, protocol-level, and integration testing
5. **Flexible output formats** - Supports console, HTML, and JSON reporting

## Test Result Categories:

### ✅ READY FOR DEPLOYMENT
- Direct tests: >95% pass rate
- Protocol tests: Full MCP compliance
- Performance: Within acceptable ranges
- No critical failures

### ⚠️ NEEDS ATTENTION
- Direct tests: 85-95% pass rate  
- Minor protocol issues
- Performance concerns
- Non-critical failures only

### ❌ NOT READY
- Direct tests: <85% pass rate
- Protocol violations
- Critical failures
- Performance issues

## Usage Examples:
```bash
# Quick smoke test of V0 server
/mcp-comprehensive-testing
# Select: vercel-v0-enhanced, Quick Smoke Test, Local only, Console output

# Pre-deployment validation
/mcp-comprehensive-testing
# Select: github-http, Pre-Deployment Validation, Both environments, All formats

# Standard testing after changes  
/mcp-comprehensive-testing
# Select: supabase-v4, Standard Test Suite, Local only, HTML report
```

This comprehensive testing framework ensures thorough validation using proven patterns and provides consistent, reliable results for deployment decisions.