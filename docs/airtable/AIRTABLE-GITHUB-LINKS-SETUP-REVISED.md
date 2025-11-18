# Add GitHub URL Links to Airtable - REVISED Guide (Using Lookups)

This guide shows you how to add clickable GitHub links to all tables in your Airtable base.

**Status:**
- ✅ Marketplaces - COMPLETED
- ✅ Plugins - COMPLETED
- ⏳ Agents - TODO
- ⏳ Commands - TODO
- ⏳ Skills - TODO
- ⏳ MCP Servers - TODO

---

## ✅ STEP 1 & 2: Already Completed

You've already completed the Marketplaces and Plugins tables!

---

## STEP 3: Agents Table

**Go to:** Agents table in Airtable

### Step 3.1: Add Lookup Field

1. Click "+" button
2. Field type: **Lookup**
3. Field name: **Marketplace GitHub URL**
4. "Pick a linked record field": Select **Plugin**
5. "Pick a field to look up": Select **Marketplace GitHub URL**
6. Click Create

### Step 3.2: Add Formula Field

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. Formula:
```
ARRAYJOIN({Marketplace GitHub URL}) & "/blob/master/" & TRIM({File Path})
```
5. Click Create

**VERIFY:** URLs should look like:
```
https://github.com/vanman2024/dev-lifecycle-marketplace/blob/master/plugins/planning/agents/spec-writer.md
```

---

## STEP 4: Commands Table

**Go to:** Commands table in Airtable

### Step 4.1: Add Lookup Field

1. Click "+" button
2. Field type: **Lookup**
3. Field name: **Marketplace GitHub URL**
4. "Pick a linked record field": Select **Plugin**
5. "Pick a field to look up": Select **Marketplace GitHub URL**
6. Click Create

### Step 4.2: Add Formula Field

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. Formula:
```
ARRAYJOIN({Marketplace GitHub URL}) & "/blob/master/" & TRIM({File Path})
```
5. Click Create

**VERIFY:** URLs should look like:
```
https://github.com/vanman2024/ai-dev-marketplace/blob/master/plugins/nextjs-frontend/commands/init.md
```

---

## STEP 5: Skills Table

**Go to:** Skills table in Airtable

### Step 5.1: Add Lookup Field

1. Click "+" button
2. Field type: **Lookup**
3. Field name: **Marketplace GitHub URL**
4. "Pick a linked record field": Select **Plugin**
5. "Pick a field to look up": Select **Marketplace GitHub URL**
6. Click Create

### Step 5.2: Add Formula Field

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. Formula:
```
ARRAYJOIN({Marketplace GitHub URL}) & "/tree/master/" & TRIM({Directory Path})
```
5. Click Create

**VERIFY:** URLs should look like:
```
https://github.com/vanman2024/dev-lifecycle-marketplace/tree/master/plugins/planning/skills/spec-management
```

---

## STEP 6: MCP Servers Table

**Go to:** MCP Servers table in Airtable

### Step 6.1: Add Lookup Field (for plugin-provided MCP servers)

1. Click "+" button
2. Field type: **Lookup**
3. Field name: **Plugin GitHub URL**
4. "Pick a linked record field": Select **Source Plugin**
5. "Pick a field to look up": Select **GitHub URL**
6. Click Create

### Step 6.2: Add Formula Field

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. Formula:
```
IF({Source Plugin}, ARRAYJOIN({Plugin GitHub URL}) & "/.mcp.json", "")
```
5. Click Create

**VERIFY:**
- Plugin-provided MCP servers show URLs to .mcp.json files
- Built-in MCP servers show blank (this is correct)

---

## DONE!

Once you complete steps 3-6, all tables will have clickable GitHub links!

### Benefits:

✅ Click any record to view source code on GitHub
✅ Always shows latest version (updates when you push)
✅ Zero maintenance - lookups and formulas automatically update
✅ No scripts to run

---

## What Changed from Original Guide?

The original guide used "dot notation" like `{Plugin.Marketplace Link.GitHub URL}`, but **Airtable doesn't support this in formulas**.

Instead, we use **Lookup fields** to pull the GitHub URL from linked records, then combine it in a Formula field.

This is the correct Airtable way to reference fields from linked tables!
