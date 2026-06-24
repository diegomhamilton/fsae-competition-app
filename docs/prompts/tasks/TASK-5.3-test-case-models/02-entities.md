# Entities Prompt

Given this task:

Task: `5.3 Implement test case models and draft state composition from test step drafts.`

Identify the domain entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Include at least:

- `InspectionTestCase`
- `InspectionTestStep`
- `StepResult` or `TestStepDraft`
- Test case draft/composed state
- Test case progress
- Rule references
- Stable accessibility identifiers or string keys, if model helpers need them

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Constraints:

- Preserve `Sendable`, `Codable`, and `Hashable` conventions where appropriate.
- Keep service validation rules scoped to TASK#5.4.
- Expected PR title: `TASK#5.3: Implement test case models`
- Build policy: do not build automatically; user owns build unless explicitly requested.
