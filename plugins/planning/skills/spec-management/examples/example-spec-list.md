# Example: Specification List Outputs

This example shows what the `list-specs.sh` script output looks like in different formats and with various filters.

---

## Example 1: Default Table Format (All Specs)

```bash
$ bash scripts/list-specs.sh
```

**Output:**
```
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
001    User Authentication System               implemented     🔴 critical  auth-team        2024-12-15
002    API Rate Limiting                        implemented     🟠 high      backend-team     2024-12-20
003    Dashboard Redesign                       in-progress     🟡 medium    frontend-team    2025-01-18
004    Payment Gateway Integration              review          🔴 critical  payments-team    2025-01-17
005    Email Notification Service               approved        🟠 high      platform-team    2025-01-16
006    User Profile Management                  draft           🟡 medium    frontend-team    2025-01-15
007    Real-Time Chat System                    in-progress     🟠 high      platform-team    2025-01-19
008    Advanced Search Functionality            draft           🟡 medium    search-team      2025-01-14
009    Multi-Factor Authentication              review          🔴 critical  security-team    2025-01-18
010    Database Migration to PostgreSQL         rejected        🟡 medium    backend-team     2024-11-30
011    Mobile App Push Notifications            in-progress     🟠 high      mobile-team      2025-01-17
012    Admin Panel Enhancement                  draft           🟢 low       admin-team       2025-01-10
013    GraphQL API Implementation               approved        🟠 high      api-team         2025-01-15
014    CDN Integration                          implemented     🟡 medium    devops-team      2024-12-28
015    User Profile Page                        draft           🟡 medium    frontend-team    2025-01-15
016    Analytics Dashboard                      in-progress     🟠 high      analytics-team   2025-01-19
017    OAuth 2.0 Integration                    review          🔴 critical  auth-team        2025-01-18
018    Backup and Disaster Recovery             approved        🔴 critical  devops-team      2025-01-16
019    API Documentation Portal                 in-progress     🟡 medium    docs-team        2025-01-17
020    A/B Testing Framework                    draft           🟠 high      product-team     2025-01-14

Total specifications: 20
```

---

## Example 2: Filter by Status (Draft)

```bash
$ bash scripts/list-specs.sh --status draft
```

**Output:**
```
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
006    User Profile Management                  draft           🟡 medium    frontend-team    2025-01-15
008    Advanced Search Functionality            draft           🟡 medium    search-team      2025-01-14
012    Admin Panel Enhancement                  draft           🟢 low       admin-team       2025-01-10
015    User Profile Page                        draft           🟡 medium    frontend-team    2025-01-15
020    A/B Testing Framework                    draft           🟠 high      product-team     2025-01-14

Total specifications: 5
```

---

## Example 3: Filter by Priority (Critical)

```bash
$ bash scripts/list-specs.sh --priority critical
```

**Output:**
```
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
001    User Authentication System               implemented     🔴 critical  auth-team        2024-12-15
004    Payment Gateway Integration              review          🔴 critical  payments-team    2025-01-17
009    Multi-Factor Authentication              review          🔴 critical  security-team    2025-01-18
017    OAuth 2.0 Integration                    review          🔴 critical  auth-team        2025-01-18
018    Backup and Disaster Recovery             approved        🔴 critical  devops-team      2025-01-16

Total specifications: 5
```

---

## Example 4: JSON Format

```bash
$ bash scripts/list-specs.sh --format json --status in-progress
```

**Output:**
```json
[
  {
    "id": "003",
    "title": "Dashboard Redesign",
    "status": "in-progress",
    "priority": "medium",
    "owner": "frontend-team",
    "updated": "2025-01-18",
    "filename": "003-dashboard-redesign.md"
  },
  {
    "id": "007",
    "title": "Real-Time Chat System",
    "status": "in-progress",
    "priority": "high",
    "owner": "platform-team",
    "updated": "2025-01-19",
    "filename": "007-real-time-chat.md"
  },
  {
    "id": "011",
    "title": "Mobile App Push Notifications",
    "status": "in-progress",
    "priority": "high",
    "owner": "mobile-team",
    "updated": "2025-01-17",
    "filename": "011-mobile-push-notifications.md"
  },
  {
    "id": "016",
    "title": "Analytics Dashboard",
    "status": "in-progress",
    "priority": "high",
    "owner": "analytics-team",
    "updated": "2025-01-19",
    "filename": "016-analytics-dashboard.md"
  },
  {
    "id": "019",
    "title": "API Documentation Portal",
    "status": "in-progress",
    "priority": "medium",
    "owner": "docs-team",
    "updated": "2025-01-17",
    "filename": "019-api-documentation-portal.md"
  }
]
```

---

## Example 5: Markdown Format (For Documentation)

