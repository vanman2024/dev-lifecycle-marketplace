# Changelog

All notable changes to the Supervisor plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-31

### Added
- Initial release of supervisor plugin
- Multi-agent parallel development orchestration
- Git worktree isolation for concurrent work
- Commands:
  - `/supervisor:start` - Verify agent setup and worktree readiness before work begins
  - `/supervisor:mid` - Monitor agent progress and task completion during development
  - `/supervisor:end` - Validate completion and generate PR commands before creating pull requests
  - `/supervisor:init` - Initialize git worktrees for parallel agent execution
- Comprehensive documentation and examples
- Worktree-based parallel execution
- Agent coordination and progress monitoring
- PR validation and generation

[1.0.0]: https://github.com/dev-lifecycle-marketplace/plugins/releases/tag/supervisor-v1.0.0
