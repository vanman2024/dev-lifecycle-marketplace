#!/bin/bash
# Setup approval gate configuration for release workflows
# Usage: bash setup-approval-gates.sh <project-dir>

set -euo pipefail

PROJECT_DIR="${1:-.}"
APPROVAL_CONFIG_DIR="$PROJECT_DIR/.github/releases"
APPROVAL_GATES_FILE="$APPROVAL_CONFIG_DIR/approval-gates.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create approval configuration directory
create_config_directory() {
    if [ ! -d "$APPROVAL_CONFIG_DIR" ]; then
        mkdir -p "$APPROVAL_CONFIG_DIR"
        mkdir -p "$APPROVAL_CONFIG_DIR/approvals"
        log_info "Created approval configuration directory: $APPROVAL_CONFIG_DIR"
    else
        log_info "Approval configuration directory already exists"
    fi
}

# Create default approval gates configuration
create_approval_gates() {
    if [ -f "$APPROVAL_GATES_FILE" ]; then
        log_warn "Approval gates file already exists: $APPROVAL_GATES_FILE"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping approval gates creation"
            return
        fi
    fi

    cat > "$APPROVAL_GATES_FILE" <<'EOF'
# Release Approval Gates Configuration
# Define stakeholder groups and approval requirements for releases

approval_gates:
  - stage: development
    description: Technical validation and code review
    approvers:
      - "@tech-lead"
      - "@senior-dev"
    required: 2
    optional: []
    timeout_hours: 24
    notify_channels:
      - "dev-team-slack-channel-id-here"

  - stage: qa
    description: Quality assurance and testing validation
    approvers:
      - "@qa-lead"
    required: 1
    optional:
      - "@qa-engineer"
    timeout_hours: 12
    depends_on:
      - development
    notify_channels:
      - "qa-team-slack-channel-id-here"

  - stage: security
    description: Security review and vulnerability assessment
    approvers:
      - "@security-team-lead"
    required: 1
    optional: []
    timeout_hours: 48
    veto_power: true
    notify_channels:
      - "security-team-slack-channel-id-here"
    auto_approve_conditions:
      - patch_release: true
      - no_breaking_changes: true
      - all_tests_passing: true

  - stage: release
    description: Final release sign-off and deployment approval
    approvers:
      - "@release-manager"
      - "@product-owner"
    required: 2
    optional: []
    timeout_hours: 12
    depends_on:
      - development
      - qa
      - security
    notify_channels:
      - "release-team-slack-channel-id-here"

# Approval policies
policies:
  # Auto-approve conditions for low-risk changes
  auto_approve:
    enabled: false
    conditions:
      - docs_only: true
      - patch_version: true
      - no_code_changes: true

  # Escalation settings
  escalation:
    enabled: true
    grace_period_hours: 12
    escalate_to:
      - "@engineering-manager"
      - "@cto"

  # Emergency release overrides
  emergency_override:
    enabled: true
    requires_justification: true
    approvers:
      - "@cto"
      - "@engineering-manager"
    audit_required: true

# Notification settings
notifications:
  slack:
    enabled: true
    webhook_url_secret: "SLACK_WEBHOOK_URL"
    channels:
      default: "releases-slack-channel-id-here"
      urgent: "urgent-releases-slack-channel-id-here"

  github:
    enabled: true
    create_issue: true
    issue_labels:
      - "release"
      - "approval-required"
    mention_approvers: true

# Audit settings
audit:
  enabled: true
  store_in_git: true
  approval_records_dir: ".github/releases/approvals"
  include_timestamps: true
  include_comments: true
EOF

    log_info "Created approval gates configuration: $APPROVAL_GATES_FILE"
}