```bash
$ bash scripts/list-specs.sh --format markdown --priority high
```

**Output:**
```markdown
| ID | Title | Status | Priority | Owner | Updated |
|----|-------|--------|----------|-------|---------|
| 002 | API Rate Limiting | implemented | high | backend-team | 2024-12-20 |
| 005 | Email Notification Service | approved | high | platform-team | 2025-01-16 |
| 007 | Real-Time Chat System | in-progress | high | platform-team | 2025-01-19 |
| 011 | Mobile App Push Notifications | in-progress | high | mobile-team | 2025-01-17 |
| 013 | GraphQL API Implementation | approved | high | api-team | 2025-01-15 |
| 016 | Analytics Dashboard | in-progress | high | analytics-team | 2025-01-19 |
| 020 | A/B Testing Framework | draft | high | product-team | 2025-01-14 |
```

---

## Example 6: CSV Format (For Spreadsheets)

```bash
$ bash scripts/list-specs.sh --format csv --status review
```

**Output:**
```csv
ID,Title,Status,Priority,Owner,Updated,Filename
"004","Payment Gateway Integration","review","critical","payments-team","2025-01-17","004-payment-gateway.md"
"009","Multi-Factor Authentication","review","critical","security-team","2025-01-18","009-mfa.md"
"017","OAuth 2.0 Integration","review","critical","auth-team","2025-01-18","017-oauth-integration.md"
```

---

## Example 7: Filter by Tag

```bash
$ bash scripts/list-specs.sh --tag security
```

**Output:**
```
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
001    User Authentication System               implemented     🔴 critical  auth-team        2024-12-15
009    Multi-Factor Authentication              review          🔴 critical  security-team    2025-01-18
017    OAuth 2.0 Integration                    review          🔴 critical  auth-team        2025-01-18

Total specifications: 3
```

---

## Example 8: Combined Filters

```bash
$ bash scripts/list-specs.sh --status in-progress --priority high
```

**Output:**
```
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
007    Real-Time Chat System                    in-progress     🟠 high      platform-team    2025-01-19
011    Mobile App Push Notifications            in-progress     🟠 high      mobile-team      2025-01-17
016    Analytics Dashboard                      in-progress     🟠 high      analytics-team   2025-01-19

Total specifications: 3
```

---

## Example 9: Team View (Filter by Owner)

```bash
$ bash scripts/list-specs.sh | grep frontend-team
```

**Output:**
```
003    Dashboard Redesign                       in-progress     🟡 medium    frontend-team    2025-01-18
006    User Profile Management                  draft           🟡 medium    frontend-team    2025-01-15
015    User Profile Page                        draft           🟡 medium    frontend-team    2025-01-15
```

---

## Example 10: Status Distribution Report

```bash
$ bash scripts/list-specs.sh --format csv | cut -d',' -f3 | tail -n +2 | sort | uniq -c
```

**Output:**
```
      3 "approved"
      5 "draft"
      3 "implemented"
      5 "in-progress"
      1 "rejected"
      3 "review"
```

---

## Example 11: Priority Distribution

```bash
$ bash scripts/list-specs.sh --format csv | cut -d',' -f4 | tail -n +2 | sort | uniq -c
```

**Output:**
```
      5 "critical"
      7 "high"
      1 "low"
      7 "medium"
```

---

## Example 12: Recent Activity (Updated in Last 7 Days)

```bash
$ bash scripts/list-specs.sh | awk -F' ' '$NF >= "2025-01-13"'
```

**Output:**
```
003    Dashboard Redesign                       in-progress     🟡 medium    frontend-team    2025-01-18
004    Payment Gateway Integration              review          🔴 critical  payments-team    2025-01-17
005    Email Notification Service               approved        🟠 high      platform-team    2025-01-16
006    User Profile Management                  draft           🟡 medium    frontend-team    2025-01-15
007    Real-Time Chat System                    in-progress     🟠 high      platform-team    2025-01-19
008    Advanced Search Functionality            draft           🟡 medium    search-team      2025-01-14
009    Multi-Factor Authentication              review          🔴 critical  security-team    2025-01-18
011    Mobile App Push Notifications            in-progress     🟠 high      mobile-team      2025-01-17
013    GraphQL API Implementation               approved        🟠 high      api-team         2025-01-15
015    User Profile Page                        draft           🟡 medium    frontend-team    2025-01-15
016    Analytics Dashboard                      in-progress     🟠 high      analytics-team   2025-01-19
017    OAuth 2.0 Integration                    review          🔴 critical  auth-team        2025-01-18
018    Backup and Disaster Recovery             approved        🔴 critical  devops-team      2025-01-16
019    API Documentation Portal                 in-progress     🟡 medium    docs-team        2025-01-17
020    A/B Testing Framework                    draft           🟠 high      product-team     2025-01-14
```

