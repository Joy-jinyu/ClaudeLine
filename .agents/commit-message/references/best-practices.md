# Commit Message Best Practices

## Writing Guidelines

### Subject Line
- **Length**: Maximum 50 characters
- **Format**: `type(scope): description`
- **Tone**: Imperative mood ("add" not "added")
- **Case**: Lowercase first letter
- **Punctuation**: No trailing period

### Body (Optional)
- **When to include**: For complex changes that need explanation
- **Format**: Wrap at 72 characters
- **Content**: Explain what, why, and any side effects
- **Tone**: Imperative mood

### Footer (Optional)
- **References**: Link to issues/tickets
- **Breaking changes**: Use "BREAKING CHANGE:" prefix

## Quality Checklist

Before committing, ask yourself:
- [ ] Does the subject clearly describe the change?
- [ ] Is the type accurate?
- [ ] Would a new team member understand this change?
- [ ] Is this a single logical change?
- [ ] Are there any breaking changes noted?

## Common Mistakes

### ❌ Too vague
```
fix: bug
update: code
chore: stuff
```

### ❌ Too long
```
feat: add a really comprehensive user authentication system with JWT tokens and refresh token functionality
```

### ❌ Wrong tense
```
feat: added login page
fix: fixed navigation bug
docs: updated README file
```

### ✅ Good examples
```
feat(auth): add JWT authentication
fix(nav): resolve mobile menu toggle issue
docs(api): update endpoint documentation
```

## Advanced Patterns

### Multi-paragraph body
```
refactor(database): optimize user query performance

Replace N+1 query pattern with single JOIN query.
Add database indexes for frequently accessed columns.
Implement query result caching for user profiles.

Performance improvement: 300ms -> 50ms average response time.
Memory usage reduced by 40% during peak hours.

Closes #234
```

### Breaking changes
```
feat(api): migrate to v2 authentication

BREAKING CHANGE: API now requires Bearer token authentication.
Old API key authentication is no longer supported.
See migration guide: docs/migration-v2.md

Closes #345
```

### Multiple issue references
```
fix(payment): resolve checkout validation errors

Handle edge cases in credit card validation.
Fix currency conversion for international payments.

Fixes #123, #145
Closes #167
```