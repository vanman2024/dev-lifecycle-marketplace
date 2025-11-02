# Changelog

All notable changes to the Planning plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-31

### Added
- Initial release of planning plugin
- Specification and architecture documentation
- Commands:
  - `/planning:architecture` - Design and document system architecture
  - `/planning:decide` - Create Architecture Decision Records (ADRs)
  - `/planning:notes` - Capture technical notes and development journal
  - `/planning:roadmap` - Create development roadmap and timeline
  - `/planning:spec` - Create, list, and validate specifications in specs/ directory
- Agents:
  - `architecture-designer` - System architecture design with diagrams and flows
  - `decision-documenter` - ADR creation and management with proper numbering
  - `roadmap-planner` - Project roadmaps with milestones and timelines
  - `spec-writer` - Feature specification creation and validation
- Skills:
  - `architecture-patterns` - Architecture design templates and mermaid diagrams
  - `decision-tracking` - ADR templates and decision history management
  - `spec-management` - Specification templates and organization
- Comprehensive documentation and examples
- Mermaid diagram generation
- Sequential ADR numbering
- Specification validation patterns

[1.0.0]: https://github.com/dev-lifecycle-marketplace/plugins/releases/tag/planning-v1.0.0
