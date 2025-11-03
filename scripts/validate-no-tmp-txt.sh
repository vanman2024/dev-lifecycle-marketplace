#!/bin/bash
# Validation script: Ensure no /tmp/architecture-context.txt references remain
# Usage: bash scripts/validate-no-tmp-txt.sh

set -e

echo "🔍 Validating removal of /tmp/architecture-context.txt..."
echo ""

ERRORS=0

# Check for /tmp/architecture-context.txt references
echo "Checking for /tmp/architecture-context.txt references..."
if grep -r "/tmp/architecture-context.txt" plugins/planning/ 2>/dev/null; then
    echo "❌ ERROR: Found /tmp/architecture-context.txt references"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No /tmp/architecture-context.txt references found"
fi
echo ""

# Check for @/tmp/architecture-context.txt references
echo "Checking for @/tmp/architecture-context.txt references..."
if grep -r "@/tmp/architecture-context.txt" plugins/planning/ 2>/dev/null; then
    echo "❌ ERROR: Found @/tmp/architecture-context.txt references"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No @/tmp/architecture-context.txt references found"
fi
echo ""

# Verify direct .md references exist in init-project.md
echo "Verifying direct .md references in init-project.md..."
if grep -q "@docs/architecture/frontend.md" plugins/planning/commands/init-project.md && \
   grep -q "@docs/architecture/backend.md" plugins/planning/commands/init-project.md && \
   grep -q "@docs/architecture/data.md" plugins/planning/commands/init-project.md && \
   grep -q "@docs/adr/\*.md" plugins/planning/commands/init-project.md && \
   grep -q "@docs/ROADMAP.md" plugins/planning/commands/init-project.md; then
    echo "✅ init-project.md has direct .md references"
else
    echo "❌ ERROR: init-project.md missing direct .md references"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verify direct .md references exist in spec-writer.md
echo "Verifying direct .md references in spec-writer.md..."
if grep -q "@docs/architecture/frontend.md" plugins/planning/agents/spec-writer.md && \
   grep -q "@docs/architecture/backend.md" plugins/planning/agents/spec-writer.md && \
   grep -q "@docs/adr/\*.md" plugins/planning/agents/spec-writer.md && \
   grep -q "@docs/ROADMAP.md" plugins/planning/agents/spec-writer.md; then
    echo "✅ spec-writer.md has direct .md references"
else
    echo "❌ ERROR: spec-writer.md missing direct .md references"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verify direct .md references exist in feature-analyzer.md
echo "Verifying direct .md references in feature-analyzer.md..."
if grep -q "@docs/architecture/frontend.md" plugins/planning/agents/feature-analyzer.md && \
   grep -q "@docs/architecture/backend.md" plugins/planning/agents/feature-analyzer.md && \
   grep -q "@docs/adr/\*.md" plugins/planning/agents/feature-analyzer.md && \
   grep -q "@docs/ROADMAP.md" plugins/planning/agents/feature-analyzer.md; then
    echo "✅ feature-analyzer.md has direct .md references"
else
    echo "❌ ERROR: feature-analyzer.md missing direct .md references"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verify /tmp/feature-breakdown.json still exists (legitimate use)
echo "Verifying /tmp/feature-breakdown.json references (legitimate)..."
if grep -q "/tmp/feature-breakdown.json" plugins/planning/commands/init-project.md && \
   grep -q "/tmp/feature-breakdown.json" plugins/planning/agents/spec-writer.md; then
    echo "✅ /tmp/feature-breakdown.json references present (correct)"
else
    echo "⚠️  WARNING: /tmp/feature-breakdown.json references missing (may be intentional)"
fi
echo ""

# Check for any cat commands creating /tmp/ files
echo "Checking for cat commands creating /tmp/ files..."
if grep -r "cat.*> /tmp/" plugins/planning/ 2>/dev/null | grep -v "feature-breakdown.json"; then
    echo "❌ ERROR: Found cat commands creating /tmp/ files"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No cat commands creating /tmp/ files (except feature-breakdown.json)"
fi
echo ""

# Summary
echo "=================================="
if [ $ERRORS -eq 0 ]; then
    echo "✅ VALIDATION PASSED"
    echo "All /tmp/architecture-context.txt references removed"
    echo "Direct .md references properly implemented"
    exit 0
else
    echo "❌ VALIDATION FAILED"
    echo "Found $ERRORS error(s)"
    exit 1
fi
