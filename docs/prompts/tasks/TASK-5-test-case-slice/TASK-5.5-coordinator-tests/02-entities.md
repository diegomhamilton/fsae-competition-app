# Entities Prompt

Given this task:

Task: `5.5 Add coordinator tests for opening a test case, opening a test step, applying edits, and returning edits to the parent test case.`

Identify the domain, draft, and coordinator entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, coordinator state, service state, or test fixture data

Include at least:

- Judge
- Stage/list context
- `InspectionTestCase`
- `InspectionTestStep`
- Test case route or selection
- Test step route or selection
- `TestCaseDraft`
- `TestStepDraft`
- Outcome edit
- Note edit
- Measurement edit, if supported by existing draft models
- Evidence attachment metadata, if supported by existing draft models
- Parent test case draft aggregation
- Minimal test case coordinator or coordinator contract

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Keep the entity list scoped to Test Case navigation and draft handoff.
