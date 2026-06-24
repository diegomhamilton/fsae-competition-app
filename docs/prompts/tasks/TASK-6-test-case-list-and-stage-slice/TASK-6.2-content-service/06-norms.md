# Norms Prompt

Apply the project norms to this task:

Task: `6.2 Implement InspectionContentService as an async service that loads the six bundled inspection JSON resources.`

Check the proposed work against these norms:

- TDD for models, services, coordinators, and view helpers
- Swift 6 and Concurrency-first boundaries
- Async services for content loading
- Sendable-safe immutable inspection content models
- Bundled JSON resources are the offline source of truth
- Typed errors must prevent partial corrupted official content from being displayed
- Feature scenarios are the acceptance backbone
- SwiftUI views keep small local UI state only; this task should not edit stage/list views
- Stable data IDs must support later navigation and accessibility identifiers
- Branch name is `codex/task-6.2-content-service`
- PR titles must start with `TASK#{TASK NUMBER}:`, using `TASK#6.2: Add content service`
- Commit titles must be 52 characters or fewer
- Do not build automatically; capture build and validation as user-run unless explicitly asked

Return any adjustments needed before implementation.

Expected PR title:

`TASK#6.2: Add content service`

Recommended commit title candidates:

- `Add TASK#6.2 prompt run`
- `Add inspection content service`
- `Load bundled inspection JSON`