---

## Example 13: Sprint Planning View (In-Progress + Approved)

```bash
$ bash scripts/list-specs.sh --status in-progress && bash scripts/list-specs.sh --status approved
```

**Output:**
```
## In Progress
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
003    Dashboard Redesign                       in-progress     🟡 medium    frontend-team    2025-01-18
007    Real-Time Chat System                    in-progress     🟠 high      platform-team    2025-01-19
011    Mobile App Push Notifications            in-progress     🟠 high      mobile-team      2025-01-17
016    Analytics Dashboard                      in-progress     🟠 high      analytics-team   2025-01-19
019    API Documentation Portal                 in-progress     🟡 medium    docs-team        2025-01-17

Total specifications: 5

## Approved (Ready to Start)
ID     Title                                    Status          Priority   Owner            Updated
--------------------------------------------------------------------------------------------------------------
005    Email Notification Service               approved        🟠 high      platform-team    2025-01-16
013    GraphQL API Implementation               approved        🟠 high      api-team         2025-01-15
018    Backup and Disaster Recovery             approved        🔴 critical  devops-team      2025-01-16

Total specifications: 3
```

---

## Example 14: Team Workload Summary

```bash
$ bash scripts/list-specs.sh --format csv --status in-progress | cut -d',' -f5 | tail -n +2 | sort | uniq -c | sort -rn
```

**Output:**
```
      2 "platform-team"
      1 "mobile-team"
      1 "frontend-team"
      1 "docs-team"
      1 "analytics-team"
```

---

## Example 15: Export for Project Management Tool

```bash
$ bash scripts/list-specs.sh --format json > specs-export.json
```

Then import `specs-export.json` into Jira, Linear, Asana, or other PM tools.

---

## Example 16: Dashboard View (HTML Table)

Convert markdown to HTML for internal dashboard:

```bash
$ bash scripts/list-specs.sh --format markdown | pandoc -f markdown -t html > specs-dashboard.html
```

**Result:** `specs-dashboard.html` with formatted table for team dashboard

---

## Using List in Scripts

### Check for Specs Needing Review

```bash
#!/bin/bash
# alert-stale-specs.sh - Find specs not updated in 30 days

THIRTY_DAYS_AGO=$(date -d '30 days ago' +%Y-%m-%d)

bash scripts/list-specs.sh --format csv | tail -n +2 | while IFS=',' read -r id title status priority owner updated filename; do
  updated=$(echo "$updated" | tr -d '"')
  if [[ "$updated" < "$THIRTY_DAYS_AGO" && "$status" != "implemented" && "$status" != "rejected" ]]; then
    echo "⚠️ Stale spec: $id - $title (last updated: $updated)"
  fi
done
```

### Generate Weekly Status Email

```bash
#!/bin/bash
# weekly-spec-report.sh

cat <<EOF
Weekly Specification Report - $(date +%Y-%m-%d)

📊 Status Summary:
$(bash scripts/list-specs.sh --format csv | tail -n +2 | cut -d',' -f3 | sort | uniq -c)

🔥 High Priority In Progress:
$(bash scripts/list-specs.sh --status in-progress --priority high --format markdown)

✅ Recently Approved:
$(bash scripts/list-specs.sh --status approved --format markdown)

⏳ Pending Review:
$(bash scripts/list-specs.sh --status review --format markdown)

📝 New Drafts:
$(bash scripts/list-specs.sh --status draft --format markdown)
EOF
```

### Integration with Slack Bot

```bash
#!/bin/bash
# slack-specs-summary.sh

JSON=$(bash scripts/list-specs.sh --format json --status in-progress)
COUNT=$(echo "$JSON" | jq '. | length')

curl -X POST -H 'Content-type: application/json' \
  --data "{
    \"text\": \"📊 Spec Update\",
    \"blocks\": [{
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"*$COUNT specs currently in progress*\"
      }
    }]
  }" \
  "$SLACK_WEBHOOK_URL"
```

---

## Tips for Using List Command

1. **Use JSON for scripting**: `--format json` for parsing with jq
2. **Use CSV for exports**: `--format csv` for spreadsheets
3. **Use markdown for docs**: `--format markdown` for documentation
4. **Combine with grep/awk**: Filter output further with Unix tools
5. **Create custom views**: Chain multiple list commands for custom reports
6. **Automate reporting**: Schedule daily/weekly status reports
7. **Track metrics**: Monitor spec distribution and team workload
8. **Integration**: Export to PM tools, dashboards, Slack
9. **Color coding**: Terminal colors help quickly identify priorities
10. **Pipe to files**: Save outputs for historical tracking
