# Approach Prompt

Given this task and entities:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first strategy using Swift Testing
- Existing model, draft, fixture, and test patterns to follow
- Smallest coordinator or coordinator contract needed if production coordinator types do not exist yet
- How to represent opening a test case from a stage/list context
- How to represent opening a test step from a parent test case
- How draft edits are applied to the active step draft
- How edited step draft state returns to and updates the parent test case draft
- Swift 6 and Concurrency considerations
- Accessibility and localization considerations, if any behavior touches identifiers or strings
- Manual validation path

Do not write code yet. Explain the solution shape and collaboration points.

Constraints:

- Keep this scoped to the Test Case Slice.
- Do not implement full app/session coordinators planned for task `7.x`.
- Do not add UI tests.
- Do not refactor unrelated views or services.
- Do not build automatically; the user owns build and validation unless explicitly requested.
