# Norms Prompt

Apply the project norms to this task:

Task: `6.1 Add failing unit tests for InspectionStage, InspectionSection, bundled JSON decoding, display ordering, stable IDs, unsupported step type errors, and malformed JSON failures.`

Check the proposed work against these norms:

- TDD for models, services, coordinators, and view helpers
- Swift 6 and Concurrency-first boundaries
- Swift Testing unit tests for domain behavior
- Bundled JSON resources are the offline source of truth
- Stable IDs must support navigation, drafts, validation, accessibility identifiers, and later UI tests
- Feature scenarios are the acceptance backbone
- Views keep small local UI state only; this task should not edit SwiftUI views
- Structured `Strings` enums belong to later UI-facing tasks, not this test-only task
- Stable accessibility identifiers are required later, but TASK#6.1 should preserve the data needed to construct them
- One feature branch / PR per major slice unless review context gets too broad
- Branch name is `codex/task-6.1-stage-content-tests`
- PR titles must start with `TASK#{TASK NUMBER}:`, using `TASK#6.1: Add stage content tests`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state unless this repo's TDD flow expects failing-test commits and the tension is reported clearly
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes belong in later TASK#6.7, not in this test-only task

Return any adjustments needed before implementation.

Expected PR title:

`TASK#6.1: Add stage content tests`

Recommended commit title candidates:

- `Add TASK#6.1 prompt run`
- `Add stage content tests`
- `Add failing stage tests`
