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
- Ownership of keyboard dismissal controls in repeated views
- Any small reusable SwiftUI dismissal bar needed to avoid unreliable keyboard toolbar placement
- Suggested commit boundaries
- Risks from over-generalizing the fix
- How this task stays separate from task `5.1`

Prefer the smallest SwiftUI change that solves the bug without changing inspection domain models.

For repeated stage cards, keep one parent-level `@FocusState` focused step ID. Child cards may bind their Notes field to that shared state. Manual validation has shown three failed SwiftUI toolbar placements: unguarded row/card toolbars create duplicate `Done` buttons; a parent-level toolbar can disappear; a conditionally emitted focused row/card toolbar can also fail to appear. Do not use UIKit for this task. If `.toolbar(placement: .keyboard)` is unreliable, use a SwiftUI `safeAreaInset(edge: .bottom)` dismissal bar owned by the screen and shown only while a Notes field is focused.

Commit rule:

Each commit title must be 52 characters or fewer and must not intentionally leave the project in a non-compiling state at commit boundaries.
