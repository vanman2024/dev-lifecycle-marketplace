# Airtable Sync - Quick Start

**5-Minute Setup for Automatic Airtable → GitHub Sync**

## What You Get

✅ **Hourly automatic sync** from Airtable to GitHub
✅ **Markdown files** for every agent, command, and skill
✅ **JSON exports** of all tables
✅ **Summary reports** with statistics
✅ **Manual trigger** anytime via GitHub UI

## Setup (3 Steps)

### Step 1: Get Airtable Token (2 minutes)

1. Go to https://airtable.com/create/tokens
2. Create token with scopes: `data.records:read`, `schema.bases:read`
3. Grant access to base: **Claude Plugins** (`appHbSB7WhT1TxEQb`)
4. Copy the token

### Step 2: Add GitHub Secrets (1 minute)

1. GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add secret: `AIRTABLE_TOKEN` = your token from Step 1
3. Add secret: `AIRTABLE_BASE_ID` = `appHbSB7WhT1TxEQb`

### Step 3: Enable Workflow Permissions (1 minute)

1. GitHub repo → **Settings** → **Actions** → **General**
2. Under **Workflow permissions**:
   - Select **"Read and write permissions"**
3. Click **Save**

## Test It

1. Go to **Actions** tab
2. Click **"Sync Airtable to GitHub"**
3. Click **"Run workflow"** → **"Run workflow"**
4. Wait ~30 seconds
5. Check the new commit with synced files!

## What Gets Created

```
airtable-sync/
├── agents/
│   ├── test-generator.md
│   ├── code-validator.md
│   └── ...
├── commands/
│   ├── quality-test.md
│   ├── quality-validate-code.md
│   └── ...
├── skills/
│   ├── newman-testing.md
│   ├── playwright-e2e.md
│   └── ...
├── agents.json           # Full table export
├── commands.json         # Full table export
├── skills.json           # Full table export
├── plugins.json          # Full table export
├── mcp-servers.json      # Full table export
└── SYNC-REPORT.md        # Summary stats
```

## Schedule

- **Automatic**: Every hour
- **Manual**: Run anytime via Actions UI
- **Webhook**: Optional (see full docs)

## Customization

**Change frequency** - Edit `.github/workflows/sync-airtable.yml`:
```yaml
schedule:
  - cron: '0 */6 * * *'  # Every 6 hours
```

**Add tables** - Edit `scripts/sync-airtable-to-github.py`:
```python
hooks_data = sync_table_to_json(api, "Hooks", SYNC_DIR / "hooks.json")
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| No commits appear | Normal if no data changed |
| "Token not set" error | Add secrets in Settings → Secrets |
| Sync fails | Check Actions → Workflow permissions |

## Full Documentation

See [AIRTABLE-SYNC-SETUP.md](./AIRTABLE-SYNC-SETUP.md) for:
- Webhook triggers (real-time sync)
- Custom output formats
- Advanced configuration
- Security best practices

---

**That's it!** Your Airtable data will now sync to GitHub every hour automatically. 🚀
