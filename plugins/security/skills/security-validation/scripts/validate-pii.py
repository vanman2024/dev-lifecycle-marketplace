#!/usr/bin/env python3
"""
PII Detection and Masking

Detects and automatically masks Personally Identifiable Information (PII) in content.
Maintains audit trail of PII encounters for compliance.

Usage:
    python validate-pii.py "<content>"
    echo "content" | python validate-pii.py

Exit Codes:
    0 - Always (non-blocking, logs only)
"""

import re
import sys
import json
from typing import Dict, List, Tuple

# PII detection patterns
PII_PATTERNS = {
    "email": {
        "pattern": r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
        "mask": "***@***.***",
        "severity": "medium"
    },
    "phone_us": {
        "pattern": r'\b(?:\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b',
        "mask": "***-***-****",
        "severity": "medium"
    },
    "phone_international": {
        "pattern": r'\+[1-9]\d{1,14}\b',
        "mask": "+***********",
        "severity": "medium"
    },
    "ssn": {
        "pattern": r'\b\d{3}-\d{2}-\d{4}\b',
        "mask": "***-**-****",
        "severity": "high"
    },
    "credit_card": {
        "pattern": r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
        "mask": "****-****-****-****",
        "severity": "critical"
    },
    "ip_address": {
        "pattern": r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b',
        "mask": "***.***.***.***",
        "severity": "low"
    },
    "street_address": {
        "pattern": r'\b\d+\s+[\w\s]+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir)\b',
        "mask": "*** *** Street",
        "severity": "medium"
    },
    "zip_code": {
        "pattern": r'\b\d{5}(?:-\d{4})?\b',
        "mask": "*****",
        "severity": "low"
    },
}

def detect_pii(content: str) -> Tuple[bool, List[Dict], str]:
    """
    Detect and mask PII in content.

    Returns:
        (has_pii, pii_detections, masked_content)
    """
    pii_detections = []
    masked_content = content

    # Track line numbers for audit trail
    lines = content.split('\n')

    for pii_type, config in PII_PATTERNS.items():
        pattern = config["pattern"]
        mask = config["mask"]
        severity = config["severity"]

        # Find all matches
        matches = list(re.finditer(pattern, content, re.IGNORECASE))

        if matches:
            # Record detections
            for match in matches:
                matched_text = match.group(0)

                # Find line number
                line_num = content[:match.start()].count('\n') + 1

                pii_detections.append({
                    "type": pii_type,
                    "value": matched_text[:20] + "..." if len(matched_text) > 20 else matched_text,  # Truncated for security
                    "line": line_num,
                    "severity": severity,
                    "masked": True
                })

            # Mask all occurrences
            masked_content = re.sub(pattern, mask, masked_content, flags=re.IGNORECASE)

    has_pii = len(pii_detections) > 0

    return has_pii, pii_detections, masked_content

def get_pii_summary(pii_detections: List[Dict]) -> Dict:
    """Generate summary statistics for PII detections."""
    summary = {
        "total_detected": len(pii_detections),
        "by_type": {},
        "by_severity": {
            "critical": 0,
            "high": 0,
            "medium": 0,
            "low": 0
        }
    }

    for detection in pii_detections:
        pii_type = detection["type"]
        severity = detection["severity"]

        # Count by type
        summary["by_type"][pii_type] = summary["by_type"].get(pii_type, 0) + 1

        # Count by severity
        summary["by_severity"][severity] += 1

    return summary

def main():
    """Main entry point."""
    # Read input from argument or stdin
    if len(sys.argv) > 1:
        content = ' '.join(sys.argv[1:])
    else:
        content = sys.stdin.read()

    if not content.strip():
        print(json.dumps({
            "has_pii": False,
            "masked_content": "",
            "pii_types": [],
            "summary": {"total_detected": 0}
        }))
        sys.exit(0)

    # Detect and mask PII
    has_pii, pii_detections, masked_content = detect_pii(content)

    # Generate summary
    summary = get_pii_summary(pii_detections)

    # Output results as JSON
    result = {
        "has_pii": has_pii,
        "masked_content": masked_content,
        "pii_detections": pii_detections,
        "pii_types": list(set(d["type"] for d in pii_detections)),
        "summary": summary
    }

    print(json.dumps(result, indent=2))

    # Always exit 0 (non-blocking)
    sys.exit(0)

if __name__ == "__main__":
    main()
