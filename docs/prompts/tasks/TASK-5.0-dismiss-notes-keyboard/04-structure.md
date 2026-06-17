# Structure Prompt

Given this task and approach:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Approach: `<paste approach>`

Define the implementation structure.

Include:

- Views likely involved
- UI state needed for keyboard focus
- Any local string constants required for visible controls
- Dependencies between note text state, focus state, and keyboard dismissal
- Suggested commit boundaries
- Risks from over-generalizing the fix
- How this task stays separate from task `5.1`

Prefer the smallest SwiftUI change that solves the bug without changing inspection domain models.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state at commit boundaries.
