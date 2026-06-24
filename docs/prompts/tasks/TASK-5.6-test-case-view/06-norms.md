# Norms Prompt

Apply the project norms to this task:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

Check the proposed work against these norms:

- TDD for models, services, coordinators, and view helpers
- Swift 6 and Concurrency-first boundaries
- SwiftUI views with small local UI state only
- Structured `Strings` enums for localizable text
- Stable accessibility identifiers separate from localized labels
- Feature scenarios as acceptance backbone
- Reuse visual language from `FullStageView` and `StageChecklistView`
- Keep keyboard dismissal behavior aligned with TASK#5.0
- One feature branch / PR per major slice unless review context gets too broad
- PR titles must start with `TASK#{TASK NUMBER}:`; use `TASK#5.6: Add test case view`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes in PR description

Return any adjustments needed before implementation.

Expected PR title:

`TASK#5.6: Add test case view`

Recommended commit title candidates:

- `Add TASK#5.6 prompt run`
- `Add test case view`
- `Add test case view tests`
