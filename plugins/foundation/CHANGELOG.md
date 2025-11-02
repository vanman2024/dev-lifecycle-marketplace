# Changelog

All notable changes to the Foundation plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-31

### Added
- Initial release of foundation plugin
- MCP ecosystem management and minimal environment setup
- Tech stack detection and project.json population
- Commands:
  - `/foundation:detect` - Detect project tech stack and populate .claude/project.json
  - `/foundation:env-check` - Verify required tools are installed for detected tech stack
  - `/foundation:env-vars` - Manage environment variables for project configuration
  - `/foundation:hooks-setup` - Install standardized git hooks and GitHub Actions workflow
  - `/foundation:mcp-manage` - Add, install, remove, list MCP servers and manage API keys
  - `/foundation:mcp-registry` - Manage universal MCP server registry
  - `/foundation:mcp-sync` - Sync universal MCP registry to target format
- Agents:
  - `stack-detector` - Comprehensive tech stack detection and analysis
  - `env-detector` - Environment variable detection from multiple sources
- Skills:
  - `environment-setup` - Environment verification and tool checking
  - `git-hooks` - Git hooks installation and configuration
  - `mcp-configuration` - MCP server configuration and management
  - `project-detection` - Tech stack detection patterns
- Comprehensive documentation and examples
- Production-ready automation scripts
- Security scanning and secret detection
- Git hooks for commit message validation

[1.0.0]: https://github.com/dev-lifecycle-marketplace/plugins/releases/tag/foundation-v1.0.0
