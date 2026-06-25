# Approach Prompt

Given this task and entities:

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

Entities: `<paste entity summary>`

Propose a high-level implementation approach.

Include:

- Files or areas likely affected
- Test-first strategy
- Existing patterns to follow from `InspectionTestStepModels.swift`, `InspectionDraftModels.swift`, and existing tests
- Swift 6 / Concurrency considerations
- Accessibility and localization considerations
- Manual validation path

Do not write code yet. Explain the solution shape and collaboration points.

Constraints:

- Add model behavior only for TASK#5.3.
- Compose test case state from existing step draft state without taking over validation service rules for TASK#5.4.
- Preserve ordered steps, stable IDs, rule references, and draft values.
- Do not refactor TASK#5.6 UI in this slice.
- Expected PR title: `TASK#5.3: Implement test case models`
- Build policy: do not build automatically; user owns build unless explicitly requested.
