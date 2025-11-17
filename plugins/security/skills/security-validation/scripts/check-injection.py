#!/usr/bin/env python3
"""
Prompt Injection Detection

Detects prompt injection attempts using pattern matching and applies spotlighting
technique to mark boundaries of untrusted content.

Usage:
    python check-injection.py "<user-input>"
    echo "input" | python check-injection.py

Exit Codes:
    0 - Low/medium risk
    1 - High risk
    2 - Critical risk
"""

import re
import sys
import json
from typing import Dict, List, Tuple

# Prompt injection patterns
INJECTION_PATTERNS = {
    "instruction_override": {
        "patterns": [
            r"ignore\s+(all\s+)?(previous|prior|above)\s+instructions",
            r"disregard\s+(all\s+)?(previous|prior)\s+",
            r"forget\s+(everything|all)",
            r"new\s+instructions?:",
            r"instead,?\s+(do|follow|execute)",
        ],
        "severity": "critical",
        "description": "Attempting to override system instructions"
    },
    "role_confusion": {
        "patterns": [
            r"you\s+are\s+now\s+",
            r"pretend\s+(you\s+are|to\s+be)",
            r"act\s+as\s+(if\s+)?",
            r"imagine\s+you(\'re|\s+are)",
            r"from\s+now\s+on,?\s+you",
        ],
        "severity": "high",
        "description": "Attempting to change AI role or behavior"
    },
    "context_manipulation": {
        "patterns": [
            r"system\s*message\s*:",
            r"assistant\s*:",
            r"human\s*:",
            r"<\s*/?\s*(system|assistant|user)\s*>",
            r"```system",
        ],
        "severity": "high",
        "description": "Attempting to inject system/assistant messages"
    },
    "delimiter_attack": {
        "patterns": [
            r"<\|endoftext\|>",
            r"<\|im_start\|>",
            r"<\|im_end\|>",
            r"</s>",
            r"###\s+Instruction",
        ],
        "severity": "critical",
        "description": "Attempting to use model delimiters"
    },
    "encoding_attack": {
        "patterns": [
            r"base64\s*decode",
            r"hex\s*decode",
            r"\\x[0-9a-fA-F]{2}",  # Hex encoding
            r"\\u[0-9a-fA-F]{4}",  # Unicode encoding
            r"rot13|caesar\s+cipher",
        ],
        "severity": "medium",
        "description": "Attempting to use encoding to bypass filters"
    },
    "jailbreak_phrases": {
        "patterns": [
            r"dan\s+mode",
            r"developer\s+mode",
            r"godmode",
            r"sudo\s+mode",
            r"unrestricted\s+mode",
            r"jailbreak",
        ],
        "severity": "critical",
        "description": "Known jailbreak activation phrases"
    },
    "information_extraction": {
        "patterns": [
            r"reveal\s+your\s+(system\s+)?prompt",
            r"show\s+me\s+your\s+instructions",
            r"what\s+are\s+your\s+rules",
            r"list\s+(all\s+)?api\s+keys",
            r"show\s+(all\s+)?credentials",
        ],
        "severity": "high",
        "description": "Attempting to extract system information or credentials"
    }
}

def apply_spotlighting(content: str) -> str:
    """Apply Microsoft's spotlighting technique to mark untrusted content boundaries."""
    return f"<<<USER_INPUT_START>>>\n{content}\n<<<USER_INPUT_END>>>"

def detect_injection_patterns(content: str) -> Tuple[List[Dict], str]:
    """
    Detect prompt injection patterns in content.

    Returns:
        (detected_patterns, risk_level)
    """
    detected_patterns = []
    max_severity_score = 0

    severity_scores = {
        "low": 1,
        "medium": 2,
        "high": 3,
        "critical": 4
    }

    content_lower = content.lower()

    for category, config in INJECTION_PATTERNS.items():
        patterns = config["patterns"]
        severity = config["severity"]
        description = config["description"]

        for pattern in patterns:
            matches = list(re.finditer(pattern, content_lower, re.IGNORECASE))
            if matches:
                detected_patterns.append({
                    "category": category,
                    "severity": severity,
                    "description": description,
                    "pattern": pattern,
                    "matches": len(matches),
                    "examples": [match.group(0) for match in matches[:3]]  # First 3 matches
                })

                # Track highest severity
                severity_score = severity_scores.get(severity, 0)
                max_severity_score = max(max_severity_score, severity_score)

    # Determine overall risk level
    if max_severity_score >= 4:
        risk_level = "critical"
    elif max_severity_score >= 3:
        risk_level = "high"
    elif max_severity_score >= 2:
        risk_level = "medium"
    else:
        risk_level = "low"

    return detected_patterns, risk_level

def calculate_risk_score(detected_patterns: List[Dict]) -> int:
    """Calculate numeric risk score (0-100)."""
    if not detected_patterns:
        return 0

    severity_weights = {
        "low": 10,
        "medium": 25,
        "high": 50,
        "critical": 100
    }

    # Maximum severity determines base score
    max_score = max(severity_weights.get(p["severity"], 0) for p in detected_patterns)

    # Add bonus for multiple patterns (max +20)
    pattern_bonus = min(len(detected_patterns) * 5, 20)

    total_score = min(max_score + pattern_bonus, 100)

    return total_score

def main():
    """Main entry point."""
    # Read input from argument or stdin
    if len(sys.argv) > 1:
        content = ' '.join(sys.argv[1:])
    else:
        content = sys.stdin.read()

    if not content.strip():
        print(json.dumps({
            "risk_level": "low",
            "risk_score": 0,
            "detected_patterns": [],
            "spotted_content": "",
            "recommendation": "No input provided"
        }))
        sys.exit(0)

    # Detect injection patterns
    detected_patterns, risk_level = detect_injection_patterns(content)

    # Calculate risk score
    risk_score = calculate_risk_score(detected_patterns)

    # Apply spotlighting
    spotted_content = apply_spotlighting(content)

    # Generate recommendation
    if risk_level == "critical":
        recommendation = "BLOCK: Critical injection attempt detected. Do not process this input."
    elif risk_level == "high":
        recommendation = "WARN: High-risk patterns detected. Require user confirmation before processing."
    elif risk_level == "medium":
        recommendation = "CAUTION: Medium-risk patterns detected. Use spotted content with boundaries."
    else:
        recommendation = "SAFE: No significant injection patterns detected. Process normally with spotlighting."

    # Output results as JSON
    result = {
        "risk_level": risk_level,
        "risk_score": risk_score,
        "detected_patterns": detected_patterns,
        "spotted_content": spotted_content,
        "pattern_count": len(detected_patterns),
        "recommendation": recommendation
    }

    print(json.dumps(result, indent=2))

    # Exit with appropriate code
    if risk_level == "critical":
        sys.exit(2)
    elif risk_level == "high":
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
