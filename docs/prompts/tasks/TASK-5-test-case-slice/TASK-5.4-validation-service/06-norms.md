# Norms Prompt

Apply the project norms to this task:

Task: `5.4 Implement InspectionValidationService rules for missing outcome, failed note requirement, invalid measurement, and missing evidence.`

Check the proposed work against these norms:

- TDD for services and model-adjacent helpers
- Swift 6 and Concurrency-first boundaries
- Sendable-safe value types for service inputs and outputs
- Deterministic validation issue codes and messages suitable for UI summaries and tests
- Deterministic validation issue codes, localization keys, and interpolation arguments suitable for UI summaries and tests
- Stable accessibility identifiers are future UI work; validation display text should be localization-ready in this service slice when existing code already exposes summary text
- Feature scenarios `US-002`, `US-003`, and `US-004` as acceptance backbone
- One feature branch / PR per major slice unless review context gets too broad
- PR titles must start with `TASK#{TASK NUMBER}:`
- Each task must be split into reviewable commits with commit titles of 52 characters or fewer
- Commits must not intentionally leave the project in a non-compiling state
- Do not build the code automatically; capture build and validation as user-run unless the user explicitly asks the agent to build
- Manual validation notes in PR description

Return any adjustments needed before implementation.

Expected branch:

`codex/task-5.4-validation-service`

Expected PR title:

`TASK#5.4: Implement validation service`

Recommended commit title candidates:

- `Add validation service tests`
- `Implement inspection validation rules`
- `Mark TASK#5.4 complete`
