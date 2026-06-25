# Entities Prompt

Given this task:

Task: `5.6 Refactor the existing stage step card pattern into a test case view that renders ordered steps and validation summaries.`

Identify the domain and UI entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, or test fixture data

Include at least:

- Judge
- Stage
- Test case
- Ordered test step
- Step outcome
- Step note
- Validation summary
- Validation issue
- Keyboard dismissal action
- Mock JSON or fixture-backed model state
- Stable accessibility identifier
- Structured `Strings` enum

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Constraints:

- Keep the entities scoped to the Test Case Slice.
- Do not introduce bundled stage loading entities for this task.
- Treat UI tests as out of scope.
- Do not build automatically; capture validation as user-run unless explicitly requested.
