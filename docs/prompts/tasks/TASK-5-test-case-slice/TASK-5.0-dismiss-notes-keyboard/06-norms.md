# Norms Prompt

Apply the project norms to this task:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Check the proposed work against these norms:

- Keep the fix isolated and reviewable as a separate PR
- SwiftUI views should keep only small local UI state
- Structured `Strings` enums should hold new user-visible strings
- Stable accessibility identifiers must not be replaced with localized labels
- PR titles must start with `TASK#{TASK NUMBER}:`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes belong in the PR description

Return any adjustments needed before implementation.

Expected PR title:

`TASK#5.0: Fix notes keyboard dismissal`

Recommended commit title candidate:

- `Fix notes keyboard dismissal`
