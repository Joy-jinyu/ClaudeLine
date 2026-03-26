---
name: commit-message
description: Generate high-quality commit messages following Conventional Commits and industry best practices. Use when users need to create git commit messages (including /commit slash command), validate commit formats (/commit-validate), analyze git diffs, or want guidance on commit message standards. Automatically analyzes git changes to suggest appropriate commit types, scopes, and descriptions.
---

# Commit Message

## Overview

This skill helps generate professional, standardized commit messages that follow Conventional Commits specification and industry best practices like the Udacity Git Style Guide. It analyzes git diffs to automatically suggest appropriate commit types, scopes, and descriptions, and provides validation tools to ensure commit messages meet quality standards.

## Slash Commands

Use these convenient slash commands for quick access:

### `/commit`
Automatically analyzes your current git changes and generates a commit message:
```bash
/commit
```

**What it does:**
1. Runs `git diff --cached` to analyze staged changes
2. Determines appropriate commit type (feat, fix, docs, etc.)
3. Extracts scope from file paths
4. Generates descriptive commit message
5. Suggests the complete commit message following Conventional Commits format

### `/commit-validate <message>`
Validates a commit message against standards:
```bash
/commit-validate "feat(auth): add user login system"
```

**What it does:**
1. Checks commit message format
2. Validates commit type
3. Verifies subject line length (≤50 chars)
4. Checks for proper imperative mood
5. Provides suggestions for improvements

## Core Capabilities

### 1. Automatic Commit Message Generation
Analyzes git changes and generates appropriate commit messages:

```bash
# Analyze current staged changes
git diff --cached | python scripts/analyze_diff.py

# Analyze specific file changes
python scripts/analyze_diff.py path/to/diff.txt -v
```

**Example output:**
```
📝 Suggested commit message:
   feat(auth): add JWT authentication

📊 Analysis:
Added: src/auth/jwt.ts, src/middleware/auth.ts
Modified: src/app.ts
Lines: +145, -12

Commit type: feat
Scope: auth
```

### 2. Commit Message Validation
Validates commit messages against Conventional Commits and best practices:

```bash
python scripts/validate_commit.py "feat(auth): add user login system"
# ✅ Commit message is valid!

python scripts/validate_commit.py "fixed some bugs" -v
# ❌ Commit message has errors:
#   - Subject line must follow format: type(scope): description
```

### 3. Smart Type Detection
Automatically determines commit type based on changes:

- **feat**: New files added (non-test, non-docs)
- **fix**: Existing files modified
- **docs**: Only documentation files (.md, README)
- **test**: Only test files (test/, spec/, __test__)
- **refactor**: Large changes (>100 lines) or file deletions
- **chore**: Config files only (.json, .yml, .config)
- **style**: Formatting/whitespace changes

### 4. Intelligent Scope Detection
Extracts meaningful scopes from file paths:
- First meaningful directory (ignoring src/, ., ..)
- Most common scope when multiple files changed
- Package/module names from monorepo structures

## Commit Format Standards

### Basic Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Valid Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Formatting (no code logic change)
- **refactor**: Code restructuring (no feature/bug change)
- **perf**: Performance improvement
- **test**: Adding/updating tests
- **chore**: Maintenance (build, dependencies)
- **build**: Build system changes
- **ci**: CI configuration changes

### Subject Line Rules
- Maximum 50 characters
- Imperative mood ("add" not "added")
- Lowercase first letter
- No trailing period
- Format: `type(scope): description`

### Body Guidelines (Optional)
- Wrap at 72 characters
- Explain **what** and **why**, not how
- Use imperative mood
- Separate from subject with blank line

### Footer (Optional)
- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: ...`

## Usage Examples

### Basic Usage
**User request:** "Generate a commit message for my changes"

**Response:**
```bash
# First, let me analyze your staged changes
git diff --cached | python scripts/analyze_diff.py

# Based on the analysis:
feat(dashboard): add real-time data updates

Implement WebSocket connection for live dashboard data.
Add automatic refresh every 30 seconds as fallback.

Closes #234
```

### Validation
**User request:** "Check if this commit message is valid: 'Updated some files'"

**Response:**
```bash
python scripts/validate_commit.py "Updated some files"

# ❌ Commit message has errors:
#   - Subject line must follow format: type(scope): description
#   - Invalid commit type 'Updated'. Valid types: feat, fix, docs, style, refactor, perf, test, chore, build, ci

# Suggested improvement:
chore: update configuration files
```

### Custom Analysis
**User request:** "What commit type should I use for adding tests?"

**Response:**
Based on the analysis patterns:
- **test**: When only adding/updating test files
- **feat**: When adding tests for a new feature alongside the feature code
- **fix**: When adding tests to cover a bug fix

Example:
```
test: add unit tests for user authentication
feat(auth): add login system with test coverage
```

## Quality Checklist

Before committing, verify:
- [ ] Subject clearly describes the change
- [ ] Commit type accurately reflects the change nature
- [ ] Scope is meaningful and specific
- [ ] Description uses imperative mood
- [ ] Single logical change per commit
- [ ] Breaking changes are documented in footer
- [ ] Related issues are referenced

## Common Patterns

### Feature Development
```
feat(api): add user registration endpoint
feat(ui): add signup form component
test(auth): add registration flow tests
docs(api): update authentication guide
```

### Bug Fixes
```
fix(checkout): resolve payment validation error
test(checkout): add payment edge case tests
docs(troubleshooting): add payment error guide
```

### Refactoring
```
refactor(database): extract query helpers
test(database): update query helper tests
perf(database): optimize user lookup queries
```

### Breaking Changes
```
feat(api): migrate to v2 authentication

BREAKING CHANGE: API now requires Bearer token authentication.
Old API key authentication is no longer supported.
See migration guide: docs/migration-v2.md

Closes #345
```

