---
name: Performance Monitoring
description: Analyze performance and identify bottlenecks. Use when analyzing performance, profiling code, identifying bottlenecks, optimizing algorithms, or when user mentions performance, optimization, slow code, bottlenecks, profiling, memory leaks, or algorithm complexity.
---

# Performance Monitoring

**CRITICAL: The description field above controls when Claude auto-loads this skill.**

## Overview

Provides performance analysis, bottleneck identification, algorithm complexity assessment, and optimization recommendations for projects.

## Instructions

### Performance Analysis

1. Use `scripts/analyze-performance.sh` to identify slow code paths
2. Profile memory usage and identify leaks
3. Assess algorithm complexity (O(n), O(n²), etc.)

### Bottleneck Identification

1. Scan for common performance anti-patterns
2. Identify inefficient algorithms and data structures
3. Detect N+1 query problems
4. Find blocking operations and resource-intensive computations

### Optimization Recommendations

1. Suggest algorithmic improvements
2. Recommend caching strategies
3. Identify parallelization opportunities
4. Propose lazy loading and code splitting

## Available Scripts

- **analyze-performance.sh**: Identifies performance bottlenecks
- **profile-memory.sh**: Analyzes memory usage patterns
- **check-complexity.sh**: Assesses algorithm complexity
- **generate-performance-report.sh**: Creates optimization report

## Templates

- **performance-report.template**: Performance audit report format
- **optimization-checklist.md**: Performance optimization checklist
- **profiling-config.template**: Profiling tool configuration

## Requirements

- Support multiple languages and frameworks
- Provide specific file locations and line numbers
- Include expected performance improvements
- Suggest concrete code examples for fixes
- Assess impact (critical/high/medium/low)
