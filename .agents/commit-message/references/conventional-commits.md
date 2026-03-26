# Conventional Commits Specification

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation

## Scope

The scope provides additional contextual information:
- Optional, but recommended
- Noun describing a section of the codebase
- Examples: `init`, `runner`, `watcher`, `config`, `web-server`, `proxy`

## Description

- Use the imperative, present tense: "change" not "changed" nor "changes"
- Don't capitalize the first letter
- No dot (.) at the end
- Maximum 50 characters

## Body

- Use the imperative, present tense
- Explain what and why vs. how
- Wrap at 72 characters
- Separate from subject by blank line

## Footer

- Reference issues and pull requests
- Note breaking changes with "BREAKING CHANGE:"

## Examples

```
feat(auth): add OAuth2 authentication

Implement OAuth2 flow for user authentication
- Add OAuth2 provider configuration
- Create auth middleware
- Add user session management

Closes #123
```

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Fixes #456
```

```
docs(readme): update installation instructions

BREAKING CHANGE: drop support for Node 8
```