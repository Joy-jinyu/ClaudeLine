# Udacity Git Style Guide Highlights

## Commit Message Structure

```
type: subject

body

footer
```

## Commit Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Changes to documentation
- **style**: Formatting, missing semicolons, etc; no code change
- **refactor**: Refactoring production code
- **test**: Adding tests, refactoring test; no production code change
- **chore**: Updating build tasks, package manager configs, etc; no production code change

## Subject Line Rules

1. **Limit to 50 characters** - Forces concise, clear description
2. **Use imperative mood** - "Add feature" not "Added feature" or "Adds feature"
3. **Don't capitalize first letter** - Following Conventional Commits
4. **No period at the end** - Trailing punctuation is unnecessary

## Body Guidelines

- **Wrap at 72 characters** for readability in all git tools
- **Use imperative mood** - Consistent with subject line
- **Explain WHAT and WHY** - Not HOW (code shows how)
- **Separate from subject with blank line**

## Footer

- Reference issues: "Fixes #123", "Closes #456", "Resolves #789"
- Note breaking changes: "BREAKING CHANGE: ..."

## Examples

**Good commit messages:**
```
feat: add user authentication system

Implement JWT-based authentication with refresh tokens.
Add middleware to protect routes and handle token validation.

Closes #45
```

```
fix: resolve memory leak in image processing

Remove circular references in ImageProcessor class.
Properly dispose of canvas contexts after use.

Fixes #128
```

**Bad commit messages:**
```
Updated stuff
Fix bug
Added new feature for users to login and authenticate themselves properly
```

## Best Practices

1. **Write commits for future you** - Clear, descriptive messages
2. **One logical change per commit** - Atomic commits are easier to review
3. **Test before committing** - Ensure code works
4. **Review your diff** - Check what you're actually committing