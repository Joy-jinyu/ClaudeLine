Please use the commit-message skill to analyze my current git changes and generate a high-quality commit message following Conventional Commits specification.

First, run `git diff --cached` to see what changes are staged for commit. Then analyze the changes to determine:

1. Appropriate commit type (feat, fix, docs, test, refactor, chore, etc.)
2. Scope based on the affected files/modules
3. Clear, descriptive subject line in imperative mood
4. Optional body explaining what and why (if needed)
5. Footer with issue references or breaking change notes (if applicable)

Format the final commit message according to Conventional Commits:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Make sure the subject line is ≤50 characters and uses imperative mood (e.g., "add", "fix", "update" not "added", "fixed", "updated").