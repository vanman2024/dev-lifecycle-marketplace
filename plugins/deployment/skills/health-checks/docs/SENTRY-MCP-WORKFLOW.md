# Sentry MCP Workflow (Global Setup)

The Sentry MCP server works like Supabase - **globally configured**, agents select projects dynamically.

## Step 1: Store Auth Token in Doppler

```bash
# Store your Sentry auth token securely
doppler secrets set SENTRY_AUTH_TOKEN="your_sentry_token_here" --config dev
doppler secrets set SENTRY_AUTH_TOKEN="your_sentry_token_here" --config staging  
doppler secrets set SENTRY_AUTH_TOKEN="your_sentry_token_here" --config production
```

## Step 2: MCP Server Auto-Loads

The Sentry MCP server in `plugins/deployment/.mcp.json` is now **global**:
- Only needs `SENTRY_AUTH_TOKEN` (no org/project hardcoded)
- Agents can list all organizations
- Agents can list all projects
- Agents can create projects
- Agents can query issues across all projects

## Step 3: Use MCP to Manage Sentry

### List Organizations
"Show me my Sentry organizations"

### List Projects
"List all Sentry projects"
"Show projects in organization collars-employment-group-ltd"

### Create Project
"Create a Sentry project called red-ai in organization collars-employment-group-ltd for Next.js"

### Query Issues
"Show me the top 10 errors in project red-ai"
"What errors occurred in the last hour in red-ai?"

### Create Alerts
"Create an alert in red-ai if error rate exceeds 1% in 5 minutes"

## Step 4: Automated Setup in /deployment:setup-monitoring

The command will:
1. Use MCP to list organizations
2. Ask user to select or confirm org (via AskUserQuestion)
3. Use MCP to check if project exists
4. If not exists: Use MCP to create project
5. Get project DSN from MCP
6. Run Sentry wizard with project details
7. Store DSN in Doppler

## Benefits

✅ Single auth token manages all orgs/projects
✅ No hardcoded org/project in config
✅ Dynamic project selection like Supabase
✅ Agents can create projects automatically
✅ Query across all projects from one place

## Security

- Auth token stored in Doppler only
- Never committed to git
- Injected via doppler run -- at runtime
- Works with both Sentry Cloud and self-hosted
