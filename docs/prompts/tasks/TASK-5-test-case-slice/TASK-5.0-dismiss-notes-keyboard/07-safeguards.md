# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond keyboard dismissal
- Accidental changes to inspection domain models
- Missing Notes input locations
- Duplicate keyboard toolbar buttons from attaching `.toolbar(placement: .keyboard)` inside repeated card/list views
- Missing keyboard toolbar button from attaching `.toolbar(placement: .keyboard)` too high in the view hierarchy
- Missing keyboard toolbar button from a conditionally emitted focused card-level SwiftUI toolbar
- Over-reliance on SwiftUI keyboard toolbar placement after manual validation shows no visible `Done` button
- UIKit usage for this task
- A SwiftUI safe-area dismissal bar that appears when no Notes field is focused
- Dismissal action that loses note text
- Dismissal action that changes broader Done/save navigation behavior
- Accessibility regression
- New visible strings outside structured string constants
- Commit boundaries that would knowingly break compilation
- PR title not starting with `TASK#5.0:`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.
