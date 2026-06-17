# Norms Prompt

Apply the project norms to this task:

Task: `5.1 Add failing unit tests for InspectionTestCase, ordered steps, rule references, draft aggregation, blocker counts, and test case progress.`

Check the proposed work against these norms:

- TDD for models, services, coordinators, and view helpers
- Swift 6 and Concurrency-first boundaries
- Swift Testing unit tests for domain behavior
- SwiftUI views with small local UI state only
- Structured `Strings` enums for localizable text
- Stable accessibility identifiers separate from localized labels
- Feature scenarios as acceptance backbone
- One feature branch / PR per major slice unless review context gets too broad
- Branch name is `codex/task-5.1-test-case-model-tests`
- PR titles must start with `TASK#{TASK NUMBER}:`, using `TASK#5.1: Add test case model tests`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state unless this repo's TDD flow expects failing-test commits and the tension is reported clearly
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes belong in the PR description

Return any adjustments needed before implementation.

Expected PR title:

`TASK#5.1: Add test case model tests`

Recommended commit title candidates:

- `Add TASK#5.1 prompt run`
- `Add test case model tests`
- `Add failing test case tests`