# Create GitHub Actions workflow for approvals
create_github_workflow() {
    local workflow_dir="$PROJECT_DIR/.github/workflows"
    local workflow_file="$workflow_dir/release-approval.yml"

    if [ ! -d "$workflow_dir" ]; then
        mkdir -p "$workflow_dir"
        log_info "Created GitHub workflows directory"
    fi

    if [ -f "$workflow_file" ]; then
        log_warn "GitHub workflow already exists: $workflow_file"
        return
    fi

    cat > "$workflow_file" <<'EOF'
name: Release Approval Workflow

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to approve (e.g., 1.2.3)'
        required: true
        type: string

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  request-approvals:
    name: Request Release Approvals
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Load approval gates configuration
        id: load-config
        run: |
          echo "Loading approval gates from .github/releases/approval-gates.yml"
          # Parse YAML and extract approvers (requires yq)
          # For now, just verify file exists
          if [ ! -f ".github/releases/approval-gates.yml" ]; then
            echo "ERROR: Approval gates configuration not found"
            exit 1
          fi

      - name: Create approval tracking issue
        uses: actions/github-script@v7
        with:
          script: |
            const version = '${{ inputs.version }}';
            const body = `
            # Release Approval: v${version}

            ## Approval Status

            - [ ] Development Team (@tech-lead, @senior-dev)
            - [ ] QA Team (@qa-lead)
            - [ ] Security Team (@security-team-lead)
            - [ ] Release Management (@release-manager, @product-owner)

            ## Version Information

            **Version**: v${version}
            **Requested**: ${new Date().toISOString()}

            ## Instructions

            Approvers: Comment with \`/approve\` to approve or \`/reject <reason>\` to reject.
            `;

            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: \`Release Approval: v\${version}\`,
              body: body,
              labels: ['release', 'approval-required']
            });

      - name: Notify Slack (if configured)
        if: env.SLACK_WEBHOOK_URL != ''
        run: |
          curl -X POST "${{ secrets.SLACK_WEBHOOK_URL }}" \
            -H 'Content-Type: application/json' \
            -d '{
              "text": "🚀 Release Approval Requested",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Release Approval Requested*\n\nVersion: v${{ inputs.version }}\n\nPlease review and approve in GitHub."
                  }
                }
              ]
            }'
EOF

    log_info "Created GitHub Actions workflow: $workflow_file"
}

# Create README with instructions
create_readme() {
    local readme_file="$APPROVAL_CONFIG_DIR/README.md"

    cat > "$readme_file" <<'EOF'
# Release Approval Configuration

This directory contains approval gate configuration and approval records for releases.

## Structure

```
.github/releases/
├── approval-gates.yml       # Approval gate configuration
├── approvals/               # Approval records (audit trail)
│   ├── v1.0.0.json
│   ├── v1.1.0.json
│   └── ...
└── README.md               # This file
```

## Configuration

Edit `approval-gates.yml` to customize:
- Stakeholder groups and approvers
- Approval thresholds (required vs optional)
- Timeout and escalation policies
- Notification channels
- Auto-approve conditions

## Usage

### Request Approval

```bash
# Using versioning plugin
/versioning:approve-release 1.2.3

# Using GitHub Actions workflow
gh workflow run release-approval.yml -f version=1.2.3
```

### Check Approval Status

```bash
bash .claude/plugins/marketplaces/dev-lifecycle-marketplace/plugins/versioning/skills/release-approval/scripts/check-approval-status.sh 1.2.3
```

### Manual Approval

Approvers can approve via:
- GitHub issue comments: `/approve` or `/reject <reason>`
- Pull request reviews: Approve/Request Changes
- Direct script execution: `bash scripts/request-approval.sh 1.2.3 development approved "All tests passing"`

## Security

**Never commit real credentials or webhook URLs!**

Store sensitive data in GitHub Secrets:
- `SLACK_WEBHOOK_URL` - Slack webhook for notifications
- `GITHUB_TOKEN` - GitHub token for API access (automatically provided in Actions)

Use placeholders in configuration files:
```yaml
webhook_url: "YOUR_SLACK_WEBHOOK_HERE"
```

## Approval Records

Approval records are stored as JSON in `approvals/`:

```json
{
  "version": "1.2.3",
  "requested_at": "2025-01-15T10:00:00Z",
  "completed_at": "2025-01-15T14:30:00Z",
  "approvals": [
    {
      "stage": "development",
      "approver": "tech-lead",
      "decision": "approved",
      "timestamp": "2025-01-15T11:00:00Z",
      "comments": "All tests passing"
    }
  ],
  "final_decision": "approved"
}
```

These records provide a permanent audit trail of all release approvals.
EOF

    log_info "Created README: $readme_file"
}

# Main execution
main() {
    log_info "Setting up approval gates for project: $PROJECT_DIR"

    create_config_directory
    create_approval_gates
    create_github_workflow
    create_readme

    log_info ""
    log_info "Approval gates setup complete!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Review and customize: $APPROVAL_GATES_FILE"
    log_info "2. Update stakeholder GitHub usernames"
    log_info "3. Configure Slack webhook in GitHub Secrets: SLACK_WEBHOOK_URL"
    log_info "4. Test approval workflow: /versioning:approve-release <version>"
    log_info ""
    log_info "Documentation: $APPROVAL_CONFIG_DIR/README.md"
}

main
