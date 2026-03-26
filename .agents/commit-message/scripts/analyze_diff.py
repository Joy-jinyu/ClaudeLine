#!/usr/bin/env python3
"""
Analyze git diff and suggest commit message based on changes.
Usage: python analyze_diff.py [git_diff_file]
"""

import re
import sys
import argparse
from collections import defaultdict, Counter

def analyze_changes(diff_text):
    """
    Analyze git diff and categorize changes to suggest commit type and description.
    Returns (suggested_type, suggested_scope, suggested_description, analysis)
    """
    if not diff_text:
        return None, None, "empty diff", "No changes detected"

    # Track different types of changes
    changes = {
        'files_added': [],
        'files_deleted': [],
        'files_modified': [],
        'test_files': [],
        'doc_files': [],
        'config_files': [],
        'code_files': [],
        'lines_added': 0,
        'lines_deleted': 0
    }

    # Analyze file changes
    file_changes = re.findall(r'diff --git a/([^\s]+) b/([^\s]+)', diff_text)
    for old_file, new_file in file_changes:
        if old_file == '/dev/null':
            changes['files_added'].append(new_file)
        elif new_file == '/dev/null':
            changes['files_deleted'].append(old_file)
        else:
            changes['files_modified'].append(new_file)

        # Categorize files
        file_to_check = new_file if new_file != '/dev/null' else old_file
        if any(pattern in file_to_check.lower() for pattern in ['test', 'spec', '__test__']):
            changes['test_files'].append(file_to_check)
        elif any(pattern in file_to_check.lower() for pattern in ['readme', 'doc', '.md', 'changelog']):
            changes['doc_files'].append(file_to_check)
        elif any(file_to_check.endswith(ext) for ext in ['.json', '.yml', '.yaml', '.toml', '.ini', '.config']):
            changes['config_files'].append(file_to_check)
        else:
            changes['code_files'].append(file_to_check)

    # Count line changes
    added_lines = len(re.findall(r'^\+[^+]', diff_text, re.MULTILINE))
    deleted_lines = len(re.findall(r'^-[^-]', diff_text, re.MULTILINE))
    changes['lines_added'] = added_lines
    changes['lines_deleted'] = deleted_lines

    # Determine commit type based on changes
    commit_type = determine_commit_type(changes)
    scope = determine_scope(changes)
    description = generate_description(changes, commit_type)

    analysis = format_analysis(changes)

    return commit_type, scope, description, analysis

def determine_commit_type(changes):
    """Determine the most appropriate commit type based on changes."""

    # Test files only
    if changes['test_files'] and not changes['code_files']:
        return 'test'

    # Documentation only
    if changes['doc_files'] and not changes['code_files'] and not changes['test_files']:
        return 'docs'

    # Config files only
    if changes['config_files'] and not changes['code_files'] and not changes['test_files']:
        return 'chore'

    # New files suggest new features
    if changes['files_added'] and not changes['files_deleted']:
        if any('test' in f for f in changes['files_added']):
            return 'test'
        elif any('.md' in f for f in changes['files_added']):
            return 'docs'
        else:
            return 'feat'

    # Deleted files might be refactoring or fixes
    if changes['files_deleted']:
        return 'refactor'

    # Large changes might be refactoring
    total_changes = changes['lines_added'] + changes['lines_deleted']
    if total_changes > 100:
        return 'refactor'

    # Default to fix for modifications
    return 'fix'

def determine_scope(changes):
    """Determine appropriate scope based on file paths."""
    all_files = (changes['files_added'] + changes['files_deleted'] +
                 changes['files_modified'])

    if not all_files:
        return None

    # Extract potential scope from file paths
    scopes = []
    for file in all_files:
        parts = file.split('/')
        if len(parts) > 1:
            # Use the first meaningful directory
            potential_scope = parts[0]
            if potential_scope not in ['.', '..', 'src']:
                scopes.append(potential_scope)
            elif len(parts) > 2:
                scopes.append(parts[1])

    if scopes:
        # Return most common scope
        scope_counts = Counter(scopes)
        return scope_counts.most_common(1)[0][0]

    return None

def generate_description(changes, commit_type):
    """Generate a descriptive commit message based on changes."""
    descriptions = {
        'feat': generate_feat_description,
        'fix': generate_fix_description,
        'docs': generate_docs_description,
        'test': generate_test_description,
        'refactor': generate_refactor_description,
        'chore': generate_chore_description
    }

    generator = descriptions.get(commit_type, lambda x: "update code")
    return generator(changes)

def generate_feat_description(changes):
    if changes['files_added']:
        added_count = len(changes['files_added'])
        if added_count == 1:
            filename = changes['files_added'][0].split('/')[-1]
            return f"add {filename.replace('_', ' ').replace('-', ' ')}"
        else:
            return f"add {added_count} new files"
    return "add new functionality"

def generate_fix_description(changes):
    if len(changes['files_modified']) == 1:
        filename = changes['files_modified'][0].split('/')[-1]
        return f"resolve issue in {filename}"
    return "resolve bugs and issues"

def generate_docs_description(changes):
    if changes['doc_files']:
        doc_file = changes['doc_files'][0].split('/')[-1]
        if 'readme' in doc_file.lower():
            return "update README documentation"
        return f"update {doc_file} documentation"
    return "update documentation"

def generate_test_description(changes):
    test_count = len(changes['test_files'])
    if test_count == 1:
        return "add test coverage"
    elif test_count > 1:
        return f"add {test_count} test files"
    return "update tests"

def generate_refactor_description(changes):
    if changes['files_deleted']:
        return "restructure and clean up code"
    return "improve code structure"

def generate_chore_description(changes):
    if changes['config_files']:
        return "update configuration"
    return "update build tools and dependencies"

def format_analysis(changes):
    """Format the analysis for display."""
    analysis = []

    if changes['files_added']:
        analysis.append(f"Added: {', '.join(changes['files_added'])}")
    if changes['files_deleted']:
        analysis.append(f"Deleted: {', '.join(changes['files_deleted'])}")
    if changes['files_modified']:
        analysis.append(f"Modified: {', '.join(changes['files_modified'])}")

    analysis.append(f"Lines: +{changes['lines_added']}, -{changes['lines_deleted']}")

    return "\n".join(analysis)

def main():
    parser = argparse.ArgumentParser(description="Analyze git diff and suggest commit message")
    parser.add_argument("diff_file", nargs="?", help="Git diff file (or stdin if not provided)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show detailed analysis")

    args = parser.parse_args()

    # Read diff from file or stdin
    if args.diff_file:
        try:
            with open(args.diff_file, 'r') as f:
                diff_text = f.read()
        except FileNotFoundError:
            print(f"Error: File '{args.diff_file}' not found")
            sys.exit(1)
    else:
        diff_text = sys.stdin.read()

    commit_type, scope, description, analysis = analyze_changes(diff_text)

    if commit_type:
        # Generate commit message
        scope_part = f"({scope})" if scope else ""
        suggested_message = f"{commit_type}{scope_part}: {description}"

        print("📝 Suggested commit message:")
        print(f"   {suggested_message}")

        if args.verbose:
            print("\n📊 Analysis:")
            print(analysis)
            print(f"\nCommit type: {commit_type}")
            print(f"Scope: {scope or 'none'}")
    else:
        print("❌ Unable to analyze diff - no changes detected")
        sys.exit(1)

if __name__ == "__main__":
    main()