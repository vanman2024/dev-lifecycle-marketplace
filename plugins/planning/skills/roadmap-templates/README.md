# Roadmap Templates Skill

JSON schema templates for the spec-driven development roadmap system. Use these templates when initializing a new project to set up the full roadmap tracking infrastructure.

## Templates Included

| File | Purpose |
|------|---------|
| `features.json` | Feature tracking with phases, dependencies, progress |
| `infrastructure.json` | Infrastructure components with providers, links |
| `sprints.json` | Sprint planning with scope, concurrency |
| `enhancements.json` | Feature enhancements/sub-specs tracking |
| `project.json` | Project metadata, tech stack, AI configuration |
| `worktree-config.json` | Worktree strategy, port mapping |
| `activities.json` | Activity log for commits, PRs, deployments |
| `worktree-history.json` | Worktree lifecycle events |

## Usage

```bash
# Initialize a new project with roadmap structure
/foundation:init-structure --with-roadmap

# Or copy templates manually
cp ~/.claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/planning/skills/roadmap-templates/templates/*.json ./roadmap/
```

## Schema Relationships

```
project.json (metadata)
    ↓
features.json ←→ infrastructure.json (cross-references)
    ↓                    ↓
enhancements.json    worktree-config.json
    ↓                    ↓
sprints.json ←--------→ activities.json
                         ↓
                    worktree-history.json
```

## Key Fields

### features.json
- `id`: F### format (F001, F002, etc.)
- `infrastructure_dependencies`: Array of I### IDs
- `enhancements`: Array of enhancement objects
- `tasks_total` / `tasks_completed`: Progress tracking

### enhancements.json
- Links enhancements to parent features
- Tracks enhancement-level progress
- Combined progress = feature + enhancements

### infrastructure.json
- `id`: I### format (I001, I002, etc.)
- `feature_links`: Features that depend on this infra
- `blocks`: Features blocked until this is complete
