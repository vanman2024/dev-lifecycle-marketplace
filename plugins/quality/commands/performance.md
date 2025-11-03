---
description: Analyze performance and identify bottlenecks
argument-hint: [analysis-type]
allowed-tools: Task, Read, Bash, Glob, Grep
---

## Security Requirements

**CRITICAL:** All generated files must follow security rules:

@docs/security/SECURITY-RULES.md

**Key requirements:**
- Never hardcode API keys or secrets
- Use placeholders: `your_service_key_here`
- Protect `.env` files with `.gitignore`
- Create `.env.example` with placeholders only
- Document key acquisition for users

**Arguments**: $ARGUMENTS

Goal: Analyze application performance, identify bottlenecks, and provide optimization recommendations

Core Principles:
- Comprehensive performance profiling
- Bottleneck identification
- Database query optimization
- Frontend performance analysis
- Actionable optimization recommendations

## Phase 1: Discovery
Goal: Identify performance profiling tools and application structure

Actions:
- Load project context:
  @.claude/project.json
- Detect project type and framework:
  - Next.js: !{bash test -f next.config.js -o -f next.config.ts && echo "✅ Next.js"}
  - FastAPI: !{bash grep -r "from fastapi" --include="*.py" 2>/dev/null | head -1}
  - Django: !{bash test -f manage.py && echo "✅ Django"}
- Check for performance profiling tools:
  - Lighthouse (Node.js): !{bash which lighthouse &>/dev/null && echo "✅ lighthouse installed" || echo "❌"}
  - py-spy (Python): !{bash which py-spy &>/dev/null && echo "✅ py-spy installed" || echo "❌"}
  - Chrome DevTools Protocol available
- Determine analysis scope from arguments:
  - Empty or "all": Full performance analysis
  - "frontend": Frontend/UI performance only
  - "backend": Backend/API performance only
  - "database": Database query performance only

## Phase 2: Analysis
Goal: Assess current performance baseline

Actions:
- Identify performance-critical files:
  !{bash find . -name "*.tsx" -o -name "*.ts" -o -name "*.py" 2>/dev/null | grep -E "api|route|handler|view" | head -20}
- Check for existing performance reports:
  !{bash find . -name "lighthouse-report*" -o -name "perf-report*" 2>/dev/null}
- Scan for common performance issues:
  - Large bundle sizes: !{bash du -sh dist/ build/ .next/ 2>/dev/null}
  - Slow database queries: !{bash grep -r "SELECT \*" --include="*.py" --include="*.ts" 2>/dev/null | wc -l}
  - N+1 queries indicators
  - Missing indexes hints
- Count components/endpoints to analyze:
  - API endpoints: !{bash grep -r "@app.get\|@app.post\|export.*GET\|export.*POST" --include="*.py" --include="*.ts" 2>/dev/null | wc -l}

## Phase 3: Planning
Goal: Prepare performance analysis strategy

Actions:
- Create performance reports directory:
  !{bash mkdir -p performance-reports && echo "✅ Created performance-reports/"}
- Plan analysis execution:
  1. Frontend performance (Lighthouse, bundle analysis)
  2. Backend performance (API response times, profiling)
  3. Database performance (query analysis, index recommendations)
  4. Network performance (payload sizes, caching)
- Allocate report files:
  - performance-reports/frontend-analysis.json
  - performance-reports/backend-analysis.json
  - performance-reports/database-analysis.json
  - performance-reports/optimization-recommendations.md
- Define performance benchmarks and targets

## Phase 4: Implementation
Goal: Invoke performance-analyzer agent to execute analysis

Actions:

Launch the performance-analyzer agent to perform comprehensive performance analysis.

Provide the agent with:
- Context: Analysis type from arguments ($ARGUMENTS)
- Project framework and structure detected in Phase 1
- Performance tools available
- Requirements:
  - Analyze frontend performance (Core Web Vitals, bundle sizes, render times)
  - Profile backend API performance (response times, throughput, resource usage)
  - Analyze database queries (slow queries, N+1 problems, missing indexes)
  - Identify code-level bottlenecks (hot paths, inefficient algorithms)
  - Measure network performance (payload sizes, compression, caching)
  - Generate detailed performance reports with metrics
- Deliverables:
  - performance-reports/frontend-analysis.json (Lighthouse scores, bundle analysis)
  - performance-reports/backend-analysis.json (API profiling, hot paths)
  - performance-reports/database-analysis.json (slow queries, index recommendations)
  - performance-reports/optimization-recommendations.md (prioritized action items)
  - Performance metrics dashboard data

## Phase 5: Verification
Goal: Validate performance analysis execution and results

Actions:
- Check performance reports created:
  !{bash test -d performance-reports && ls -la performance-reports/}
- Extract key performance metrics:
  !{bash grep -r "score\|metric\|duration" performance-reports/*.json 2>/dev/null | head -10}
- Count bottlenecks identified:
  !{bash grep -r "bottleneck\|slow\|optimization" performance-reports/ 2>/dev/null | wc -l}
- Verify all analysis types completed successfully
- Validate recommendations are actionable

## Phase 6: Summary
Goal: Report performance analysis results and optimization guidance

Actions:
- Display performance summary:
  - Overall performance score: X/100
  - Frontend performance: Y/100
  - Backend performance: Z/100
  - Database performance: A/100
- Show key findings by category:
  - Critical bottlenecks: X found
  - Performance warnings: Y found
  - Optimization opportunities: Z identified
- Highlight top performance issues:
  - "Largest Contentful Paint (LCP): 4.2s (target: <2.5s)"
  - "API /users endpoint: 850ms average (target: <200ms)"
  - "Database query on users table: 1.2s (missing index on email)"
- Provide optimization recommendations:
  - Frontend: "Enable code splitting, lazy load images, optimize fonts"
  - Backend: "Add caching layer, optimize database queries, use connection pooling"
  - Database: "Add indexes on frequently queried columns, optimize N+1 queries"
- Suggest next steps:
  - "Review performance-reports/optimization-recommendations.md for details"
  - "Implement high-priority optimizations first"
  - "Run /quality:performance again after optimizations to measure improvements"
  - "Set up continuous performance monitoring"
- Provide before/after comparison framework for tracking improvements
