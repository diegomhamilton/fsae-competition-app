# Entities Prompt

Given this task:

Task: `5.7 Manually validate the Test Case view with mock JSONs and record positive, negative, and edge cases from the .feature file.`

Identify the domain, validation, and documentation entities involved.

For each entity, describe:

- Responsibility
- Key fields or state
- Relationships to other entities
- Whether it is immutable content, mutable draft state, UI state, service state, test fixture data, or validation evidence

Include at least:

- Judge
- `InspectionTestCase`
- Ordered `InspectionTestStep` list
- `TestCaseDraft`
- `TestStepDraft`
- `InspectionOutcome`
- `MeasurementValue`
- Evidence attachment metadata
- Validation summary
- Validation blocker
- Rule reference
- Energized safety badge
- Mock test case JSON fixture
- PR validation note

Use the project's inspection-event language: stages, sections, test cases, test steps, outcomes, measurements, evidence, validation, submissions, rechecks, sessions, teams, and judges.

Scope note:

This task records manual validation evidence or prepares a checklist. It must not introduce new production behavior unless the missing validation documentation surface already exists and only needs a narrowly scoped documentation update.

