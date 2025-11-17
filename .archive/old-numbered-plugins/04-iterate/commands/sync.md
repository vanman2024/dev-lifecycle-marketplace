---
allowed-tools: Bash, Read, Write
description: Synchronize spec files and cross-references for consistency
argument-hint: <spec-id>
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

## Overview

Synchronizes spec ecosystem to maintain consistency across all documentation files.

## Step 1: Validate Spec Directory

!{bash test -d "specs/$ARGUMENTS" && echo "Spec found: $ARGUMENTS" || echo "Spec not found: $ARGUMENTS"}

## Step 2: Update Cross-References

!{bash
SPEC_DIR="specs/$ARGUMENTS"

# Find all markdown files in spec
find "$SPEC_DIR" -name "*.md" -type f | while read -r file; do
  # Check for broken internal links
  grep -o '\[.*\](.*.md)' "$file" | while read -r link; do
    target=$(echo "$link" | sed 's/.*(\(.*\))/\1/')
    if [ ! -f "$SPEC_DIR/$target" ]; then
      echo "Broken link in $file: $target"
    fi
  done
done
}

## Step 3: Regenerate Quickstart

!{bash
SPEC_DIR="specs/$ARGUMENTS"

# Extract key sections from spec.md
if [ -f "$SPEC_DIR/spec.md" ]; then
  {
    echo "# Quickstart: $ARGUMENTS"
    echo ""
    echo "Auto-generated summary from spec.md"
    echo ""

    # Extract overview section
    sed -n '/^## Overview/,/^##/p' "$SPEC_DIR/spec.md" | head -n -1

    # Extract requirements section
    sed -n '/^## Requirements/,/^##/p' "$SPEC_DIR/spec.md" | head -n -1
  } > "$SPEC_DIR/quickstart.md"

  echo "Quickstart regenerated"
fi
}

## Step 4: Update Symlinks

!{bash
SPEC_DIR="specs/$ARGUMENTS"

# Link to current tasks
if [ -f "$SPEC_DIR/agent-tasks/layered-tasks.md" ]; then
  ln -sf agent-tasks/layered-tasks.md "$SPEC_DIR/current-tasks.md"
else
  ln -sf tasks.md "$SPEC_DIR/current-tasks.md"
fi

echo "Symlinks updated"
}

## Step 5: Report Status

Display sync summary:
- Cross-references validated
- Quickstart regenerated from latest spec
- Symlinks updated to current tasks

Spec is now synchronized and consistent.
