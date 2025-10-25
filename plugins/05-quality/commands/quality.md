---
allowed-tools: SlashCommand(*), Read(*), Bash(*)
description: Quality orchestrator - routes to appropriate quality checks
argument-hint: <check-type>
---

**Arguments**: $ARGUMENTS

## Overview

Orchestrates quality workflows by routing to appropriate granular commands based on check type.

## Step 1: Determine Check Type

!{bash echo "Quality check type: $ARGUMENTS"}

## Step 2: Route to Appropriate Command

Based on check type, invoke the appropriate command:

**Testing** (test):
SlashCommand: /quality:test $ARGUMENTS

**Test Generation** (test-generate):
SlashCommand: /quality:test-generate $ARGUMENTS

**Security** (security):
SlashCommand: /quality:security $ARGUMENTS

**Performance** (performance):
SlashCommand: /quality:performance $ARGUMENTS

**Validation** (validate):
SlashCommand: /quality:validate $ARGUMENTS

**Compliance** (compliance):
SlashCommand: /quality:compliance $ARGUMENTS

## Step 3: Report Completion

Display summary of quality check completed.
