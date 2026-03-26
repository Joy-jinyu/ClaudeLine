#!/usr/bin/env python3
"""
Validate commit message format against Conventional Commits and Udacity style guide.
Usage: python validate_commit.py "commit message"
"""

import re
import sys
import argparse

# Valid commit types
VALID_TYPES = {
    'feat', 'fix', 'docs', 'style', 'refactor',
    'perf', 'test', 'chore', 'build', 'ci'
}

def validate_commit_message(message):
    """
    Validate commit message and return (is_valid, errors, warnings)
    """
    errors = []
    warnings = []

    lines = message.split('\n')
    subject = lines[0] if lines else ""

    # Check if message is empty
    if not message.strip():
        errors.append("Commit message cannot be empty")
        return False, errors, warnings

    # Parse subject line
    subject_pattern = r'^(\w+)(\([^)]+\))?: (.+)$'
    match = re.match(subject_pattern, subject)

    if not match:
        errors.append("Subject line must follow format: type(scope): description")
        return False, errors, warnings

    commit_type, scope, description = match.groups()

    # Validate commit type
    if commit_type not in VALID_TYPES:
        errors.append(f"Invalid commit type '{commit_type}'. Valid types: {', '.join(sorted(VALID_TYPES))}")

    # Check subject line length
    if len(subject) > 50:
        errors.append(f"Subject line too long ({len(subject)} chars). Max 50 characters.")

    # Check description
    if not description:
        errors.append("Description cannot be empty")
    elif description[0].isupper():
        warnings.append("Description should start with lowercase letter")
    elif description.endswith('.'):
        warnings.append("Description should not end with a period")

    # Check for imperative mood (basic check)
    non_imperative_words = ['added', 'fixed', 'updated', 'changed', 'removed']
    first_word = description.split()[0].lower() if description else ""
    if first_word in non_imperative_words:
        warnings.append(f"Consider using imperative mood: '{first_word}' -> '{first_word.rstrip('d')}'")

    # Check body formatting if present
    if len(lines) > 1:
        # Check for blank line after subject
        if len(lines) > 1 and lines[1].strip():
            errors.append("Subject and body must be separated by a blank line")

        # Check body line length
        for i, line in enumerate(lines[2:], 3):
            if line.strip() and len(line) > 72:
                warnings.append(f"Line {i} exceeds 72 characters ({len(line)} chars)")

    is_valid = len(errors) == 0
    return is_valid, errors, warnings

def main():
    parser = argparse.ArgumentParser(description="Validate commit message format")
    parser.add_argument("message", help="Commit message to validate")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show detailed output")

    args = parser.parse_args()

    is_valid, errors, warnings = validate_commit_message(args.message)

    if is_valid:
        print("✅ Commit message is valid!")
        if warnings and args.verbose:
            print("\n⚠️  Suggestions:")
            for warning in warnings:
                print(f"  - {warning}")
    else:
        print("❌ Commit message has errors:")
        for error in errors:
            print(f"  - {error}")

        if warnings:
            print("\n⚠️  Additional suggestions:")
            for warning in warnings:
                print(f"  - {warning}")

        sys.exit(1)

if __name__ == "__main__":
    main()