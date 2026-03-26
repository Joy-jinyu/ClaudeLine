Please use the commit-message skill to validate a commit message against Conventional Commits specification and industry best practices.

**Usage**: `/commit-validate "<your commit message>"`

The validation will check:

1. **Format compliance**: Ensures message follows `type(scope): description` pattern
2. **Valid commit type**: Verifies type is one of: feat, fix, docs, style, refactor, perf, test, chore, build, ci
3. **Subject line length**: Must be ≤50 characters
4. **Imperative mood**: Checks description uses imperative form (e.g., "add" not "added")
5. **Capitalization**: Ensures proper lowercase first letter
6. **No trailing period**: Subject should not end with a period

If the message has issues, I'll provide specific feedback and suggest improvements.

**Examples:**
- ✅ `feat(auth): add JWT authentication`
- ✅ `fix(api): resolve null pointer error`
- ❌ `Updated some files` → Missing type and scope
- ❌ `feat(auth): Added new login feature.` → Wrong mood, trailing period

Please provide the commit message you'd like me to validate in quotes.