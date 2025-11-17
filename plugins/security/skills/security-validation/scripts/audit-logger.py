#!/usr/bin/env python3
"""
Structured Audit Logger

Creates and manages structured audit logs for all agent actions and security events.
Supports JSON Lines format with daily rotation.

Usage:
    # Log an event
    python audit-logger.py log --agent="agent-name" --action="file_write" --path="file.md"

    # Query logs
    python audit-logger.py query --date="2025-01-15" --agent="agent-name"

    # Generate daily report
    python audit-logger.py report --date="2025-01-15"

    # Clean up old logs
    python audit-logger.py cleanup --days=90

Exit Codes:
    0 - Success
    1 - Error
"""

import sys
import json
import argparse
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional

# Audit log directory
AUDIT_LOG_DIR = Path.home() / ".claude" / "security" / "audit-logs"

def ensure_log_directory():
    """Create audit log directory if it doesn't exist."""
    AUDIT_LOG_DIR.mkdir(parents=True, exist_ok=True)

def get_log_file_path(date: Optional[str] = None) -> Path:
    """Get the log file path for a specific date."""
    if date:
        log_date = datetime.strptime(date, "%Y-%m-%d")
    else:
        log_date = datetime.now()

    filename = log_date.strftime("%Y-%m-%d.jsonl")
    return AUDIT_LOG_DIR / filename

def log_event(
    agent: str,
    action: str,
    path: Optional[str] = None,
    result: str = "success",
    security_events: Optional[List[Dict]] = None,
    risk_level: str = "low",
    details: Optional[Dict] = None
):
    """Log an audit event."""
    ensure_log_directory()

    log_entry = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "agent": agent,
        "action": action,
        "result": result,
        "risk_level": risk_level
    }

    if path:
        log_entry["path"] = path

    if security_events:
        log_entry["security_events"] = security_events

    if details:
        log_entry["details"] = details

    # Append to today's log file
    log_file = get_log_file_path()
    with log_file.open('a') as f:
        f.write(json.dumps(log_entry) + '\n')

    print(json.dumps({"status": "logged", "file": str(log_file)}, indent=2))

def query_logs(
    date: Optional[str] = None,
    agent: Optional[str] = None,
    action: Optional[str] = None,
    risk_level: Optional[str] = None
) -> List[Dict]:
    """Query audit logs with filters."""
    if not date:
        date = datetime.now().strftime("%Y-%m-%d")

    log_file = get_log_file_path(date)

    if not log_file.exists():
        return []

    results = []

    with log_file.open('r') as f:
        for line in f:
            if not line.strip():
                continue

            entry = json.loads(line)

            # Apply filters
            if agent and entry.get("agent") != agent:
                continue
            if action and entry.get("action") != action:
                continue
            if risk_level and entry.get("risk_level") != risk_level:
                continue

            results.append(entry)

    return results

def generate_report(date: Optional[str] = None) -> Dict:
    """Generate a summary report for a specific date."""
    if not date:
        date = datetime.now().strftime("%Y-%m-%d")

    logs = query_logs(date=date)

    if not logs:
        return {
            "date": date,
            "total_events": 0,
            "message": "No events logged for this date"
        }

    # Aggregate statistics
    report = {
        "date": date,
        "total_events": len(logs),
        "by_agent": {},
        "by_action": {},
        "by_risk_level": {
            "low": 0,
            "medium": 0,
            "high": 0,
            "critical": 0
        },
        "security_events": {
            "total": 0,
            "by_type": {}
        },
        "errors": 0
    }

    for entry in logs:
        # Count by agent
        agent = entry.get("agent", "unknown")
        report["by_agent"][agent] = report["by_agent"].get(agent, 0) + 1

        # Count by action
        action = entry.get("action", "unknown")
        report["by_action"][action] = report["by_action"].get(action, 0) + 1

        # Count by risk level
        risk_level = entry.get("risk_level", "low")
        report["by_risk_level"][risk_level] += 1

        # Count errors
        if entry.get("result") == "error":
            report["errors"] += 1

        # Count security events
        security_events = entry.get("security_events", [])
        if security_events:
            report["security_events"]["total"] += len(security_events)
            for event in security_events:
                event_type = event.get("type", "unknown")
                report["security_events"]["by_type"][event_type] = \
                    report["security_events"]["by_type"].get(event_type, 0) + 1

    return report

def cleanup_old_logs(retention_days: int = 90):
    """Remove audit logs older than retention period."""
    ensure_log_directory()

    cutoff_date = datetime.now() - timedelta(days=retention_days)

    removed_files = []

    for log_file in AUDIT_LOG_DIR.glob("*.jsonl"):
        try:
            # Extract date from filename
            file_date_str = log_file.stem
            file_date = datetime.strptime(file_date_str, "%Y-%m-%d")

            if file_date < cutoff_date:
                log_file.unlink()
                removed_files.append(str(log_file))
        except (ValueError, OSError):
            continue

    return {
        "removed_count": len(removed_files),
        "removed_files": removed_files,
        "retention_days": retention_days
    }

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Structured Audit Logger")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Log command
    log_parser = subparsers.add_parser("log", help="Log an audit event")
    log_parser.add_argument("--agent", required=True, help="Agent name")
    log_parser.add_argument("--action", required=True, help="Action type")
    log_parser.add_argument("--path", help="File path (optional)")
    log_parser.add_argument("--result", default="success", help="Result (success/error)")
    log_parser.add_argument("--security-events", help="Security events JSON")
    log_parser.add_argument("--risk-level", default="low", help="Risk level")
    log_parser.add_argument("--details", help="Additional details JSON")

    # Query command
    query_parser = subparsers.add_parser("query", help="Query audit logs")
    query_parser.add_argument("--date", help="Date (YYYY-MM-DD)")
    query_parser.add_argument("--agent", help="Filter by agent")
    query_parser.add_argument("--action", help="Filter by action")
    query_parser.add_argument("--risk-level", help="Filter by risk level")

    # Report command
    report_parser = subparsers.add_parser("report", help="Generate daily report")
    report_parser.add_argument("--date", help="Date (YYYY-MM-DD)")

    # Cleanup command
    cleanup_parser = subparsers.add_parser("cleanup", help="Remove old logs")
    cleanup_parser.add_argument("--days", type=int, default=90, help="Retention days")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    try:
        if args.command == "log":
            security_events = json.loads(args.security_events) if args.security_events else None
            details = json.loads(args.details) if args.details else None

            log_event(
                agent=args.agent,
                action=args.action,
                path=args.path,
                result=args.result,
                security_events=security_events,
                risk_level=args.risk_level,
                details=details
            )

        elif args.command == "query":
            results = query_logs(
                date=args.date,
                agent=args.agent,
                action=args.action,
                risk_level=args.risk_level
            )
            print(json.dumps(results, indent=2))

        elif args.command == "report":
            report = generate_report(date=args.date)
            print(json.dumps(report, indent=2))

        elif args.command == "cleanup":
            result = cleanup_old_logs(retention_days=args.days)
            print(json.dumps(result, indent=2))

        sys.exit(0)

    except Exception as e:
        print(json.dumps({
            "error": True,
            "message": str(e),
            "code": "EXECUTION_ERROR"
        }), file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
