# Safeguards Prompt

Act as the SPDD safeguard reviewer for this task:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

Plan: `<paste operations>`

Review for:

- Scope creep beyond the Test Case Slice
- Broad stage-flow rewrites
- Accidental bundled stage loading implementation from task 6.x
- Missing OpenSpec, feature, agent, view, keyboard, model, or service context
- Missing failing or focused helper/model tests where practical
- Missing manual validation path when tests are impractical
- Ordered step rendering that depends on unstable fixture order
- Validation summaries that are disconnected from model or service state
- Duplicate keyboard dismissal affordances in repeated note inputs
- Loss of TASK#5.0 keyboard dismissal behavior
- Accessibility gaps for actionable controls or statuses
- User-visible strings outside structured `Strings` enums
- Unstable accessibility identifiers based on localized labels
- Unsafe concurrency or shared mutable state
- JSON fixture/schema assumptions
- UI test additions in this PR
- Automatic build/test execution despite the user-run build policy
- OpenSpec task checkbox marked complete before the view work is actually complete
- PR title not starting with `TASK#5.6:`
- Commit titles over 52 characters

Return blockers first, then recommendations, then a final go/no-go.
