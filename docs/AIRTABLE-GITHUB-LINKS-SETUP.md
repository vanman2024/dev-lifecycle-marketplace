# Add GitHub URL Links to Airtable - Step by Step Guide

This guide shows you how to add clickable GitHub links to all tables in your Airtable base.

**Total time:** 5-10 minutes
**Maintenance:** Zero - formulas work forever!

---

## STEP 1: Marketplaces Table (Do this FIRST)

**Go to:** Marketplaces table in Airtable

### Add Field 1: GitHub Owner

1. Click "+" button to add new field
2. Field type: **Single line text**
3. Field name: **GitHub Owner**
4. Click Create

**Fill in values for GitHub Owner:**
- For ALL 6 marketplace records, type: `vanman2024`

### Add Field 2: GitHub Repo Name

1. Click "+" button again
2. Field type: **Single line text**
3. Field name: **GitHub Repo Name**
4. Click Create

**Fill in values for GitHub Repo Name:**
- dev-lifecycle → type: `dev-lifecycle-marketplace`
- ai-dev → type: `ai-dev-marketplace`
- mcp-servers → type: `mcp-servers-marketplace`
- domain-plugin-builder → type: `domain-plugin-builder` *(no "-marketplace" suffix)*
- low-code → type: `low-code-marketplace`

### Add Field 3: GitHub URL (Formula)

1. Click "+" button again
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. In the formula box, paste this EXACTLY:

```
"https://github.com/" & TRIM({GitHub Owner}) & "/" & TRIM({GitHub Repo Name})
```

5. Click Save

**VERIFY:** You should see URLs like `https://github.com/vanman2024/dev-lifecycle-marketplace` appear automatically!

---

## STEP 2: Plugins Table (Do this SECOND)

**Go to:** Plugins table in Airtable

### Add Field: GitHub URL (Formula)

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. In the formula box, paste this EXACTLY:

```
TRIM({Marketplace Link.GitHub URL}) & "/tree/master/" & TRIM({Directory Path})
```

5. Click Save

**VERIFY:** You should see URLs like:
```
https://github.com/vanman2024/dev-lifecycle-marketplace/tree/master/plugins/planning
```

---

## STEP 3: Agents Table (Do this THIRD)

**Go to:** Agents table in Airtable

### Add Field: GitHub URL (Formula)

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. In the formula box, paste this EXACTLY:

```
TRIM({Plugin.Marketplace Link.GitHub URL}) & "/blob/master/" & TRIM({File Path})
```

5. Click Save

**VERIFY:** You should see URLs like:
```
https://github.com/vanman2024/dev-lifecycle-marketplace/blob/master/plugins/planning/agents/spec-writer.md
```

---

## STEP 4: Commands Table (Do this FOURTH)

**Go to:** Commands table in Airtable

### Add Field: GitHub URL (Formula)

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. In the formula box, paste this EXACTLY:

```
TRIM({Plugin.Marketplace Link.GitHub URL}) & "/blob/master/" & TRIM({File Path})
```

5. Click Save

**VERIFY:** You should see URLs like:
```
https://github.com/vanman2024/ai-dev-marketplace/blob/master/plugins/nextjs-frontend/commands/init.md
```

---

## STEP 5: Skills Table (Do this FIFTH)

**Go to:** Skills table in Airtable

### Add Field: GitHub URL (Formula)

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. In the formula box, paste this EXACTLY:

```
TRIM({Plugin.Marketplace Link.GitHub URL}) & "/tree/master/" & TRIM({Directory Path})
```

5. Click Save

**VERIFY:** You should see URLs like:
```
https://github.com/vanman2024/dev-lifecycle-marketplace/tree/master/plugins/planning/skills/spec-management
```

---

## STEP 6: MCP Servers Table (Do this LAST)

**Go to:** MCP Servers table in Airtable

### Add Field: GitHub URL (Formula)

1. Click "+" button
2. Field type: **Formula**
3. Field name: **GitHub URL**
4. In the formula box, paste this EXACTLY:

```
IF({Source Plugin}, TRIM({Source Plugin.GitHub URL}) & "/.mcp.json", "")
```

5. Click Save

**VERIFY:**
- Plugin-provided MCP servers will show URLs
- Built-in ones will be blank (this is correct!)

---

## DONE!

All 499 records now have clickable GitHub links that automatically update when data changes.

### What You Get:

- **6 Marketplaces** → Link to marketplace repo root
- **24 Plugins** → Link to plugin folder
- **141 Agents** → Link to agent .md file
- **215 Commands** → Link to command .md file
- **97 Skills** → Link to skill folder
- **16 MCP Servers** → Link to .mcp.json (for plugin-provided ones)

### Benefits:

✅ Click any record to view source code on GitHub
✅ Always shows latest version (updates when you push to GitHub)
✅ Zero maintenance - formulas automatically update
✅ No scripts to run or maintain

---

## Troubleshooting

**Problem:** Formula shows #ERROR!

**Solution:** Check that:
1. Field names are typed exactly as shown (case-sensitive)
2. Curly braces `{}` are used for field references
3. You completed previous steps first (formulas depend on earlier fields)

**Problem:** URL is blank

**Solution:** Check that:
1. The record has required fields filled in (File Path, Directory Path, etc.)
2. The plugin is linked to a marketplace
3. The marketplace has GitHub Owner and GitHub Repo Name filled in

---

**Questions?** Check the Airtable architecture doc: `docs/airtable-architecture.md`
