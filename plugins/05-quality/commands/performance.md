---
allowed-tools: Task(*), Bash(*), Read(*), Glob(*)
description: Performance analysis and optimization recommendations
argument-hint: <target>
---

**Arguments**: $ARGUMENTS

## Overview

Analyzes code for performance bottlenecks and provides optimization recommendations.

## Step 1: Validate Target

!{bash test -e "$ARGUMENTS" && echo "Target found: $ARGUMENTS" || echo "Analyzing entire project"}

## Step 2: Detect Project Type

!{bash test -f package.json && echo "Node.js" || test -f requirements.txt && echo "Python" || test -f Cargo.toml && echo "Rust" || test -f go.mod && echo "Go" || echo "Unknown"}

## Step 3: Basic Performance Checks

Check for common performance issues:

!{bash grep -r "console.log\|print(" ${ARGUMENTS:-.} --include="*.js" --include="*.ts" --include="*.py" 2>/dev/null | wc -l}

!{bash find ${ARGUMENTS:-.} -name "*.js" -o -name "*.ts" -o -name "*.py" | wc -l}

## Step 4: Invoke Performance Analyzer Agent

Task(
  description="Performance analysis",
  subagent_type="performance-analyzer",
  prompt="Analyze performance of ${ARGUMENTS:-.} and provide optimization recommendations.

**Performance Checks:**
- Inefficient algorithms (O(n²) or worse)
- Memory leaks and excessive memory usage
- Database query optimization (N+1 queries)
- Unnecessary loops and iterations
- Blocking operations
- Large file operations
- Resource-intensive computations
- Caching opportunities

**Analysis:**
- Review algorithm complexity
- Identify bottlenecks
- Check resource usage patterns
- Find optimization opportunities

**Deliverables:**
- Performance issues with impact assessment
- Specific optimization recommendations
- Expected performance improvements
- Code examples for fixes
- Caching strategies"
)

## Step 5: Report Results

Display performance report:
- Bottlenecks identified
- Optimization opportunities
- Expected impact of fixes
- Implementation priorities
