# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond keyboard dismissal
- Accidental changes to inspection domain models
- Missing Notes input locations
- Dismissal action that loses note text
- Dismissal action that changes broader Done/save navigation behavior
- Accessibility regression
- New visible strings outside structured string constants
- Commit boundaries that would knowingly break compilation
- PR title not starting with `TASK#5.0:`
- Automatic build/test execution despite the user-run build policy
- Manual validation omissions

Return blockers first, then recommendations, then a final go/no-go.
