#!/usr/bin/env python3
"""
Output Validation and Exfiltration Prevention

Detects data exfiltration attempts in agent-generated output including markdown injection,
suspicious URLs, and base64-encoded data. Validates external URLs against allowlist.

Usage:
    python validate-output.py <file-path>
    echo "content" | python validate-output.py

Exit Codes:
    0 - Safe output
    1 - Unsafe output (blocked)
"""

import re
import sys
import json
from pathlib import Path
from typing import Dict, List, Tuple
from urllib.parse import urlparse, parse_qs

# Exfiltration detection patterns
EXFILTRATION_PATTERNS = {
    "markdown_image_injection": {
        "pattern": r'!\[.*?\]\(https?://[^/)]+/[^)]*[?&][^)]*\)',
        "severity": "critical",
        "description": "Markdown image with query parameters (potential data exfiltration)"
    },
    "base64_subdomain": {
        "pattern": r'https?://[A-Za-z0-9+/=]{20,}\.[A-Za-z0-9.-]+',
        "severity": "critical",
        "description": "Base64-encoded data in subdomain (exfiltration technique)"
    },
    "data_url": {
        "pattern": r'data:[^,]+,[A-Za-z0-9+/=]{50,}',
        "severity": "high",
        "description": "Large data URL (potential data exfiltration)"
    },
    "external_link_with_data": {
        "pattern": r'https?://[^/\s]+/[^?\s]*\?[^#\s]{100,}',
        "severity": "high",
        "description": "External URL with large query string (potential data in params)"
    },
    "webhook_url": {
        "pattern": r'https?://[^/\s]*webhook[^/\s]*/[^\s]+',
        "severity": "medium",
        "description": "Webhook URL (verify if expected)"
    },
    "suspicious_callback": {
        "pattern": r'https?://[^/\s]*/?(callback|collect|track|beacon|pixel)[^/\s]*',
        "severity": "medium",
        "description": "Tracking/callback URL"
    }
}

# Trusted domains (allowlist)
TRUSTED_DOMAINS = {
    # Development
    "localhost",
    "127.0.0.1",
    "0.0.0.0",

    # Major AI providers
    "anthropic.com",
    "openai.com",
    "google.com",
    "googleapis.com",
    "microsoft.com",
    "azure.com",

    # Development platforms
    "github.com",
    "gitlab.com",
    "bitbucket.org",

    # Cloud platforms
    "vercel.com",
    "vercel.app",
    "netlify.com",
    "netlify.app",
    "railway.app",

    # Database/backend
    "supabase.com",
    "supabase.co",
    "firebase.com",
    "firebaseapp.com",

    # Documentation/resources
    "docs.anthropic.com",
    "platform.openai.com",
    "cloud.google.com",
}

def is_trusted_domain(url: str) -> bool:
    """Check if URL domain is in allowlist."""
    try:
        parsed = urlparse(url)
        domain = parsed.netloc.lower()

        # Remove port if present
        if ':' in domain:
            domain = domain.split(':')[0]

        # Check exact match
        if domain in TRUSTED_DOMAINS:
            return True

        # Check subdomain match (e.g., api.github.com matches github.com)
        for trusted in TRUSTED_DOMAINS:
            if domain.endswith('.' + trusted) or domain == trusted:
                return True

        return False
    except Exception:
        return False

def detect_exfiltration_patterns(content: str) -> Tuple[List[Dict], bool]:
    """
    Detect exfiltration patterns in content.

    Returns:
        (violations, is_safe)
    """
    violations = []

    for pattern_name, config in EXFILTRATION_PATTERNS.items():
        pattern = config["pattern"]
        severity = config["severity"]
        description = config["description"]

        matches = list(re.finditer(pattern, content, re.IGNORECASE))

        if matches:
            for match in matches:
                matched_text = match.group(0)

                # Find line number
                line_num = content[:match.start()].count('\n') + 1

                violations.append({
                    "type": pattern_name,
                    "severity": severity,
                    "description": description,
                    "line": line_num,
                    "matched": matched_text[:100],  # Truncate for security
                    "context": content[max(0, match.start()-50):match.end()+50]
                })

    # Check all URLs
    url_pattern = r'https?://[^\s\)]+'
    url_matches = re.finditer(url_pattern, content)

    untrusted_urls = []
    for match in url_matches:
        url = match.group(0)
        if not is_trusted_domain(url):
            line_num = content[:match.start()].count('\n') + 1
            untrusted_urls.append({
                "url": url,
                "line": line_num,
                "trusted": False
            })

    # Add untrusted URLs as violations
    for url_info in untrusted_urls:
        violations.append({
            "type": "untrusted_external_url",
            "severity": "medium",
            "description": "URL to untrusted domain (not in allowlist)",
            "line": url_info["line"],
            "matched": url_info["url"]
        })

    # Determine if safe
    critical_violations = [v for v in violations if v["severity"] == "critical"]
    is_safe = len(critical_violations) == 0

    return violations, is_safe

def sanitize_content(content: str, violations: List[Dict]) -> str:
    """
    Remove or sanitize violations from content.

    Returns:
        sanitized_content
    """
    sanitized = content

    # Remove critical violations
    critical_violations = [v for v in violations if v["severity"] == "critical"]

    for violation in critical_violations:
        matched = violation.get("matched", "")
        if matched:
            # Replace with warning comment
            warning = f"[BLOCKED: {violation['description']}]"
            sanitized = sanitized.replace(matched, warning)

    return sanitized

def main():
    """Main entry point."""
    # Read input from file or stdin
    if len(sys.argv) > 1:
        file_path = Path(sys.argv[1])
        if not file_path.exists():
            print(json.dumps({
                "error": True,
                "message": f"File not found: {file_path}",
                "code": "FILE_NOT_FOUND"
            }))
            sys.exit(3)

        content = file_path.read_text()
    else:
        content = sys.stdin.read()

    if not content.strip():
        print(json.dumps({
            "safe": True,
            "violations": [],
            "sanitized_content": "",
            "untrusted_url_count": 0
        }))
        sys.exit(0)

    # Detect exfiltration patterns
    violations, is_safe = detect_exfiltration_patterns(content)

    # Sanitize if needed
    sanitized_content = sanitize_content(content, violations) if not is_safe else content

    # Count untrusted URLs
    untrusted_url_count = len([v for v in violations if v["type"] == "untrusted_external_url"])

    # Generate summary
    summary = {
        "total_violations": len(violations),
        "by_severity": {
            "critical": len([v for v in violations if v["severity"] == "critical"]),
            "high": len([v for v in violations if v["severity"] == "high"]),
            "medium": len([v for v in violations if v["severity"] == "medium"]),
        }
    }

    # Output results as JSON
    result = {
        "safe": is_safe,
        "violations": violations,
        "sanitized_content": sanitized_content,
        "untrusted_url_count": untrusted_url_count,
        "summary": summary,
        "recommendation": "SAFE: No critical violations" if is_safe else "BLOCKED: Critical exfiltration patterns detected"
    }

    print(json.dumps(result, indent=2))

    # Exit with appropriate code
    sys.exit(0 if is_safe else 1)

if __name__ == "__main__":
    main()
