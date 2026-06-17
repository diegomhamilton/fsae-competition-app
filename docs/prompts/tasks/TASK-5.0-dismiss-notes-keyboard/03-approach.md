# Approach Prompt

Given this task and entities:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Whether the fix belongs in a shared helper or local view state
- Whether a Notes input appears once or inside a repeated collection
- Where the keyboard dismissal affordance should be owned so repeated cards do not create duplicate or missing buttons
- Existing SwiftUI patterns to follow
- When to use a SwiftUI `safeAreaInset` dismissal bar instead of SwiftUI `.toolbar(placement: .keyboard)`
- Accessibility and localization considerations
- Manual validation path

Do not write code yet. Explain the solution shape and collaboration points.

Constraints:

- Keep the fix isolated to notes keyboard dismissal.
- Do not refactor inspection models, validation, or test case behavior.
- Incorporate current manual validation evidence: putting `.toolbar(placement: .keyboard)` on each repeated stage card produced duplicate `Done` buttons; moving it to the parent made `Done` disappear; conditionally emitting a row/card-level SwiftUI toolbar for only the focused note field still resulted in no visible `Done` button.
- In list/card contexts, keep one shared focused step ID so only one Notes input is active at a time.
- Do not use UIKit for this task.
- If SwiftUI keyboard toolbar placement is unreliable in the active hierarchy, prefer a SwiftUI `safeAreaInset(edge: .bottom)` dismissal bar that appears only while a Notes input is focused and clears only the note focus state.
- Do not build automatically.
