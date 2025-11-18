# Airtable to GitHub Sync Setup

This guide shows you how to automatically sync your Airtable database to GitHub.

## Overview

The sync system:
- ✅ Runs **every hour automatically** via GitHub Actions
- ✅ Can be **triggered manually** via GitHub UI
- ✅ Generates **markdown files** for agents, commands, skills
- ✅ Exports **JSON files** for all tables
- ✅ Creates **summary reports** with statistics
- ✅ Only commits when changes are detected

## Setup Instructions

### 1. Get Your Airtable Token

1. Go to https://airtable.com/create/tokens
2. Click **"Create new token"**
3. Name it: `GitHub Sync Token`
4. Add these scopes:
   - `data.records:read` (Read records)
   - `schema.bases:read` (Read base schema)
5. Add access to your base: **Claude Plugins** (`appHbSB7WhT1TxEQb`)
6. Click **"Create token"** and copy it

### 2. Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add these secrets:

   **Secret 1:**
   - Name: `AIRTABLE_TOKEN`
   - Value: Your Airtable token from step 1

   **Secret 2:**
   - Name: `AIRTABLE_BASE_ID`
   - Value: `appHbSB7WhT1TxEQb`

### 3. Enable GitHub Actions

1. Go to **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - ✅ Read and write permissions
3. Click **Save**

### 4. Test the Sync

**Manual Trigger:**
1. Go to **Actions** tab in GitHub
2. Click **"Sync Airtable to GitHub"** workflow
3. Click **"Run workflow"** → **"Run workflow"**
4. Wait for it to complete (~30-60 seconds)
5. Check the **Files changed** tab to see what was synced

**Verify Output:**
- Check the `airtable-sync/` directory for generated files
- Review `airtable-sync/SYNC-REPORT.md` for summary

## What Gets Synced

### Directory Structure

```
airtable-sync/
├── agents/              # Markdown files for each agent
├── commands/            # Markdown files for each command
├── skills/              # Markdown files for each skill
├── plugins/             # (future)
├── mcp-servers/         # (future)
├── agents.json          # Full agents table export
├── commands.json        # Full commands table export
├── skills.json          # Full skills table export
├── plugins.json         # Full plugins table export
├── mcp-servers.json     # Full MCP servers table export
└── SYNC-REPORT.md       # Summary statistics
```

### Example Agent File

`airtable-sync/agents/test-generator.md`:

```markdown
# test-generator

**Plugin**: quality
**File Path**: `plugins/quality/agents/test-generator.md`
**Status**: Needs Update

## Purpose

Generates comprehensive test suites from implementation analysis

## Capabilities

- Has Slash Commands Section: ✅
- Has MCP Section: ✅
- Has Skills Section: ❌

## Related Resources

**Skills**: newman-testing, playwright-e2e
**Commands**: /quality:test
**MCP Servers**: supabase, github, postman

## Notes

Agent needs completion validation...

---
*Last synced: 2025-01-09 10:30:15 UTC*
*Airtable Record ID: recHe54datvAdjwgI*
```

## Sync Schedule

- **Automatic**: Every hour at :00 minutes
- **Manual**: Via GitHub Actions UI
- **Webhook**: (Optional) Set up Airtable automation

## Customizing the Sync

### Change Sync Frequency

Edit `.github/workflows/sync-airtable.yml`:

```yaml
schedule:
  # Every 6 hours
  - cron: '0 */6 * * *'

  # Daily at midnight UTC
  - cron: '0 0 * * *'

  # Every 15 minutes
  - cron: '*/15 * * * *'
```

### Add More Tables

Edit `scripts/sync-airtable-to-github.py`:

```python
# Add this in main() function
hooks_data = sync_table_to_json(api, "Hooks", SYNC_DIR / "hooks.json")
```

### Customize Output Format

The script generates both JSON and Markdown. You can:
- Modify `sync_agents_to_markdown()` to change markdown format
- Add CSV export functions
- Generate HTML reports
- Create summary dashboards

## Optional: Webhook Triggers

For **real-time sync** when Airtable changes:

### 1. Create Airtable Automation

1. In Airtable, go to **Automations**
2. Create automation:
   - **Trigger**: When record updated
   - **Action**: Send webhook to GitHub
3. Configure webhook:
   ```
   URL: https://api.github.com/repos/YOUR_USERNAME/dev-lifecycle-marketplace/dispatches
   Method: POST
   Headers:
     Authorization: Bearer YOUR_GITHUB_TOKEN
     Content-Type: application/json
   Body:
     {
       "event_type": "airtable-update"
     }
   ```

### 2. Create GitHub Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate token with `repo` scope
3. Use in Airtable webhook

## Monitoring

### View Sync History

1. GitHub → **Actions** tab
2. Click **"Sync Airtable to GitHub"**
3. View run history and logs

### Check for Errors

Look for:
- ❌ Red X icon = Failed sync
- ⚠️ Yellow icon = Warnings
- ✅ Green check = Success

Click on any run to see detailed logs.

## Troubleshooting

### Sync fails with "AIRTABLE_TOKEN not set"

**Fix:** Make sure you added the secret in GitHub Settings → Secrets

### Sync runs but no files appear

**Fix:** Check that workflow has write permissions:
- Settings → Actions → General → Workflow permissions → Read and write

### Changes not committing

**Reason:** GitHub Actions only commits when files actually change.
- If Airtable data is unchanged, no commit is made
- This is normal and saves repository history

### Rate Limits

Airtable API limits:
- **Free plan**: 5 requests per second
- **Plus/Pro**: Higher limits

If you hit limits:
- Reduce sync frequency
- Add delays in script
- Upgrade Airtable plan

## Security Best Practices

✅ **DO:**
- Store tokens in GitHub Secrets
- Use read-only Airtable tokens when possible
- Limit token scope to specific bases
- Rotate tokens periodically

❌ **DON'T:**
- Hardcode tokens in files
- Commit tokens to repository
- Share tokens publicly
- Use admin-level tokens unnecessarily

## Next Steps

After setup:
1. **Monitor first few syncs** to ensure they work
2. **Review generated files** in `airtable-sync/`
3. **Adjust frequency** if needed
4. **Set up webhooks** for real-time sync (optional)
5. **Customize output format** to your needs

---

**Need help?** Check the workflow logs in GitHub Actions for detailed error messages.
