#!/usr/bin/env python3
"""
Populate MCP Servers table with all discovered MCP servers
"""

import os
from pyairtable import Api

# Airtable configuration
AIRTABLE_API_KEY = os.getenv("AIRTABLE_API_KEY", "pat6Wdcb4Uj6AtcFr.60698f69f01ab1e1a13d50558fdf7edbe80201d7279cde9531ed816984779ce9")
BASE_ID = "appHbSB7WhT1TxEQb"

# Initialize Airtable API
api = Api(AIRTABLE_API_KEY)
base = api.base(BASE_ID)
mcp_servers_table = base.table("MCP Servers")

# MCP Server definitions with descriptions
MCP_SERVERS = [
    {
        "MCP Server Name": "mcp__supabase",
        "Description": "Supabase database operations - execute SQL, migrations, table management",
        "Purpose": "Database queries, schema management, RLS testing",
        "Source Marketplace": "plugin:supabase"
    },
    {
        "MCP Server Name": "mcp__github",
        "Description": "GitHub operations - repos, PRs, issues, commits",
        "Purpose": "Git history, PR creation, code review, repository management",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__airtable",
        "Description": "Airtable operations - tables, records, fields",
        "Purpose": "Database management, record creation, field updates",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__postman",
        "Description": "Postman collection management and Newman testing",
        "Purpose": "API testing, collection management, test execution",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__playwright",
        "Description": "Browser automation and E2E testing",
        "Purpose": "E2E tests, browser automation, visual regression",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__context7",
        "Description": "Documentation lookup from Context7",
        "Purpose": "Library documentation, code examples, API reference",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__memory",
        "Description": "OpenMemory MCP for persistent AI memory",
        "Purpose": "Conversation memory, context persistence, user preferences",
        "Source Marketplace": "plugin:mem0"
    },
    {
        "MCP Server Name": "mcp__filesystem",
        "Description": "File system operations - read, write, search",
        "Purpose": "File operations, directory navigation, search",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__docker",
        "Description": "Docker container management",
        "Purpose": "Container operations, image management, deployment",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__fetch",
        "Description": "HTTP requests and web content fetching",
        "Purpose": "API calls, web scraping, HTTP operations",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__slack",
        "Description": "Slack messaging and workspace operations",
        "Purpose": "Notifications, messaging, team communication",
        "Source Marketplace": "built-in"
    },
    {
        "MCP Server Name": "mcp__vercel-deploy",
        "Description": "Vercel deployment operations",
        "Purpose": "Deploy Next.js apps, manage deployments",
        "Source Marketplace": "plugin:deployment"
    },
    {
        "MCP Server Name": "mcp__plugin_supabase_supabase",
        "Description": "Plugin-specific Supabase MCP server",
        "Purpose": "Supabase plugin operations, migrations, queries",
        "Source Marketplace": "plugin:supabase"
    },
    {
        "MCP Server Name": "mcp__plugin_nextjs-frontend_shadcn",
        "Description": "Shadcn UI component operations",
        "Purpose": "Component search, installation, examples",
        "Source Marketplace": "plugin:nextjs-frontend"
    },
    {
        "MCP Server Name": "mcp__plugin_nextjs-frontend_design-system",
        "Description": "Design system operations for Next.js",
        "Purpose": "Design tokens, component patterns, style management",
        "Source Marketplace": "plugin:nextjs-frontend"
    },
    {
        "MCP Server Name": "mcp__content-image-generation",
        "Description": "AI content and image generation (Google Imagen, Gemini)",
        "Purpose": "Generate images, text, video with AI models",
        "Source Marketplace": "plugin:website-builder"
    },
]

def populate_mcp_servers():
    """Create all MCP server records"""
    print("🔧 Creating MCP Server records...")

    # Check existing
    existing = mcp_servers_table.all()
    existing_names = {rec['fields'].get('MCP Server Name') for rec in existing if 'MCP Server Name' in rec['fields']}

    print(f"📊 Found {len(existing_names)} existing MCP servers")

    # Create new ones
    to_create = [mcp for mcp in MCP_SERVERS if mcp['MCP Server Name'] not in existing_names]

    if to_create:
        print(f"📝 Creating {len(to_create)} new MCP servers...")
        batch_size = 10
        for i in range(0, len(to_create), batch_size):
            batch = to_create[i:i+batch_size]
            mcp_servers_table.batch_create(batch) # type: ignore
            print(f"  ✓ Created {min(i+batch_size, len(to_create))}/{len(to_create)} MCP servers")
    else:
        print("✓ All MCP servers already exist")

    print("\n✅ MCP Servers table populated!")
    print(f"   Total: {len(existing_names) + len(to_create)} MCP servers")

if __name__ == "__main__":
    populate_mcp_servers()
