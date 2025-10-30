# {{PROJECT_NAME}} - Tool Requirements

This document specifies the required development tools and their versions for this project.

## Language Requirements

### Node.js
- **Version**: {{NODE_VERSION}}
- **Package Manager**: {{PACKAGE_MANAGER}} {{PACKAGE_MANAGER_VERSION}}
- **Installation**: https://nodejs.org/ or use nvm
- **Verification**: `node --version && npm --version`

{{#USES_PYTHON}}
### Python
- **Version**: {{PYTHON_VERSION}}
- **Package Manager**: pip {{PIP_VERSION}}
- **Virtual Environment**: {{VENV_TOOL}}
- **Installation**: https://www.python.org/downloads/ or use pyenv
- **Verification**: `python3 --version && pip3 --version`
{{/USES_PYTHON}}

{{#USES_GO}}
### Go
- **Version**: {{GO_VERSION}}
- **Installation**: https://golang.org/dl/
- **Verification**: `go version`
{{/USES_GO}}

{{#USES_RUST}}
### Rust
- **Version**: {{RUST_VERSION}}
- **Installation**: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Verification**: `rustc --version && cargo --version`
{{/USES_RUST}}

{{#USES_RUBY}}
### Ruby
- **Version**: {{RUBY_VERSION}}
- **Package Manager**: gem
- **Installation**: https://www.ruby-lang.org/ or use rbenv
- **Verification**: `ruby --version && gem --version`
{{/USES_RUBY}}

{{#USES_JAVA}}
### Java
- **Version**: {{JAVA_VERSION}}
- **Distribution**: {{JAVA_DISTRIBUTION}}
- **Installation**: https://adoptium.net/ or use jenv
- **Verification**: `java -version && javac -version`
{{/USES_JAVA}}

{{#USES_PHP}}
### PHP
- **Version**: {{PHP_VERSION}}
- **Package Manager**: composer {{COMPOSER_VERSION}}
- **Installation**: https://www.php.net/downloads or use package manager
- **Verification**: `php --version && composer --version`
{{/USES_PHP}}

## Build Tools

{{#BUILD_TOOLS}}
### {{TOOL_NAME}}
- **Version**: {{VERSION}}
- **Purpose**: {{PURPOSE}}
- **Installation**: {{INSTALL_COMMAND}}
- **Verification**: {{VERIFY_COMMAND}}
{{/BUILD_TOOLS}}

## Development Tools

### Git
- **Version**: {{GIT_VERSION}} or higher
- **Installation**: https://git-scm.com/downloads
- **Verification**: `git --version`

{{#USES_DOCKER}}
### Docker
- **Version**: {{DOCKER_VERSION}} or higher
- **Installation**: https://docs.docker.com/get-docker/
- **Verification**: `docker --version && docker-compose --version`
{{/USES_DOCKER}}

{{#USES_MAKE}}
### Make
- **Version**: {{MAKE_VERSION}} or higher
- **Installation**: Via system package manager
- **Verification**: `make --version`
{{/USES_MAKE}}

## Version Managers (Recommended)

Using version managers allows easy switching between tool versions:

- **Node.js**: nvm (https://github.com/nvm-sh/nvm)
- **Python**: pyenv (https://github.com/pyenv/pyenv)
- **Ruby**: rbenv (https://github.com/rbenv/rbenv)
- **Rust**: rustup (https://rustup.rs/)
- **Java**: jenv (https://www.jenv.be/)

## Operating System Support

| OS | Support Level | Notes |
|----|---------------|-------|
| Linux | ✅ Full | Tested on Ubuntu 20.04+ |
| macOS | ✅ Full | Tested on macOS 12+ |
| Windows | ⚠️  WSL Only | Use WSL 2 for best experience |

## Quick Setup

### Linux/macOS

```bash
# Clone repository
git clone {{REPO_URL}}
cd {{PROJECT_NAME}}

# Run environment check
bash .claude/plugins/foundation/skills/environment-setup/scripts/check-environment.sh

# Install dependencies
{{INSTALL_DEPENDENCIES_COMMAND}}
```

### Windows (WSL)

```bash
# Install WSL 2 first: https://docs.microsoft.com/en-us/windows/wsl/install

# Follow Linux setup instructions above
```

## Troubleshooting

### Common Issues

**Tool not found in PATH**
```bash
# Check PATH configuration
bash .claude/plugins/foundation/skills/environment-setup/scripts/validate-path.sh --verbose
```

**Version mismatch**
```bash
# Check version requirements
bash .claude/plugins/foundation/skills/environment-setup/scripts/validate-versions.sh
```

**Missing environment variables**
```bash
# Check environment variables
bash .claude/plugins/foundation/skills/environment-setup/scripts/check-env-vars.sh
```

## Updates

This document should be updated when:
- Minimum version requirements change
- New tools are required
- Support for new platforms is added
- Installation procedures change

**Last Updated**: {{LAST_UPDATED}}
**Maintainer**: {{MAINTAINER}}
