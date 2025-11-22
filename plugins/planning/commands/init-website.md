---
description: Create all website page specs from comprehensive description - analyzes website requirements and generates W001-W0XX specs in parallel
argument-hint: <website-description> OR --doc=<path/to/document.md>
allowed-tools: Read, Bash, Task, TodoWrite, AskUserQuestion
---

**Arguments**: $ARGUMENTS

Goal: Analyze comprehensive website description and generate ALL website page specifications (W001-W0XX) in parallel. Creates complete planning documentation for marketing/content website.

Phase 1: Parse Input
Goal: Determine input mode and basic context

Actions:
- Create todo: "Initialize website specs from description"
- Parse $ARGUMENTS:
  * If contains "--doc=": MODE = "document", extract DOC_PATH
  * Otherwise: MODE = "text", DESCRIPTION = $ARGUMENTS
- If MODE = "document":
  * Validate file exists: !{bash test -f "$DOC_PATH" && echo "exists" || echo "missing"}
  * If missing: Error and exit
- Display: "Mode: [MODE]"

Phase 2: Load Project Context
Goal: Understand existing project structure

Actions:
- Read configuration files:
  * @.claude/project.json (tech stack - should have Astro/website framework)
  * @website-design.json (existing website pages if any)
  * @features.json (to avoid overlap - features are separate from website)
- Check if website directory structure exists:
  * !{bash test -d specs/website && echo "exists" || echo "create"}
- Display: "Project context loaded"

Phase 3: Analyze Website Description
Goal: Break down website into discrete pages

Actions:

Launch the feature-analyzer agent to analyze website description:

Task(
  description="Analyze website and break into pages",
  subagent_type="planning:feature-analyzer",
  prompt="Analyze this website description and break it into discrete PAGES (not features).

  Input Mode: [MODE]
  Description: $ARGUMENTS
  Document Path: [DOC_PATH if applicable]

  Read schema template:
  - @~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/schemas/website-design-schema.json

  Analyze:
  1. Read .claude/project.json for tech stack (should have Astro or website framework)
  2. Read website-design.json for existing pages
  3. Identify distinct website pages needed:
     - Landing page, pricing, about, blog, docs, contact, etc.
     - NOT application features (those go in features.json)
     - Marketing/content pages only
  4. For each page:
     - Assign W00X ID (sequential: W001, W002, W003...)
     - Determine route (/,  /pricing, /about, etc.)
     - Identify page type (landing, content, interactive, blog)
     - Extract content requirements
     - Determine components needed
  5. Check for duplicates with existing website-design.json pages

  Return JSON array of pages:
  [
    {
      'page_id': 'W001',
      'route': '/',
      'title': 'Landing Page',
      'type': 'landing',
      'description': 'Main landing page with hero, features, CTA',
      'components': ['Hero', 'Features', 'Testimonials', 'CTA'],
      'content_needs': ['Hero copy', 'Feature list', 'Social proof']
    },
    {
      'page_id': 'W002',
      'route': '/pricing',
      'title': 'Pricing',
      'type': 'content',
      'description': 'Pricing tiers and comparison',
      'components': ['PricingTable', 'FAQ', 'CTA'],
      'content_needs': ['Pricing tiers', 'FAQ content', 'Feature comparison']
    }
  ]"
)

- Parse agent response (JSON array of pages)
- Display: "Identified X website pages"

Phase 4: Update website-design.json
Goal: Register all pages before generating specs

Actions:
- Read website-design.json (or create if missing)
- For each page from Phase 3:
  * Add entry with page_id, route, title, type, description, components
  * Record created timestamp
- Write updated website-design.json
- Display: "✅ Registered X pages in website-design.json"

Phase 5: Generate Page Specs in Parallel
Goal: Create all page specifications simultaneously

Actions:
- For each page from Phase 3, spawn feature-spec-writer agent
- Send ALL Task calls in ONE message (parallel execution)
- Provide each agent with: page_id, route, title, type, description, components, content_needs
- Each agent creates specs/website/[PAGE_ID]-[slug]/spec.md and tasks.md
- Wait for all agents to complete
- Display: "✅ Generated specs for X pages"

Phase 6: Summary
Goal: Report results and next steps

Actions:
- Mark todo complete
- Display: "✅ Website initialized:"
  * Pages: X pages defined
  * Specs: specs/website/W001-..., W002-..., etc.
  * Config: website-design.json updated
- Next steps:
  * Review specs: specs/website/
  * Implement pages: /website-builder:* commands
  * Generate content: /website-builder:generate-content
  * Build site: /website-builder:deploy-marketing-site

**Important Notes:**

**Website vs Features:**
- Website pages (W00X) = Marketing/content site (Astro, static)
- Features (F00X) = Application functionality (Next.js, dynamic)
- Keep these SEPARATE - don't mix them

**Spec Location:**
All website page specs go in `specs/website/W00X-slug/`

**Implementation:**
Use /website-builder:* or /nextjs-frontend:* commands to build pages from specs
