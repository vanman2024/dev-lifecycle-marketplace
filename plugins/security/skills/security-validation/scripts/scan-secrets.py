#!/usr/bin/env python3
"""
Runtime Secret Scanner

Detects hardcoded API keys, tokens, and credentials using pattern matching and entropy analysis.
BLOCKS file writes if real secrets are detected.

Usage:
    python scan-secrets.py <file-path>
    echo "content" | python scan-secrets.py

Exit Codes:
    0 - No secrets found (safe)
    1 - Secrets detected (blocked)
"""

import re
import sys
import json
import math
from pathlib import Path
from typing import Dict, List, Tuple

# Secret patterns for major providers
SECRET_PATTERNS = {
    "anthropic_api_key": r"sk-ant-api03-[A-Za-z0-9_-]{95,}",
    "openai_api_key": r"sk-[A-Za-z0-9]{32,}",
    "aws_access_key": r"AKIA[0-9A-Z]{16}",
    "google_api_key": r"AIza[0-9A-Za-z_-]{35}",
    "github_token": r"gh[pousr]_[A-Za-z0-9]{36,}",
    "supabase_anon_key": r"eyJ[A-Za-z0-9_-]{100,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{40,}",
    "stripe_key": r"sk_(live|test)_[A-Za-z0-9]{24,}",
    "bearer_token": r"Bearer\s+[A-Za-z0-9\-._~+/]+=*",
    "basic_auth": r"Basic\s+[A-Za-z0-9+/=]{20,}",
    "private_key": r"-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----",
}

# Safe placeholder patterns (these are allowed)
PLACEHOLDER_PATTERNS = [
    r"your_[a-z_]+_key_here",
    r"your_[a-z_]+ _here",
    r"<your-.*>",
    r"\{your-.*\}",
    r"placeholder",
    r"example",
    r"test_key_",
    r"demo_key_",
    r"REPLACE_ME",
    r"TODO:",
]

def calculate_shannon_entropy(text: str) -> float:
    """Calculate Shannon entropy of a string (measure of randomness)."""
    if not text:
        return 0.0

    entropy = 0.0
    text_len = len(text)

    # Count character frequencies
    char_counts = {}
    for char in text:
        char_counts[char] = char_counts.get(char, 0) + 1

    # Calculate entropy
    for count in char_counts.values():
        probability = count / text_len
        if probability > 0:
            entropy -= probability * math.log2(probability)

    return entropy

def is_high_entropy(text: str, threshold: float = 4.5) -> bool:
    """Check if string has high entropy (likely a secret)."""
    # Ignore short strings
    if len(text) < 20:
        return False

    entropy = calculate_shannon_entropy(text)
    return entropy > threshold

def is_placeholder(text: str) -> bool:
    """Check if text matches placeholder patterns (safe)."""
    text_lower = text.lower()
    for pattern in PLACEHOLDER_PATTERNS:
        if re.search(pattern, text_lower, re.IGNORECASE):
            return True
    return False

def scan_content(content: str) -> Tuple[bool, List[Dict], List[Dict]]:
    """
    Scan content for secrets.

    Returns:
        (blocked, violations, entropy_scores)
    """
    violations = []
    entropy_scores = []

    lines = content.split('\n')

    for line_num, line in enumerate(lines, 1):
        # Skip comments and empty lines
        if line.strip().startswith('#') or not line.strip():
            continue

        # Check for known secret patterns
        for secret_type, pattern in SECRET_PATTERNS.items():
            matches = re.finditer(pattern, line)
            for match in matches:
                matched_text = match.group(0)

                # Skip if it's a placeholder
                if is_placeholder(matched_text):
                    continue

                violations.append({
                    "type": secret_type,
                    "line": line_num,
                    "pattern": pattern,
                    "context": line.strip()[:100],  # First 100 chars
                    "severity": "critical"
                })

        # Check for high-entropy strings in assignments
        # Matches: KEY=value, "key": "value", api_key: value
        assignment_patterns = [
            r'([A-Z_]+)\s*=\s*["\']?([A-Za-z0-9+/=_-]{20,})["\']?',
            r'["\']([a-z_]+)["\']:\s*["\']([A-Za-z0-9+/=_-]{20,})["\']',
        ]

        for pattern in assignment_patterns:
            matches = re.finditer(pattern, line)
            for match in matches:
                key = match.group(1)
                value = match.group(2)

                # Skip placeholders
                if is_placeholder(value):
                    continue

                # Check entropy
                entropy = calculate_shannon_entropy(value)
                entropy_scores.append({
                    "key": key,
                    "entropy": round(entropy, 2),
                    "line": line_num,
                    "length": len(value)
                })

                if is_high_entropy(value):
                    violations.append({
                        "type": "high_entropy_secret",
                        "line": line_num,
                        "key": key,
                        "entropy": round(entropy, 2),
                        "context": line.strip()[:100],
                        "severity": "high"
                    })

    blocked = len([v for v in violations if v["severity"] == "critical"]) > 0

    return blocked, violations, entropy_scores

def main():
    """Main entry point."""
    # Read input from file or stdin
    if len(sys.argv) > 1:
        file_path = Path(sys.argv[1])
        if not file_path.exists():
            print(json.dumps({
                "error": true,
                "message": f"File not found: {file_path}",
                "code": "FILE_NOT_FOUND"
            }))
            sys.exit(3)

        content = file_path.read_text()
    else:
        content = sys.stdin.read()

    # Scan content
    blocked, violations, entropy_scores = scan_content(content)

    # Output results as JSON
    result = {
        "blocked": blocked,
        "violations": violations,
        "entropy_scores": entropy_scores,
        "total_violations": len(violations),
        "critical_violations": len([v for v in violations if v["severity"] == "critical"]),
        "high_entropy_detected": len([s for s in entropy_scores if s["entropy"] > 4.5])
    }

    print(json.dumps(result, indent=2))

    # Exit with appropriate code
    sys.exit(1 if blocked else 0)

if __name__ == "__main__":
    main()
